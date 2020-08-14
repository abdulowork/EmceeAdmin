import Foundation
import RemotePortDeterminer
import RequestSender

public final class DefaultRemotePortDeterminerProvider: RemotePortDeterminerProvider {
    private let requestSenderProvider: RequestSenderProvider
    
    public init(requestSenderProvider: RequestSenderProvider) {
        self.requestSenderProvider = requestSenderProvider
    }
    
    public func remotePortDeterminer(
        host: String
    ) -> RemotePortDeterminer {
        RemoteQueuePortScanner(
            host: host,
            portRange: 41000...41005,
            requestSenderProvider: requestSenderProvider
        )
    }
}
