import AppKit
import EasyAppKit
import SnapKit

public final class TagView: NSView {
    private lazy var highlightabeLabel = HighlightableTextFieldWrapper(textField: label)
    private lazy var label = NSTextField.create(text: text)
    
    public var text: String {
        didSet {
            label.stringValue = text
            needsUpdateConstraints = true
        }
    }
    
    public var borderInsets = NSEdgeInsets(top: 4, left: 4, bottom: 4, right: 4) {
        didSet { needsUpdateConstraints = true }
    }
    
    public var tintColor: NSColor = .black {
        didSet { needsDisplay = true }
    }
    
    public init(text: String, tintColor: NSColor, font: NSFont) {
        self.text = text
        self.tintColor = tintColor
        
        super.init(frame: .zero)
        
        wantsLayer = true
        label.font = font
        addSubview(highlightabeLabel)
    }
    
    public override var wantsUpdateLayer: Bool { true }
    
    public override func updateLayer() {
        super.updateLayer()
        
        layer?.cornerRadius = 2
        layer?.borderWidth = 1
        layer?.borderColor = tintColor.cgColor
        layer?.backgroundColor = tintColor.withAlphaComponent(0.2).cgColor
    }
    
    public override var intrinsicContentSize: NSSize {
        NSSize(
            width: borderInsets.left + label.intrinsicContentSize.width + borderInsets.right,
            height: borderInsets.top + label.intrinsicContentSize.height + borderInsets.bottom
        )
    }
    
    public override var baselineOffsetFromBottom: CGFloat {
        label.baselineOffsetFromBottom + borderInsets.bottom
    }
    
    public override var lastBaselineOffsetFromBottom: CGFloat {
        label.lastBaselineOffsetFromBottom + borderInsets.bottom
    }
    
    public override var firstBaselineOffsetFromTop: CGFloat {
        label.firstBaselineOffsetFromTop + borderInsets.top
    }
    
    public override func updateConstraints() {
        highlightabeLabel.snp.updateConstraints { make in
            make.top.equalToSuperview().offset(borderInsets.top)
            make.left.equalToSuperview().offset(borderInsets.left)
            make.bottom.equalToSuperview().offset(-borderInsets.bottom)
            make.right.equalToSuperview().offset(-borderInsets.right)
        }
        
        super.updateConstraints()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
