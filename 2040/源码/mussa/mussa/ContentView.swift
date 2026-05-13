import SwiftUI

struct ContentView: View {
    @ObservedObject var privacyManager: PrivacyManager
    @ObservedObject var store: AuraStore
    
    var body: some View {
        Group {
            if privacyManager.hasAgreed {
                if #available(iOS 14.0, *) {
                    MainTabView(store: store, privacyManager: privacyManager)
                } else {
                    // Fallback on earlier versions
                }
            } else {
                PrivacyView(privacyManager: privacyManager, showAgreeButton: true)
            }
        }
        .preferredColorScheme(.light)
        .environmentObject(AudioManager.shared)
    }
}
