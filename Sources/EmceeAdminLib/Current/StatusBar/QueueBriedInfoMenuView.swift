import AppKit
import EasyAppKit
import QueueModels
import SnapKit
import SocketModels

public final class QueueBriedInfoMenuView: NSView {
    private lazy var stackView: NSStackView = NSStackView(views: [])
    private lazy var queueAddressLabel = NSTextField.create(text: queueServerAddress.asString, font: .menuFont(ofSize: 15))
    private lazy var versionTagView = TagView(text: version.value, tintColor: version.color, font: NSFont.monospacedSystemFont(ofSize: 15, weight: .light))
    private let offset: CGFloat = 15
    
    private let queueServerAddress: SocketAddress
    private let version: Version
    
    public init(
        queueServerAddress: SocketAddress,
        version: Version
    ) {
        self.queueServerAddress = queueServerAddress
        self.version = version
        
        super.init(frame: .zero)
        
        addSubview(stackView)
        stackView.orientation = .horizontal
        stackView.addView(HighlightableTextFieldWrapper(textField: queueAddressLabel), in: .leading)
        stackView.addView(versionTagView, in: .trailing)
    }
    
    public override func updateConstraints() {
        stackView.snp.updateConstraints { make in
            make.top.left.bottom.right.equalToSuperview()
        }
        
        versionTagView.snp.updateConstraints { make in
            make.lastBaseline.equalTo(queueAddressLabel)
        }
        
        super.updateConstraints()
    }
    
    public override var intrinsicContentSize: NSSize {
        NSSize(
            width: queueAddressLabel.intrinsicContentSize.width + offset + versionTagView.intrinsicContentSize.width,
            height: 40
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension Version {
    var color: NSColor {
        if let rgbValue = UInt(value, radix: 16) {
            let red   =  CGFloat((rgbValue >> 16) & 0xff) / 255
            let green =  CGFloat((rgbValue >>  8) & 0xff) / 255
            let blue  =  CGFloat((rgbValue      ) & 0xff) / 255
            return NSColor(calibratedRed: red, green: green, blue: blue, alpha: 1.0)
        } else {
            return .black
        }
    }
}
