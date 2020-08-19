import AppKit
import EasyAppKit
import QueueModels
import Services
import SnapKit
import SocketModels

public final class ServiceBriefInfoMenuView: NSView {
    private lazy var nameLabel = NSTextField.create(text: service.name, font: .menuFont(ofSize: 15))
    private lazy var stackView: NSStackView = NSStackView(views: [])
    private lazy var addressView = TagView(text: service.socketAddress.asString, tintColor: NSColor(red: 0.298, green: 0.240, blue: 0.314, alpha: 1), font: NSFont.monospacedSystemFont(ofSize: 12, weight: .light))
    private lazy var versionTagView = TagView(text: service.version, tintColor: service.color, font: NSFont.monospacedSystemFont(ofSize: 12, weight: .light))
    private let offset: CGFloat = 15
    private let service: Service
    
    public init(
        service: Service
    ) {
        self.service = service
        
        super.init(frame: .zero)
        
        addSubview(stackView)
        stackView.orientation = .horizontal
        stackView.addView(HighlightableTextFieldWrapper(textField: nameLabel), in: .leading)
        stackView.addView(addressView, in: .trailing)
        stackView.addView(versionTagView, in: .trailing)
    }
    
    public override func updateConstraints() {
        stackView.snp.updateConstraints { make in
            make.top.left.bottom.right.equalToSuperview()
        }
        
        versionTagView.snp.updateConstraints { make in
            make.lastBaseline.equalTo(nameLabel)
        }
        
        super.updateConstraints()
    }
    
    public override var intrinsicContentSize: NSSize {
        NSSize(
            width: nameLabel.intrinsicContentSize.width + offset + versionTagView.intrinsicContentSize.width,
            height: 40
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
