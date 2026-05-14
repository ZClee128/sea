import SwiftUI
import WebKit

struct PrivacyView: View {
    var onAgree: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Text("User Agreement & Privacy")
                .font(.headline)
                .padding()
            
            HTMLView(fileName: "privacy")
                .border(Color.gray.opacity(0.2))
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                Text("By clicking Agree, you confirm that you have read and accepted our Privacy Policy.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button(action: onAgree) {
                    Text("Agree and Enter")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 20)
            .background(Color.white)
            .shadow(radius: 2)
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
}

struct HTMLView: UIViewRepresentable {
    let fileName: String
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "html") {
            uiView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
    }
}
