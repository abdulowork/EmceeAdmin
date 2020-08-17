import Foundation

public protocol ServiceWorkerState {
    var id: String { get }
    var name: String { get }
    var status: String { get }
    var isPositive: Bool { get }
}
