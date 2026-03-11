import SwiftUI

@available(iOS 14.0, *)
struct LegalDocumentView: View {
    let title: String
    let content: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(content)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineSpacing(4)
            }
            .padding()
        }
        .navigationBarTitle(title, displayMode: .inline)
    }
}

// Sample contents
let termsOfServiceContent = """
1. Acceptance of Terms
By accessing and using Bexi, you accept and agree to be bound by the terms and provisions of this agreement.

2. User Generated Content
Bexi displays content from various creators. You agree not to distribute, modify, or misuse the visual content beyond personal inspiration and moodboard creation. We reserve the right to remove any content that violates intellectual property rights.

3. Appropriate Usage
You agree to use Bexi strictly for lawful purposes. Any attempt to reverse engineer the app or scrape its visual data systematically is strictly prohibited.

4. Account Terms
You are responsible for safeguarding the password that you use to access the service and for any activities or actions under your password.
"""

let privacyPolicyContent = """
1. Privacy & Data Collection
We respect your privacy. Bexi operates primarily on your local device. Your saved collections and moodboards are stored locally and are not uploaded to our servers unless explicitly shared by you.

2. Information We Info
If you choose to use our Service, then you agree to the collection and use of information in relation with this policy. The Personal Information that we collect is used for providing and improving the Service.

3. Log Data
We want to inform you that whenever you use our Service, in case of an error in the app we collect data and information (through third party products) on your phone called Log Data. This Log Data may include information such as your devices's Internet Protocol ("IP") address, device name, operating system version, configuration of the app when utilizing our Service, the time and date of your use of the Service, and other statistics.

4. Security
We value your trust in providing us your Personal Information, thus we are striving to use commercially acceptable means of protecting it. But remember that no method of transmission over the internet, or method of electronic storage is 100% secure and reliable, and we cannot guarantee its absolute security.
"""
