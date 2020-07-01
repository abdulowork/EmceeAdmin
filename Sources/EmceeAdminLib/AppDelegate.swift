import AppKit
import EasyAppKit

public final class AppDelegate: NSObject, NSApplicationDelegate {
    lazy var emceeQueueServerStatusBarController = EmceeQueueServerStatusBarController(
        hostsProvider: {
            UserDefaults(suiteName: "ru.avito.emceeadmin")?.stringArray(forKey: "hosts") ?? []
        },
        queueMetricsProvider: FakeQueueMetricsProvider(),
        remotePortDeterminerProvider: FakeRemotePortDeterminerProvider(
            result: [
                41000: "abc2123",
            ]
        ),
        windowControllerHolder: windowControllerHolder
    )
    
    lazy var windowControllerHolder = WindowControllerHolder()
    
    public func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        emceeQueueServerStatusBarController.startUpdating()
    }
}
