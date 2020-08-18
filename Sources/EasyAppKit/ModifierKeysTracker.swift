import AppKit

public final class ModifierKeysTracker {
    private var timer: Timer?
    
    public var modifierFlags = NSEvent.modifierFlags
    
    public init() {}
    
    public func track() {
        stopTracking()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { [weak self] sender in
            guard let self = self else { return sender.invalidate() }
            self.trigger()
        })
        RunLoop.current.add(timer!, forMode: .common)
    }

    public func stopTracking() {
        timer?.invalidate()
        timer = nil
    }
    
    private var observers = [(NSEvent.ModifierFlags) -> (Bool)]()
    
    public func subscribe(observer: @escaping (NSEvent.ModifierFlags) -> (Bool)) {
        observers.append(observer)
    }
    
    private func trigger() {
        if modifierFlags == NSEvent.modifierFlags {
            return
        }
        
        modifierFlags = NSEvent.modifierFlags
        
        for index in (0 ..< observers.count).reversed() {
            let observer = observers[index]
            if observer(modifierFlags) == true {
                _ = observers.remove(at: index)
            }
        }
    }
}
