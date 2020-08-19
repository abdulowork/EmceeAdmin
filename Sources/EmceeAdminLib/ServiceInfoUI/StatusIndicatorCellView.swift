import AppKit
import SnapKit
import QuartzCore

public final class StatusIndicatorCellView: NSView {
    private let indicatorView = IndicatorView()
    private let labelView = NSTextField.create()
    
    public var indicatorColor: NSColor {
        get { indicatorView.color }
        set { indicatorView.color = newValue }
    }
    
    public var backgroundColor: NSColor {
        didSet {
            needsDisplay = true
        }
    }
    
    public var indicatorSize: CGFloat = 5.0 {
        didSet { needsUpdateConstraints = true }
    }
    
    public var text: String {
        get { labelView.stringValue }
        set {
            labelView.stringValue = newValue
            needsUpdateConstraints = true
        }
    }
    
    private let indicatorToLabelOffset = 5
    
    public init(backgroundColor: NSColor, indicatorColor: NSColor, text: String) {
        self.backgroundColor = backgroundColor
        super.init(frame: .zero)
        
        wantsLayer = true
        addSubview(indicatorView)
        indicatorView.color = indicatorColor
        addSubview(labelView)
        labelView.ext_setText(text)
    }
    
    public override var wantsUpdateLayer: Bool { true }
    
    public override func updateLayer() {
        super.updateLayer()
        
        self.layer?.backgroundColor = backgroundColor.cgColor
    }
    
    public override func updateConstraints() {
        indicatorView.snp.updateConstraints { make in
            make.width.equalTo(indicatorSize)
            make.height.equalTo(indicatorSize)
            
            make.leading.equalTo(self).offset(indicatorToLabelOffset)
            make.centerY.equalTo(self)
        }
        
        labelView.snp.updateConstraints { make in
            make.leading.equalTo(indicatorView.snp.trailing).offset(text.isEmpty ? 0 : indicatorToLabelOffset)
            make.trailing.equalTo(self)
            make.centerY.equalTo(self)
        }
        
        super.updateConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class IndicatorView: NSView {
    var color: NSColor = .clear {
        didSet { needsDisplay = true }
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        self.wantsLayer = true
    }
    
    override var wantsUpdateLayer: Bool { true }
    
    override func updateLayer() {
        layer?.backgroundColor = color.cgColor
        layer?.cornerRadius = bounds.height / 2.0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
