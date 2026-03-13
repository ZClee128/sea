import SwiftUI

struct SettingsView: View {
    @State private var cacheSize = "12.4 MB"
    @State private var showClearAlert = false
    @State private var activeURL: SafariURL?
    @ObservedObject var appState = AppState.shared
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("My Account")) {
                    NavigationLink(destination: StoreView()) {
                        HStack {
                            Image(systemName: "bitcoinsign.circle.fill")
                                .foregroundColor(.yellow)
                            Text("Coin Balance")
                            Spacer()
                            Text("\(appState.coinBalance)")
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section(header: Text("Storage")) {
                    HStack {
                        Text("Cache Size")
                        Spacer()
                        Text(cacheSize).foregroundColor(.secondary)
                    }
                    
                    Button(action: {
                        showClearAlert = true
                    }) {
                        Text("Clear Cache")
                            .foregroundColor(.red)
                    }
                }
                
                Section(header: Text("About & Legal")) {
                    Button(action: {
                        if let url = URL(string: "https://docs.qq.com/doc/DQkpHcmdLQWZQaVds") {
                            self.activeURL = SafariURL(url: url)
                        }
                    }) {
                        Text("Terms of Service")
                            .foregroundColor(.blue)
                    }
                    
                    Button(action: {
                        if let url = URL(string: "https://docs.qq.com/doc/DQm9jS2diZFZQV3Jx") {
                            self.activeURL = SafariURL(url: url)
                        }
                    }) {
                        Text("Privacy Policy")
                            .foregroundColor(.blue)
                    }
                    
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0 (1)")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationBarTitle("Settings")
            .alert(isPresented: $showClearAlert) {
                Alert(
                    title: Text("Clear Cache"),
                    message: Text("Are you sure you want to clear 12.4 MB of downloaded images and videos? Your saved plan will not be deleted."),
                    primaryButton: .destructive(Text("Clear")) {
                        self.cacheSize = "0.0 MB"
                    },
                    secondaryButton: .cancel()
                )
            }
            .sheet(item: $activeURL) { safariURL in
                SafariView(url: safariURL.url)
            }
        }
    }
}
