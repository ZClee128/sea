import SwiftUI

struct SettingsView: View {
    @State private var showingClearCacheAlert = false
    @ObservedObject var storeManager = StoreManager.shared
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Premium Features")) {
                    NavigationLink(destination: CoinStoreView()) {
                        HStack {
                            Image(systemName: "circle.grid.hex.fill")
                                .foregroundColor(RevoDesign.primary)
                            Text("Coin Store")
                            Spacer()
                            Text("\(storeManager.coinBalance) coins")
                                .font(.caption)
                                .foregroundColor(RevoDesign.textSecondary)
                        }
                    }
                }
                
                Section(header: Text("App Information")) {
                    
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(RevoDesign.textSecondary)
                    }
                }
                
                Section(header: Text("Content Ownership")) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(RevoDesign.primary)
                            Text("Original Content")
                                .font(.headline)
                                .foregroundColor(RevoDesign.text)
                        }
                        Text("All tutorial videos and written guides in Revo are original content created exclusively by the Revo App Team. No content is sourced from or linked to third-party streaming platforms. Full copyright is held by Revo App Team © 2026.")
                            .font(.caption)
                            .foregroundColor(RevoDesign.textSecondary)
                            .lineSpacing(4)
                    }
                    .padding(.vertical, 6)
                }
                
                Section(header: Text("Legal & Privacy")) {
                    NavigationLink(destination: LegalContentView(title: "Terms of Service", content: termsOfServiceText)) {
                        HStack {
                            Image(systemName: "doc.text")
                            Text("Terms of Service")
                        }
                    }
                    
                    NavigationLink(destination: LegalContentView(title: "Privacy Policy", content: privacyPolicyText)) {
                        HStack {
                            Image(systemName: "shield")
                            Text("Privacy Policy")
                        }
                    }
                    
                    Button(action: {
                        if let url = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            HStack {
                                Image(systemName: "link")
                                Text("Standard EULA")
                            }
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(RevoDesign.textSecondary)
                        }
                    }
                }
                
                Section(header: Text("Support")) {
                    Button(action: {
                        showingClearCacheAlert = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Clear Cached Media")
                        }
                        .foregroundColor(.red)
                    }
                    .alert(isPresented: $showingClearCacheAlert) {
                        Alert(
                            title: Text("Clear Cache"),
                            message: Text("Are you sure you want to clear all cached offline videos and images?"),
                            primaryButton: .destructive(Text("Clear")) {
                                // Logic to clear cache
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
                
                Section {
                    HStack {
                        Spacer()
                        Text("© 2026 Revo App Team")
                            .font(.caption)
                            .foregroundColor(RevoDesign.textSecondary)
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .navigationBarTitle(Text("Settings"), displayMode: .inline)
            .background(RevoDesign.background.edgesIgnoringSafeArea(.all))
        }
        .forceLightMode()
    }
}

struct LegalContentView: View {
    let title: String
    let content: String
    
    var body: some View {
        ScrollView {
            Text(content)
                .padding()
                .font(.body)
                .foregroundColor(RevoDesign.textSecondary)
                .background(RevoDesign.background)
        }
        .navigationBarTitle(Text(title), displayMode: .inline)
        .background(RevoDesign.background.edgesIgnoringSafeArea(.all))
    }
}

// Detailed legal texts to meet Apple's guideline requirements for content-rich apps
private let termsOfServiceText = """
Terms of Service for Revo: The Art of Makeup

1. Acceptance of Terms
By accessing or using Revo, you agree to be bound by these Terms of Service. If you do not agree to all of the terms, do not use our application.

2. License to Use
We grant you a personal, non-exclusive, non-transferable license to use Revo for your own inspiration and educational purposes. You may not modify, distribute, or create derivative works based on the content available within Revo.

3. No User Account
Revo does not require a user account. We do not store your personal information on our servers. Your "Inspired Looks" and notes are stored locally on your device.

4. Intellectual Property
All content including images, videos, and descriptions are protected by copyright and intellectual property laws.

5. Disclaimer
The makeup techniques shown are for educational purposes. We are not responsible for any adverse reactions resulting from the use of specific makeup products or techniques.
"""

private let privacyPolicyText = """
Privacy Policy for Revo: The Art of Makeup

1. Data Collection & Usage
We collect unique device identifiers (Adjust ID, UUID) and usage data via third-party services like Adjust and Firebase to improve app performance and analyze user interactions.

2. In-App Purchases
Transaction details are processed through Apple StoreKit to manage your coin balance. Purchase history is used solely for app functionality.

3. Local Storage
Your "Beauty Journal" entries and personal preferences are stored locally on your device and are not transmitted to our servers.

4. Permissions
Camera, Microphone, and Photo Library access is used only for specific features (makeup analysis/saving looks) and is never shared without your consent.

5. Children's Privacy
We do not knowingly collect any information from children under the age of 13.

6. Contact Us
If you have any questions, please contact us at hathivan0204@icloud.com.
"""
