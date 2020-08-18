import AppKit
import AtomicModels
import EasyAppKit
import Services

final class EmceeQueueServerStatusBarController {
    lazy var statusBarController = StatusBarController(
        title: "Emcee Admin"
    )
    private let serviceProvider: ServiceProvider
    private let windowControllerHolder: WindowControllerHolder
    private var isSearching = false
    private let discoveredServices = AtomicValue([Service]())
    private var pickedServices = [Service]()
    
    init(
        serviceProvider: ServiceProvider,
        windowControllerHolder: WindowControllerHolder
    ) {
        self.serviceProvider = serviceProvider
        self.windowControllerHolder = windowControllerHolder
    }
    
    func startUpdating() {
        let modifierKeysTracker = ModifierKeysTracker()
        
        statusBarController.showStatusBarItem()
        statusBarController.menuItems = { [weak self] in self?.menuItems() ?? [] }
        statusBarController.willOpenMenu = { [weak self] in
            self?.pickedServices = []
            self?.discoverServices()
            
            modifierKeysTracker.subscribe { [weak self] flags in
                guard let self = self else { return true }
                
                if !self.pickedServices.isEmpty && !flags.contains(.shift) {
                    self.statusBarController.closeMenu(animated: true)
                }
                
                return !self.statusBarController.isMenuOpen
            }
            modifierKeysTracker.track()
        }
        statusBarController.didCloseMenu = { [weak self] in
            self?.showServiceInfo()
            modifierKeysTracker.stopTracking()
        }
    }
    
    private func menuItems() -> [NSMenuItem] {
        var items = [NSMenuItem]()
        items += [
            NSMenuItem.with(
                title: isSearching ? "Searching for services..." : "\(discoveredServices.currentValue().count) services found"
            ),
            NSMenuItem.separator(),
        ]

        items += discoveredServices.currentValue().sorted(by: { (left, right) -> Bool in
            if left.name == right.name {
                return left.version < right.version
            }
            return left.name < right.name
        }).map { service in
            NSMenuItem.with(
                title: "",
                view: EAKMenuView(
                    actionable: true,
                    contentView: ServiceBriefInfoMenuView(service: service),
                    highlightable: true,
                    selected: false,
                    multipleSelectionEnabled: true
                )
            ) { [weak self] in
                guard let self = self else { return }
                self.pickedServices.append(service)
                if !self.statusBarController.isMenuOpen {
                    self.showServiceInfo()
                }
            }
        }

        return items + [
            NSMenuItem.separator(),
            NSMenuItem.with(title: "Quit", key: "q", enabled: true, action: { NSApp.terminate(nil) }),
        ]
    }
    
    private func discoverServices() {
        isSearching = true
        self.updateUI()
        
        let queue = OperationQueue()
        
        queue.addOperation {
            self.discoveredServices.set(self.serviceProvider.services())
            self.isSearching = false
            
            self.updateUI()
        }
    }
    
    private func showServiceInfo() {
        guard !pickedServices.isEmpty else { return }

        let windowController = ServiceInfoWindowController(
            services: pickedServices
        )
        let key = windowControllerHolder.hold(windowController: windowController)
        windowController.showWindow(nil)
        windowController.window?.center()
        windowController.onWindowClose = { [windowControllerHolder] in
            windowControllerHolder.release(windowControllerUnderKey: key)
        }
    }
    
    private func updateUI() {
        DispatchQueue.main.async {
            self.statusBarController.updateMenuItems()
        }
    }
}
