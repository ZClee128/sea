import SwiftUI

@available(iOS 15.0, *)
struct RootView: View {
    @ObservedObject var privacyManager: PrivacyManager
    @ObservedObject var appSettings: AppSettings

    var body: some View {
        Group {
            if privacyManager.isAgreed {
                MainTabView()
                    .environmentObject(privacyManager)
                    .environmentObject(appSettings)
            } else {
                PrivacyView(privacyManager: privacyManager)
                    .environmentObject(privacyManager)
            }
        }
        .animation(.default, value: privacyManager.isAgreed)
    }
}

