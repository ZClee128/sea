import Foundation
import Combine

class PolicyAgreementManager: ObservableObject {
    @Published var hasAgreed: Bool {
        didSet {
            UserDefaults.standard.set(hasAgreed, forKey: "Rivo_HasAgreedToPolicy")
        }
    }
    
    init() {
        self.hasAgreed = UserDefaults.standard.bool(forKey: "Rivo_HasAgreedToPolicy")
    }
}
