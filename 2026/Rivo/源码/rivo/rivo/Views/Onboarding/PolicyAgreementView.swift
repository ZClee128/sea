import SwiftUI

struct PolicyAgreementView: View {
    @ObservedObject var manager: PolicyAgreementManager
    @State private var showingPrivacy = false
    @State private var showingTerms = false
    
    var body: some View {
        ZStack {
            // Background Gradient
            // Background
            Color(UIColor.systemBackground)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Spacer()
                
                // App Logo / Icon Placeholder
                Image(systemName: "figure.dance")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundColor(.blue)
                    .padding(25)
                    .background(Circle().fill(Color.blue.opacity(0.2)))
                    .overlay(Circle().stroke(Color.blue.opacity(0.5), lineWidth: 2))
                
                VStack(spacing: 10) {
                    Text("Welcome to Rivo")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Your Professional Dance Inspiration & Practice Guide")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
                
                VStack(spacing: 15) {
                    Text("By using Rivo, you agree to our policies.")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 20) {
                        Button(action: { showingPrivacy = true }) {
                            Text("Privacy Policy")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.blue)
                        }
                        
                        Text("|")
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Button(action: { showingTerms = true }) {
                            Text("Terms of Service")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Button(action: {
                    withAnimation {
                        manager.hasAgreed = true
                    }
                }) {
                    Text("Agree & Continue")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.blue)
                        .cornerRadius(16)
                        .padding(.horizontal, 40)
                }
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showingPrivacy) {
            PolicyDocumentView(title: "Privacy Policy", filename: "PrivacyPolicy")
        }
        .sheet(isPresented: $showingTerms) {
            PolicyDocumentView(title: "Terms of Service", filename: "TermsOfService")
        }
    }
}

struct PolicyDocumentView: View {
    let title: String
    let filename: String
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            if #available(iOS 14.0, *) {
                ScrollView {
                    Text(loadContent())
                        .padding()
                        .font(.system(size: 15))
                }
                .navigationBarTitle(title, displayMode: .inline)
                .navigationBarItems(trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                })
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    private func loadContent() -> String {
        guard let path = Bundle.main.path(forResource: filename, ofType: "md"),
              let content = try? String(contentsOfFile: path) else {
            return "Content not found."
        }
        return content
    }
}

// Helper for Hex Colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
