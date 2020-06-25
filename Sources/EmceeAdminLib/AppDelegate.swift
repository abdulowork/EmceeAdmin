import AppKit
import EasyAppKit

public final class AppDelegate: NSObject, NSApplicationDelegate {
    lazy var emceeQueueServerStatusBarController = EmceeQueueServerStatusBarController(
        hostsProvider: {
            UserDefaults(suiteName: "ru.avito.emceeadmin")?.stringArray(forKey: "hosts") ?? []
        },
        remotePortDeterminerProvider: FakeRemotePortDeterminerProvider(
            result: [
                41000: "abc2123",
            ]
        )
    )
    
    public func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        emceeQueueServerStatusBarController.startUpdating()
    }
}
