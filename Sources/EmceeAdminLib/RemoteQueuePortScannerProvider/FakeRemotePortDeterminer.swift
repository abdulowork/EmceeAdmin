import Foundation
import Models
import RemotePortDeterminer

public final class FakeRemotePortDeterminer: RemotePortDeterminer {
    private let result: [Models.Port : Version]
    
    public init(result: [Models.Port : Version]) {
        self.result = result
    }
    
    public func queryPortAndQueueServerVersion(timeout: TimeInterval) -> [Models.Port : Version] {
        result
    }
}
