import SwiftUI

@available(iOS 15.0, *)
struct LaunchCoordinatorView: View {
    @State private var hasConsented: Bool = UserDefaults.standard.bool(forKey: "user_consented_privacy")
    
    var body: some View {
        Group {
            if hasConsented {
                MainTabView()
            } else {
                PrivacyConsentView {
                    UserDefaults.standard.set(true, forKey: "user_consented_privacy")
                    withAnimation {
                        hasConsented = true
                    }
                }
            }
        }
        .preferredColorScheme(.dark) // Force dark mode as requested
    }
}

@available(iOS 14.0, *)
struct PrivacyConsentView: View {
    var onAccept: () -> Void
    @State private var privacyContent: String = "Loading..."
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.accentColor)
                
                Text("Privacy & Terms")
                    .font(.title).bold()
                    .foregroundColor(.white)
                
                ScrollView {
                    Text(privacyContent)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
                .frame(maxHeight: 300)
                
                Text("By clicking 'Agree and Continue', you confirm that you have read and agree to our Privacy Policy.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button(action: onAccept) {
                    Text("Agree and Continue")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(14)
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            loadPrivacyContent()
        }
    }
    
    private func loadPrivacyContent() {
        if let path = Bundle.main.path(forResource: "Privacy", ofType: "txt"),
           let content = try? String(contentsOfFile: path) {
            self.privacyContent = content
        } else {
            self.privacyContent = "Error loading privacy policy. Please contact support."
        }
    }
}
