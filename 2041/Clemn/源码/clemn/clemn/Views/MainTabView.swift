import SwiftUI

@available(iOS 14.0, *)
struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            GalleryView()
                .tabItem {
                    Image(systemName: "square.grid.2x2")
                    Text("Reference")
                }
                .tag(0)
            
            AudioPlayerView()
                .tabItem {
                    Image(systemName: "waveform.path.ecg")
                    Text("Studio")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
                .tag(2)
        }
        .accentColor(.blue)
    }
}
