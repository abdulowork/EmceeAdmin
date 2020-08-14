import AppKit
import EasyAppKit
import QueueModels
import RequestSender
import TeamcityApi

public final class AppDelegate: NSObject, NSApplicationDelegate {
    lazy var emceeQueueServerStatusBarController = productionDataBasedEmceeQueueServerStatusBarController()
    lazy var userDefaults = UserDefaults(suiteName: "ru.avito.emceeadmin")
    lazy var windowControllerHolder = WindowControllerHolder()
    
    public func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        emceeQueueServerStatusBarController.startUpdating()
    }
    
    private func productionDataBasedEmceeQueueServerStatusBarController () -> EmceeQueueServerStatusBarController {
        let requestSenderProvider = DefaultRequestSenderProvider()
        return EmceeQueueServerStatusBarController(
            hostsProvider: {
                self.userDefaults?.stringArray(forKey: "hosts") ?? []
            },
            queueMetricsProvider: DefaultQueueMetricsProvider(
                requestSenderProvider: requestSenderProvider
            ),
            remotePortDeterminerProvider: DefaultRemotePortDeterminerProvider(
                requestSenderProvider: requestSenderProvider
            ),
            windowControllerHolder: windowControllerHolder,
            workerStatusSetter: DefaultWorkerStatusSetter(
                requestSenderProvider: requestSenderProvider
            )
        )
    }
    
    private func fakeDataBasedEmceeQueueServerStatusBarController() -> EmceeQueueServerStatusBarController {
        let metricsProvider = FakeQueueMetricsProvider()
        
        return EmceeQueueServerStatusBarController(
            hostsProvider: {
                ["example.com"]
            },
            queueMetricsProvider: metricsProvider,
            remotePortDeterminerProvider: FakeRemotePortDeterminerProvider(
                result: [
                    41000: "abc2123",
                ]
            ),
            windowControllerHolder: windowControllerHolder,
            workerStatusSetter: metricsProvider
        )
    }
    
    private var teamcityConfig: TeamcityConfig? {
        guard let teamcityApiEndpoint = userDefaults?.string(forKey: "teamcityApiEndpoint") else { return nil }
        guard let teamcityApiUsername = userDefaults?.string(forKey: "teamcityApiUsername") else { return nil }
        guard let teamcityApiPassword = userDefaults?.string(forKey: "teamcityApiPassword") else { return nil }
        guard let teamcityPoolIds = try? userDefaults?.castedArray(Int.self, forKey: "teamcityPoolIds") else { return nil }
        
        return TeamcityConfig(
            teamcityApiEndpoint: URL(string: teamcityApiEndpoint)!,
            teamcityApiPassword: teamcityApiPassword,
            teamcityApiUsername: teamcityApiUsername,
            teamcityPoolIds: teamcityPoolIds
        )
    }
}

extension UserDefaults {
    struct CastError: Error {}
    func castedArray<T>(_ type: T.Type, forKey key: String) throws -> [T] {
        return try (array(forKey: key) ?? []).map {
            guard let obj = $0 as? T else { throw CastError() }
            return obj
        }
    }
}
