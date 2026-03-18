import UIKit
import SwiftUI

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        // Check if terms are accepted
        let hasAcceptedTerms = UserDefaults.standard.bool(forKey: "revo_terms_accepted")
        
        if hasAcceptedTerms {
            window.rootViewController = UIHostingController(rootView: MainTabView())
        } else {
            window.rootViewController = UIHostingController(rootView: LegalAgreementView())
        }
        
        self.window = window
        window.makeKeyAndVisible()
        
        return true
    }

    // UISceneSession is removed to avoid black screen on some project configurations
}
