import AppKit

public extension NSTextField {
    static func create(
        text: String,
        alignment: NSTextAlignment = .natural
    ) -> NSTextField {
        let field = NSTextField(labelWithString: text)
        field.alignment = alignment
        return field
    }
}
