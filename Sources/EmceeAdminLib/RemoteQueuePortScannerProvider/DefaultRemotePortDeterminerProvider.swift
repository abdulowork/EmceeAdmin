import Foundation
import RemotePortDeterminer
import RequestSender

public final class DefaultRemotePortDeterminerProvider: RemotePortDeterminerProvider {
    public func remotePortDeterminer(host: String) -> RemotePortDeterminer {
        RemoteQueuePortScanner(
            host: host,
            portRange: 41000...41005,
            requestSenderProvider: DefaultRequestSenderProvider()
        )
    }
}
