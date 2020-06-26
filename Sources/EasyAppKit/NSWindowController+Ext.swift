import AppKit

public protocol ContentViewControllerProviding {
    static func createContentViewController() -> NSViewController
}

public extension ContentViewControllerProviding where Self: NSWindowController {
    static func create(
        windowStyle: NSWindow.StyleMask = [.closable, .miniaturizable, .resizable, .titled]
    ) -> Self {
        let window = NSWindow(
            contentRect: NSWindow.contentRect(
                forFrameRect: NSRect(x: 20, y: 20, width: 200, height: 200),
                styleMask: windowStyle
            ),
            styleMask: windowStyle,
            backing: .buffered,
            defer: true
        )
        
        let contentViewController = Self.createContentViewController()
        
        window.contentViewController = contentViewController
        window.bind(.title, to: contentViewController, withKeyPath: "title", options: nil)
        
        return Self(
            window: window
        )
    }
}
