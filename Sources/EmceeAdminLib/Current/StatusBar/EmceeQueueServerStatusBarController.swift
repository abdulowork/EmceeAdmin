import AppKit
import AtomicModels
import EasyAppKit
import Services

final class EmceeQueueServerStatusBarController {
    lazy var statusBarController = StatusBarController(
        title: "Emcee Admin"
    )
    private let serviceProvider: ServiceProvider
    private let windowControllerHolder: WindowControllerHolder
    private var isSearching = false
    private let discoveredServices = AtomicValue([Service]())
    
    init(
        serviceProvider: ServiceProvider,
        windowControllerHolder: WindowControllerHolder
    ) {
        self.serviceProvider = serviceProvider
        self.windowControllerHolder = windowControllerHolder
    }
    
    func startUpdating() {
        statusBarController.showStatusBarItem()
        statusBarController.menuItems = { [weak self] in self?.menuItems() ?? [] }
        statusBarController.willOpenMenu = { [weak self] in
            self?.discoverServices()
        }
    }
    
    private func menuItems() -> [NSMenuItem] {
        var items = [NSMenuItem]()
        items += [
            NSMenuItem.with(
                title: isSearching ? "Searching for services..." : "\(discoveredServices.currentValue().count) services found"
            ),
            NSMenuItem.separator(),
        ]

        items += discoveredServices.currentValue().sorted(by: { (left, right) -> Bool in
            if left.name == right.name {
                return left.version < right.version
            }
            return left.name < right.name
        }).map { service in
            NSMenuItem.with(
                title: "",
                view: EAKMenuView(
                    actionable: true,
                    contentView: ServiceBriefInfoMenuView(service: service),
                    highlightable: true
                )
            ) { [weak self] in
//                self?.showQueueInfo(runningQueue: runningQueue)
            }
        }

        return items + [
            NSMenuItem.separator(),
            NSMenuItem.with(title: "Quit", key: "q", enabled: true, action: { NSApp.terminate(nil) }),
        ]
    }
    
    private func discoverServices() {
        isSearching = true
        self.updateUI()
        
        let queue = OperationQueue()
        
        queue.addOperation {
            self.discoveredServices.set(self.serviceProvider.services())
            self.isSearching = false
            
            self.updateUI()
        }
    }
//
//    private func didFindQueues(on host: String, ports: [SocketModels.Port: Version]) {
//        if !ports.isEmpty {
//            runningQueues.withExclusiveAccess {
//                for (port, version) in ports {
//                    let runningQueue = RunningQueue(
//                        socketAddress: SocketAddress(
//                            host: host,
//                            port: port
//                        ),
//                        version: version
//                    )
//                    if !$0.contains(runningQueue) {
//                        $0.append(runningQueue)
//                    }
//                }
//            }
//            updateUI()
//        }
//    }
    
    private func updateUI() {
        DispatchQueue.main.async {
            self.statusBarController.updateMenuItems()
        }
    }
    
//    private func showQueueInfo(runningQueue: RunningQueue) {
//        let alreadyExistingWindowControllers: [QueueInfoWindowController] = windowControllerHolder.typedWindowControllers().filter {
//            $0.runningQueue == runningQueue
//        }
//        if let alreadyExistingWindowController = alreadyExistingWindowControllers.first {
//            return alreadyExistingWindowController.showWindow(nil)
//        }
//
//        let windowController = QueueInfoWindowController(
//            runningQueue: runningQueue,
//            queueMetricsProvider: queueMetricsProvider,
//            workerStatusSetter: workerStatusSetter
//        )
//        let key = windowControllerHolder.hold(windowController: windowController)
//        windowController.showWindow(nil)
//        windowController.window?.center()
//        windowController.onWindowClose = { [windowControllerHolder] in
//            windowControllerHolder.release(windowControllerUnderKey: key)
//        }
//    }
}
