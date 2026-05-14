import SwiftUI

@available(iOS 14.0, *)
struct MainTabView: View {
    var body: some View {
        TabView {
            TimerView()
                .tabItem {
                    Image(systemName: "timer")
                    Text("Focus")
                }
            
            if #available(iOS 15.0, *) {
                MoodSelectorView()
                    .tabItem {
                        Image(systemName: "sparkles")
                        Text("Mood")
                    }
            } else {
                // Fallback on earlier versions
            }
            
            HistoryView()
                .tabItem {
                    Image(systemName: "list.bullet.rectangle")
                    Text("History")
                }
            
            if #available(iOS 15.0, *) {
                SettingsView()
                    .tabItem {
                        Image(systemName: "gearshape")
                        Text("Settings")
                    }
            } else {
                // Fallback on earlier versions
            }
        }
        .accentColor(.blue)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 14.0, *) {
            MainTabView()
        } else {
            // Fallback on earlier versions
        }
    }
}
