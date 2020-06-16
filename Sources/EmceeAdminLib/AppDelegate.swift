import AppKit
import EasyAppKit

public final class AppDelegate: NSObject, NSApplicationDelegate {
    lazy var statusBarController = StatusBarController.with(
        menuItems: [
            NSMenuItem(title: "Searching for Emcee Queues...", action: nil, keyEquivalent: ""),
            NSMenuItem.separator(),
            NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"),
        ],
        title: "Emcee Admin"
    )
    
    public func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        _ = statusBarController
    }
}
