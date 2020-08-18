import Foundation

public class DefaultTeamcitySessionProvider: NSObject, TeamcitySessionProvider, URLSessionDelegate, URLSessionTaskDelegate {
    private let teamcityConfig: TeamcityConfig
    private let delegateQueue = OperationQueue()
    
    public init(teamcityConfig: TeamcityConfig) {
        self.teamcityConfig = teamcityConfig
    }
    
    public func createSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        
        let cookieStorage = HTTPCookieStorage()
        cookieStorage.cookieAcceptPolicy = .never
        
        configuration.httpCookieStorage = cookieStorage
        
        return URLSession(configuration: configuration, delegate: self, delegateQueue: delegateQueue)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.host == teamcityConfig.teamcityApiEndpoint.host {
            return completionHandler(
                .useCredential,
                URLCredential(user: teamcityConfig.teamcityApiUsername, password: teamcityConfig.teamcityApiPassword, persistence: .forSession)
            )
        }
        
        completionHandler(.cancelAuthenticationChallenge, nil)
    }
}
