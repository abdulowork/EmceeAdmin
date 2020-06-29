import AppKit
import EasyAppKit
import Models
import WorkerAlivenessModels

public final class QueueWorkerDetailsTableController: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    public var workerAlivenesses: [WorkerId: WorkerAliveness] = [:]
    
    public override init() {
        
    }
    
    public func prepare(tableView: NSTableView) {
        for column in tableView.tableColumns {
            tableView.removeTableColumn(column)
        }
        
        tableView.addTableColumn(TableColumnIds.workerId.createTableColumn())
        tableView.addTableColumn(TableColumnIds.isRegistered.createTableColumn())
        tableView.addTableColumn(TableColumnIds.isAlive.createTableColumn())
        tableView.addTableColumn(TableColumnIds.isEnabled.createTableColumn())
        
        tableView.columnAutoresizingStyle = .firstColumnOnlyAutoresizingStyle
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private var alivenesses: [(workerId: WorkerId, aliveness: WorkerAliveness)] {
        let alivenesses = workerAlivenesses.sorted {
            $0.key.value < $1.key.value
        }
        return alivenesses.map { (workerId: $0.key, aliveness: $0.value) }
    }
    
    public func numberOfRows(in tableView: NSTableView) -> Int {
        workerAlivenesses.count
    }
    
    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let tableColumn = tableColumn else { return nil }
        
        let workerInfo = alivenesses[row]
        
        switch tableColumn.identifier {
        case TableColumnIds.workerId.identifier:
            return NSTextField.create(text: workerInfo.workerId.value)
            
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
    
    private let blueColor = NSColor(calibratedRed: 0.105, green: 0.678, blue: 0.972, alpha: 1)
    private let greenColor = NSColor(calibratedRed: 0.196, green: 0.843, blue: 0.294, alpha: 1)
    private let yellowColor = NSColor(calibratedRed: 1.0, green: 0.839, blue: 0, alpha: 1)
    private let brownColor = NSColor(calibratedRed: 0.675, green: 0.557, blue: 0.290, alpha: 1)
}

private enum TableColumnIds: String {
    case workerId
    case isRegistered
    case isAlive
    case isEnabled
    
    var identifier: NSUserInterfaceItemIdentifier {
        NSUserInterfaceItemIdentifier(rawValue: rawValue)
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
        return c
    }
}
