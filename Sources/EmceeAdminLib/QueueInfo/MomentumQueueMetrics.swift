import Foundation
import Models
import WorkerAlivenessModels

public struct StaticQueueMetrics {
    public let socketAddress: SocketAddress
    public let version: Version
    public let startedAt: Date
    
    public init(socketAddress: SocketAddress, version: Version, startedAt: Date) {
        self.socketAddress = socketAddress
        self.version = version
        self.startedAt = startedAt
    }
}

public struct MomentumQueueMetrics {
    public let enqueuedTests: Int
    public let currentlyProcessingTests: Int
    
    public let enqueuedBuckets: Int
    
    public let workerAlivenesses: [WorkerId: WorkerAliveness]
    
    public var currentlyProcessingBuckets: Int {
        workerAlivenesses.reduce(into: 0, { $0 += $1.value.bucketIdsBeingProcessed.count })
    }
    
    public init(
        enqueuedTests: Int,
        currentlyProcessingTests: Int,
        enqueuedBuckets: Int,
        workerAlivenesses: [WorkerId: WorkerAliveness]
    ) {
        self.enqueuedTests = enqueuedTests
        self.currentlyProcessingTests = currentlyProcessingTests
        self.enqueuedBuckets = enqueuedBuckets
        self.workerAlivenesses = workerAlivenesses
    }
}
