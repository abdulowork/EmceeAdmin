import AppKit
import EasyAppKit
import Models

public final class QueueInfoWindowController: NSWindowController {
    private let queueInfoViewController: QueueInfoViewController
    
    public init(
        runningQueue: RunningQueue,
        queueMetricsProvider: QueueMetricsProvider,
        workerStatusSetter: WorkerStatusSetter
    ) {
        self.queueInfoViewController = QueueInfoViewController(
            queueMetricsProvider: queueMetricsProvider,
            runningQueue: runningQueue,
            workerStatusSetter: workerStatusSetter
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
