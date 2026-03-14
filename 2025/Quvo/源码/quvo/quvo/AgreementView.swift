import SwiftUI
import SafariServices

struct SafariURL: Identifiable {
    let id = UUID()
    let url: URL
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
    }
}

struct AgreementView: View {
    @ObservedObject var appState = AppState.shared
    @State private var activeURL: SafariURL?
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "figure.mind.and.body")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .padding(.top, 40)
            
            Text("Welcome to Quvo")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Your personal guide to exploring fitness, yoga, and healthy routines.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    Text("We respect your privacy. All your saved routines and plans are stored locally on your device. By using this application, you agree to our Terms of Use and Privacy Policy. We do not tolerate objectionable content or abusive users.")
                        .font(.footnote)
                    
                    Button(action: {
                        if let url = URL(string: "https://docs.qq.com/doc/DQkpHcmdLQWZQaVds") {
                            self.activeURL = SafariURL(url: url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "doc.text.fill")
                            Text("Terms of Service")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                    }
                    
                    Button(action: {
                        if let url = URL(string: "https://docs.qq.com/doc/DQm9jS2diZFZQV3Jx") {
                            self.activeURL = SafariURL(url: url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "hand.raised.fill")
                            Text("Privacy Policy")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                    }
                }
                .padding()
            }
            .frame(maxHeight: 280)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            .padding(.horizontal)
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    appState.hasAgreedToEULA = true
                }
            }) {
                Text("Agree and Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .sheet(item: $activeURL) { safariURL in
            SafariView(url: safariURL.url)
        }
    }
}

#if DEBUG
struct AgreementView_Previews: PreviewProvider {
    static var previews: some View {
        AgreementView()
    }
}
#endif
