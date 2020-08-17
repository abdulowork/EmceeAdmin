import Foundation

public protocol Service {
    var id: String { get }
    var name: String { get }
    
    var serviceWorkers: [ServiceWorker] { get }
    func updateWorkers()
}
