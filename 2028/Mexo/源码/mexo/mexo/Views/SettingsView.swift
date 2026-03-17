import SwiftUI

@available(iOS 14.0, *)
struct SettingsView: View {
    @State private var showingTerms = false
    @State private var showingPrivacy = false
    @State private var showingStore = false
    @State private var cacheCleared = false
    @StateObject private var storeManager = StoreManager.shared
    
    var body: some View {
        NavigationView {
            if #available(iOS 14.0, *) {
                Form {
                    Section(header: Text("Account & Balance")) {
                        HStack {
                            Label {
                                Text("Coin Balance")
                            } icon: {
                                Image(systemName: "bitcoinsign.circle.fill")
                                    .foregroundColor(.orange)
                            }
                            Spacer()
                            Text("\(storeManager.coins)")
                                .fontWeight(.bold)
                        }
                        
                        Button(action: { showingStore = true }) {
                            HStack {
                                Label("Premium Store", systemImage: "star.fill")
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                    }

                    Section(header: Text("Legal & Information")) {
                        Button(action: { showingTerms = true }) {
                            HStack {
                                Text("Terms of Service")
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Button(action: { showingPrivacy = true }) {
                            HStack {
                                Text("Privacy Policy")
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    Section(header: Text("Data Management"), footer: Text("Clearing cache will remove downloaded images but keep your saved favorites list intact.")) {
                        Button(action: {
                            clearCache()
                        }) {
                            HStack {
                                Text(cacheCleared ? "Cache Cleared" : "Clear Image Cache")
                                    .foregroundColor(cacheCleared ? .green : .red)
                                Spacer()
                                if cacheCleared {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                        .disabled(cacheCleared)
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
                .navigationTitle("Settings")
                .sheet(isPresented: $showingTerms) {
                    DocumentView(title: "Terms of Service", content: StoreManager.termsOfService)
                }
                .sheet(isPresented: $showingPrivacy) {
                    DocumentView(title: "Privacy Policy", content: StoreManager.privacyPolicy)
                }
                .sheet(isPresented: $showingStore) {
                    if #available(iOS 14.0, *) {
                        StoreView()
                    }
                }
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    private func clearCache() {
        // Implement SDWebImage or URLCache clear here
        URLCache.shared.removeAllCachedResponses()
        
        withAnimation {
            cacheCleared = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                cacheCleared = false
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 14.0, *) {
            SettingsView()
        } else {
            // Fallback on earlier versions
        }
    }
}
