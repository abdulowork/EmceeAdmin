import AppKit

public extension NSTextField {
    static func create(
        text: String? = nil,
        alignment: NSTextAlignment = .natural,
        font: NSFont = .labelFont(ofSize: NSFont.systemFontSize)
    ) -> NSTextField {
        let field = NSTextField(labelWithString: text ?? "")
        field.alignment = alignment
        field.font = font
        return field
    }
    
    func ext_setText(_ text: String?) {
        stringValue = text ?? ""
    }
}
