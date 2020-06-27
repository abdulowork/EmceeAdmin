import Dispatch
import Foundation
import Models
import WorkerAlivenessModels

public final class FakeQueueMetricsProvider: QueueMetricsProvider {
    public func staticQueueMetrics(
        queueSocketAddress: SocketAddress,
        callbackQueue: DispatchQueue,
        completion: @escaping (Result<StaticQueueMetrics, Error>) -> ()
    ) {
        callbackQueue.async {
            completion(
                Result.success(
                    StaticQueueMetrics(
                        socketAddress: queueSocketAddress,
                        version: "version",
                        startedAt: Date(),
                        hostLogsPath: "~/Library/Logs/ru.avito.emcee.logs/EmceeQueueServer_version/pid_123.wefwe.log"
                    )
                )
            )
        }
    }
    
    public func momentumQueueMetrics(
        queueSocketAddress: SocketAddress,
        callbackQueue: DispatchQueue,
        completion: @escaping (Result<MomentumQueueMetrics, Error>) -> ()
    ) {
        let numberOfWorkersToReport = 50
        
        var workerAlivenesses = [WorkerId: WorkerAliveness]()
        for workerIndex in 0 ..< numberOfWorkersToReport {
            workerAlivenesses[WorkerId(value: "emcee-worker-machine\(workerIndex).example.com")] = WorkerAliveness(registered: Bool.random(), bucketIdsBeingProcessed: [], disabled: Bool.random(), silent: Bool.random())
        }
        
        callbackQueue.async {
            completion(
                .success(
                    MomentumQueueMetrics(
                        enqueuedTests: 0,
                        currentlyProcessingTests: 0,
                        enqueuedBuckets: 0,
                        workerAlivenesses: workerAlivenesses
                    )
                )
            )
        }
    }
}
