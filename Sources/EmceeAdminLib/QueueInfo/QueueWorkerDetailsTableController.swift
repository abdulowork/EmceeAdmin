import AppKit
import EasyAppKit
import Models
import WorkerAlivenessModels

public final class QueueWorkerDetailsTableController: NSObject, NSTableViewDataSource, NSTableViewDelegate, NSMenuDelegate {
    public var workerAlivenesses: [WorkerId: WorkerAliveness] = [:] {
        didSet {
            alivenesses = sortingColumnId.sort(items: workerAlivenesses.map { (workerId: $0.key, aliveness: $0.value) })
        }
    }
    
    public var onEnableWorkerId: (WorkerId) -> () = { _ in }
    public var onDisableWorkerId: (WorkerId) -> () = { _ in }
    
    private weak var tableView: NSTableView?
    
    public override init() {
        
    }
    
    public func prepare(tableView: NSTableView) {
        for column in tableView.tableColumns {
            tableView.removeTableColumn(column)
        }
        
        configureColumns(tableView: tableView)
        
        tableView.columnAutoresizingStyle = .firstColumnOnlyAutoresizingStyle
        tableView.usesAlternatingRowBackgroundColors = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.tableView = tableView
        
        tableView.menu = NSMenu.create(delegate: self)
    }
    
    private var alivenesses: [(workerId: WorkerId, aliveness: WorkerAliveness)] = []
    
    public func numberOfRows(in tableView: NSTableView) -> Int {
        workerAlivenesses.count
    }
    
    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let tableColumn = tableColumn else { return nil }
        
        let workerInfo = alivenesses[row]
        
        switch tableColumn.identifier {
        case TableColumnIds.workerId.identifier:
            return WorkerNameCellView(text: workerInfo.workerId.value)
            
        case TableColumnIds.isRegistered.identifier:
            return StatusIndicatorCellView(
                color: workerInfo.aliveness.registered ? greenColor : blueColor,
                text: workerInfo.aliveness.registered ? "Registered" : "Not Registered"
            )
            
        case TableColumnIds.isAlive.identifier:
            return StatusIndicatorCellView(
                color: workerInfo.aliveness.alive ? greenColor : yellowColor,
                text: workerInfo.aliveness.alive ? "Alive" : "Silent"
            )
            
        case TableColumnIds.isEnabled.identifier:
            return StatusIndicatorCellView(
                color: workerInfo.aliveness.enabled ? greenColor : brownColor,
                text: workerInfo.aliveness.enabled ? "Enabled" : "Disabled"
            )
            
        default:
            fatalError("Unknown table column \(tableColumn.identifier)")
        }
    }
    
    public func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        40
    }
    
    public func tableView(_ tableView: NSTableView, didClick tableColumn: NSTableColumn) {
        sortingColumnId = TableColumnIds(rawValue: tableColumn.identifier.rawValue)!
        sortAlivenesses()
        tableView.reloadData()
    }
    
    private let blueColor = NSColor(calibratedRed: 0.105, green: 0.678, blue: 0.972, alpha: 1)
    private let greenColor = NSColor(calibratedRed: 0.196, green: 0.843, blue: 0.294, alpha: 1)
    private let yellowColor = NSColor(calibratedRed: 1.0, green: 0.839, blue: 0, alpha: 1)
    private let brownColor = NSColor(calibratedRed: 0.675, green: 0.557, blue: 0.290, alpha: 1)
    
    private func configureColumns(tableView: NSTableView) {
        let workerIdColumn = TableColumnIds.workerId.createTableColumn()
        let isRegisteredColumn = TableColumnIds.isRegistered.createTableColumn()
        let isAliveColumn = TableColumnIds.isAlive.createTableColumn()
        let isEnabledColumn = TableColumnIds.isEnabled.createTableColumn()
        
        tableView.addTableColumn(workerIdColumn)
        tableView.addTableColumn(isRegisteredColumn)
        tableView.addTableColumn(isAliveColumn)
        tableView.addTableColumn(isEnabledColumn)
        
        tableView.setIndicatorImage(NSImage(named: "NSAscendingSortIndicator"), in: workerIdColumn)
    }
    
    private var sortingColumnId: TableColumnIds = .workerId
    
    private func sortAlivenesses() {
        alivenesses = sortingColumnId.sort(items: workerAlivenesses.map { (workerId: $0.key, aliveness: $0.value) })
    }
    
    // MARK: NSMenuDelegate
    
    public func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()
        
        guard let clickedRow = tableView?.clickedRow, clickedRow >= 0 else {
            menu.cancelTrackingWithoutAnimation()
            return
        }
        
        let workerInfo = alivenesses[clickedRow]
        
        if workerInfo.aliveness.enabled {
            menu.addItem(
                .with(title: "Disable \(workerInfo.workerId.value)") { [weak self] in self?.onDisableWorkerId(workerInfo.workerId) }
            )
        } else {
            menu.addItem(
                .with(title: "Enable \(workerInfo.workerId.value)") { [weak self] in self?.onEnableWorkerId(workerInfo.workerId) }
            )
        }
    }
}

private enum TableColumnIds: String {
    case workerId
    case isRegistered
    case isAlive
    case isEnabled
    
    var identifier: NSUserInterfaceItemIdentifier {
        NSUserInterfaceItemIdentifier(rawValue: rawValue)
    }
    
    func sort(items: [(workerId: WorkerId, aliveness: WorkerAliveness)]) -> [(workerId: WorkerId, aliveness: WorkerAliveness)] {
        switch self {
        case .workerId:
            return items.sorted { (left, right) -> Bool in left.workerId < right.workerId }
        case .isRegistered:
            return items.sorted { (left, right) -> Bool in left.aliveness.registered.traditionalIntValue < right.aliveness.registered.traditionalIntValue }
        case .isAlive:
            return items.sorted { (left, right) -> Bool in left.aliveness.alive.traditionalIntValue < right.aliveness.alive.traditionalIntValue }
        case .isEnabled:
            return items.sorted { (left, right) -> Bool in left.aliveness.enabled.traditionalIntValue < right.aliveness.enabled.traditionalIntValue }
        }
    }
    
    var title: String {
        switch self {
        case .workerId:
            return "Worker Id"
        case .isRegistered:
            return "Registered"
        case .isAlive:
            return "Alive"
        case .isEnabled:
            return "Enabled"
        }
    }
    
    var width: CGFloat {
        switch self {
        case .workerId:
            return 100
        case .isRegistered:
            return 125
        case .isAlive:
            return 80
        case .isEnabled:
            return 125
        }
    }
    
    func createTableColumn() -> NSTableColumn {
        let c = NSTableColumn.create(identifier: identifier, title: title)
        c.width = width
        c.minWidth = width
        return c
    }
}

private extension Bool {
    var traditionalIntValue: Int {
        if self { return 1 } else { return 0 }
    }
}
