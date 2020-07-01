import AppKit

public extension NSMenuItem {
    
    private class InternalMenuItemAction {
        private let handler: () -> ()
        
        init(handler: @escaping () -> ()) {
            self.handler = handler
        }
        
        @objc func invoke() { handler() }
    }
    
    static func with(
        title: String,
        image: NSImage? = nil,
        key: String = "",
        enabled: Bool = false,
        action: @escaping () -> () = {}
    ) -> NSMenuItem {
        let item = NSMenuItem()
        item.title = title
        item.image = image
        item.keyEquivalent = key
        item.isEnabled = enabled
        
        let internalHandler = InternalMenuItemAction(handler: action)
        item.target = internalHandler
        item.action = #selector(InternalMenuItemAction.invoke)
        item.representedObject = internalHandler
        
        return item
    }
}

public extension NSMenu {
    static func create(title: String = "", items: [NSMenuItem] = [], delegate: NSMenuDelegate? = nil) -> NSMenu {
        let menu = NSMenu(title: title)
        menu.items = items
        menu.delegate = delegate
        return menu
    }
}
