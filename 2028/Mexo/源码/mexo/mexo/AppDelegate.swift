import UIKit
import SwiftUI

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        // Set the root view to ContentView for now, later AgreementView
        let rootView = ContentView()
        let hostingController = UIHostingController(rootView: rootView)
        
        window.rootViewController = hostingController
        window.makeKeyAndVisible()
        self.window = window
        
        // Force Light Mode globally
        if #available(iOS 13.0, *) {
            window.overrideUserInterfaceStyle = .light
        }
        
        return true
    }
}
