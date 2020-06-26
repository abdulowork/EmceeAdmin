import Foundation
import Models

public protocol QueueInfoProvider {
    func momentumQueueMetrics(queueSocketAddress: SocketAddress) -> MomentumQueueMetrics
}
