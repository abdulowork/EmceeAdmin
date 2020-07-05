import AppKit

public extension NSView {
    func recursivelySetEnabledOnSubviews(_ enabled: Bool) {
        for subview in subviews {
            if subview.responds(to: #selector(setter: NSControl.isEnabled)) {
                let control = subview as! NSControl
                control.isEnabled = enabled
            }
            subview.recursivelySetEnabledOnSubviews(enabled)
        }
    }
    
    func recursivelySetHighlightedOnSubviews(_ highlighted: Bool) {
        for subview in subviews {
            if subview.responds(to: #selector(setter: NSControl.isHighlighted)) {
                let control = subview as! NSControl
                control.isHighlighted = highlighted
            }
            subview.recursivelySetHighlightedOnSubviews(highlighted)
        }
    }
}
