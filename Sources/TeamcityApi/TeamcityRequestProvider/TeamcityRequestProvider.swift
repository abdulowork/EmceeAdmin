import Foundation

public protocol TeamcityRequestProvider {
    func fetchServerInfo(completion: @escaping (Result<TeamcityServerInfo, Error>) -> ())
    func fetchAgentPool(poolId: Int, completion: @escaping (Result<TeamcityAgentPool, Error>) -> ())
    func fetchAgentDetails(agentId: Int, completion: @escaping (Result<TeamcityAgentWithDetails, Error>) -> ())
}
