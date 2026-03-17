import SwiftUI

struct SettingsView: View {
    @State private var showingTerms = false
    @State private var showingPrivacy = false
    @State private var cacheCleared = false
    
    var body: some View {
        NavigationView {
            if #available(iOS 14.0, *) {
                Form {
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
                    DocumentView(title: "Terms of Service", content: "These are the Terms of Service for Mexo.\n\nBy using this app, you agree to... [Content to be populated]")
                }
                .sheet(isPresented: $showingPrivacy) {
                    DocumentView(title: "Privacy Policy", content: "This is the Privacy Policy for Mexo.\n\nWe value your privacy and... [Content to be populated]")
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
        SettingsView()
    }
}
