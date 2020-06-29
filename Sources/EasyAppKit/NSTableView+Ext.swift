import AppKit

public extension NSTableView {
    static func createTableContainer(
        borderType: NSBorderType = .noBorder,
        columns: Int = 1
    ) -> (scrollView: NSScrollView, tableView: NSTableView) {
        let scrollView = NSScrollView(frame: .zero)
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        
        let tableView = NSTableView(frame: .zero)
        for columnIndex in 0 ..< columns {
            tableView.addTableColumn(NSTableColumn(identifier: .with("column_\(columnIndex)")))
        }
        
        scrollView.borderType = borderType
        scrollView.documentView = tableView
        
        return (scrollView: scrollView, tableView: tableView)
    }
}
