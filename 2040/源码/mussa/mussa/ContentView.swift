import SwiftUI

struct ContentView: View {
    @ObservedObject var privacyManager: PrivacyManager
    @ObservedObject var store: AuraStore
    @ObservedObject var chatManager: ChatManager
    
    var body: some View {
        Group {
            if privacyManager.hasAgreed {
                MainTabView(store: store, privacyManager: privacyManager, chatManager: chatManager)
            } else {
                PrivacyView(privacyManager: privacyManager, showAgreeButton: true)
            }
        }
        .preferredColorScheme(.light) // Force light mode
    }
}
