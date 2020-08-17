import AppKit
import EasyAppKit
import QueueModels
import RequestSender
import TeamcityApi

public final class AppDelegate: NSObject, NSApplicationDelegate {
    lazy var emceeQueueServerStatusBarController = createStatusBarController()
    lazy var userDefaults = UserDefaults(suiteName: "ru.avito.emceeadmin")
    lazy var windowControllerHolder = WindowControllerHolder()
    
    public func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        emceeQueueServerStatusBarController.startUpdating()
    }
    
    private func createStatusBarController() -> EmceeQueueServerStatusBarController {
        return EmceeQueueServerStatusBarController(
            serviceProvider: DefaultServiceProvider(
                remotePortDeterminerProvider: DefaultRemotePortDeterminerProvider(
                    requestSenderProvider: DefaultRequestSenderProvider()
                ),
                userDefaults: userDefaults!
            ),
            windowControllerHolder: windowControllerHolder
        )
    }
}
