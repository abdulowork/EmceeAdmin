import AppKit

public extension NSWindow {
    static func createWindow(
        contentViewController: NSViewController,
        windowFrame: NSRect = .zero,
        windowStyle: NSWindow.StyleMask = [.closable, .miniaturizable, .resizable, .titled]
    ) -> NSWindow {
        let window = NSWindow(
            contentRect: NSWindow.contentRect(
                forFrameRect: windowFrame,
                styleMask: windowStyle
            ),
            styleMask: windowStyle,
            backing: .buffered,
            defer: true
        )
        
        window.contentViewController = contentViewController
        window.bind(.title, to: contentViewController, withKeyPath: "title", options: nil)
        
        return window
    }
}
