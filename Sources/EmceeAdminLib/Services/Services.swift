import Foundation

public protocol Service {
    var id: String { get }
    var name: String { get }
    
    var serviceWorkers: [ServiceWorker] { get }
    func updateWorkers()
}

public protocol ServiceWorker {
    var id: String { get }
    var name: String { get }
    var states: [ServiceWorkerState] { get }
    var actions: [ServiceWorkerAction] { get }
}

public protocol ServiceWorkerState {
    var id: String { get }
    var name: String { get }
    var status: String { get }
}

public protocol ServiceWorkerAction {
    var id: String { get }
    var name: String { get }
}
