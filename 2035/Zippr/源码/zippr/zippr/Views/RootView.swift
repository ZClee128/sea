import SwiftUI

@available(iOS 15.0, *)
struct RootView: View {
    @AppStorage("hasAgreedPrivacy") private var hasAgreedPrivacy: Bool = false

    var body: some View {
        Group {
            if hasAgreedPrivacy {
                MainTabView()
            } else {
                PrivacyPolicyView(hasAgreedPrivacy: $hasAgreedPrivacy)
            }
        }
        .preferredColorScheme(.light)
    }
}
