import UIKit
import SwiftUI

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        print("APP LAUNCHED - didFinishLaunchingWithOptions")
        
        // For iOS 13 fallback (if running on actual iOS 13 device/simulator)
        if #available(iOS 14.0, *) {
            // Managed by SwiftUI App
        } else {
            let window = UIWindow(frame: UIScreen.main.bounds)
            let hasAgreed = UserDefaults.standard.bool(forKey: "HasAgreedToTerms")
            let rootView = RootView(hasAgreed: hasAgreed)
            window.rootViewController = UIHostingController(rootView: rootView)
            self.window = window
            window.makeKeyAndVisible()
        }
        
        return true
    }
}
