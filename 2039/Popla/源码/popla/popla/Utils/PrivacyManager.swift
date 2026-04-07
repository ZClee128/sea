import Foundation
import SwiftUI
import Combine

class PrivacyManager: ObservableObject {
    @Published var isAgreed: Bool {
        didSet {
            UserDefaults.standard.set(isAgreed, forKey: "user_agreed_privacy")
        }
    }
    
    init() {
        self.isAgreed = UserDefaults.standard.bool(forKey: "user_agreed_privacy")
    }
    
    func getPrivacyContent() -> String {
        guard let path = Bundle.main.path(forResource: "PrivacyPolicy", ofType: "txt") else {
            return "Unable to find Privacy Policy file."
        }
        do {
            let content = try String(contentsOfFile: path, encoding: .utf8)
            return content
        } catch {
            return "Error reading Privacy Policy: \(error.localizedDescription)"
        }
    }
}
