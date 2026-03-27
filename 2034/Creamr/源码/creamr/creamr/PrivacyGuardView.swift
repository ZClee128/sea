import SwiftUI

@available(iOS 15.0, *)
struct PrivacyGuardView: View {
    @State private var privacyText: String = "Loading..."
    @AppStorage("hasAcceptedPrivacy") private var hasAccepted: Bool = false

    var body: some View {
        if hasAccepted {
            MainTabView()
        } else {
            policyView
        }
    }

    private var policyView: some View {
        VStack(spacing: 20) {
            Image(systemName: "shield.lefthalf.fill")
                .font(.system(size: 60))
                .foregroundColor(.pink)
                .padding(.top, 50)

            Text("Welcome to Creamr")
                .font(.system(size: 28, weight: .bold, design: .rounded))

            Text("Ethereal Digital Art & Landscapes")
                .font(.subheadline)
                .foregroundColor(.secondary)

            ScrollView {
                Text(privacyText)
                    .font(.footnote)
                    .padding()
                    .multilineTextAlignment(.leading)
            }
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)

            Button(action: { hasAccepted = true }) {
                Text("Accept and Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.pink)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .onAppear(perform: loadPolicy)
    }

    private func loadPolicy() {
        guard let path = Bundle.main.path(forResource: "PrivacyPolicy", ofType: "txt"),
              let text = try? String(contentsOfFile: path, encoding: .utf8) else {
            privacyText = "We do not collect any personal information. Please read our full privacy policy at https://creamr.app/privacy."
            return
        }
        privacyText = text
    }
}
