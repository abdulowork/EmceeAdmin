import AppKit
import EasyAppKit

public final class QueueInfoWindowController: NSWindowController, ContentViewControllerProviding {
    public static func createContentViewController() -> NSViewController {
        QueueInfoViewController()
    }
}
