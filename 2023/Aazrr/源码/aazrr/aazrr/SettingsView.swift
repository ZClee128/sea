import SwiftUI

struct SettingsView: View {
    @State private var showPrivacy = false
    @State private var showTerms = false
    @State private var cacheCleared = false
    
    var body: some View {
        NavigationView {
            List {
                // Premium Store Section
                Section(header: Text("Account")) {
                    NavigationLink(destination: PremiumStoreView()) {
                        HStack {
                            Image(systemName: "dollarsign.circle.fill")
                                .foregroundColor(.yellow)
                                .frame(width: 30)
                            Text("Premium Store")
                                .foregroundColor(.primary)
                            Spacer()
                            Text("\(StoreManager.shared.coinBalance) coins")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section(header: Text("Legal & Terms")) {
                    Button(action: { showPrivacy = true }) {
                        HStack {
                            Image(systemName: "hand.raised.fill")
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            Text("Privacy Policy")
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Button(action: { showTerms = true }) {
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(.green)
                                .frame(width: 30)
                            Text("Terms of Service")
                                .foregroundColor(.primary)
                        }
                    }
                }
                
                Section(header: Text("App Data")) {
                    Button(action: {
                        // Mock local storage clear
                        self.cacheCleared = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            self.cacheCleared = false
                        }
                    }) {
                        HStack {
                            Image(systemName: "trash.fill")
                                .foregroundColor(.red)
                                .frame(width: 30)
                            Text(cacheCleared ? "Cache Cleared!" : "Clear Local Cache")
                                .foregroundColor(cacheCleared ? .green : .primary)
                        }
                    }
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0 (1)")
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("Compatibility")
                        Spacer()
                        Text("iOS 13.0+")
                            .foregroundColor(.gray)
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Settings")
            .sheet(isPresented: $showPrivacy) {
                LegalDocumentView(title: "Privacy Policy", filename: "PrivacyPolicy")
            }
            .sheet(isPresented: $showTerms) {
                LegalDocumentView(title: "Terms of Service", filename: "TermsOfService")
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
