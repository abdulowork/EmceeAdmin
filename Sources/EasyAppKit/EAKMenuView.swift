import AppKit

open class EAKMenuView: NSView {
    private lazy var effectView: NSVisualEffectView = {
        let effectView = NSVisualEffectView(frame: bounds)
        effectView.autoresizingMask = [.width, .height]
        effectView.state = .active
        effectView.material = .selection
        effectView.isEmphasized = true
        effectView.blendingMode = .behindWindow
        effectView.isHidden = true
        return effectView
    }()
    
    public var actionable: Bool
    public var contentView: NSView {
        didSet {
            oldValue.removeFromSuperview()
            addSubview(contentView)
            needsLayout = true
        }
    }
    public var enabled: Bool = true {
        didSet {
            recursivelySetEnabledOnSubviews(enabled)
        }
    }
    public var highlightable: Bool
    public var contentInsets: NSEdgeInsets = NSEdgeInsets(top: 0, left: 19, bottom: 3, right: 19)
    
    public init(actionable: Bool, contentView: NSView, highlightable: Bool) {
        self.actionable = actionable
        self.contentView = contentView
        self.highlightable = highlightable
        
        super.init(
            frame: NSRect(
                x: 0,
                y: 0,
                width: contentView.bounds.width + contentInsets.left + contentInsets.right,
                height: contentView.bounds.height + contentInsets.top + contentInsets.bottom
            )
        )
        
        addSubview(effectView)
        addSubview(contentView)
    }
    
    public override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        
        if window == nil {
            didDisappear()
        } else {
            matchWidthToMenuWidth()
            didAppear()
            window?.becomeKey()
        }
    }

    open func didAppear() {}
    
    open func didDisappear() {}
    
    open func didStartTracking() {}
    
    open func didStopTracking() {}
    
    private func matchWidthToMenuWidth() {
        if let windowWidth = window?.frame.width {
            setFrameSize(NSSize(width: windowWidth, height: bounds.size.height))
        }
    }
    
    // MARK: - Layout
    
    open override func layout() {
        let contentRect = NSRect(
            x: contentInsets.left,
            y: contentInsets.top,
            width: bounds.width - contentInsets.left - contentInsets.right,
            height: bounds.height - contentInsets.top - contentInsets.bottom
        )
        contentView.frame = contentRect
        layoutIn(contentRect: contentRect)
    }
    
    open func layoutIn(contentRect: NSRect) {}
    
    // MARK: - Tracking
    
    private var __eak_trackingStorage = false
    private var eak_tracking: Bool {
        get { __eak_trackingStorage }
        set {
            var newValue = newValue
            if !highlightable { newValue = false }
            
            if __eak_trackingStorage != newValue {
                __eak_trackingStorage = newValue
                needsDisplay = true
                if newValue {
                    effectView.isHidden = false
                    didStartTracking()
                } else {
                    effectView.isHidden = true
                    didStopTracking()
                }
            }
        }
    }
    
    private var eak_menuTrackingArea: NSTrackingArea?
    private var eak_cancellingTracking = false
    
    open override func updateTrackingAreas() {
        super.updateTrackingAreas()
        
        if let currentTrackingArea = eak_menuTrackingArea {
            removeTrackingArea(currentTrackingArea)
        }
        
        let newTrackingArea = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: [:])
        addTrackingArea(newTrackingArea)
        eak_menuTrackingArea = newTrackingArea
    }
    
    open override func mouseEntered(with event: NSEvent) {
        if !enabled || eak_cancellingTracking { return }
        eak_tracking = true
    }
    
    open override func mouseExited(with event: NSEvent) {
        if !enabled || eak_cancellingTracking { return }
        eak_tracking = false
    }
    
    open override func mouseUp(with event: NSEvent) {
        guard actionable && enabled else { return }
        if (highlightable) {
            cancelTrackingWithAnimation()
        } else {
            cancelTrackingWithoutAnimation()
        }
    }
    
    func cancelTrackingWithAnimation() {
        eak_cancellingTracking = true
        eak_tracking = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            self.eak_tracking = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                let menuItem = self.enclosingMenuItem
                menuItem?.menu?.cancelTracking()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                    if let action = menuItem?.action {
                        NSApp.sendAction(action, to: menuItem?.target, from: menuItem)
                    }
                    
                    self.eak_tracking = false
                    self.eak_cancellingTracking = false
                }
            }
        }
    }
    
    func cancelTrackingWithoutAnimation() {
        guard let menuItem = enclosingMenuItem, let menu = menuItem.menu else {
            return
        }
        
        menu.cancelTracking()
        if let action = menuItem.action {
            NSApp.sendAction(action, to: menuItem.target, from: menuItem)
        }
    }
    
    // MARK: - Bullshit
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
