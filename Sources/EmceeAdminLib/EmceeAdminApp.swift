import AppKit
import EasyAppKit
import Logging
import RequestSender
import RemotePortDeterminer

public final class EmceeAdminApp: MainMenuProvider {
    public init() {
        GlobalLoggerConfig.loggerHandler = FileHandleLoggerHandler(
            fileHandle: .standardOutput,
            verbosity: .always,
            logEntryTextFormatter: NSLogLikeLogEntryTextFormatter(),
            supportsAnsiColors: false,
            fileHandleShouldBeClosed: false
        )
    }
    
    public func run() {
        let delegate = AppDelegate()
        let applicationLauncher = ApplicationLauncher(delegate: delegate, mainMenuProvider: self)
        applicationLauncher.run()
    }
    
    public func populate(applicationSubmenu: NSMenu) {
        applicationSubmenu.add(
            items: [
                .with(title: "Quit", key: "q", enabled: true, action: { NSApp.terminate(nil) })
            ]
        )
    }
    
    public func additionalSubmenus() -> [NSMenuItem] {
        []
    }
}
