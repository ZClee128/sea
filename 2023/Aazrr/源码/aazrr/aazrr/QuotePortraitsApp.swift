import SwiftUI

@available(iOS 14.0, *)
struct QuotePortraitsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            AppContainerView()
        }
    }
}

// Global container to handle UserDefaults updates more cleanly
struct AppContainerView: View {
    @State private var hasAgreed: Bool = UserDefaults.standard.bool(forKey: "HasAgreedToTerms")
    
    var body: some View {
        Group {
            if hasAgreed {
                MainTabView()
            } else {
                AgreementViewWrapper(hasAgreed: $hasAgreed)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
            self.hasAgreed = UserDefaults.standard.bool(forKey: "HasAgreedToTerms")
        }
    }
}

struct AgreementViewWrapper: View {
    @Binding var hasAgreed: Bool
    
    var body: some View {
        AgreementView(hasAgreed: $hasAgreed)
    }
}
