import AppKit
import AtomicModels
import EasyAppKit
import Models
import RemotePortDeterminer
import RequestSender

public final class EmceeQueueServerStatusBarController {
    lazy var statusBarController = StatusBarController(
        title: "Emcee Admin"
    )
    private let hostsProvider: () -> [String]
    private let queueMetricsProvider: QueueMetricsProvider
    private let remotePortDeterminerProvider: RemotePortDeterminerProvider
    private let windowControllerHolder: WindowControllerHolder
    private let workerStatusSetter: WorkerStatusSetter
    
    public init(
        hostsProvider: @escaping () -> [String],
        queueMetricsProvider: QueueMetricsProvider,
        remotePortDeterminerProvider: RemotePortDeterminerProvider,
        windowControllerHolder: WindowControllerHolder,
        workerStatusSetter: WorkerStatusSetter
    ) {
        self.hostsProvider = hostsProvider
        self.queueMetricsProvider = queueMetricsProvider
        self.remotePortDeterminerProvider = remotePortDeterminerProvider
        self.windowControllerHolder = windowControllerHolder
        self.workerStatusSetter = workerStatusSetter
    }
    
    public func startUpdating() {
        statusBarController.showStatusBarItem()
        statusBarController.menuItems = { [weak self] in self?.menuItems() ?? [] }
        statusBarController.willOpenMenu = { [weak self] in
            self?.searchForRunningQueues()
        }
    }
    
    private func menuItems() -> [NSMenuItem] {
        var items = [NSMenuItem]()
        items += [
            NSMenuItem.with(
                title: isSearching ? "Searching for queues..." : "\(runningQueues.currentValue().count) queues found"
            ),
            NSMenuItem.separator(),
        ]

        items += runningQueues.currentValue().sorted().map { runningQueue in
            NSMenuItem.with(
                title: "",
                view: EAKMenuView(
                    actionable: true,
                    contentView: QueueBriedInfoMenuView(
                        queueServerAddress: runningQueue.socketAddress,
                        version: runningQueue.version
                    ),
                    highlightable: true
                )
            ) { [weak self] in
                self?.showQueueInfo(runningQueue: runningQueue)
            }
        }

        return items + [
            NSMenuItem.separator(),
            NSMenuItem.with(title: "Quit", key: "q", enabled: true, action: { NSApp.terminate(nil) }),
        ]
    }
    
    private var isSearching = false
    private let runningQueues = AtomicValue([RunningQueue]())
    
    private func searchForRunningQueues() {
        isSearching = true
        let foundQueues = AtomicValue([RunningQueue]())

        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 5
        for host in hostsProvider() {
            queue.addOperation { [weak self] in
                guard let self = self else { return }
                
                let remotePortDeterminer = self.remotePortDeterminerProvider.remotePortDeterminer(
                    host: host
                )
                
                let result = remotePortDeterminer.queryPortAndQueueServerVersion(timeout: 10)
                self.didFindQueues(on: host, ports: result)
                
                foundQueues.withExclusiveAccess {
                    $0.append(
                        contentsOf: result.map {
                            RunningQueue(socketAddress: SocketAddress(host: host, port: $0.key), version: $0.value)
                        }
                    )
                }
            }
        }
        
        queue.addBarrierBlock {
            self.isSearching = false
            self.runningQueues.set(foundQueues.currentValue())
            self.updatedRunningQueues()
        }
    }
    
    private func didFindQueues(on host: String, ports: [Models.Port: Version]) {
        if !ports.isEmpty {
            runningQueues.withExclusiveAccess {
                for (port, version) in ports {
                    let runningQueue = RunningQueue(
                        socketAddress: SocketAddress(
                            host: host,
                            port: port
                        ),
                        version: version
                    )
                    if !$0.contains(runningQueue) {
                        $0.append(runningQueue)
                    }
                }
            }
            updatedRunningQueues()
        }
    }
    
    private func updatedRunningQueues() {
        DispatchQueue.main.async {
            self.statusBarController.updateMenuItems()
        }
    }
    
    private func showQueueInfo(runningQueue: RunningQueue) {
        let alreadyExistingWindowControllers: [QueueInfoWindowController] = windowControllerHolder.typedWindowControllers().filter {
            $0.runningQueue == runningQueue
        }
        if let alreadyExistingWindowController = alreadyExistingWindowControllers.first {
            return alreadyExistingWindowController.showWindow(nil)
        }
        
        let windowController = QueueInfoWindowController(
            runningQueue: runningQueue,
            queueMetricsProvider: queueMetricsProvider,
            workerStatusSetter: workerStatusSetter
        )
        let key = windowControllerHolder.hold(windowController: windowController)
        windowController.showWindow(nil)
        windowController.window?.center()
        windowController.onWindowClose = { [windowControllerHolder] in
            windowControllerHolder.release(windowControllerUnderKey: key)
        }
    }
}
