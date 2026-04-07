import UIKit
import AVFAudio
import SwiftUI

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let privacyManager = PrivacyManager()
    let appSettings = AppSettings()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Configure Global Audio Session for Background Playback
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category.")
        }

        let window = UIWindow(frame: UIScreen.main.bounds)
        if #available(iOS 15.0, *) {
            window.rootViewController = UIHostingController(rootView: RootView(privacyManager: privacyManager, appSettings: appSettings))
        } else {
            // Fallback on earlier versions
        }
        self.window = window
        window.makeKeyAndVisible()
        
        return true
    }
}

// Global entry point
@main
struct AppEntry {
    static func main() {
        UIApplicationMain(
            CommandLine.argc,
            CommandLine.unsafeArgv,
            nil,
            NSStringFromClass(AppDelegate.self)
        )
    }
}
