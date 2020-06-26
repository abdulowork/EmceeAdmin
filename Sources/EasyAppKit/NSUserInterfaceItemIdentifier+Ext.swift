import AppKit

public extension NSUserInterfaceItemIdentifier {
    static func with(_ value: String) -> NSUserInterfaceItemIdentifier {
        NSUserInterfaceItemIdentifier(rawValue: value)
    }
}
