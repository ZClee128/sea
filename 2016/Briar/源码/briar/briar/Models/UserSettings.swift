import Foundation
import SwiftUI
import Combine

class UserSettings: ObservableObject {
    @Published var fontSizeMultiplier: CGFloat {
        didSet {
            UserDefaults.standard.set(fontSizeMultiplier, forKey: "fontSizeMultiplier")
        }
    }
    
    @Published var backgroundAudioLoop: Bool {
        didSet {
            UserDefaults.standard.set(backgroundAudioLoop, forKey: "backgroundAudioLoop")
        }
    }
    
    init() {
        let size = UserDefaults.standard.object(forKey: "fontSizeMultiplier") as? CGFloat
        self.fontSizeMultiplier = size ?? 1.0
        
        let shouldLoop = UserDefaults.standard.object(forKey: "backgroundAudioLoop") as? Bool
        self.backgroundAudioLoop = shouldLoop ?? true
    }
}
