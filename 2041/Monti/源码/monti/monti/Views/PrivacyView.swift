import SwiftUI

struct PrivacyView: View {
    var onAgree: () -> Void
    
    @State private var policyText: String = "Loading policy..."
    
    var body: some View {
        ZStack {
            // Dark elegant backdrop
            Color(red: 0.08, green: 0.08, blue: 0.10)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Top Header Graphic / Brand
                VStack(spacing: 8) {
                    Image(systemName: "hand.raised.fill")
                        .font(.system(size: 44))
                        .foregroundColor(Color(red: 1.00, green: 0.00, blue: 0.50)) // Neon pink accents
                        .padding(.top, 40)
                    
                    Text("Monti Safety & Privacy")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Performance & Conditioning Agreement")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                // Policy text container
                VStack(alignment: .leading, spacing: 10) {
                    ScrollView {
                        Text(policyText)
                            .font(.system(size: 13))
                            .lineSpacing(4)
                            .foregroundColor(Color.white.opacity(0.85))
                            .padding()
                    }
                    .background(Color(red: 0.12, green: 0.12, blue: 0.15))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 20)
                
                // Footer buttons
                VStack(spacing: 12) {
                    // Agree Button
                    Button(action: {
                        UserDefaults.standard.set(true, forKey: "PrivacyPolicyAgreed")
                        onAgree()
                    }) {
                        Text("Agree and Enter")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(red: 1.00, green: 0.00, blue: 0.50), Color(red: 0.50, green: 0.00, blue: 1.00)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(25)
                            .shadow(color: Color(red: 1.00, green: 0.00, blue: 0.50).opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 20)
                    
                    // Disagree Button
                    Button(action: {
                        // Exit the app gracefully
                        exit(0)
                    }) {
                        Text("Disagree and Exit")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                            .padding(.vertical, 8)
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            loadPolicyFile()
        }
    }
    
    private func loadPolicyFile() {
        if let filepath = Bundle.main.path(forResource: "PrivacyPolicy", ofType: "txt") {
            do {
                let contents = try String(contentsOfFile: filepath)
                self.policyText = contents
            } catch {
                self.policyText = "Error reading Privacy Policy file: \(error.localizedDescription)"
            }
        } else {
            // Fallback content if file path cannot be resolved during bundle setup
            self.policyText = """
            Privacy Policy - Monti
            
            Welcome to Monti. Your privacy is paramount.
            - We store all stunt, training, and log data locally on your device.
            - We collect NO personal identifiers.
            - No network transmission is done for telemetry.
            - Complying fully with Apple Guidelines.
            
            If this file was not bundled, please contact support@montiapp.com.
            """
        }
    }
}

// Preview Provider for SwiftUI development
struct PrivacyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyView(onAgree: {})
    }
}
