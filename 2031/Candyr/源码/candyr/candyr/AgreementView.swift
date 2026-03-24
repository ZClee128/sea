import SwiftUI

struct AgreementView: View {
    @State private var termsText: String = "Loading..."
    @State private var showingPrivacy = false
    var onAgree: () -> Void

    var body: some View {
        ZStack {
            NeonCouture.background.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                Text("CANDYR")
                    .font(NeonCouture.titleFont)
                    .foregroundColor(NeonCouture.primary)
                    .neonGlow()
                    .padding(.top, 40)
                
                VStack(spacing: 4) {
                    Text("Legal and Privacy")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(termsText)
                            .font(NeonCouture.bodyFont)
                    }
                    .padding()
                }
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                
                HStack(spacing: 20) {
                    Button("Read Privacy Policy") {
                        showingPrivacy = true
                    }
                    .font(.caption)
                    .foregroundColor(NeonCouture.primary)
                }
                
                Button(action: {
                    UserDefaults.standard.set(true, forKey: "hasAgreedToTerms")
                    onAgree()
                }) {
                    Text("I Agree & Enter")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [NeonCouture.primary, NeonCouture.secondary]), startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(30)
                        .neonGlow()
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
            }
        }
        .onAppear(perform: loadTerms)
        .sheet(isPresented: $showingPrivacy) {
            PrivacySheetView()
        }
    }
    
    func loadTerms() {
        if let path = Bundle.main.path(forResource: "TermsOfService", ofType: "txt") {
            self.termsText = (try? String(contentsOfFile: path)) ?? "Agreement not found."
        }
    }
}

struct PrivacySheetView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var privacyText: String = "Loading..."
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .padding()
            }
            ScrollView {
                Text(privacyText)
                    .padding()
            }
        }
        .onAppear {
            if let path = Bundle.main.path(forResource: "PrivacyPolicy", ofType: "txt") {
                self.privacyText = (try? String(contentsOfFile: path)) ?? "Privacy Policy not found."
            }
        }
    }
}

struct AgreementView_Previews: PreviewProvider {
    static var previews: some View {
        AgreementView(onAgree: {})
    }
}
