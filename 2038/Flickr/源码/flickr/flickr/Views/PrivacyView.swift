import SwiftUI

struct PrivacyView: View {
    @State private var policyText: String = "Loading..."
    var onAgree: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Privacy Policy")
                .font(.system(size: 28, weight: .bold, design: .serif))
                .padding(.top, 40)
            
            ScrollView {
                Text(policyText)
                    .font(.system(size: 14, design: .serif))
                    .lineSpacing(4)
                    .padding()
            }
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
            
            Button(action: {
                UserDefaults.standard.set(true, forKey: "hasAgreedToPrivacy")
                onAgree()
            }) {
                Text("AGREE & CONTINUE")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .onAppear(perform: loadPolicy)
    }

    private func loadPolicy() {
        if let url = Bundle.main.url(forResource: "PrivacyPolicy", withExtension: "txt") {
            if let content = try? String(contentsOf: url) {
                self.policyText = content
            }
        }
    }
}

struct PrivacyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyView(onAgree: {})
    }
}
