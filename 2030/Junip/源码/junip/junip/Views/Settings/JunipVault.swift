import SwiftUI

@available(iOS 14.0, *)
struct JunipVault: View {
    @State private var showingMailAlert = false
    @StateObject private var coinManager = CoinManager.shared
    @State private var showingCoinStore = false
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    private var appBuild: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1.0.0"
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("WALLET")) {
                    HStack {
                        Image(systemName: "bitcoinsign.circle.fill")
                            .foregroundColor(AppTheme.primary)
                        Text("My Coins")
                        Spacer()
                        Text("\(coinManager.balance)")
                            .fontWeight(.bold)
                    }
                    
                    Button(action: { showingCoinStore = true }) {
                        Text("Top Up Coins")
                            .foregroundColor(AppTheme.primary)
                    }
                }
                
                Section(header: Text("LEGAL & PRIVACY")) {
                    NavigationLink(destination: AgreementContentView(title: "Terms of Service", fileName: "TermsOfService")) {
                        Text("Terms of Service")
                    }
                    NavigationLink(destination: AgreementContentView(title: "Privacy Policy", fileName: "PrivacyPolicy")) {
                        Text("Privacy Policy")
                    }
                }
                
                Section(header: Text("APP IDENTITY")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appVersion)
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Text("Build")
                        Spacer()
                        Text(appBuild)
                            .foregroundColor(.gray)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("Vault")
        }
        .alert(isPresented: $showingMailAlert) {
            Alert(
                title: Text("Notice"),
                message: Text("Thank you for your interest in Junip. Please reach out to our editorial team via the App Store."),
                dismissButton: .default(Text("OK"))
            )
        }
        .sheet(isPresented: $showingCoinStore) {
            CoinStoreView()
        }

    }
}

struct JunipVault_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 14.0, *) {
            JunipVault()
        }
    }
}
