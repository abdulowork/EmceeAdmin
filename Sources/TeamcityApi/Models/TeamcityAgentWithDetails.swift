import Foundation

public struct TeamcityAgentWithDetails {
    public let id: Int
    public let name: String
    public let agentDetailsWebUrl: URL
    public let authorized: Bool
    public let enabled: Bool
    public let connected: Bool
}
