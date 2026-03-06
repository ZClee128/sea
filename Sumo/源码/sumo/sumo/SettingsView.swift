import SwiftUI

@available(iOS 15.0, *)
struct SettingsView: View {
    @EnvironmentObject var appState: AppStateManager
    @EnvironmentObject var cacheManager: CacheManager
    
    @State private var showingClearCacheAlert = false
    
    // Hardcoded version string for demo
    let appVersion = "1.0.0 (1)"
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Storage & Data")) {
                    HStack {
                        Text("Local Cache Size")
                        Spacer()
                        Text(cacheManager.cacheSizeString)
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: {
                        showingClearCacheAlert = true
                    }) {
                        Text("Clear Media Cache")
                            .foregroundColor(.red)
                    }
                    .alert(isPresented: $showingClearCacheAlert) {
                        Alert(
                            title: Text("Clear Cache"),
                            message: Text("This will remove locally cached images and videos to free up space. Your Wardrobe saves will not be affected."),
                            primaryButton: .destructive(Text("Clear")) {
                                cacheManager.clearCache()
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
                
                Section(header: Text("Appearance")) {
                    NavigationLink(destination: EmptyView()) {
                        HStack {
                            Text("Theme")
                            Spacer()
                            Text("Auto")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section(header: Text("Privacy & Security")) {
                    NavigationLink(destination: BlockedUsersView()) {
                        Text("Blocked Users")
                    }
                }
                
                Section(header: Text("About & Policies")) {
                    Link(destination: URL(string: "https://example.com/terms")!) {
                        HStack {
                            Text("Terms of Use")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "safari")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Link(destination: URL(string: "https://example.com/privacy")!) {
                        HStack {
                            Text("Privacy Policy")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "safari")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appVersion)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
        }
    }
}
