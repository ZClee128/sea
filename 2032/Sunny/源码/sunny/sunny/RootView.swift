import SwiftUI

struct RootView: View {
    @State private var hasAgreedToTerms = UserDefaults.standard.bool(forKey: "hasAgreedToTerms")
    
    var body: some View {
        Group {
            if hasAgreedToTerms {
                MainTabView()
            } else {
                OnboardingView(onAgree: {
                    UserDefaults.standard.set(true, forKey: "hasAgreedToTerms")
                    withAnimation {
                        hasAgreedToTerms = true
                    }
                })
            }
        }
        .preferredColorScheme(.light)  // 强制Light Mode
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
