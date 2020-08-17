import Foundation
import SocketModels

public protocol Service {
    var id: String { get }
    var name: String { get }
    var socketAddress: SocketAddress { get }
    var version: String { get }
    
    var serviceWorkers: [ServiceWorker] { get }
    func updateWorkers()
}
