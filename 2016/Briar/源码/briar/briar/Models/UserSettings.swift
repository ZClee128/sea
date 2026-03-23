import SwiftUI

class UserSettings: ObservableObject {
    @Published var fontSizeMultiplier: CGFloat {
        didSet {
            UserDefaults.standard.set(Double(fontSizeMultiplier), forKey: "fontSizeMultiplier")
        }
    }
    
    init() {
        let saved = UserDefaults.standard.double(forKey: "fontSizeMultiplier")
        self.fontSizeMultiplier = saved == 0 ? 1.0 : CGFloat(saved)
    }
}
