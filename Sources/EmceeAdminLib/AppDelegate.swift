import AppKit
import EasyAppKit

public final class AppDelegate: NSObject, NSApplicationDelegate {
    lazy var emceeQueueServerStatusBarController = EmceeQueueServerStatusBarController(
        hosts: UserDefaults(suiteName: "ru.avito.emceeadmin")?.stringArray(forKey: "hosts") ?? []
    )
    
    public func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        emceeQueueServerStatusBarController.startUpdating()
    }
}
