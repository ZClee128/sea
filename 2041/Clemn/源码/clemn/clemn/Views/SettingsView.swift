import SwiftUI

@available(iOS 14.0, *)
struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingPrivacy = false
    @State private var showingStore = false
    @ObservedObject var iapManager = IAPManager.shared
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Account & Assets")) {
                    HStack {
                        Image(systemName: "m.circle.fill")
                            .foregroundColor(.orange)
                        Text("Clemn Coins")
                        Spacer()
                        Text("\(iapManager.coins)")
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: { showingStore = true }) {
                        HStack {
                            Image(systemName: "cart.fill")
                                .foregroundColor(.blue)
                            Text("Get More Coins")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .sheet(isPresented: $showingStore) {
                        StoreView()
                    }
                }
                
                Section(header: Text("Preferences")) {
                    HStack {
                        Text("App Name")
                        Spacer()
                        Text("Clemn")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appState.version)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Legal")) {
                    Button(action: { showingPrivacy = true }) {
                        HStack {
                            Text("Privacy Policy")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section {
                    Button(action: {
                        // Reset agreement for testing purposes
                        // appState.hasAgreedToPrivacy = false
                    }) {
                        Text("Copyright © 2026 Clemn Studio")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .disabled(true)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Settings")
            .sheet(isPresented: $showingPrivacy) {
                VStack {
                    HStack {
                        Spacer()
                        Button("Close") {
                            showingPrivacy = false
                        }
                        .padding()
                    }
                    HTMLView(htmlFileName: "PrivacyPolicy")
                }
            }
        }
    }
}
