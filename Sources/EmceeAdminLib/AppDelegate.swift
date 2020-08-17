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
    

}
