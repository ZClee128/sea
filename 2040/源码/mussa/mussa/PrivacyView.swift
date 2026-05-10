import SwiftUI
import WebKit

struct PrivacyView: View {
    @ObservedObject var privacyManager: PrivacyManager
    var showAgreeButton: Bool = true
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            // Header for App UI
            HStack {
                Text("Privacy Policy")
                    .font(.headline)
                Spacer()
                if !showAgreeButton {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            
            // Web Content
            PrivacyWebView(fileName: "index")
                .edgesIgnoringSafeArea(.bottom)
            
            if showAgreeButton {
                VStack {
                    Button(action: {
                        withAnimation {
                            privacyManager.hasAgreed = true
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
                    .padding()
                }
                .background(Color.white.shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: -5))
            }
        }
        .background(Color.white.edgesIgnoringSafeArea(.all))
    }
}

// MARK: - WebView Wrapper

struct PrivacyWebView: UIViewRepresentable {
    let fileName: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.backgroundColor = .clear
        webView.isOpaque = false
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "html") {
            uiView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
    }
}

struct PrivacyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyView(privacyManager: PrivacyManager())
    }
}
