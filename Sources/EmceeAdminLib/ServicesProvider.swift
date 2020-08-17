import AtomicModels
import Foundation
import Services
import SocketModels

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
        
        if let teamcityDefaultsSettings = TeamcityDefaultsSettings.from(userDefaults: userDefaults) {
            services.append(
                TeamcityService(
                    agentPoolIds: teamcityDefaultsSettings.teamcityPoolIds,
                    teamcityConfig: teamcityDefaultsSettings.teamcityConfig
                )
            )
        }
        
        services.append(contentsOf: discoverRunningEmceeServices())
        
        return services
    }
    
    private func discoverRunningEmceeServices() -> [EmceeService] {
        let hostsToQuery = userDefaults.stringArray(forKey: "hosts") ?? []
        
        let discoveredServices = AtomicValue([EmceeService]())
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 5
        for host in hostsToQuery {
            queue.addOperation { [weak self] in
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
        
        return discoveredServices.currentValue()
    }
}
