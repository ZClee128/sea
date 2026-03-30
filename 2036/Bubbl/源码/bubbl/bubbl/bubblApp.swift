import UIKit
import SwiftUI
import Combine
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Configure audio session to support background playback
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AVAudioSession setup failed: \(error)")
        }
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIHostingController(rootView: RootView())
        window.overrideUserInterfaceStyle = .light
        
        self.window = window
        window.makeKeyAndVisible()
        
        return true
    }
}

// iOS 13 compatible UserDefaults publisher to act as @AppStorage
class PrivacyManager: ObservableObject {
    static let shared = PrivacyManager()
    private let key = "hasAgreedToPrivacy"
    
    @Published var hasAgreed: Bool {
        didSet {
            UserDefaults.standard.set(hasAgreed, forKey: key)
        }
    }
    
    init() {
        self.hasAgreed = UserDefaults.standard.bool(forKey: key)
    }
    
    func agree() {
        hasAgreed = true
    }
}

// iOS 13 compatible Settings manager
class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    private let bgKey = "allowBackgroundPlayback"
    private let favKey = "favoriteDancerTitles"
    private let coinsKey = "coinBalance"
    private let unlockedKey = "unlockedDancerTitles"
    
    @Published var allowBackgroundPlayback: Bool {
        didSet { UserDefaults.standard.set(allowBackgroundPlayback, forKey: bgKey) }
    }
    
    @Published var favoriteDancerTitles: [String] {
        didSet { UserDefaults.standard.set(favoriteDancerTitles, forKey: favKey) }
    }
    
    @Published var coinBalance: Int {
        didSet { UserDefaults.standard.set(coinBalance, forKey: coinsKey) }
    }
    
    @Published var unlockedDancerTitles: [String] {
        didSet { UserDefaults.standard.set(unlockedDancerTitles, forKey: unlockedKey) }
    }
    
    init() {
        self.allowBackgroundPlayback = UserDefaults.standard.bool(forKey: bgKey)
        self.favoriteDancerTitles = UserDefaults.standard.stringArray(forKey: favKey) ?? []
        self.coinBalance = UserDefaults.standard.integer(forKey: coinsKey)
        self.unlockedDancerTitles = UserDefaults.standard.stringArray(forKey: unlockedKey) ?? []
    }
    
    func unlockDancer(_ title: String) {
        if !unlockedDancerTitles.contains(title) {
            unlockedDancerTitles.append(title)
        }
    }
    
    func isUnlocked(_ title: String) -> Bool {
        unlockedDancerTitles.contains(title)
    }
    
    func isFavorite(_ title: String) -> Bool {
        favoriteDancerTitles.contains(title)
    }
    
    func toggleFavorite(_ title: String) {
        if let index = favoriteDancerTitles.firstIndex(of: title) {
            favoriteDancerTitles.remove(at: index)
        } else {
            favoriteDancerTitles.append(title)
        }
    }
}

// The root switcher
struct RootView: View {
    @ObservedObject var privacyManager = PrivacyManager.shared
    
    var body: some View {
        if privacyManager.hasAgreed {
            MainTabView()
        } else {
            PrivacyPolicyView(privacyManager: privacyManager)
        }
    }
}
