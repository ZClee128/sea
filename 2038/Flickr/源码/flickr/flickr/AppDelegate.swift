import UIKit
import SwiftUI
import AVFoundation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Register Defaults
        UserDefaults.standard.register(defaults: [
            "isBackgroundPlaybackEnabled": true,
            "hasAgreedToPrivacy": false
        ])
        
        // Configure Audio Session for Video Background Playback
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category: \(error.localizedDescription)")
        }
        
        // Force Light Mode
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        }
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        
        let hasAgreed = UserDefaults.standard.bool(forKey: "hasAgreedToPrivacy")
        
        if hasAgreed {
            showMainContent()
        } else {
            showPrivacyAgreement {
                self.showMainContent()
            }
        }
        
        window.makeKeyAndVisible()
        
        return true
    }
    
    func showPrivacyAgreement(onAgree: @escaping () -> Void) {
        let privacyView = PrivacyView {
            onAgree()
        }
        let hostingController = UIHostingController(rootView: privacyView)
        window?.rootViewController = hostingController
    }
    
    func showMainContent() {
        if #available(iOS 15.0, *) {
            let mainTabView = MainTabView()
            let hostingController = UIHostingController(rootView: mainTabView)
            
            // Transition effect for better UX
            UIView.transition(with: window!, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.window?.rootViewController = hostingController
            }, completion: nil)
        } else {
            // Fallback on earlier versions
        }
        
    }
}
