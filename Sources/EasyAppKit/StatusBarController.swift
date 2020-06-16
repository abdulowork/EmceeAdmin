import AppKit

public final class StatusBarController {
    public let item: NSStatusItem
    
    public static func createItem(length: CGFloat) -> NSStatusItem {
        NSStatusBar.system.statusItem(withLength: length)
    }
    
    public convenience init(itemLength: CGFloat) {
        self.init(item: StatusBarController.createItem(length: itemLength))
    }

    public init(item: NSStatusItem) {
        self.item = item
    }
}
