import Dispatch
import Foundation
import Models
import QueueClient
import RequestSender
import WorkerAlivenessModels

public final class DefaultQueueMetricsProvider: QueueMetricsProvider {
    private let requestSenderProvider: RequestSenderProvider
    
    public init(
        requestSenderProvider: RequestSenderProvider
    ) {
        self.requestSenderProvider = requestSenderProvider
    }
    
    public func momentumQueueMetrics(
        queueSocketAddress: SocketAddress,
        callbackQueue: DispatchQueue,
        completion: @escaping (Result<MomentumQueueMetrics, Error>) -> ()
    ) {
        let fetcher = WorkerStatusFetcherImpl(
            requestSender: requestSenderProvider.requestSender(socketAddress: queueSocketAddress)
        )
        fetcher.fetch(
            callbackQueue: callbackQueue
        ) { (response: Either<[WorkerId: WorkerAliveness], Error>) in
            do {
                let metrics = MomentumQueueMetrics(workerAlivenesses: try response.dematerialize())
                completion(.success(metrics))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func staticQueueMetrics(
        queueSocketAddress: SocketAddress,
        callbackQueue: DispatchQueue,
        completion: @escaping (Result<StaticQueueMetrics, Error>) -> ()
    ) {
        let fetcher = QueueServerVersionFetcherImpl(
            requestSender: requestSenderProvider.requestSender(socketAddress: queueSocketAddress)
        )
        fetcher.fetchQueueServerVersion(callbackQueue: callbackQueue) { (response: Either<Version, Error>) in
            do {
                let metrics = StaticQueueMetrics(
                    socketAddress: queueSocketAddress,
                    version: try response.dematerialize(),
                    startedAt: Date(),
                    hostLogsPath: ""
                )
                completion(.success(metrics))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
