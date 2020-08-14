import AppKit
import EasyAppKit

public final class QueueInfoWindowController: NSWindowController, NSWindowDelegate {
    private let queueInfoViewController: QueueInfoViewController
    public let runningQueue: RunningQueue
    
    public var onWindowClose: () -> () = {}
    
    public init(
        runningQueue: RunningQueue,
        queueMetricsProvider: QueueMetricsProvider,
        workerStatusSetter: WorkerStatusSetter
    ) {
        self.runningQueue = runningQueue
        
        self.queueInfoViewController = QueueInfoViewController(
            queueMetricsProvider: queueMetricsProvider,
            runningQueue: runningQueue,
            workerStatusSetter: workerStatusSetter
        )
        
        let window = NSWindow.createWindow(
            contentViewController: queueInfoViewController
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
