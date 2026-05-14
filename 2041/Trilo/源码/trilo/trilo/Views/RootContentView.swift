import SwiftUI

struct RootContentView: View {
    @State private var hasAgreed = UserDefaults.standard.bool(forKey: "hasAgreedToPrivacy")
    
    var body: some View {
        Group {
            if hasAgreed {
                if #available(iOS 14.0, *) {
                    MainTabView()
                } else {
                    // Fallback on earlier versions
                }
            } else {
                PrivacyView {
                    hasAgreed = true
                    UserDefaults.standard.set(true, forKey: "hasAgreedToPrivacy")
                }
            }
        }
    }
}
