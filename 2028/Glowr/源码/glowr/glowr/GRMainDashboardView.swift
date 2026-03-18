import SwiftUI

struct GRMainDashboardView: View {
    var body: some View {
        TabView {
            GRDiscoverGalleryView()
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Models")
                }
            
            GRReelsDisplayView()
                .tabItem {
                    Image(systemName: "play.rectangle.fill")
                    Text("Reels")
                }
            
            GRFavoritesHubView()
                .tabItem {
                    Image(systemName: "heart.text.square.fill")
                    Text("Collection")
                }
            
            GRTalentStudioView()
                .tabItem {
                    Image(systemName: "metronome.fill")
                    Text("Studio")
                }
            
            if #available(iOS 14.0, *) {
                GRSettingsPanelView()
                    .tabItem {
                        Image(systemName: "gearshape.fill")
                        Text("Settings")
                    }
            } else {
                // Fallback on earlier versions
            }
        }
        .accentColor(.black)
        .preferredColorScheme(.light)
    }
}

struct GRMainDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        GRMainDashboardView()
    }
}
