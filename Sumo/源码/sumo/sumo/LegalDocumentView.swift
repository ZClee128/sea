import SwiftUI

// MARK: - Generic in-app legal document viewer

@available(iOS 15.0, *)
struct LegalDocumentView: View {
    let title: String
    let sections: [(heading: String, body: String)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Last updated: March 2026")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)

                ForEach(sections, id: \.heading) { section in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(section.heading)
                            .font(.headline)
                        Text(section.body)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding()
        }
        .navigationBarTitle(title, displayMode: .large)
    }
}

// MARK: - Terms of Use content

private let termsOfUseSections: [(heading: String, body: String)] = [
    (
        "1. Acceptance of Terms",
        "By downloading, installing, or using Sumo - OOTD & Inspiration (the App), you agree to be bound by these Terms of Use. If you do not agree, do not use the App."
    ),
    (
        "2. Eligibility",
        "You must be at least 18 years old to use the App. By using it, you represent that you meet this age requirement. If you are under 18, you are not permitted to use the App."
    ),
    (
        "3. User Content",
        "You are solely responsible for any content you create, share, or save within the App. You grant us a non-exclusive, royalty-free licence to display your content within the App. You must not post content that is illegal, harmful, abusive, defamatory, or that violates any third-party rights."
    ),
    (
        "4. Prohibited Conduct",
        "You agree not to: (a) reverse-engineer or modify the App; (b) use the App for any unlawful purpose; (c) harass, threaten, or intimidate other users; (d) post false or misleading information; (e) attempt to gain unauthorised access to any part of the App or its systems."
    ),
    (
        "5. Intellectual Property",
        "All content, design, graphics, and code within the App are owned by or licensed to us and are protected by applicable intellectual property laws. You may not reproduce or distribute any part of the App without our express written permission."
    ),
    (
        "6. Disclaimers",
        "The App is provided as-is without warranties of any kind, express or implied. We do not guarantee that the App will be error-free, uninterrupted, or free of viruses or other harmful components."
    ),
    (
        "7. Limitation of Liability",
        "To the fullest extent permitted by law, we shall not be liable for any indirect, incidental, special, or consequential damages arising from your use of the App, even if advised of the possibility of such damages."
    ),
    (
        "8. Modifications",
        "We reserve the right to modify these Terms at any time. Continued use of the App after changes are posted constitutes your acceptance of the revised Terms."
    ),
    (
        "9. Governing Law",
        "These Terms are governed by the laws of the jurisdiction in which our company is registered, without regard to its conflict of law provisions."
    ),
    (
        "10. Contact",
        "If you have questions about these Terms, please contact us at: support@sumoootd.app"
    )
]

@available(iOS 15.0, *)
struct TermsOfUseView: View {
    var body: some View {
        LegalDocumentView(title: "Terms of Use", sections: termsOfUseSections)
    }
}

// MARK: - Privacy Policy content

private let privacyPolicySections: [(heading: String, body: String)] = [
    (
        "1. Information We Collect",
        "We collect only the information necessary to provide our services:\n- Device & usage data: device type, OS version, and in-app interactions collected anonymously to improve the App.\n- User-generated content: outfit looks and AI-generated images you choose to save.\n- Local storage: your saved looks and preferences are stored only on your device using UserDefaults."
    ),
    (
        "2. How We Use Your Information",
        "We use collected information to: (a) provide and improve the App features; (b) diagnose technical issues; (c) personalise your in-app experience. We do not sell or rent your personal information to third parties."
    ),
    (
        "3. Camera, Microphone & Photo Library",
        "If you grant access, your camera and photo library are used solely to capture and display outfit content within the App. Media is processed on-device and is never uploaded to our servers without your explicit action."
    ),
    (
        "4. Third-Party AI Services (Pollinations.ai)",
        "The App uses the following third-party services:\n- Pollinations.ai: for AI image generation. When you explicitly agree to the Data Privacy Consent toggle, we only transmit the text prompt you entered to Pollinations.ai. We do not transmit your name, face, photos, UDID, IP address, or any other personal identifiers. Pollinations.ai does not use your text prompt to identify you personally and provides equal protection of your privacy.\n- Picsum Photos: anonymous placeholder avatar images."
    ),
    (
        "5. Data Retention",
        "Content you save (outfit looks, AI-generated images) is stored locally on your device. Clearing the cache or uninstalling the App permanently removes this data. We do not retain copies on our servers."
    ),
    (
        "6. Children's Privacy",
        "The App is not directed to children under 13. We do not knowingly collect personal information from children under 13. If we learn we have inadvertently collected such information, we will delete it promptly."
    ),
    (
        "7. Security",
        "We implement industry-standard measures to protect information stored within the App. However, no method of data storage is 100% secure, and we cannot guarantee absolute security."
    ),
    (
        "8. Your Rights",
        "Depending on your jurisdiction, you may have the right to access, correct, or delete personal data we hold. Since most data is stored locally on your device, you can exercise these rights by clearing the App data or uninstalling the App."
    ),
    (
        "9. Changes to This Policy",
        "We may update this Privacy Policy from time to time. We will notify you of significant changes by updating the date at the top. Continued use of the App constitutes acceptance of the revised Policy."
    ),
    (
        "10. Contact Us",
        "If you have any questions about this Privacy Policy, please contact us at: privacy@sumoootd.app"
    )
]

@available(iOS 15.0, *)
struct PrivacyPolicyView: View {
    var body: some View {
        LegalDocumentView(title: "Privacy Policy", sections: privacyPolicySections)
    }
}
