import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var storeManager: StoreManager
    @State private var showingContact = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("WALLET").foregroundColor(.gray)) {
                    HStack {
                        Image(systemName: "circle.grid.hex.fill")
                            .foregroundColor(.yellow)
                        Text("My Coins")
                        Spacer()
                        Text("\(storeManager.coinBalance)")
                            .foregroundColor(.yellow)
                            .fontWeight(.bold)
                    }
                    
                    NavigationLink(destination: CoinShopView(storeManager: storeManager)) {
                        HStack {
                            Image(systemName: "cart.fill")
                                .foregroundColor(.blue)
                            Text("Top Up Coins")
                        }
                    }
                }
                
                Section(header: Text("ABOUT RIVO").foregroundColor(.gray)) {
                    NavigationLink(destination: PolicyDocumentView(title: "Privacy Policy", filename: "PrivacyPolicy")) {
                        HStack {
                            Image(systemName: "lock.shield")
                                .foregroundColor(.gray)
                            Text("Privacy Policy")
                        }
                    }
                    
                    NavigationLink(destination: PolicyDocumentView(title: "Terms of Service", filename: "TermsOfService")) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.gray)
                            Text("Terms of Service")
                        }
                    }
                    
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.gray)
                        Text("Version")
                        Spacer()
                        Text("1.0.0").foregroundColor(.gray)
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Settings")
        }
        .alert(isPresented: $showingContact) {
            Alert(title: Text("Support"), message: Text("Please contact us at support@rivoapp.example.com"), dismissButton: .default(Text("OK")))
        }
    }
}
