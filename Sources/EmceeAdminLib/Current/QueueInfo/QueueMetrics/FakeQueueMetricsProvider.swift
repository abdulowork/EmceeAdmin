import Dispatch
import Foundation
import QueueModels
import SocketModels
import WorkerAlivenessModels

public final class FakeQueueMetricsProvider: QueueMetricsProvider, WorkerStatusSetter {
    private var workerAlivenesses = [WorkerId: WorkerAliveness]()
    private let numberOfWorkersToReport = 50
    
    public init() {
        for workerIndex in 0 ..< numberOfWorkersToReport {
            workerAlivenesses[WorkerId(value: "emcee-worker-machine\(workerIndex).example.com")] = WorkerAliveness(
                registered: Bool.random(),
                bucketIdsBeingProcessed: [],
                disabled: Bool.random(),
                silent: Bool.random()
            )
        }
    }
    
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
        callbackQueue.async {
            completion(
                .success(
                    MomentumQueueMetrics(
                        workerAlivenesses: self.workerAlivenesses
                    )
                )
            )
        }
    }
    
    public func disable(queueServerAddress: SocketAddress, workerId: WorkerId, callbackQueue: DispatchQueue, completion: @escaping (Error?) -> ()) {
        guard let existingAliveness = workerAlivenesses[workerId] else { return }
        workerAlivenesses[workerId] = WorkerAliveness(
            registered: existingAliveness.registered,
            bucketIdsBeingProcessed: existingAliveness.bucketIdsBeingProcessed,
            disabled: true,
            silent: existingAliveness.silent
        )
        
        callbackQueue.async {
            completion(nil)
        }
    }
    
    public func enable(queueServerAddress: SocketAddress, workerId: WorkerId, callbackQueue: DispatchQueue, completion: @escaping (Error?) -> ()) {
        guard let existingAliveness = workerAlivenesses[workerId] else { return }
        workerAlivenesses[workerId] = WorkerAliveness(
            registered: existingAliveness.registered,
            bucketIdsBeingProcessed: existingAliveness.bucketIdsBeingProcessed,
            disabled: false,
            silent: existingAliveness.silent
        )
        
        callbackQueue.async {
            completion(nil)
        }
    }
    
    public func kickstart(queueServerAddress: SocketAddress, workerId: WorkerId, callbackQueue: DispatchQueue, completion: @escaping (Error?) -> ()) {
        guard let existingAliveness = workerAlivenesses[workerId] else { return }
        workerAlivenesses[workerId] = WorkerAliveness(
            registered: true,
            bucketIdsBeingProcessed: existingAliveness.bucketIdsBeingProcessed,
            disabled: existingAliveness.disabled,
            silent: false
        )
        
        callbackQueue.async {
            completion(nil)
        }
    }
}
