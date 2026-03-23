import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: UserSettings
    @ObservedObject var iap = IAPManager.shared
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Account & Store")) {
                    HStack {
                        Image(systemName: "bitcoinsign.circle.fill")
                            .foregroundColor(.yellow)
                        Text("Coin Balance")
                        Spacer()
                        Text("\(iap.coins)")
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    
                    NavigationLink(destination: StoreView()) {
                        Text("Get More Coins")
                            .foregroundColor(.blue)
                    }
                }
                
                Section(header: Text("Video Settings")) {
                    Toggle(isOn: $settings.backgroundAudioLoop) {
                        Text("Background Audio Loop")
                    }
                }
                
                Section(header: Text("Activity")) {
                    NavigationLink(destination: HistoryView()) {
                        Text("Recently Viewed")
                    }
                    Button(action: {
                        UserDefaults.standard.removeObject(forKey: "FavoritePosts")
                    }) {
                        Text("Clear Bookmarks")
                            .foregroundColor(.red)
                    }
                }
                
                Section(header: Text("Legal & About")) {
                    NavigationLink(destination: DocumentView(filename: "Agreement", title: "Terms of Service")) {
                        Text("Terms of Service")
                    }
                    NavigationLink(destination: DocumentView(filename: "Privacy", title: "Privacy Policy")) {
                        Text("Privacy Policy")
                    }
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0") (\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"))")
                            .foregroundColor(.gray)
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Settings")
        }
    }
}
