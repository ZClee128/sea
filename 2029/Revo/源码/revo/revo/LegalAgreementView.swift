import SwiftUI

struct LegalAgreementView: View {
    @State private var isAccepted = false
    @State private var showMainApp = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // Logo or Icon
                Image(systemName: "sparkles")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundColor(RevoDesign.primary)
                
                Text("Welcome to Revo")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(RevoDesign.text)
                
                Text("Your Ultimate Makeup Artist Companion")
                    .font(.headline)
                    .foregroundColor(RevoDesign.textSecondary)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Terms & Conditions")
                            .font(.headline)
                            .foregroundColor(RevoDesign.text)
                        
                        Text("By using Revo, you agree to our Terms of Use and Privacy Policy. This application provides makeup inspiration and educational content. We do not collect personal data as we do not use an account system.")
                            .font(.body)
                            .foregroundColor(RevoDesign.textSecondary)
                        
                        Text("User Conduct")
                            .font(.headline)
                            .foregroundColor(RevoDesign.text)
                        
                        Text("You agree to use this app for personal, non-commercial purposes. Content visualization and extraction are strictly for inspiration and learning from the provided technique tutorials.")
                            .font(.body)
                            .foregroundColor(RevoDesign.textSecondary)
                        
                        Text("Data Privacy")
                            .font(.headline)
                            .foregroundColor(RevoDesign.text)
                        
                        Text("Revo operates entirely on your local device. Any 'Inspired Looks' or 'Beauty Notes' you save are stored locally and are not transmitted to any external servers.")
                            .font(.body)
                            .foregroundColor(RevoDesign.textSecondary)
                        
                        Text("Age Requirement")
                            .font(.headline)
                            .foregroundColor(RevoDesign.text)
                        
                        Text("You must be at least 13 years old to use the Revo application.")
                            .font(.body)
                            .foregroundColor(RevoDesign.textSecondary)
                    }
                    .padding()
                    .background(RevoDesign.secondary.opacity(0.3))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                Spacer()
                
                VStack(spacing: 15) {
                    Button(action: {
                        isAccepted = true
                        UserDefaults.standard.set(true, forKey: "revo_terms_accepted")
                        navigateToMainApp()
                    }) {
                        Text("Agree and Continue")
                    }
                    .buttonStyle(GlassyButtonStyle())
                    .padding(.horizontal)
                    
                    Text("By continuing, you accept our standard Apple EULA and Privacy Policy.")
                        .font(.caption)
                        .foregroundColor(RevoDesign.textSecondary)
                }
                .padding(.bottom, 20)
            }
            .background(RevoDesign.background.edgesIgnoringSafeArea(.all))
            .preferredColorScheme(.light)
        }
    }
    
    private func navigateToMainApp() {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            let transition = CATransition()
            transition.duration = 0.5
            transition.type = .fade
            delegate.window?.layer.add(transition, forKey: kCATransition)
            delegate.window?.rootViewController = UIHostingController(rootView: MainTabView())
        }
    }
}

struct LegalAgreementView_Previews: PreviewProvider {
    static var previews: some View {
        LegalAgreementView()
    }
}
