import Foundation
import Models
import WorkerAlivenessModels

public struct StaticQueueMetrics {
    public let socketAddress: SocketAddress
    public let version: Version
    public let startedAt: Date
    public let hostLogsPath: String
    
    public init(socketAddress: SocketAddress, version: Version, startedAt: Date, hostLogsPath: String) {
        self.socketAddress = socketAddress
        self.version = version
        self.startedAt = startedAt
        self.hostLogsPath = hostLogsPath
    }
}
