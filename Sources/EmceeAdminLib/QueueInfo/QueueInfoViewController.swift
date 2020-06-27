import AppKit
import EasyAppKit
import Models
import SnapKit

public final class QueueInfoViewController: NSViewController {
    private lazy var stackView = NSStackView(views: [gridView, tableContainer.scrollView])
    
    // Grig View Shit
    private lazy var gridView = NSGridView(views: createGridViewContents())
    private lazy var queueAddressLabel = NSTextField.create(text: runningQueue.socketAddress.asString)
    private lazy var queueVersionLabel = NSTextField.create(text: runningQueue.version.value)
    private lazy var queueStartTimestampLabel = NSTextField.create(text: "-")
    private lazy var queueLogsPathLabel = NSTextField.create(text: "-")
    
    private lazy var tableContainer = NSTableView.createTableContainer()
    
    private let runningQueue: RunningQueue
    private let queueMetricsProvider: QueueMetricsProvider
    
    public init(
        runningQueue: RunningQueue,
        queueMetricsProvider: QueueMetricsProvider
    ) {
        self.runningQueue = runningQueue
        self.queueMetricsProvider = queueMetricsProvider
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 640, height: 480))
        view.addSubview(stackView)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        gridView.columnSpacing = 10
        gridView.rowSpacing = 10
        gridView.rowAlignment = .lastBaseline
        gridView.column(at: 0).leadingPadding = 10
        gridView.column(at: gridView.numberOfColumns - 1).trailingPadding = 10
        gridView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        stackView.orientation = .vertical
        stackView.snp.makeConstraints { maker in
            maker.top.left.bottom.right.equalToSuperview()
        }
        
        fetchValues()
    }
    
    private func createGridViewContents() -> [[NSView]] {
        [
            [NSGridCell.emptyContentView],
            [NSTextField.create(text: "Queue Address:", alignment: .right), queueAddressLabel],
            [NSTextField.create(text: "Version:", alignment: .right), queueVersionLabel],
            [NSTextField.create(text: "Started At:", alignment: .right), queueStartTimestampLabel],
            [NSTextField.create(text: "Logs Path:", alignment: .right), queueLogsPathLabel, NSButton.create(title: "Copy", bezelStyle: .inline, target: self, action: #selector(copyPathToLog))],
            [NSGridCell.emptyContentView],
        ]
    }
    
    private func fetchValues() {
        queueMetricsProvider.staticQueueMetrics(queueSocketAddress: runningQueue.socketAddress, callbackQueue: DispatchQueue.main) { result in
            if let staticMetrics = try? result.get() {
                self.queueStartTimestampLabel.ext_setText(staticMetrics.startedAt.description)
                self.queueLogsPathLabel.ext_setText(staticMetrics.hostLogsPath)
            }
        }
    }
    
    @objc private func copyPathToLog() {
        
    }
}
