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
    private let hosts: [String]
    
    public init(hosts: [String]) {
        self.hosts = hosts
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
            NSMenuItem.with(title: "Quit", key: "q", enabled: true, action: #selector(NSApplication.terminate(_:))),
        ]
    }
    
    private struct RunningQueue: Comparable {
        static func < (lhs: EmceeQueueServerStatusBarController.RunningQueue, rhs: EmceeQueueServerStatusBarController.RunningQueue) -> Bool {
            if lhs.host == rhs.host {
                return lhs.port < rhs.port
            }
            return lhs.host < rhs.host
        }
        
        let host: String
        let port: Int
        let version: Version
    }
    
    private var isSearching = false
    private let runningQueues = AtomicValue([RunningQueue]())
    
    private func searchForRunningQueues() {
        isSearching = true
        let foundQueues = AtomicValue([RunningQueue]())

        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 5
        for host in hosts {
            queue.addOperation { [weak self] in
                let scanner = RemoteQueuePortScanner(
                    host: host,
                    portRange: 41000...41005,
                    requestSenderProvider: DefaultRequestSenderProvider()
                )
                
                let result = scanner.queryPortAndQueueServerVersion(timeout: 10)
                self?.didFindQueues(on: host, ports: result)
                
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
    
    private func didFindQueues(on host: String, ports: [Int: Version]) {
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
