import Foundation
import Models

struct RunningQueue: Comparable {
    static func < (lhs: RunningQueue, rhs: RunningQueue) -> Bool {
        if lhs.host == rhs.host {
            return lhs.port < rhs.port
        }
        return lhs.host < rhs.host
    }
    
    let host: String
    let port: Models.Port
    let version: Version
}
