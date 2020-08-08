import Foundation
import QueueModels
import RemotePortDeterminer
import RequestSender
import SocketModels

public final class FakeRemotePortDeterminerProvider: RemotePortDeterminerProvider {
    private let result: [SocketModels.Port : Version]
    
    public init(result: [SocketModels.Port : Version]) {
        self.result = result
    }
    
    public func remotePortDeterminer(host: String) -> RemotePortDeterminer {
        FakeRemotePortDeterminer(result: result)
    }
}
