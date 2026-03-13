import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            PosesFeedView()
                .tabItem {
                    Image(systemName: "photo.on.rectangle")
                    Text("Poses")
                }
            
            ClassesView()
                .tabItem {
                    Image(systemName: "play.rectangle")
                    Text("Classes")
                }
            
            MyPlanView()
                .tabItem {
                    Image(systemName: "star.square")
                    Text("My Plan")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .accentColor(.blue)
    }
}
