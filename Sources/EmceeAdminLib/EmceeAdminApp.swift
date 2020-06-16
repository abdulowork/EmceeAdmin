import AppKit
import EasyAppKit
import Logging
import RequestSender
import RemotePortDeterminer

public final class EmceeAdminApp {
    public init() {}
    
    public func run() {
        let delegate = AppDelegate()
        let applicationLauncher = ApplicationLauncher(delegate: delegate)
        applicationLauncher.run()
    }
}
//
//GlobalLoggerConfig.loggerHandler = FileHandleLoggerHandler(
//    fileHandle: .standardOutput,
//    verbosity: .always,
//    logEntryTextFormatter: NSLogLikeLogEntryTextFormatter(),
//    supportsAnsiColors: false,
//    fileHandleShouldBeClosed: false
//)
//
//let scanner = RemoteQueuePortScanner(
//    host: "ios-build-machine72.msk.avito.ru",
//    portRange: 41000...41010,
//    requestSenderProvider: DefaultRequestSenderProvider()
//)
//
//let result = scanner.queryPortAndQueueServerVersion(timeout: 10)
//Logger.always("result = \(result)")
