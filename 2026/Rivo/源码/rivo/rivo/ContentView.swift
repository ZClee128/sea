import SwiftUI
import Combine

struct ContentView: View {
    @ObservedObject private var policyManager = PolicyAgreementManager()
    @ObservedObject private var storeManager = StoreManager()
    
    var body: some View {
        Group {
            if policyManager.hasAgreed {
                MainTabView()
                    .environmentObject(storeManager)
            } else {
                PolicyAgreementView(manager: policyManager)
            }
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var storeManager: StoreManager
    
    var body: some View {
        TabView {
            if #available(iOS 14.0, *) {
                MainGalleryView()
                    .tabItem {
                        Image(systemName: "photo.on.rectangle")
                        Text("Inspo")
                    }
            } else {
                // Fallback on earlier versions
            }
            
            if #available(iOS 14.0, *) {
                VideoListView()
                    .tabItem {
                        Image(systemName: "play.rectangle")
                        Text("Videos")
                    }
            } else {
                // Fallback on earlier versions
            }
            
            PracticeTimerView()
                .tabItem {
                    Image(systemName: "timer")
                    Text("Training")
                }
            
            if #available(iOS 14.0, *) {
                SettingsView()
                    .tabItem {
                        Image(systemName: "gearshape")
                        Text("Settings")
                    }
            } else {
                // Fallback on earlier versions
            }
        }
    }
}

#Preview {
    ContentView()
}
