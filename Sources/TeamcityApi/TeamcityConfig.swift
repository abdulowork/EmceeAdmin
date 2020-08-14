import Foundation

public struct TeamcityConfig {
    public let teamcityApiEndpoint: URL
    public let teamcityApiPassword: String
    public let teamcityApiUsername: String
    public let teamcityPoolIds: [Int]
    
    public init(
        teamcityApiEndpoint: URL,
        teamcityApiPassword: String,
        teamcityApiUsername: String,
        teamcityPoolIds: [Int]
    ) {
        self.teamcityApiEndpoint = teamcityApiEndpoint
        self.teamcityApiPassword = teamcityApiPassword
        self.teamcityApiUsername = teamcityApiUsername
        self.teamcityPoolIds = teamcityPoolIds
    }
}
