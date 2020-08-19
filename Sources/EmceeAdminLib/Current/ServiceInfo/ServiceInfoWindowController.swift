import AppKit
import EasyAppKit
import Services

public final class ServiceInfoWindowController: NSWindowController, NSWindowDelegate {
    private let serviceInfoViewController: ServiceInfoViewController
    
    public var onWindowClose: () -> () = {}
    
    public init(
        services: [Service]
    ) {
        self.serviceInfoViewController = ServiceInfoViewController(
            services: services
        )
        
        let window = NSWindow.createWindow(
            contentViewController: serviceInfoViewController
        )
        
        super.init(window: window)
        
        window.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func windowWillClose(_ notification: Notification) {
        onWindowClose()
    }
}
