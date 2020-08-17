import AppKit
import EasyAppKit
import Services

public final class ServiceWorkerDetailsTableController: NSObject, NSTableViewDataSource, NSTableViewDelegate, NSMenuDelegate {
    public var serviceWorkers: [ServiceWorker] = [] {
        didSet {
            updateTableViewSorting()
        }
    }
    
    private weak var tableView: NSTableView?
    
    public override init() {}
    
    public func prepare(tableView: NSTableView) {
        for column in tableView.tableColumns {
            tableView.removeTableColumn(column)
        }
        
        do {
            let workerIdColumn = NSTableColumn()
            workerIdColumn.identifier = ServiceWorkerDetailsTableController.workerNameColumnId
            tableView.addTableColumn(workerIdColumn)
        }
        
        var uniqueStateIds = Set<String>()
        
        for serviceWorker in serviceWorkers {
            for state in serviceWorker.states {
                uniqueStateIds.insert(state.id)
            }
        }
        
        for columnId in uniqueStateIds {
            let column = NSTableColumn()
            column.identifier = NSUserInterfaceItemIdentifier(columnId)
            column.title = columnId
            tableView.addTableColumn(column)
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
    
    public func numberOfRows(in tableView: NSTableView) -> Int {
        serviceWorkers.count
    }
    
    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let tableColumn = tableColumn else { return nil }
        
        let serviceWorker = serviceWorkers[row]
        
        if tableColumn.identifier == ServiceWorkerDetailsTableController.workerNameColumnId {
            return WorkerNameCellView(text: serviceWorker.name)
        } else {
            guard let state = serviceWorker.states.first(where: { $0.id == tableColumn.identifier.rawValue } ) else {
                return NSView()
            }
            
            return StatusIndicatorCellView(color: state.isPositive ? greenColor : redColor, text: state.status)
        }
    }
    
    public func tableView(_ tableView: NSTableView, didClick tableColumn: NSTableColumn) {
        sortingColumnId = tableColumn.identifier
    }
    
    private let blueColor = NSColor(calibratedRed: 0.105, green: 0.678, blue: 0.972, alpha: 1)
    private let brownColor = NSColor(calibratedRed: 0.675, green: 0.557, blue: 0.290, alpha: 1)
    private let greenColor = NSColor(calibratedRed: 0.196, green: 0.843, blue: 0.294, alpha: 1)
    private let redColor = NSColor(calibratedRed: 1.000, green: 0.164, blue: 0.408, alpha: 1)
    private let yellowColor = NSColor(calibratedRed: 1.0, green: 0.839, blue: 0, alpha: 1)
    
    private static let workerNameColumnId = NSUserInterfaceItemIdentifier("WorkerName")
    
    private var sortingColumnId: NSUserInterfaceItemIdentifier = ServiceWorkerDetailsTableController.workerNameColumnId {
        didSet {
            updateTableViewSorting()
        }
    }
    
    private func updateTableViewSorting() {
//        alivenesses = sortingColumnId.sort(
//            items: workerAlivenesses.map {
//                ComplexWorkerAliveness(
//                    workerId: $0.key,
//                    workerStatus: $0.value.workerStatus,
//                    enabled: $0.value.enabled
//                )
//            }
//        )
//
        guard let tableView = tableView else { return }
//
//        for columnId in TableColumnIds.allCases.map({ $0.identifier }) {
//            let columnIndex = tableView.column(withIdentifier: columnId)
//            guard columnIndex >= 0 else { continue }
//            tableView.setIndicatorImage(
//                columnId == sortingColumnId.identifier ? NSImage(named: "NSAscendingSortIndicator") : nil,
//                in: tableView.tableColumns[columnIndex]
//            )
//        }
//
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

        } else {

        }
    }
}
