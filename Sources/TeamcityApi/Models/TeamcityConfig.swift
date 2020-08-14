import Foundation

public struct TeamcityConfig {
    public let teamcityApiEndpoint: URL
    public let teamcityApiPassword: String
    public let teamcityApiUsername: String
    
    public init(
        teamcityApiEndpoint: URL,
        teamcityApiPassword: String,
        teamcityApiUsername: String
    ) {
        self.teamcityApiEndpoint = teamcityApiEndpoint
        self.teamcityApiPassword = teamcityApiPassword
        self.teamcityApiUsername = teamcityApiUsername
    }
}
