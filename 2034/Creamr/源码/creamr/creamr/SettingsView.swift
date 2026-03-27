import SwiftUI

@available(iOS 15.0, *)
struct SettingsView: View {
    @AppStorage("backgroundPlayback") private var backgroundPlayback = true
    @ObservedObject private var coinStore = CoinStore.shared
    @State private var showCoinShop = false

    var body: some View {
        NavigationView {
            List {

                // ── Coins ──────────────────────────────────────────
                Section(header: Text("Coins")) {
                    Button(action: { showCoinShop = true }) {
                        HStack(spacing: 12) {
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.title2)
                                .foregroundColor(Color(red: 0.9, green: 0.65, blue: 0.1))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Coin Shop")
                                    .font(.body)
                                Text("Unlock premium Studio filter packs")
                                    .font(.caption).foregroundColor(.secondary)
                            }
                            Spacer()
                            HStack(spacing: 4) {
                                Text("🪙")
                                Text("\(coinStore.coinBalance)")
                                    .font(.subheadline).fontWeight(.bold)
                                    .foregroundColor(Color(red: 0.9, green: 0.65, blue: 0.1))
                            }
                            Image(systemName: "chevron.right")
                                .font(.caption).foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                // ── Playback ────────────────────────────────────────
                Section(header: Text("Playback")) {
                    Toggle(isOn: $backgroundPlayback) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Background Playback")
                                    .font(.body)
                                Text("Keep audio playing when app is minimized")
                                    .font(.caption).foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: "play.rectangle.on.rectangle.fill")
                                .foregroundColor(.purple)
                        }
                    }
                    .tint(.purple)
                }

                // ── Legal ───────────────────────────────────────────
                Section(header: Text("Legal")) {
                    NavigationLink(destination: PrivacyPolicyDetailView()) {
                        Text("Privacy Policy")
                    }
                    NavigationLink(destination: TermsView()) {
                        Text("Terms of Service")
                    }
                }

                // ── App Info ────────────────────────────────────────
                Section(header: Text("Application")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0").foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Name")
                        Spacer()
                        Text("Creamr").foregroundColor(.secondary)
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationTitle("Settings")
            .sheet(isPresented: $showCoinShop) {
                NavigationView {
                    CoinShopView()
                }
            }
        }
    }
}

@available(iOS 14.0, *)
struct PrivacyPolicyDetailView: View {
    @State private var text: String = "Loading..."
    
    var body: some View {
        ScrollView {
            Text(text)
                .padding()
                .font(.footnote)
        }
        .navigationTitle("Privacy Policy")
        .onAppear {
            if let path = Bundle.main.path(forResource: "PrivacyPolicy", ofType: "txt") {
                text = (try? String(contentsOfFile: path, encoding: .utf8)) ?? "No policy found."
            }
        }
    }
}

@available(iOS 14.0, *)
struct TermsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Group {
                    termsSection("Terms of Service", body: "Last Updated: March 27, 2026\n\nPlease read these Terms of Service (\"Terms\") carefully before using the Creamr mobile application (\"the App\") operated by Creamr (\"we\", \"us\", or \"our\"). By accessing or using the App, you agree to be bound by these Terms.")

                    termsSection("1. Acceptance of Terms", body: "By downloading, installing, or using Creamr, you confirm that you are at least 13 years of age and agree to comply with and be bound by these Terms. If you do not agree to these Terms, please do not use the App.")

                    termsSection("2. Description of Service", body: "Creamr is a digital art appreciation and creative tool application that provides:\n• A curated gallery of fantasy and CGI digital artworks\n• Atmospheric video content for focus and relaxation\n• An Art Studio for applying creative filters to your personal photos\n• Educational content about digital art techniques and color theory\n\nAll features are provided for personal, non-commercial use only.")

                    termsSection("3. Intellectual Property", body: "All artwork, illustrations, videos, written content, software, and design elements within the App (except user-generated content) are the intellectual property of Creamr or its licensed content providers. You may not reproduce, distribute, modify, or create derivative works from any App content without prior written permission.\n\nThe Creamr name, logo, and associated brand elements are trademarks of Creamr and may not be used without permission.")

                    termsSection("4. User-Generated Content & Photo Library", body: "When you use the Art Studio feature, you grant Creamr no rights over your personal photos. Your images are processed exclusively on your device using Apple's CoreImage framework. We do not access, upload, store, or transmit your photos to any server. Any styled images you save are stored in your device's local photo library under your full control.")

                    termsSection("5. Acceptable Use", body: "You agree not to:\n• Use the App for any unlawful purpose\n• Attempt to reverse-engineer or decompile the App\n• Use the App to infringe upon any third party's intellectual property rights\n• Reproduce or redistribute App content without permission\n• Use the App in any manner that could damage or overburden our services")

                    termsSection("6. Disclaimer of Warranties", body: "The App is provided on an \"AS IS\" and \"AS AVAILABLE\" basis without any warranties, express or implied. We do not warrant that the App will be uninterrupted, error-free, or free of viruses or other harmful components. Your use of the App is at your sole risk.")

                    termsSection("7. Limitation of Liability", body: "To the fullest extent permitted by applicable law, Creamr shall not be liable for any indirect, incidental, special, consequential, or punitive damages arising from your use of or inability to use the App, even if we have been advised of the possibility of such damages.")

                    termsSection("8. Privacy", body: "Your use of the App is also governed by our Privacy Policy, which is incorporated into these Terms by reference. Please review our Privacy Policy to understand our practices.")

                    termsSection("9. Changes to Terms", body: "We reserve the right to modify these Terms at any time. Changes will be effective immediately upon posting within the App. Your continued use of the App after any changes constitutes your acceptance of the new Terms.")

                    termsSection("10. Termination", body: "We reserve the right to terminate or suspend your access to the App at any time, without notice, for conduct that we believe violates these Terms or is otherwise harmful to other users, the App, or third parties.")

                    termsSection("11. Governing Law", body: "These Terms shall be governed by and construed in accordance with applicable laws. Any disputes arising under these Terms shall be subject to the exclusive jurisdiction of the competent courts.")

                    termsSection("12. Contact Us", body: "If you have any questions about these Terms of Service, please contact us at:\n\nphamvankien1288@icloud.com")
                }
            }
            .padding()
        }
        .navigationTitle("Terms of Service")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func termsSection(_ title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline).fontWeight(.bold)
            Text(body)
                .font(.footnote).foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
