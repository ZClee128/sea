import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Appearance")) {
                    VStack(alignment: .leading) {
                        Text("Reading Font Size")
                        Slider(value: $settings.fontSizeMultiplier, in: 0.8...1.5, step: 0.1)
                        Text("Preview Text: A swift fox jumps.")
                            .font(.system(size: 16 * settings.fontSizeMultiplier))
                            .padding(.top, 4)
                    }
                    .padding(.vertical, 8)
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
                    NavigationLink(destination: AgreementView(hasAgreed: .constant(true))) {
                        Text("Terms of Service")
                    }
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.1.0")
                            .foregroundColor(.gray)
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Settings")
        }
    }
}
