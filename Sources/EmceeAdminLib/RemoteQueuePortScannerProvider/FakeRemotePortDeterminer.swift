import Foundation
import QueueModels
import RemotePortDeterminer
import SocketModels

public final class FakeRemotePortDeterminer: RemotePortDeterminer {
    private let result: [SocketModels.Port : Version]
    
    public init(result: [SocketModels.Port : Version]) {
        self.result = result
    }
    
    public func queryPortAndQueueServerVersion(timeout: TimeInterval) -> [SocketModels.Port : Version] {
        result
    }
}
