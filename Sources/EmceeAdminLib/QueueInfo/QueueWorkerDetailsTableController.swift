import AppKit
import EasyAppKit
import Models
import WorkerAlivenessModels

public final class QueueWorkerDetailsTableController: NSObject, NSTableViewDataSource, NSTableViewDelegate, NSMenuDelegate {
    public var workerAlivenesses: [WorkerId: WorkerAliveness] = [:] {
        didSet {
            updateTableViewSorting()
        }
    }
    
    public var onEnableWorkerId: (WorkerId) -> () = { _ in }
    public var onDisableWorkerId: (WorkerId) -> () = { _ in }
    public var toggleEnableness: ((enable: [WorkerId], disable: [WorkerId])) -> () = { _ in }
    
    private weak var tableView: NSTableView?
    
    public override init() {
        
    }
    
    public func prepare(tableView: NSTableView) {
        for column in tableView.tableColumns {
            tableView.removeTableColumn(column)
        }
        
        for columnId in TableColumnIds.allCases {
            tableView.addTableColumn(columnId.createTableColumn())
        }
        
        tableView.columnAutoresizingStyle = .firstColumnOnlyAutoresizingStyle
        tableView.usesAlternatingRowBackgroundColors = true
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 40
        tableView.allowsMultipleSelection = true
        
        self.tableView = tableView
        
        tableView.menu = NSMenu.create(delegate: self)
        
        updateTableViewSorting()
    }
    
    private var alivenesses: [ComplexWorkerAliveness] = []
    
    public func numberOfRows(in tableView: NSTableView) -> Int {
        workerAlivenesses.count
    }
    
    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let tableColumn = tableColumn else { return nil }
        
        let workerInfo = alivenesses[row]
        
        switch tableColumn.identifier {
        case TableColumnIds.workerId.identifier:
            return WorkerNameCellView(text: workerInfo.workerId.value)

        case TableColumnIds.status.identifier:
            let text: String
            let color: NSColor
            switch workerInfo.workerStatus {
            case .notStarted:
                text = "Not Started"
                color = redColor
            case .startedSilent:
                text = "Silent"
                color = yellowColor
            case .startedAlive:
                text = "Alive"
                color = greenColor
            }
            return StatusIndicatorCellView(color: color, text: text)
            
        case TableColumnIds.isEnabled.identifier:
            return StatusIndicatorCellView(
                color: workerInfo.enabled ? greenColor : brownColor,
                text: workerInfo.enabled ? "Enabled" : "Disabled"
            )
            
        default:
            fatalError("Unknown table column \(tableColumn.identifier)")
        }
    }
    
    public func tableView(_ tableView: NSTableView, didClick tableColumn: NSTableColumn) {
        sortingColumnId = TableColumnIds(rawValue: tableColumn.identifier.rawValue)!
    }
    
    private let blueColor = NSColor(calibratedRed: 0.105, green: 0.678, blue: 0.972, alpha: 1)
    private let brownColor = NSColor(calibratedRed: 0.675, green: 0.557, blue: 0.290, alpha: 1)
    private let greenColor = NSColor(calibratedRed: 0.196, green: 0.843, blue: 0.294, alpha: 1)
    private let redColor = NSColor(calibratedRed: 1.000, green: 0.164, blue: 0.408, alpha: 1)
    private let yellowColor = NSColor(calibratedRed: 1.0, green: 0.839, blue: 0, alpha: 1)
    
    private var sortingColumnId: TableColumnIds = .workerId {
        didSet {
            updateTableViewSorting()
        }
    }
    
    private func updateTableViewSorting() {
        alivenesses = sortingColumnId.sort(
            items: workerAlivenesses.map {
                ComplexWorkerAliveness(
                    workerId: $0.key,
                    workerStatus: $0.value.workerStatus,
                    enabled: $0.value.enabled
                )
            }
        )
        
        guard let tableView = tableView else { return }
        
        for columnId in TableColumnIds.allCases.map({ $0.identifier }) {
            let columnIndex = tableView.column(withIdentifier: columnId)
            guard columnIndex >= 0 else { continue }
            tableView.setIndicatorImage(
                columnId == sortingColumnId.identifier ? NSImage(named: "NSAscendingSortIndicator") : nil,
                in: tableView.tableColumns[columnIndex]
            )
        }
        
        tableView.reloadData()
    }
    
    // MARK: NSMenuDelegate
    
    public func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()
        
        guard let selectedRows = tableView?.selectedRowIndexes else {
            menu.cancelTrackingWithoutAnimation()
            return
        }
        
        guard let clickedRow = tableView?.clickedRow, clickedRow >= 0 else {
            menu.cancelTrackingWithoutAnimation()
            return
        }
        
        if selectedRows.contains(clickedRow) {
            let workerInfos = selectedRows.map { alivenesses[$0] }
            let workerIdsToEnable = workerInfos.filter { !$0.enabled }.map { $0.workerId }
            let workerIdsToDisable = workerInfos.filter { $0.enabled }.map { $0.workerId }
            
            menu.addItem(
                .with(title: "Toggle enableness of \(workerInfos.map { $0.workerId.value }.joined(separator: ", "))", action: { [weak self] in
                    self?.toggleEnableness((enable: workerIdsToEnable, disable: workerIdsToDisable))
                })
            )
        } else {
            let workerInfo = alivenesses[clickedRow]
            
            if workerInfo.enabled {
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
}

private struct ComplexWorkerAliveness {
    enum WorkerStatus: Int {
        case notStarted
        case startedSilent
        case startedAlive
    }
    
    let workerId: WorkerId
    let workerStatus: WorkerStatus
    let enabled: Bool
}

private enum TableColumnIds: String, CaseIterable {
    case workerId
    case status
    case isEnabled
    
    var identifier: NSUserInterfaceItemIdentifier {
        NSUserInterfaceItemIdentifier(rawValue: rawValue)
    }
    
    func sort(items: [ComplexWorkerAliveness]) -> [ComplexWorkerAliveness] {
        switch self {
        case .workerId:
            return items.sorted { (left, right) -> Bool in left.workerId < right.workerId }
        case .status:
            return items.sorted { (left, right) -> Bool in
                if left.workerStatus != right.workerStatus {
                    return left.workerStatus.rawValue < right.workerStatus.rawValue
                }
                return left.workerId < right.workerId
            }
        case .isEnabled:
            return items.sorted { (left, right) -> Bool in
                if left.enabled != right.enabled {
                    return left.enabled.traditionalIntValue < right.enabled.traditionalIntValue
                }
                return left.workerId < right.workerId
            }
        }
    }
    
    var title: String {
        switch self {
        case .workerId:
            return "Worker Id"
        case .status:
            return "Status"
        case .isEnabled:
            return "Enabled"
        }
    }
    
    var width: CGFloat {
        switch self {
        case .workerId:
            return 125
        case .status:
            return 125
        case .isEnabled:
            return 100
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

private extension WorkerAliveness {
    var workerStatus: ComplexWorkerAliveness.WorkerStatus {
        if !registered {
            return .notStarted
        }
        
        if alive {
            return .startedAlive
        } else {
            return .startedSilent
        }
    }
}
