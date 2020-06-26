import AppKit

public final class WindowControllerHolder {
    private var heldWindowControllers = [String: NSWindowController]()
    
    public init() {}
    
    public func hold(windowController: NSWindowController, key: String) {
        heldWindowControllers[key] = windowController
    }
    
    public func release(windowControllerUnderKey key: String) -> NSWindowController? {
        heldWindowControllers.removeValue(forKey: key)
    }
}
