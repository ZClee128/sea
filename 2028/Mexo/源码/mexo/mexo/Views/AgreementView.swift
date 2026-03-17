import SwiftUI

struct AgreementView: View {
    @Binding var isAgreed: Bool
    @State private var showingTerms = false
    @State private var showingPrivacy = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "camera.macro")
                .font(.system(size: 80))
                .foregroundColor(.blue)
                .padding(.bottom, 20)
            
            Text("Welcome to Mexo")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Your personal guide to portrait styling and photography poses.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
            
            VStack(spacing: 12) {
                Text("By continuing, you agree to our Terms of Service and Privacy Policy.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                HStack(spacing: 20) {
                    Button("Terms of Service") {
                        showingTerms = true
                    }
                    .font(.footnote)
                    .foregroundColor(.blue)
                    
                    Button("Privacy Policy") {
                        showingPrivacy = true
                    }
                    .font(.footnote)
                    .foregroundColor(.blue)
                }
            }
            .padding(.bottom, 20)
            
            Button(action: {
                withAnimation {
                    UserDefaults.standard.set(true, forKey: "hasAgreedToTerms")
                    isAgreed = true
                }
            }) {
                Text("Agree & Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
        .sheet(isPresented: $showingTerms) {
            DocumentView(title: "Terms of Service", content: "These are the Terms of Service for Mexo.\n\nBy using this app, you agree to... [Content to be populated]")
        }
        .sheet(isPresented: $showingPrivacy) {
            DocumentView(title: "Privacy Policy", content: "This is the Privacy Policy for Mexo.\n\nWe value your privacy and... [Content to be populated]")
        }
    }
}

struct DocumentView: View {
    let title: String
    let content: String
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            if #available(iOS 14.0, *) {
                ScrollView {
                    Text(content)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .navigationTitle(title)
                .navigationBarItems(trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                })
            } else {
                // Fallback on earlier versions
            }
        }
    }
}

struct AgreementView_Previews: PreviewProvider {
    static var previews: some View {
        AgreementView(isAgreed: .constant(false))
    }
}
