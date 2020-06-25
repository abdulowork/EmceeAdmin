import Foundation
import Models
import RemotePortDeterminer
import RequestSender

public final class FakeRemotePortDeterminerProvider: RemotePortDeterminerProvider {
    private let result: [Models.Port : Version]
    
    public init(result: [Models.Port : Version]) {
        self.result = result
    }
    
    public func remotePortDeterminer(host: String) -> RemotePortDeterminer {
        FakeRemotePortDeterminer(result: result)
    }
}
