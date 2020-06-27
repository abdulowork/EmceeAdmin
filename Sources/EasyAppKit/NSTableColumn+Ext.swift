import AppKit

public extension NSTableColumn {
    static func create(
        identifier: NSUserInterfaceItemIdentifier,
        title: String = "",
        editable: Bool = false
    ) -> NSTableColumn {
        let column = NSTableColumn(identifier: identifier)
        column.title = title
        column.isEditable = editable
        return column
    }
}
