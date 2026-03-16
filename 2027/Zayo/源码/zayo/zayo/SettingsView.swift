import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var storeManager: StoreManager
    @EnvironmentObject var coinManager: CoinManager
    @State private var showingStore = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Premium")) {
                    Button(action: {
                        self.showingStore = true
                    }) {
                        HStack {
                            Image(systemName: "star.circle.fill")
                                .foregroundColor(.yellow)
                            Text("Premium Store")
                                .foregroundColor(.black)
                            Spacer()
                            Text("\(coinManager.balance) Coins")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section(header: Text("General")) {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        Text("About Zayo")
                        Spacer()
                        Text("v1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    NavigationLink(destination: VisionView()) {
                        HStack {
                            Image(systemName: "person.2")
                                .foregroundColor(.orange)
                            Text("Our Vision")
                        }
                    }
                }
                
                Section(header: Text("Legal")) {
                    NavigationLink(destination: TermsOfServiceView()) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.gray)
                            Text("Terms of Service")
                        }
                    }
                    
                    NavigationLink(destination: PrivacyPolicyView()) {
                        HStack {
                            Image(systemName: "shield")
                                .foregroundColor(.green)
                            Text("Privacy Policy")
                        }
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Settings")
        }
        .sheet(isPresented: $showingStore) {
            StoreView()
                .environmentObject(self.storeManager)
                .environmentObject(self.coinManager)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
