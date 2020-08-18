import AtomicModels
import Foundation
import Services
import SocketModels
import TeamcityApi

protocol ServiceProvider {
    func services() -> [Service]
}

final class DefaultServiceProvider: ServiceProvider {
    private let remotePortDeterminerProvider: RemotePortDeterminerProvider
    private let userDefaults: UserDefaults
    
    init(
        remotePortDeterminerProvider: RemotePortDeterminerProvider,
        userDefaults: UserDefaults
    ) {
        self.remotePortDeterminerProvider = remotePortDeterminerProvider
        self.userDefaults = userDefaults
    }
    
    func services() -> [Service] {
        var services = [Service]()
        
        services.append(contentsOf: discoverRunningTeamcityService())
        services.append(contentsOf: discoverRunningEmceeServices())
        
        return services
    }
    
    private func discoverRunningTeamcityService() -> [TeamcityService] {
        guard let teamcityDefaultsSettings = TeamcityDefaultsSettings.from(userDefaults: userDefaults) else { return [] }
        
        let group = DispatchGroup()
        
        group.enter()
        
        var response: Result<TeamcityServerInfo, Error>? = nil
        
        let teamcityRequestProvider = DefaultTeamcityRequestProvider(
            restApiEndpoint: teamcityDefaultsSettings.teamcityConfig.teamcityApiEndpoint,
            session: DefaultTeamcitySessionProvider(teamcityConfig: teamcityDefaultsSettings.teamcityConfig).createSession()
        )
        teamcityRequestProvider.fetchServerInfo {
            defer {
                group.leave()
            }
            response = $0
        }
        
        group.wait()
        
        do {
            let info = try response!.get()
            return [
                TeamcityService(
                    agentPoolIds: teamcityDefaultsSettings.teamcityPoolIds,
                    teamcityConfig: teamcityDefaultsSettings.teamcityConfig,
                    version: "\(info.versionMajor).\(info.versionMinor)",
                    teamcityRequestProvider: teamcityRequestProvider
                )
            ]
        } catch {
            return []
        }
    }
    
    private func discoverRunningEmceeServices() -> [EmceeService] {
        let hostsToQuery = userDefaults.stringArray(forKey: "hosts") ?? []
        
        let discoveredServices = AtomicValue([EmceeService]())
        
        let group = DispatchGroup()
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 5
        for host in hostsToQuery {
            group.enter()
            queue.addOperation { [weak self] in
                defer {
                    group.leave()
                }
                guard let self = self else { return }
                
                let remotePortDeterminer = self.remotePortDeterminerProvider.remotePortDeterminer(
                    host: host
                )
                
                let result = remotePortDeterminer.queryPortAndQueueServerVersion(timeout: 10)
                
                for (port, version) in result {
                    discoveredServices.withExclusiveAccess {
                        $0.append(
                            EmceeService(
                                queueSocketAddress: SocketAddress(
                                    host: host,
                                    port: port
                                ),
                                version: version
                            )
                        )
                    }
                }
            }
        }
        
        group.wait()
        
        return discoveredServices.currentValue()
    }
}
