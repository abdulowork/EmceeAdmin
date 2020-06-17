import AppKit
import EasyAppKit
import Logging
import RequestSender
import RemotePortDeterminer

public final class EmceeAdminApp {
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
        let applicationLauncher = ApplicationLauncher(delegate: delegate)
        applicationLauncher.run()
    }
}
