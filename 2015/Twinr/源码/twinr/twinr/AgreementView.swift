import SwiftUI

struct AgreementView: View {
    @Binding var isAgreed: Bool
    @State private var showFullAgreement = false
    @State private var privacyPolicyContent: String = "Loading policy content..."
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.shield.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.pink)
                .padding(.top, 50)
            
            Text("Welcome to Twinr")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Nail Art Inspo & DIY Tutorials")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Text("User Agreement & Privacy Policy")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    Text(privacyPolicyContent)
                        .font(.body)
                        .foregroundColor(.primary)
                }
                .padding()
            }
            .frame(maxHeight: 350)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
            
            Spacer()
            
            Button(action: {
                UserDefaults.standard.set(true, forKey: "hasAgreed")
                isAgreed = true
            }) {
                Text("Agree and Continue")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.pink)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .padding()
        .preferredColorScheme(.light)
        .onAppear {
            loadLegalContent()
        }
    }
    
    private func loadLegalContent() {
        if let path = Bundle.main.path(forResource: "PrivacyPolicy", ofType: "txt") {
            do {
                self.privacyPolicyContent = try String(contentsOfFile: path, encoding: .utf8)
            } catch {
                self.privacyPolicyContent = "Error loading agreement: \(error.localizedDescription)"
            }
        }
    }
}

#Preview {
    AgreementView(isAgreed: .constant(false))
}
