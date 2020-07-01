import Dispatch
import Models
import QueueClient
import RequestSender
import SynchronousWaiter

public final class DefaultWorkerStatusSetter: WorkerStatusSetter {
    private let requestSenderProvider: RequestSenderProvider
    
    public init(
        requestSenderProvider: RequestSenderProvider
    ) {
        self.requestSenderProvider = requestSenderProvider
    }
    
    public func disable(queueServerAddress: SocketAddress, workerId: WorkerId, callbackQueue: DispatchQueue, completion: @escaping (Error?) -> ()) {
        let disabler = WorkerDisablerImpl(requestSender: requestSenderProvider.requestSender(socketAddress: queueServerAddress))
        disabler.disableWorker(workerId: workerId, callbackQueue: callbackQueue) { (response: Either<WorkerId, Error>) in
            completion(response.right)
        }
    }
    
    public func enable(queueServerAddress: SocketAddress, workerId: WorkerId, callbackQueue: DispatchQueue, completion: @escaping (Error?) -> ()) {
        let enabler = WorkerEnablerImpl(requestSender: requestSenderProvider.requestSender(socketAddress: queueServerAddress))
        enabler.enableWorker(workerId: workerId, callbackQueue: callbackQueue) { (response: Either<WorkerId, Error>) in
            completion(response.right)
        }
    }
}
