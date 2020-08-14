import Foundation

public class TeamcitySessionProvider: NSObject, URLSessionDelegate, URLSessionTaskDelegate {
    private let apiEndpoint: URL
    private let apiUsername: String
    private let apiPassword: String
    private let delegateQueue = OperationQueue()
    
    public init(apiEndpoint: URL, apiUsername: String, apiPassword: String) {
        self.apiEndpoint = apiEndpoint
        self.apiUsername = apiUsername
        self.apiPassword = apiPassword
    }
    
    public func createSession() -> URLSession {
        return URLSession(configuration: .ephemeral, delegate: self, delegateQueue: delegateQueue)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.host == apiEndpoint.host {
            return completionHandler(
                .useCredential,
                URLCredential(user: apiUsername, password: apiPassword, persistence: .forSession)
            )
        }
        
        completionHandler(.cancelAuthenticationChallenge, nil)
    }
}
