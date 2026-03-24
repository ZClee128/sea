import SwiftUI
import Combine

@available(iOS 14.0, *)
struct SettingsView: View {
    @ObservedObject var storeManager = StoreManager.shared
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Account & Wallet")) {
                    NavigationLink(destination: StoreView()) {
                        HStack {
                            Image(systemName: "bitcoinsign.circle.fill")
                                .foregroundColor(.yellow)
                            Text("My Coins")
                            Spacer()
                            Text("\(storeManager.coins)")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section(header: Text("Legal & About")) {
                    NavigationLink(destination: DocumentView(title: "Privacy Policy", fileName: "PrivacyPolicy")) {
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(.pink)
                            Text("Privacy Policy")
                        }
                    }
                    
                    NavigationLink(destination: DocumentView(title: "Terms of Service", fileName: "TermsOfService")) {
                        HStack {
                            Image(systemName: "doc.plaintext.fill")
                                .foregroundColor(.pink)
                            Text("Terms of Service")
                        }
                    }
                    
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.pink)
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
                .navigationTitle("Settings")
            }
        }
    }
}
