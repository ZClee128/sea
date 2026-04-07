import SwiftUI
import Combine

class AppSettings: ObservableObject {
    @Published var isBackgroundPlaybackEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isBackgroundPlaybackEnabled, forKey: "isBackgroundPlaybackEnabled")
        }
    }
    
    init() {
        // Default to false for privacy/battery, unless previously set
        if UserDefaults.standard.object(forKey: "isBackgroundPlaybackEnabled") == nil {
            self.isBackgroundPlaybackEnabled = false
        } else {
            self.isBackgroundPlaybackEnabled = UserDefaults.standard.bool(forKey: "isBackgroundPlaybackEnabled")
        }
    }
}
