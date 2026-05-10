import SwiftUI

@available(iOS 14.0, *)
struct SettingsView: View {
    @ObservedObject var privacyManager: PrivacyManager
    @ObservedObject var auraStore: AuraStore
    @State private var showingPrivacy = false
    @State private var showingStore = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Balance")) {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(.yellow)
                        Text("My Coins")
                        Spacer()
                        Text("\(auraStore.userCoins)")
                            .bold()
                    }
                    Button(action: {
                        showingStore = true
                    }) {
                        Text("Get More Coins")
                            .foregroundColor(.blue)
                            .bold()
                    }
                }
                
                Section(header: Text("App Information")) {
                    HStack {
                        Text("App Name")
                        Spacer()
                        Text("Mussa")
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                }
                
                Section(header: Text("Legal")) {
                    Button(action: {
                        showingPrivacy = true
                    }) {
                        HStack {
                            Text("Privacy Policy")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
//                Section(header: Text("Support")) {
//                    Text("Contact Us")
//                    Text("Clear Cache")
//                }
            }
            .listStyle(GroupedListStyle()) // Compatible with iOS 13
            .navigationTitle("Settings")
            .sheet(isPresented: $showingPrivacy) {
                PrivacyView(privacyManager: privacyManager, showAgreeButton: false)
            }
            .sheet(isPresented: $showingStore) {
                CoinStoreView(auraStore: auraStore)
            }
        }
    }
}
