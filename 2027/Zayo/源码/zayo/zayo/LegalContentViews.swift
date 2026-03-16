import SwiftUI

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Terms of Service")
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .padding(.bottom, 10)
                
                Group {
                    Text("Last Updated: March 2026")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("1. Acceptance of Terms")
                        .font(.headline)
                    Text("By accessing and using Zayo, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the application.")
                    
                    Text("2. Description of Service")
                        .font(.headline)
                    Text("Zayo is a premium photography showcase and workshop application. It provides access to high-resolution artistic portraiture, cinematic video portraits, and professional lighting workshop tools for educational and inspirational purposes.")
                }
                
                Group {
                    Text("3. Intellectual Property")
                        .font(.headline)
                    Text("All content available on Zayo, including but not limited to images, videos, technical lighting guides, text, and graphics, is the property of Zayo and is protected by international copyright laws. Unauthorized reproduction, distribution, or commercial use is strictly prohibited.")
                    
                    Text("4. User License")
                        .font(.headline)
                    Text("Zayo grants you a limited, non-exclusive, non-transferable license to access and use the application for your personal, non-commercial use. Use of the Workshop 'Export' feature is permitted for personal photography project planning.")
                }
                
                Group {
                    Text("5. Disclaimer of Warranties")
                        .font(.headline)
                    Text("The application is provided 'as is' without warranties of any kind. While we strive for technical accuracy in our Workshop guides, we do not warrant that the application will meet your specific photography requirements.")
                    
                    Text("6. Limitation of Liability")
                        .font(.headline)
                    Text("Zayo shall not be liable for any indirect, incidental, or consequential damages arising out of your use of the application.")
                    
                    Text("7. Contact Us")
                        .font(.headline)
                    Text("If you have any questions regarding these terms, please contact us at nguyenhongnhung0185@icloud.com.")
                }
            }
            .padding(24)
        }
        .navigationBarTitle("Terms", displayMode: .inline)
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Privacy Policy")
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .padding(.bottom, 10)
                
                Group {
                    Text("Last Updated: March 16, 2026")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("1. Zero-Data Policy")
                        .font(.headline)
                    Text("Zayo is designed to operate without user accounts. We do not collect, store, or transmit any personally identifiable information (PII) such as your name, email address, or phone number.")
                    
                    Text("2. Device Permissions")
                        .font(.headline)
                    Text("To provide interactive features, we may request access to:\n• Camera: For reference photos in the Workshop.\n• Microphone: For recording voice notes.\n• Photo Library: For saving artistic exports and importing references.\n\nAll data remains locally on your device.")
                }
                
                Group {
                    Text("3. In-App Purchases")
                        .font(.headline)
                    Text("All payment processing is handled securely by Apple. Zayo does not receive or store your credit card or payment information. We use local storage to persist your virtual coin balance.")
                    
                    Text("4. Local Data Storage")
                        .font(.headline)
                    Text("Your 'Styles', favorites, and checklists are stored exclusively on your device. This data is never sent to our servers.")
                }
                
                Group {
                    Text("5. Third-Party Services")
                        .font(.headline)
                    Text("Zayo does not use third-party analytics or advertising trackers. We provide a pure, focused, and private artistic environment.")
                    
                    Text("6. Contact Us")
                        .font(.headline)
                    Text("If you have any questions, please contact us at nguyenhongnhung0185@icloud.com.")
                }
            }
            .padding(24)
        }
        .navigationBarTitle("Privacy", displayMode: .inline)
    }
}

struct LegalContentViews_Previews: PreviewProvider {
    static var previews: some View {
        TermsOfServiceView()
        PrivacyPolicyView()
    }
}
