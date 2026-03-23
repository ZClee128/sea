import SwiftUI

@available(iOS 14.0, *)
struct ServiceAgreementView: View {
    var onAccept: () -> Void
    @State private var showingTerms = false
    @State private var showingPrivacy = false
    
    var body: some View {
        ZStack {
            AppTheme.secondary.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Spacer()
                
                Image(systemName: "scissors")
                    .font(.system(size: 60))
                    .foregroundColor(AppTheme.primary)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
                
                Text("Welcome to Junip")
                    .font(AppTheme.titleSemiBold(size: 32))
                    .foregroundColor(.white)
                
                Text("Your personal guide to premium hair styling and professional care.")
                    .font(AppTheme.bodyRegular(size: 16))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                VStack(spacing: 15) {
                    Text("By entering Junip, you agree to our")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                    
                    HStack(spacing: 20) {
                        Button("Terms of Service") {
                            showingTerms = true
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppTheme.primary)
                        
                        Divider().background(Color.white.opacity(0.3)).frame(height: 15)
                        
                        Button("Privacy Policy") {
                            showingPrivacy = true
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppTheme.primary)
                    }
                    
                    Button(action: onAccept) {
                        Text("AGREE & CONTINUE")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppTheme.secondary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.primary)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 10)
                }
                .padding(.bottom, 50)
            }
        }
        .sheet(isPresented: $showingTerms) {
            AgreementContentView(title: "Terms of Service", fileName: "TermsOfService")
        }
        .sheet(isPresented: $showingPrivacy) {
            AgreementContentView(title: "Privacy Policy", fileName: "PrivacyPolicy")
        }
    }
}
