import AppKit

public protocol MainMenuProvider {
    func populate(applicationSubmenu: NSMenu)
    func additionalSubmenus() -> [NSMenuItem]
}
