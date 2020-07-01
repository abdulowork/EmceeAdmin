import AppKit
import EasyAppKit
import Models

public final class QueueInfoWindowController: NSWindowController {
    private let queueInfoViewController: QueueInfoViewController
    
    public init(
        queueMetricsProvider: QueueMetricsProvider,
        runningQueue: RunningQueue
    ) {
        self.queueInfoViewController = QueueInfoViewController(
            runningQueue: runningQueue,
            queueMetricsProvider: queueMetricsProvider
        )
        
        super.init(
            window: NSWindow.createWindow(
                contentViewController: queueInfoViewController
            )
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
