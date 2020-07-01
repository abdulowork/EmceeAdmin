import AppKit

public final class ApplicationLauncher {
    private let delegate: NSApplicationDelegate
    private let mainMenuProvider: MainMenuProvider

    public init(delegate: NSApplicationDelegate, mainMenuProvider: MainMenuProvider) {
        self.delegate = delegate
        self.mainMenuProvider = mainMenuProvider
    }
    
    public func run() {
        let mainMenu = NSMenu(title: "MainMenu")
        
        let applicationSubmenuItem = NSMenuItem.with(title: "Application")
        let applicationSubmenu = NSMenu(title: "Application")
        mainMenuProvider.populate(applicationSubmenu: applicationSubmenu)
        applicationSubmenuItem.submenu = applicationSubmenu
        mainMenu.addItem(applicationSubmenuItem)
        
        let additionalMenuItems = mainMenuProvider.additionalSubmenus()
        mainMenu.add(items: additionalMenuItems)
        
        NSApplication.shared.mainMenu = mainMenu
        NSApplication.shared.delegate = delegate
        NSApplication.shared.run()
    }
}
