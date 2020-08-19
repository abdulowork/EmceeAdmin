import Foundation
import RemotePortDeterminer

public protocol RemotePortDeterminerProvider {
    func remotePortDeterminer(host: String) -> RemotePortDeterminer
}
