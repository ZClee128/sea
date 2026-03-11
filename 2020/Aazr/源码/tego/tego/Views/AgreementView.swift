//
//  AgreementView.swift
//  tego
//

import SwiftUI

struct AgreementView: View {
    @ObservedObject var viewModel: AppViewModel
    
    @State private var agreedToTerms = false
    @State private var agreedToPrivacy = false
    @State private var showingTerms = false
    @State private var showingPrivacy = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Text("Welcome to Tego")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Your ultimate guide to fashion trends and aesthetic photography. Before we begin, please review our terms.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 16) {
                Toggle(isOn: $agreedToTerms) {
                    Button(action: { showingTerms = true }) {
                        Text("I agree to the ")
                            .foregroundColor(.primary)
                        + Text("Terms of Service")
                            .foregroundColor(.blue)
                            .underline()
                    }
                    .font(.body)
                }
                
                Toggle(isOn: $agreedToPrivacy) {
                    Button(action: { showingPrivacy = true }) {
                        Text("I agree to the ")
                            .foregroundColor(.primary)
                        + Text("Privacy Policy")
                            .foregroundColor(.blue)
                            .underline()
                    }
                    .font(.body)
                }
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal)
            
            Spacer()
            
            Button(action: {
                viewModel.hasAgreedToTerms = true
            }) {
                Text("Enter Tego")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background((agreedToTerms && agreedToPrivacy) ? Color.blue : Color.gray)
                    .cornerRadius(12)
            }
            .disabled(!(agreedToTerms && agreedToPrivacy))
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
        .sheet(isPresented: $showingTerms) {
            if #available(iOS 15, *) {
                LocalPolicyView(title: "Terms of Service", content: termsOfServiceText)
            }
        }
        .sheet(isPresented: $showingPrivacy) {
            if #available(iOS 15, *) {
                LocalPolicyView(title: "Privacy Policy", content: privacyPolicyText)
            }
        }
    }
}

// MARK: - Policy Sheet View

@available(iOS 14.0, *)
struct LocalPolicyView: View {
    let title: String
    let content: String
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(content)
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding()
            }
            .navigationBarTitle(title, displayMode: .inline)
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// MARK: - Policy Text

private let termsOfServiceText = """
Terms of Service

Last updated: March 2026

1. Acceptance of Terms
By using Tego ("the App"), you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the App.

2. Use of the App
The App is intended for personal, non-commercial use. You agree not to misuse the App or help anyone else do so.

3. User Content
Any content you submit, post, or display through the App remains your responsibility. You grant Tego a license to use, display, and distribute your content within the App.

4. In-App Purchases
The App offers optional in-app purchases (coin packs). All purchases are final and non-refundable except as required by applicable law.

5. Intellectual Property
All content, features, and functionality of the App are owned by Tego and protected by international copyright, trademark, and other intellectual property laws.

6. Limitation of Liability
Tego is provided "as is" without warranties of any kind. We are not liable for any damages arising from your use of the App.

7. Changes to Terms
We reserve the right to modify these terms at any time. Continued use of the App after changes constitutes acceptance of the new terms.

8. Contact
For questions about these Terms, contact us at support@aazr.app
"""

private let privacyPolicyText = """
Privacy Policy

Last updated: March 2026

1. Information We Collect
We collect information you provide directly to us, such as when you use the App's features. This includes:
- App usage data and preferences
- Purchase history (managed by Apple)
- Favorited content

2. How We Use Your Information
We use collected information to:
- Provide and improve the App
- Process in-app purchases
- Save your preferences and favorites

3. Data Storage
Your favorites and settings are stored locally on your device. In-app purchase records are managed by Apple's StoreKit framework.

4. Third-Party Services
The App uses Apple's StoreKit for in-app purchases. Apple's Privacy Policy governs data collected through these services.

5. AI Features
The AI Look Generator feature uses Pollinations.ai to generate images. Images you submit for AI generation may be processed by Pollinations.ai servers. By using this feature, you consent to this processing.

6. Data Retention
Locally stored data (favorites, settings) remains on your device until you delete the App.

7. Children's Privacy
The App is not directed at children under 13. We do not knowingly collect information from children under 13.

8. Changes to This Policy
We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new policy in the App.

9. Contact
For privacy questions, contact us at privacy@aazr.app
"""
