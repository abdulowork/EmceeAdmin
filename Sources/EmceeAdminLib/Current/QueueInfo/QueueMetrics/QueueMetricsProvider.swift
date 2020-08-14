import Dispatch
import Foundation
import SocketModels

public protocol QueueMetricsProvider {
    func staticQueueMetrics(
        queueSocketAddress: SocketAddress,
        callbackQueue: DispatchQueue,
        completion: @escaping (Result<StaticQueueMetrics, Error>) -> ()
    )
    
    func momentumQueueMetrics(
        queueSocketAddress: SocketAddress,
        callbackQueue: DispatchQueue,
        completion: @escaping (Result<MomentumQueueMetrics, Error>) -> ()
    )
}
