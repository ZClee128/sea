import SwiftUI
import WebKit

struct OnboardingView: View {
    let onAgree: () -> Void
    
    @State private var showPrivacy = false
    @State private var showTerms = false
    
    var body: some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 1.0, green: 0.95, blue: 0.9),
                    Color(red: 0.98, green: 0.9, blue: 0.85)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                Spacer()
                
                // Logo和标题
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(red: 1.0, green: 0.8, blue: 0.4), Color(red: 1.0, green: 0.6, blue: 0.2)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                }
                .shadow(color: Color.orange.opacity(0.3), radius: 20, x: 0, y: 10)
                
                Text("Sunny")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.9, green: 0.5, blue: 0.2))
                    .padding(.top, 16)
                
                Text("Your Style, Your Sunshine")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
                    .padding(.top, 4)
                
                Spacer()
                
                // 协议内容
                VStack(spacing: 16) {
                    Text("Please read and agree to our terms to continue")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    
                    // 协议链接按钮
                    HStack(spacing: 20) {
                        Button(action: { showPrivacy = true }) {
                            HStack(spacing: 4) {
                                Image(systemName: "doc.text")
                                    .font(.system(size: 12))
                                Text("Privacy Policy")
                                    .font(.system(size: 13))
                            }
                            .foregroundColor(Color(red: 0.9, green: 0.5, blue: 0.2))
                        }
                        
                        Button(action: { showTerms = true }) {
                            HStack(spacing: 4) {
                                Image(systemName: "doc.text.fill")
                                    .font(.system(size: 12))
                                Text("Terms of Service")
                                    .font(.system(size: 13))
                            }
                            .foregroundColor(Color(red: 0.9, green: 0.5, blue: 0.2))
                        }
                    }
                    
                    // 同意按钮
                    Button(action: onAgree) {
                        Text("Agree & Continue")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(red: 1.0, green: 0.6, blue: 0.2), Color(red: 1.0, green: 0.5, blue: 0.1)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(25)
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                }
                .padding(.bottom, 60)
            }
        }
        .sheet(isPresented: $showPrivacy) {
            WebView(htmlFile: "PrivacyPolicy")
        }
        .sheet(isPresented: $showTerms) {
            WebView(htmlFile: "TermsOfService")
        }
    }
}

// WebView用于显示本地HTML文件
struct WebView: UIViewRepresentable {
    let htmlFile: String
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        
        // 加载本地HTML文件
        if let url = Bundle.main.url(forResource: htmlFile, withExtension: "html") {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(onAgree: {})
    }
}
