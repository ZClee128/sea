import SwiftUI

@available(iOS 14.0, *)
struct RootView: View {
    @EnvironmentObject var storageManager: StorageManager
    
    var body: some View {
        ZStack {
            // Always render ContentView so TabView and NavigationViews calculate their safe areas correctly on launch
            ContentView()
            
            if !storageManager.hasAcceptedTerms {
                TermsView()
                    .background(Color(UIColor.systemBackground).ignoresSafeArea())
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .animation(.default, value: storageManager.hasAcceptedTerms)
    }
}

#Preview {
    if #available(iOS 14.0, *) {
        RootView()
            .environmentObject(StorageManager())
    } else {
        // Fallback on earlier versions
    }
}
