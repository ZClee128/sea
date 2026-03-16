import SwiftUI

struct AgreementView: View {
    @State private var accepted = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Welcome to Zayo")
                            .font(.system(size: 34, weight: .bold, design: .serif))
                            .padding(.top, 40)
                        
                        Text("Terms & Privacy")
                            .font(.headline)
                        
                        Text("Please review our terms of service and privacy policy to understand how Zayo provides its services and protects your artistic journey.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Group {
                            Text("1. Digital Art License")
                                .font(.headline)
                            Text("All photography, technical data, and workshop materials in Zayo are protected content. You are granted a personal, non-commercial license to use these resources for inspiration and educational purposes.")
                            
                            Text("2. Workshop Utility")
                                .font(.headline)
                            Text("The Workshop tools and 'Export' features are provided to assist in your photography planning. Users are responsible for their own safe use of photography equipment.")
                            
                            Text("3. Privacy & Transparency")
                                .font(.headline)
                            Text("Zayo operates with a 'Zero Data' policy. We do not collect personal info. Virtual coins are handled via Apple, and device permissions (Camera/Mic) are used only for local Workshop features.")
                        }
                        .font(.body)
                        .lineSpacing(6)
                        
                        Text("Continuing below signifies your acceptance of these terms.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 20)
                    }
                    .padding(24)
                }
                
                Button(action: {
                    UserDefaults.standard.set(true, forKey: "UserHasAgreedToTerms")
                    // In a real app, we might use a Coordinator or @EnvironmentObject to switch roots
                    // For simplicity here, we'll suggest a refresh or the AppDelegate will handle next launch
                    // But to show immediate effect, we'll use a hack or just inform the user.
                    if let window = UIApplication.shared.windows.first {
                        window.rootViewController = UIHostingController(rootView: ZayoMainView())
                        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil, completion: nil)
                    }
                }) {
                    Text("Agree and Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(12)
                }
                .padding([.horizontal, .bottom], 24)
            }
            .navigationBarHidden(true)
        }
    }
}

struct AgreementView_Previews: PreviewProvider {
    static var previews: some View {
        AgreementView()
    }
}
