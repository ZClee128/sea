import SwiftUI

@available(iOS 14.0, *)
struct ProfileSettingsView: View {
    @EnvironmentObject var storageManager: StorageManager
    @State private var showingProPaywall = false
    @State private var showingClearCacheAlert = false
    @State private var cacheCleared = false
    
    var body: some View {
        NavigationView {
            List {
                // Profile Section
                Section {
                    HStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.gray)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Creative Explorer")
                                .font(.title3)
                                .fontWeight(.bold)
                            Text("Bexi Free User")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    
                    HStack {
                        VStack {
                            Text("\(storageManager.savedItems.count)")
                                .font(.headline)
                            Text("Saved")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        
                        Divider()
                        
                        VStack {
                            Text("\(storageManager.moodboards.count)")
                                .font(.headline)
                            Text("Moodboards")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical, 8)
                }
                
                // Coin Shop Section
                Section {
                    Button(action: {
                        showingProPaywall = true
                    }) {
                        HStack {
                            Image(systemName: "bitcoinsign.circle.fill")
                                .foregroundColor(.yellow)
                            Text("Buy Coins")
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            Spacer()
                            Text("\(storageManager.coins)")
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                // Settings Section
                Section(header: Text("Settings")) {
                    Button(action: {
                        showingClearCacheAlert = true
                    }) {
                        HStack {
                            Text("Clear Image Cache")
                                .foregroundColor(.primary)
                            Spacer()
                            if cacheCleared {
                                Text("0 MB")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .alert(isPresented: $showingClearCacheAlert) {
                        Alert(
                            title: Text("Clear Cache"),
                            message: Text("Are you sure you want to clear all downloaded image caches?"),
                            primaryButton: .destructive(Text("Clear")) {
                                cacheCleared = true
                                // Handled via Kingfisher ideally, or URLCache.shared.removeAllCachedResponses()
                                URLCache.shared.removeAllCachedResponses()
                            },
                            secondaryButton: .cancel()
                        )
                    }
                    
                    NavigationLink(destination: LegalDocumentView(title: "Terms of Service", content: termsOfServiceContent)) {
                        Text("Terms of Service")
                            .foregroundColor(.primary)
                    }
                    
                    NavigationLink(destination: LegalDocumentView(title: "Privacy Policy", content: privacyPolicyContent)) {
                        Text("Privacy Policy")
                            .foregroundColor(.primary)
                    }
                }
                
                Section {
                    HStack {
                        Spacer()
                        Text("Bexi Version 1.0.0")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
                .listRowBackground(Color.clear)
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Profile")
            .sheet(isPresented: $showingProPaywall) {
                BexiProPaywallView()
            }
        }
    }
}

#Preview {
    if #available(iOS 14.0, *) {
        ProfileSettingsView()
            .environmentObject(StorageManager())
    } else {
        // Fallback on earlier versions
    }
}

