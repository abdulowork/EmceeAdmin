import AppKit
import EasyAppKit
import Services

public final class ServiceInfoWindowController: NSWindowController, NSWindowDelegate {
    private let serviceInfoViewController: ServiceInfoViewController
    public let service: Service
    
    public var onWindowClose: () -> () = {}
    
    public init(
        service: Service
    ) {
        self.service = service
        
        self.serviceInfoViewController = ServiceInfoViewController(
            service: service
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
