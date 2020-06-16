import AppKit

public final class StatusBarController {
    public let item: NSStatusItem
    
    public static func with(
        menuItems: [NSMenuItem],
        title: String = "",
        image: NSImage? = nil
    ) -> StatusBarController {
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = title
        statusItem.button?.image = image
        statusItem.menu = NSMenu(title: title)
        menuItems.forEach {
            statusItem.menu?.addItem($0)
        }
        return StatusBarController(item: statusItem)
    }

    public init(item: NSStatusItem) {
        self.item = item
    }
}
