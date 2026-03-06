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
                

                Section(header: Text("Privacy & Security")) {
                    NavigationLink(destination: BlockedUsersView()) {
                        Text("Blocked Users")
                    }
                }
                
                Section(header: Text("About & Policies")) {
                    NavigationLink(destination: TermsOfUseView()) {
                        Text("Terms of Use")
                    }
                    
                    NavigationLink(destination: PrivacyPolicyView()) {
                        Text("Privacy Policy")
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
