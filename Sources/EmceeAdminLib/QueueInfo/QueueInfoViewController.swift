import AppKit
import EasyAppKit
import QueueModels
import SnapKit
import Timer

public final class QueueInfoViewController: NSViewController {
    private lazy var stackView = NSStackView(views: [tableContainer.scrollView])
    
    private lazy var tableContainer = NSTableView.createTableContainer()
    
    private let autoupdateTimer = DispatchBasedTimer(repeating: .seconds(20), leeway: .seconds(1))
    
    private let queueMetricsProvider: QueueMetricsProvider
    private let queueWorkerDetailsTableController = QueueWorkerDetailsTableController()
    private let runningQueue: RunningQueue
    private let workerStatusSetter: WorkerStatusSetter
    
    public init(
        queueMetricsProvider: QueueMetricsProvider,
        runningQueue: RunningQueue,
        workerStatusSetter: WorkerStatusSetter
    ) {
        self.queueMetricsProvider = queueMetricsProvider
        self.runningQueue = runningQueue
        self.workerStatusSetter = workerStatusSetter
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 640, height: 480))
        view.addSubview(stackView)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Queue " + runningQueue.socketAddress.asString + " Version: " + runningQueue.version.value
        
        stackView.orientation = .vertical
        stackView.snp.makeConstraints { maker in
            maker.top.left.bottom.right.equalToSuperview()
        }
        
        queueWorkerDetailsTableController.prepare(tableView: tableContainer.tableView)
        queueWorkerDetailsTableController.onEnableWorkerId = { [weak self] workerId in
            guard let self = self else { return }
            self.enable(workerId: workerId, callbackQueue: .main, completion: self.fetchValues)
        }
        queueWorkerDetailsTableController.onDisableWorkerId = { [weak self] workerId in
            guard let self = self else { return }
            self.disable(workerId: workerId, callbackQueue: .main, completion: self.fetchValues)
        }
        queueWorkerDetailsTableController.toggleEnableness = { [weak self] (request: (enable: [WorkerId], disable: [WorkerId])) in
            guard let self = self else { return }
            
            let queue = DispatchQueue.global(qos: .userInitiated)
            let group = DispatchGroup()
            
            for workerId in request.enable {
                group.enter()
                self.enable(workerId: workerId, callbackQueue: queue, completion: group.leave)
            }
            
            for workerId in request.disable {
                group.enter()
                self.disable(workerId: workerId, callbackQueue: queue, completion: group.leave)
            }
            
            group.notify(queue: .main) { self.fetchValues() }
        }
        
        autoupdateTimer.start { [weak self] timer in
            guard let self = self else { return timer.stop() }
            DispatchQueue.main.async { self.fetchValues() }
        }
    }
        
    private func fetchValues() {
        tableContainer.tableView.isEnabled = false
        queueMetricsProvider.momentumQueueMetrics(queueSocketAddress: runningQueue.socketAddress, callbackQueue: .main) { result in
            self.tableContainer.tableView.isEnabled = true
            if let momentumMetrics = try? result.get() {
                self.queueWorkerDetailsTableController.workerAlivenesses = momentumMetrics.workerAlivenesses
                self.tableContainer.tableView.reloadData()
            }
        }
    }

    private func enable(workerId: WorkerId, callbackQueue: DispatchQueue, completion: @escaping () -> ()) {
        workerStatusSetter.enable(queueServerAddress: runningQueue.socketAddress, workerId: workerId, callbackQueue: callbackQueue) { _ in
            completion()
        }
    }
    
    private func disable(workerId: WorkerId, callbackQueue: DispatchQueue, completion: @escaping () -> ()) {
        workerStatusSetter.disable(queueServerAddress: runningQueue.socketAddress, workerId: workerId, callbackQueue: callbackQueue) { _ in
            completion()
        }
    }
}
