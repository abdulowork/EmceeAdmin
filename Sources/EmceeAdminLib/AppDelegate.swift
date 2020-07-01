import AppKit
import EasyAppKit
import RequestSender

public final class AppDelegate: NSObject, NSApplicationDelegate {
    lazy var emceeQueueServerStatusBarController = productionDataBasedEmceeQueueServerStatusBarController()
    
    lazy var windowControllerHolder = WindowControllerHolder()
    
    public func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        emceeQueueServerStatusBarController.startUpdating()
    }
    
    private func productionDataBasedEmceeQueueServerStatusBarController () -> EmceeQueueServerStatusBarController {
        let requestSenderProvider = DefaultRequestSenderProvider()
        return EmceeQueueServerStatusBarController(
            hostsProvider: {
                UserDefaults(suiteName: "ru.avito.emceeadmin")?.stringArray(forKey: "hosts") ?? []
            },
            queueMetricsProvider: DefaultQueueMetricsProvider(
                requestSenderProvider: requestSenderProvider
            ),
            remotePortDeterminerProvider: DefaultRemotePortDeterminerProvider(
                requestSenderProvider: requestSenderProvider
            ),
            windowControllerHolder: windowControllerHolder
        )
    }
    
    private func fakeDataBasedEmceeQueueServerStatusBarController() -> EmceeQueueServerStatusBarController {
        EmceeQueueServerStatusBarController(
            hostsProvider: {
                ["example.com"]
            },
            queueMetricsProvider: FakeQueueMetricsProvider(),
            remotePortDeterminerProvider: FakeRemotePortDeterminerProvider(
                result: [
                    41000: "abc2123",
                ]
            ),
            windowControllerHolder: windowControllerHolder
        )
    }
}
