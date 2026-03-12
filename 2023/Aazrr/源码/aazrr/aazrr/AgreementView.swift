import SwiftUI

struct AgreementView: View {
    @Binding var hasAgreed: Bool
    @State private var showPrivacy = false
    @State private var showTerms = false
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Image(systemName: "quote.bubble.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.black)
                .padding(.top, 50)
            
            Text("Welcome to QuotePortraits")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Before you start using the app, please read and agree to our Privacy Policy and Terms of Service.")
                        .font(.body)
                        .foregroundColor(.gray)
                    
                    Text("Key Points:")
                        .font(.headline)
                        .padding(.top, 10)
                    
                    HStack(alignment: .top) {
                        Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                        Text("No Data Collection: We do not collect, store, or transmit any of your personal data. Everything is kept locally on your device.")
                    }
                    
                    HStack(alignment: .top) {
                        Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                        Text("No Accounts: You don't need to create an account to use any of the features.")
                    }
                    
                    HStack(alignment: .top) {
                        Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                        Text("Local Storage: Saved portraits and generated posters are stored strictly in your device's local photo library.")
                    }
                }
                .padding()
            }
            
            VStack(spacing: 15) {
                Button(action: { showPrivacy = true }) {
                    Text("Read Privacy Policy")
                        .underline()
                        .foregroundColor(.blue)
                }
                .sheet(isPresented: $showPrivacy) {
                    LegalDocumentView(title: "Privacy Policy", filename: "PrivacyPolicy")
                }
                
                Button(action: { showTerms = true }) {
                    Text("Read Terms of Service")
                        .underline()
                        .foregroundColor(.blue)
                }
                .sheet(isPresented: $showTerms) {
                    LegalDocumentView(title: "Terms of Service", filename: "TermsOfService")
                }
            }
            
            Button(action: {
                UserDefaults.standard.set(true, forKey: "HasAgreedToTerms")
                hasAgreed = true
            }) {
                Text("Agree and Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
    }
}
}

struct LegalDocumentView: View {
    let title: String
    let filename: String
    
    @State private var content: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(content)
                    .padding()
                    .font(.body)
            }
            .navigationBarTitle(Text(title), displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                if let url = Bundle.main.url(forResource: filename, withExtension: "txt"),
                   let text = try? String(contentsOf: url) {
                    content = text
                } else {
                    content = "Document not found."
                }
            }
        }
    }
}
