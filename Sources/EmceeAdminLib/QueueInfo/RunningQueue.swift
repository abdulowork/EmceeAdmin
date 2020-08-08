import Foundation
import QueueModels
import SocketModels

public struct RunningQueue: Comparable {
    public static func < (lhs: RunningQueue, rhs: RunningQueue) -> Bool {
        if lhs.socketAddress.host == rhs.socketAddress.host {
            return lhs.socketAddress.port < rhs.socketAddress.port
        }
        return lhs.socketAddress.host < rhs.socketAddress.host
    }
    
    public let socketAddress: SocketAddress
    public let version: Version
}
