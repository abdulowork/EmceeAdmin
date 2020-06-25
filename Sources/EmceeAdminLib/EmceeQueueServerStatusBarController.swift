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
    private let remotePortDeterminerProvider: RemotePortDeterminerProvider
    
    public init(
        hostsProvider: @escaping () -> [String],
        remotePortDeterminerProvider: RemotePortDeterminerProvider
    ) {
        self.hostsProvider = hostsProvider
        self.remotePortDeterminerProvider = remotePortDeterminerProvider
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

        items += runningQueues.currentValue().sorted().map {
            NSMenuItem.with(title: "\($0.host):\($0.port) \($0.version)")
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
                            RunningQueue(host: host, port: $0.key, version: $0.value)
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
                for port in ports {
                    let runningQueue = RunningQueue(host: host, port: port.key, version: port.value)
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
}
