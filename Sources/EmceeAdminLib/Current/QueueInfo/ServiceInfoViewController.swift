import AppKit
import EasyAppKit
import Services
import SnapKit
import Timer

public final class ServiceInfoViewController: NSViewController {
    private lazy var stackView = NSStackView(views: [tableContainer.scrollView])
    
    private lazy var tableContainer = NSTableView.createTableContainer()
    
    private let autoupdateTimer = DispatchBasedTimer(repeating: .seconds(20), leeway: .seconds(1))
    
    private let service: Service
    private let serviceWorkerDetailsTableController = ServiceWorkerDetailsTableController()
    
    public init(
        service: Service
    ) {
        self.service = service
        
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
        
        self.title = [service.name, "version: " + service.version].joined(separator: ", ")
        
        stackView.orientation = .vertical
        stackView.snp.makeConstraints { maker in
            maker.top.left.bottom.right.equalToSuperview()
        }
        
        service.updateWorkers()
        serviceWorkerDetailsTableController.serviceWorkers = service.serviceWorkers
        
        serviceWorkerDetailsTableController.prepare(tableView: tableContainer.tableView)
    }
}
