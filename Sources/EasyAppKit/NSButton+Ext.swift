import AppKit

public extension NSButton {
    static func create(
        title: String,
        bezelStyle: BezelStyle = .rounded,
        target: Any? = nil,
        action: Selector? = nil
    ) -> NSButton {
        let button = NSButton(title: title, target: target, action: action)
        
        button.bezelStyle = bezelStyle
        
        return button
    }
}
