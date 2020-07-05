import AppKit
import SnapKit

public final class HighlightableTextFieldWrapper: NSControl {
    public let textField: NSTextField
    
    public let defaultColor = NSColor.textColor
    public let highlightedColor = NSColor.white
    
    public init(textField: NSTextField) {
        self.textField = textField
        
        super.init(frame: textField.bounds)
        
        addSubview(textField)
    }
    
    public override func updateConstraints() {
        textField.snp.updateConstraints { make in
            make.top.left.bottom.right.equalToSuperview()
        }
        super.updateConstraints()
    }
    
    public override var intrinsicContentSize: NSSize { textField.intrinsicContentSize }
    
    public override var baselineOffsetFromBottom: CGFloat { textField.baselineOffsetFromBottom }
    
    public override var lastBaselineOffsetFromBottom: CGFloat { textField.lastBaselineOffsetFromBottom }
    
    public override var firstBaselineOffsetFromTop: CGFloat { textField.firstBaselineOffsetFromTop }
    
    public override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                textField.textColor = highlightedColor
            } else {
                textField.textColor = defaultColor
            }
        }
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
