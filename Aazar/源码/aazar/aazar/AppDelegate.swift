//
//  AppDelegate.swift
//  aazar
//
//  Created by zclee on 2026/3/11.
//

import UIKit
import AVFoundation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Configure AVAudioSession for background playback
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category. Error: \(error)")
        }
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        if UserDefaults.standard.bool(forKey: "hasAgreedToTerms") {
            window.rootViewController = MainTabBarController()
        } else {
            let agreementVC = AgreementViewController()
            agreementVC.onAgreed = {
                // Transition to main tab bar
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    window.rootViewController = MainTabBarController()
                }, completion: nil)
            }
            window.rootViewController = agreementVC
        }
        
        window.makeKeyAndVisible()
        return true
    }

}

