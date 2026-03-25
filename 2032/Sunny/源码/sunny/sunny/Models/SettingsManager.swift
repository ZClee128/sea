import Foundation
import Combine

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    @Published var backgroundPlaybackEnabled: Bool {
        didSet {
            UserDefaults.standard.set(backgroundPlaybackEnabled, forKey: "backgroundPlaybackEnabled")
        }
    }
    
    private init() {
        if UserDefaults.standard.object(forKey: "backgroundPlaybackEnabled") == nil {
            self.backgroundPlaybackEnabled = true
        } else {
            self.backgroundPlaybackEnabled = UserDefaults.standard.bool(forKey: "backgroundPlaybackEnabled")
        }
    }
}

