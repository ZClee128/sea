import SwiftUI

struct ZayoMainView: View {
    @EnvironmentObject var storeManager: StoreManager
    @EnvironmentObject var coinManager: CoinManager
    
    var body: some View {
        TabView {
            GalleryView()
                .tabItem {
                    Image(systemName: "photo.on.rectangle.angled")
                    Text("Gallery")
                }
            
            CinemaView()
                .tabItem {
                    Image(systemName: "film")
                    Text("Cinema")
                }
            
            WorkshopView()
                .tabItem {
                    Image(systemName: "hammer")
                    Text("Workshop")
                }
            
            StyleBoardView()
                .tabItem {
                    Image(systemName: "heart")
                    Text("Styles")
                }
            
            SettingsView()
                .environmentObject(storeManager)
                .environmentObject(coinManager)
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
        }
        .accentColor(.black)
    }
}

struct ZayoMainView_Previews: PreviewProvider {
    static var previews: some View {
        ZayoMainView()
    }
}
