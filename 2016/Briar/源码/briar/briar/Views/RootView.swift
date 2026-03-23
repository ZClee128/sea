import SwiftUI

struct RootView: View {
    @State private var hasAgreed: Bool = UserDefaults.standard.bool(forKey: "hasAgreedToTerms")

    var body: some View {
        Group {
            if hasAgreed {
                MainTabView()
            } else {
                AgreementView(hasAgreed: $hasAgreed)
            }
        }
    }
}
