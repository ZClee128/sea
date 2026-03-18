import SwiftUI

struct SettingsView: View {
    @State private var showingClearCacheAlert = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("App Information")) {
                    HStack {
                        Text("App Name")
                        Spacer()
                        Text("Revo: The Art of Makeup")
                            .foregroundColor(RevoDesign.textSecondary)
                    }
                    
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0 (Build 1)")
                            .foregroundColor(RevoDesign.textSecondary)
                    }
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
                        if let url = URL(string: "mailto:support@revoapp.com") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "envelope")
                            Text("Contact Support")
                        }
                    }
                    
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
Privacy Policy for Revo

1. Data Collection
Revo does not collect, store, or transmit any personal identifiable information. We do not use third-party tracking services.

2. Local Storage
Revo uses your device's local storage (UserDefaults and local files) to save your preferences and "Inspired Looks". This data stays on your device and is deleted if you uninstall the app.

3. External Links
The app may contain links to external sites (like Apple's EULA). We are not responsible for the privacy practices of those sites.

4. Children's Privacy
We do not knowingly collect any information from children under the age of 13.

5. Contact Us
If you have any questions about this Privacy Policy, please contact us at support@revoapp.com.
"""
