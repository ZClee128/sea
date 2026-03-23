import SwiftUI

struct RootView: View {
    @State private var hasAgreed: Bool = UserDefaults.standard.bool(forKey: "hasAgreedToTerms")
    @ObservedObject var settings = UserSettings()

    var body: some View {
        Group {
            if hasAgreed {
                MainTabView()
                    .environmentObject(settings)
            } else {
                AgreementView(hasAgreed: $hasAgreed)
            }
        }
    }
}
