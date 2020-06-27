import AppKit

public extension NSTextField {
    static func create(
        text: String? = nil,
        alignment: NSTextAlignment = .natural
    ) -> NSTextField {
        let field = NSTextField(labelWithString: text ?? "")
        field.alignment = alignment
        return field
    }
    
    func ext_setText(_ text: String?) {
        stringValue = text ?? ""
    }
}
