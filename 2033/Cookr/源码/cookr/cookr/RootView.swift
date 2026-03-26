import SwiftUI

// RootView is no longer needed - logic moved to CookrApp.swift
// Kept for preview compatibility
@available(iOS 14.0, *)
struct RootView: View {
    @AppStorage("hasAgreedToTerms") private var hasAgreed: Bool = false

    var body: some View {
        if hasAgreed {
            if #available(iOS 15.0, *) {
                MainTabView()
            } else {
                // Fallback on earlier versions
            }
        } else {
            AgreementView(onAgree: {
                hasAgreed = true
            })
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 14.0, *) {
            RootView()
        } else {
            // Fallback on earlier versions
        }
    }
}
