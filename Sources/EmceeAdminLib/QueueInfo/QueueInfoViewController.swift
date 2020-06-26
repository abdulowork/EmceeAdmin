import AppKit
import EasyAppKit
import SnapKit

public final class QueueInfoViewController: NSViewController {
    lazy var stackView = NSStackView(views: [gridView, tableContainer.scrollView])
    lazy var gridView = NSGridView(views: createGridViewContents())
    lazy var tableContainer = NSTableView.createTableContainer()
    
    public override func loadView() {
        stackView.orientation = .vertical
        
        gridView.columnSpacing = 10
        gridView.rowSpacing = 10
        gridView.rowAlignment = .lastBaseline
        
        gridView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        view = NSView(frame: NSRect(x: 0, y: 0, width: 640, height: 480))
        view.addSubview(stackView)
        
        stackView.snp.makeConstraints { maker in
            maker.top.left.bottom.right.equalToSuperview()
        }
    }
    
    private func createGridViewContents() -> [[NSView]] {
        [
            [NSGridCell.emptyContentView],
            [NSGridCell.emptyContentView, NSTextField.create(text: "Queue Address:", alignment: .right), NSTextField(labelWithString: "example.dermo:41002"), NSGridCell.emptyContentView],
            [NSGridCell.emptyContentView, NSTextField.create(text: "Version:", alignment: .right), NSTextField(labelWithString: "tratata223"), NSGridCell.emptyContentView],
            [NSGridCell.emptyContentView],
        ]
    }
}
