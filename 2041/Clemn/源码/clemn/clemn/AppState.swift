import SwiftUI
import Combine

@available(iOS 14.0, *)
class AppState: ObservableObject {
    @AppStorage("hasAgreedToPrivacy") var hasAgreedToPrivacy: Bool = false
    @Published var selectedTab: Int = 0
    
    // Version info
    let version: String = "1.0.0"
}
