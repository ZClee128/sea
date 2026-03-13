import SwiftUI

struct AgreementView: View {
    @ObservedObject var appState: AppState
    @State private var showingSafari = false
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "hand.raised.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.accentColor)
            
            Text("Welcome to Glamour")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Your personal hairstyle & makeup lookbook.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            VStack(spacing: 10) {
                Text("By continuing, you agree to our Terms of Service and Privacy Policy. We do not tolerate objectionable content or abusive users.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                Button(action: {
                    showingSafari = true
                }) {
                    Text("Read Terms & Privacy Policy")
                        .font(.footnote)
                        .underline()
                }
            }
            .padding(.bottom, 30)
            
            Button(action: {
                withAnimation {
                    appState.hasAgreed = true
                }
            }) {
                Text("I Agree & Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 30)
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
        .sheet(isPresented: $showingSafari) {
            if let url = URL(string: "https://docs.qq.com/doc/DQkl2THhnZVJrS2FB") {
                SafariView(url: url)
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
}
