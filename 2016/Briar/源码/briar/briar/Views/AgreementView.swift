import SwiftUI

struct AgreementView: View {
    @Binding var hasAgreed: Bool
    @State private var agreementText: String = "Loading..."
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    Text(agreementText)
                        .padding()
                        .font(.system(size: 15))
                        .foregroundColor(.primary)
                }
                .background(Color(UIColor.systemGray6))
                
                Divider()
                
                Button(action: {
                    UserDefaults.standard.set(true, forKey: "hasAgreedToTerms")
                    hasAgreed = true
                }) {
                    Text("I Agree")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(12)
                }
                .padding()
            }
            .navigationBarTitle("Terms of Service", displayMode: .inline)
            .onAppear {
                if let url = Bundle.main.url(forResource: "Agreement", withExtension: "txt"),
                   let text = try? String(contentsOf: url, encoding: .utf8) {
                    self.agreementText = text
                } else {
                    self.agreementText = "Failed to load agreement. Please check your app bundle."
                }
            }
        }
    }
}
