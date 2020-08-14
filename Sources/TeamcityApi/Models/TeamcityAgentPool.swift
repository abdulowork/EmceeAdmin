import Foundation

public struct TeamcityAgentPool {
    public let id: Int
    public let name: String
    public let agentsInPool: [TeamcityAgentInPool]
}
