import AppKit

public final class WindowControllerHolder {
    private var heldWindowControllers = [UUID: NSWindowController]()
    
    public init() {}
    
    public func hold(windowController: NSWindowController) -> UUID {
        let key = UUID()
        heldWindowControllers[key] = windowController
        return key
    }
    
    public func typedWindowControllers<T: NSWindowController>() -> [T] {
        heldWindowControllers.values.compactMap { $0 as? T }
    }
    
    @discardableResult
    public func release(windowControllerUnderKey key: UUID) -> NSWindowController? {
        heldWindowControllers.removeValue(forKey: key)
    }
}
