import SwiftUI

struct GRAcceptanceFlowView: View {
    @State private var isAgreed = false
    @State private var showMainApp = false
    @State private var showPrivacy = false
    @State private var showTerms = false
    @State private var combinedContent: String = "Loading agreements..."
    
    var body: some View {
        if showMainApp {
            GRMainDashboardView()
        } else {
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 25) {
                    Spacer()
                    
                    Image(systemName: "hand.raised.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.black)
                        .padding(.bottom, 10)
                    
                    Text("User Agreement")
                        .font(.system(size: 32, weight: .bold, design: .serif))
                        .foregroundColor(.black)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 15) {
                            Text(combinedContent)
                                .font(.footnote)
                                .foregroundColor(.black.opacity(0.8))
                                .padding()
                        }
                    }
                    .frame(height: 300)
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        HStack(spacing: 15) {
                            Button(action: { showTerms = true }) {
                                Text("Terms of Service")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .underline()
                            }
                            
                            Button(action: { showPrivacy = true }) {
                                Text("Privacy Policy")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .underline()
                            }
                        }
                        
                        Button(action: {
                            isAgreed.toggle()
                        }) {
                            HStack {
                                Image(systemName: isAgreed ? "checkmark.square.fill" : "square")
                                    .foregroundColor(isAgreed ? .blue : .gray)
                                Text("I agree to the Terms and Privacy Policy")
                                    .font(.footnote)
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    
                    Button(action: {
                        if isAgreed {
                            UserDefaults.standard.set(true, forKey: "hasAgreedToTerms")
                            withAnimation {
                                showMainApp = true
                            }
                        }
                    }) {
                        Text("Agree and Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isAgreed ? Color.black : Color.gray)
                            .cornerRadius(12)
                    }
                    .disabled(!isAgreed)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
                    
                    Spacer()
                }
            }
            .sheet(isPresented: $showPrivacy) {
                GRLegalDocumentView(fileName: "PrivacyPolicy", title: "PRIVACY POLICY")
            }
            .sheet(isPresented: $showTerms) {
                GRLegalDocumentView(fileName: "TermsOfService", title: "TERMS OF SERVICE")
            }
            .onAppear {
                loadCombinedContent()
                if UserDefaults.standard.bool(forKey: "hasAgreedToTerms") {
                    showMainApp = true
                }
            }
        }
    }
    
    func loadCombinedContent() {
        var finalContent = ""
        
        // Load Terms
        if let termsPath = Bundle.main.path(forResource: "TermsOfService", ofType: "txt"),
           let terms = try? String(contentsOfFile: termsPath, encoding: .utf8) {
            finalContent += terms
        }
        
        finalContent += "\n\n------------------\n\n"
        
        // Load Privacy
        if let privacyPath = Bundle.main.path(forResource: "PrivacyPolicy", ofType: "txt"),
           let privacy = try? String(contentsOfFile: privacyPath, encoding: .utf8) {
            finalContent += privacy
        }
        
        if finalContent.isEmpty || finalContent.count < 50 {
            combinedContent = "Welcome to Glowr. By continuing, you agree to our professional terms and privacy guidelines regarding data usage and AI analysis."
        } else {
            combinedContent = finalContent
        }
    }
}

struct GRAcceptanceFlowView_Previews: PreviewProvider {
    static var previews: some View {
        GRAcceptanceFlowView()
    }
}
