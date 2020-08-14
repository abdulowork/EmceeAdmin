import Foundation

public protocol TeamcitySessionProvider {
    func createSession() -> URLSession
}
