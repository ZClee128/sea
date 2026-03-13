import SwiftUI
import Combine

struct ContentView: View {
    // We use @AppStorage for iOS 14+. But wait, iOS 13 requires UserDefaults manual wrapping or @SceneStorage.
    // iOS 13 does NOT have @AppStorage. We must implement a custom wrapper or use @State with UserDefaults.
    // Let's implement an ObservableObject for Settings.
    
    @ObservedObject var appState = AppState.shared
    
    var body: some View {
        Group {
            if appState.hasAgreedToEULA {
                MainTabView()
            } else {
                AgreementView()
            }
        }
    }
}

class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var hasAgreedToEULA: Bool {
        didSet {
            UserDefaults.standard.set(hasAgreedToEULA, forKey: "hasAgreedToEULA")
        }
    }
    
    @Published var coinBalance: Int {
        didSet {
            UserDefaults.standard.set(coinBalance, forKey: "user_coin_balance")
        }
    }
    
    @Published var unlockedContent: [String] {
        didSet {
            UserDefaults.standard.set(unlockedContent, forKey: "unlocked_content")
        }
    }
    
    private init() {
        self.hasAgreedToEULA = UserDefaults.standard.bool(forKey: "hasAgreedToEULA")
        self.coinBalance = UserDefaults.standard.integer(forKey: "user_coin_balance")
        self.unlockedContent = UserDefaults.standard.stringArray(forKey: "unlocked_content") ?? []
    }
}
