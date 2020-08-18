import Foundation

public class DefaultTeamcityRequestProvider: TeamcityRequestProvider {
    private let restApiEndpoint: URL
    private let session: URLSession
    private let decoder = JSONDecoder()
    
    public init(
        restApiEndpoint: URL,
        session: URLSession
    ) {
        self.restApiEndpoint = restApiEndpoint
        self.session = session
    }
    
    struct NoDataError: Error {}
    
    private func createRequest(path: String, method: String = "GET") -> URLRequest {
        let endpointUrl = restApiEndpoint.appendingPathComponent(path)
        var request = URLRequest(url: endpointUrl)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    public func fetchServerInfo(completion: @escaping (Result<TeamcityServerInfo, Error>) -> ()) {
        let request = createRequest(path: "app/rest/server")
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error { return completion(.failure(error)) }
            guard let data = data else { return completion(.failure(NoDataError())) }
            
            let result = Result<TeamcityServerInfo, Error> {
                let dict = try JSONSerialization.dictionary(data: data)
                return TeamcityServerInfo(
                    versionMajor: try dict.cast(key: "versionMajor"),
                    versionMinor: try dict.cast(key: "versionMinor"),
                    buildNumber: try dict.cast(key: "buildNumber")
                )
            }
            completion(result)
        }
        task.resume()
    }
    
    public func fetchAgentPool(poolId: Int, completion: @escaping (Result<TeamcityAgentPool, Error>) -> ()) {
        let request = createRequest(path: "app/rest/agentPools/id:\(poolId)")
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error { return completion(.failure(error)) }
            guard let data = data else { return completion(.failure(NoDataError())) }
            
            let result = Result<TeamcityAgentPool, Error> {
                let dict = try JSONSerialization.dictionary(data: data)
                return TeamcityAgentPool(
                    id: try dict.cast(key: "id"),
                    name: try dict.cast(key: "name"),
                    agentsInPool: try dict.cast(NSDictionary.self, key: "agents").cast(NSArray.self, key: "agent").castedMap { (obj: NSDictionary) in
                        TeamcityAgentInPool(
                            id: try obj.cast(key: "id"),
                            name: try obj.cast(key: "name")
                        )
                    }
                )
            }
            completion(result)
        }
        task.resume()
    }
    
    public func fetchAgentDetails(agentId: Int, completion: @escaping (Result<TeamcityAgentWithDetails, Error>) -> ()) {
        let request = createRequest(path: "app/rest/agents/id:\(agentId)")
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error { return completion(.failure(error)) }
            guard let data = data else { return completion(.failure(NoDataError())) }
            
            let result = Result<TeamcityAgentWithDetails, Error> {
                let dict = try JSONSerialization.dictionary(data: data)
                return TeamcityAgentWithDetails(
                    id: try dict.cast(key: "id"),
                    name: try dict.cast(key: "name"),
                    agentDetailsWebUrl: URL(string: try dict.cast(key: "webUrl"))!,
                    authorized: try dict.cast(key: "authorized"),
                    enabled: try dict.cast(key: "enabled"),
                    connected: try dict.cast(key: "connected"),
                    agentPoolId: try dict.cast(NSDictionary.self, key: "pool").cast(key: "id"),
                    agentPoolName: try dict.cast(NSDictionary.self, key: "pool").cast(key: "name")
                )
            }
            completion(result)
        }
        task.resume()
    }
}

private extension JSONSerialization {
    struct NotDictError: Error {}
    
    static func dictionary(data: Data) throws -> NSDictionary {
        guard let obj = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
            throw NotDictError()
        }
        return obj
    }
}

private extension NSDictionary {
    struct InvalidType: Error {}
    
    func cast<T>(key: String) throws -> T {
        guard let value = self[key] as? T else {
            throw InvalidType()
        }
        return value
    }
    
    func cast<T>(_ type: T.Type, key: String) throws -> T {
        return try cast(key: key)
    }
}

private extension NSArray {
    func castedMap<K, V>(transform: (K) throws -> V) throws -> [V] {
        try map {
            guard let obj = $0 as? K else {
                throw NSDictionary.InvalidType()
            }
            return try transform(obj)
        }
    }
}
