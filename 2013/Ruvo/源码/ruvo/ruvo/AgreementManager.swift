import SwiftUI
import Combine

class AgreementManager: ObservableObject {
    @Published var hasAgreed: Bool {
        didSet {
            UserDefaults.standard.set(hasAgreed, forKey: "HasAgreedToEULA")
        }
    }
    
    static let shared = AgreementManager()
    
    private init() {
        self.hasAgreed = UserDefaults.standard.bool(forKey: "HasAgreedToEULA")
    }
}
