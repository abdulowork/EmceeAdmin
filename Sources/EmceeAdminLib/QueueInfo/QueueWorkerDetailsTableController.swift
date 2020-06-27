import AppKit
import EasyAppKit
import Models
import WorkerAlivenessModels

public final class QueueWorkerDetailsTableController: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    public var workerAlivenesses: [WorkerId: WorkerAliveness] = [:]
    
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
        
        func createTableColumn() -> NSTableColumn {
            NSTableColumn.create(identifier: identifier, title: title)
        }
    }
    
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
    
    public func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard let tableColumn = tableColumn else { return nil }
        
        let workerInfo = alivenesses[row]
        
        switch tableColumn.identifier {
        case TableColumnIds.workerId.identifier:
            return workerInfo.workerId.value
        case TableColumnIds.isRegistered.identifier:
            return workerInfo.aliveness.registered ? "Registered" : "Not Registered"
        case TableColumnIds.isAlive.identifier:
            return workerInfo.aliveness.alive ? "Alive" : "Silent"
        case TableColumnIds.isEnabled.identifier:
            return workerInfo.aliveness.enabled ? "Enabled" : "Disabled"
        default:
            fatalError("Unknown table column \(tableColumn.identifier)")
        }
    }
}
