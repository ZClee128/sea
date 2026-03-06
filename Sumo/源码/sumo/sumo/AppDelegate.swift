import UIKit
import SwiftUI
import AVFoundation

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // 1. Configure audio session FIRST so background audio works
        setupAudioSession()

        // 2. Create the UIWindow and embed SwiftUI root view
        let window = UIWindow(frame: UIScreen.main.bounds)
        if #available(iOS 15.0, *) {
            let rootView = SumoRootView()
            let hostingVC = UIHostingController(rootView: rootView)
            window.rootViewController = hostingVC
        }
        window.makeKeyAndVisible()
        self.window = window

        return true
    }

    // MARK: - Audio Session

    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            // .playback keeps audio alive when screen is locked or app is backgrounded
            try session.setCategory(.playback, mode: .moviePlayback, options: [.mixWithOthers])
            try session.setActive(true)
            print("[AppDelegate] AVAudioSession configured for background playback ✓")
        } catch {
            print("[AppDelegate] AVAudioSession setup failed: \(error)")
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Ensure the audio session stays alive when going to background
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Re-activate in case the system deactivated the session
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        try? AVAudioSession.sharedInstance().setActive(false)
    }
}
