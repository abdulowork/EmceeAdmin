import Foundation
import TeamcityApi

final class TeamcityDefaultsSettings {
    let teamcityConfig: TeamcityConfig
    let teamcityPoolIds: [Int]
    
    init(teamcityConfig: TeamcityConfig, teamcityPoolIds: [Int]) {
        self.teamcityConfig = teamcityConfig
        self.teamcityPoolIds = teamcityPoolIds
    }
    
    static func from(userDefaults: UserDefaults) -> TeamcityDefaultsSettings? {
        guard let config = teamcityConfig(userDefaults: userDefaults) else { return nil }
        let agentPoolIds = teamcityPoolIds(userDefaults: userDefaults)
        guard !agentPoolIds.isEmpty else { return nil }
        
        return TeamcityDefaultsSettings(
            teamcityConfig: config,
            teamcityPoolIds: agentPoolIds
        )
    }
    
    private static func teamcityConfig(userDefaults: UserDefaults) -> TeamcityConfig? {
        guard let teamcityApiEndpoint = userDefaults.string(forKey: "teamcityApiEndpoint") else { return nil }
        guard let teamcityApiUsername = userDefaults.string(forKey: "teamcityApiUsername") else { return nil }
        guard let teamcityApiPassword = userDefaults.string(forKey: "teamcityApiPassword") else { return nil }
        
        return TeamcityConfig(
            teamcityApiEndpoint: URL(string: teamcityApiEndpoint)!,
            teamcityApiPassword: teamcityApiPassword,
            teamcityApiUsername: teamcityApiUsername
        )
    }
    
    private static func teamcityPoolIds(userDefaults: UserDefaults) -> [Int] {
        (try? userDefaults.castedArray(Int.self, forKey: "teamcityPoolIds")) ?? []
    }
}

extension UserDefaults {
    struct UserDefaultsCastError: Error {}
    func castedArray<T>(_ type: T.Type, forKey key: String) throws -> [T] {
        return try (array(forKey: key) ?? []).map {
            guard let obj = $0 as? T else { throw UserDefaultsCastError() }
            return obj
        }
    }
}
