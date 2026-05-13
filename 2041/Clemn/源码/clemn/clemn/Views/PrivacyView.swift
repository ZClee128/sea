import SwiftUI
import WebKit

@available(iOS 14.0, *)
struct PrivacyView: View {
    @EnvironmentObject var appState: AppState
    @State private var hasScrolledToBottom = false
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Welcome to Clemn")
                .font(.largeTitle)
                .bold()
                .padding(.top, 80)
            
            Text("Portrait Lighting & Composition Reference")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom, 20)
            
            HTMLView(htmlFileName: "PrivacyPolicy")
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                Text("By clicking 'Agree and Continue', you acknowledge that you have read and understood our Privacy Policy.")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Button(action: {
                    withAnimation {
                        appState.hasAgreedToPrivacy = true
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
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .padding(.top, 20)
        }
        .background(Color.white.edgesIgnoringSafeArea(.all))
    }
}

struct HTMLView: UIViewRepresentable {
    let htmlFileName: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.backgroundColor = .clear
        webView.isOpaque = false
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let path = Bundle.main.path(forResource: htmlFileName, ofType: "html", inDirectory: "Resources") {
            let url = URL(fileURLWithPath: path)
            uiView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        } else if let path = Bundle.main.path(forResource: htmlFileName, ofType: "html") {
            // Fallback for flat structure
            let url = URL(fileURLWithPath: path)
            uiView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
    }
}
