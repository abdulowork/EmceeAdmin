import AppKit
import EasyAppKit

public final class AppDelegate: NSObject, NSApplicationDelegate {
    lazy var statusBarController = StatusBarController(itemLength: NSStatusItem.variableLength)
    
    public func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        
        statusBarController.item.button?.title = "hello"
        statusBarController.item.menu = NSMenu(title: "hello")
        statusBarController.item.menu?.addItem(
            withTitle: "Quit",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
    }
}
