import AppKit

public final class ApplicationLauncher {
    private let delegate: NSApplicationDelegate

    public init(delegate: NSApplicationDelegate) {
        self.delegate = delegate
    }
    
    public func run() {
        NSApplication.shared.delegate = delegate
        NSApplication.shared.run()
    }
}
