import Foundation

public protocol ServiceWorker {
    var id: String { get }
    var name: String { get }
    var states: [ServiceWorkerState] { get }
    var actions: [ServiceWorkerAction] { get }
}
