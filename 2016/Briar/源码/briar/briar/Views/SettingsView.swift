import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Legal")) {
                    NavigationLink(destination: AgreementView(hasAgreed: .constant(true))) {
                        Text("Terms of Service")
                    }
                }
                
                Section(header: Text("Data")) {
                    Button(action: {
                        UserDefaults.standard.removeObject(forKey: "FavoritePosts")
                    }) {
                        Text("Clear Bookmarks")
                            .foregroundColor(.red)
                    }
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Settings")
        }
    }
}
