import AppKit

public final class WorkerNameCellView: NSView {
    private let labelView = NSTextField.create()
    
    public init(text: String) {
        super.init(frame: .zero)
        addSubview(labelView)
        labelView.ext_setText(text)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var text: String {
        get { labelView.stringValue }
        set {
            labelView.stringValue = newValue
            needsUpdateConstraints = true
        }
    }
    
    public override func updateConstraints() {
        labelView.snp.updateConstraints { make in
            make.leading.equalTo(self).offset(5)
            make.trailing.equalTo(self).offset(-5)
            make.centerY.equalTo(self)
        }
        
        super.updateConstraints()
    }
}
