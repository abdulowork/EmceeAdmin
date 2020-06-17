import AppKit

public extension NSMenuItem {
    static func with(
        title: String,
        image: NSImage? = nil,
        key: String = "",
        enabled: Bool = false,
        target: AnyObject? = nil,
        action: Selector? = nil
    ) -> NSMenuItem {
        let item = NSMenuItem()
        item.title = title
        item.image = image
        item.keyEquivalent = key
        item.isEnabled = enabled
        item.target = target
        item.action = action
        return item
    }
}
