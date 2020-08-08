import Dispatch
import SocketModels
import QueueModels

public protocol WorkerStatusSetter {
    func enable(
        queueServerAddress: SocketAddress,
        workerId: WorkerId,
        callbackQueue: DispatchQueue,
        completion: @escaping (Error?) -> ()

    )
    
    func disable(
        queueServerAddress: SocketAddress,
        workerId: WorkerId,
        callbackQueue: DispatchQueue,
        completion: @escaping (Error?) -> ()
    )
    
    func kickstart(
        queueServerAddress: SocketAddress,
        workerId: WorkerId,
        callbackQueue: DispatchQueue,
        completion: @escaping (Error?) -> ()
    )
}
