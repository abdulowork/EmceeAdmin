import Foundation
import Models
import WorkerAlivenessModels

public struct MomentumQueueMetrics {
    public let workerAlivenesses: [WorkerId: WorkerAliveness]
    
    public var currentlyProcessingBuckets: Int {
        workerAlivenesses.reduce(into: 0, { $0 += $1.value.bucketIdsBeingProcessed.count })
    }
    
    public init(
        workerAlivenesses: [WorkerId: WorkerAliveness]
    ) {
        self.workerAlivenesses = workerAlivenesses
    }
}
