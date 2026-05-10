import Foundation
import Combine

class PrivacyManager: ObservableObject {
    @Published var hasAgreed: Bool {
        didSet {
            UserDefaults.standard.set(hasAgreed, forKey: "Mussa_HasAgreedToPrivacy")
        }
    }
    
    init() {
        self.hasAgreed = UserDefaults.standard.bool(forKey: "Mussa_HasAgreedToPrivacy")
    }
    
    func getPrivacyPolicy() -> String {
        guard let path = Bundle.main.path(forResource: "PrivacyPolicy", ofType: "txt"),
              let content = try? String(contentsOfFile: path, encoding: .utf8) else {
            return "Unable to load Privacy Policy. Please contact support."
        }
        return content
    }
}
