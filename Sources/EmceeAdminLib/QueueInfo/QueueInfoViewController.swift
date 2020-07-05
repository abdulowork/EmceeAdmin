import AppKit
import EasyAppKit
import Models
import SnapKit
import Timer

public final class QueueInfoViewController: NSViewController {
    private lazy var stackView = NSStackView(views: [tableContainer.scrollView])
    
    // Grig View Shit
    private lazy var gridView = NSGridView(views: createGridViewContents())
    private lazy var queueAddressLabel = NSTextField.create(text: runningQueue.socketAddress.asString)
    private lazy var queueVersionLabel = NSTextField.create(text: runningQueue.version.value)
    private lazy var queueStartTimestampLabel = NSTextField.create(text: "-")
    private lazy var queueLogsPathLabel = NSTextField.create(text: "-")
    
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
        
        gridView.columnSpacing = 10
        gridView.rowSpacing = 10
        gridView.rowAlignment = .lastBaseline
        gridView.column(at: 0).leadingPadding = 10
        gridView.column(at: gridView.numberOfColumns - 1).trailingPadding = 10
        gridView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        stackView.orientation = .vertical
        stackView.snp.makeConstraints { maker in
            maker.top.left.bottom.right.equalToSuperview()
        }
        
        queueWorkerDetailsTableController.prepare(tableView: tableContainer.tableView)
        queueWorkerDetailsTableController.onEnableWorkerId = { [weak self] workerId in
            guard let self = self else { return }
            self.workerStatusSetter.enable(queueServerAddress: self.runningQueue.socketAddress, workerId: workerId, callbackQueue: DispatchQueue.main) { error in
                self.fetchValues()
            }
        }
        queueWorkerDetailsTableController.onDisableWorkerId = { [weak self] workerId in
            guard let self = self else { return }
            self.workerStatusSetter.disable(queueServerAddress: self.runningQueue.socketAddress, workerId: workerId, callbackQueue: DispatchQueue.main) { error in
                self.fetchValues()
            }
        }
        
        autoupdateTimer.start { [weak self] timer in
            guard let self = self else { return timer.stop() }
            DispatchQueue.main.async { self.fetchValues() }
        }
    }
    
    private func createGridViewContents() -> [[NSView]] {
        [
            [NSGridCell.emptyContentView],
            [NSTextField.create(text: "Queue Address:", alignment: .right), queueAddressLabel],
            [NSTextField.create(text: "Version:", alignment: .right), queueVersionLabel],
            [NSGridCell.emptyContentView],
        ]
    }
    
    private func fetchValues() {
        queueMetricsProvider.staticQueueMetrics(queueSocketAddress: runningQueue.socketAddress, callbackQueue: DispatchQueue.main) { result in
            if let staticMetrics = try? result.get() {
                self.queueStartTimestampLabel.ext_setText(staticMetrics.startedAt.description)
                self.queueLogsPathLabel.ext_setText(staticMetrics.hostLogsPath)
            }
        }
        
        tableContainer.tableView.isEnabled = false
        queueMetricsProvider.momentumQueueMetrics(queueSocketAddress: runningQueue.socketAddress, callbackQueue: DispatchQueue.main) { result in
            self.tableContainer.tableView.isEnabled = true
            if let momentumMetrics = try? result.get() {
                self.queueWorkerDetailsTableController.workerAlivenesses = momentumMetrics.workerAlivenesses
                self.tableContainer.tableView.reloadData()
            }
        }
    }
    
    @objc private func copyPathToLog() {
        
    }
}
