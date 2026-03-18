import SwiftUI

struct ContentView: View {
    @ObservedObject var agreementManager = AgreementManager.shared
    
    var body: some View {
        if agreementManager.hasAgreed {
            MainTabView()
        } else {
            AgreementView()
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            MainGalleryView()
                .tabItem {
                    Image(systemName: "photo.fill.on.rectangle.fill")
                    Text("Gallery")
                }
            
            ScratchpadView()
                .tabItem {
                    Image(systemName: "pencil")
                    Text("Scratchpad")
                }
                
            PracticeModeView()
                .tabItem {
                    Image(systemName: "timer")
                    Text("Practice")
                }
            
            NavigationView {
                SettingsView()
            }
            .tabItem {
                Image(systemName: "gearshape.fill")
                Text("Settings")
            }
        }
        .accentColor(.blue)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
