//
//  PrivacyWebView.swift
//  melonShare
//
//  Created by zclee on 2026/5/19.
//

import SwiftUI
import WebKit

struct PrivacyWebView: UIViewRepresentable {
    let resourceName: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        
        // Load the HTML file from the main bundle
        if let url = Bundle.main.url(forResource: resourceName, withExtension: "html") {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        } else {
            // Fallback load error HTML if file not found
            let errorHTML = """
            <html>
            <body style="font-family: -apple-system; padding: 20px; text-align: center; color: #666;">
                <h3>Document Not Found</h3>
                <p>Unable to load the requested document. Please try again later.</p>
            </body>
            </html>
            """
            webView.loadHTMLString(errorHTML, baseURL: nil)
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // No dynamically changing URL updates are required for static policies
    }
}

// A beautiful sheet wrapper container for Privacy Policy / Terms that provides a navigation title and a Dismiss button.
struct LegalDocumentSheet: View {
    let title: String
    let resourceName: String
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            PrivacyWebView(resourceName: resourceName)
                .background(Color(red: 250/255, green: 250/255, blue: 250/255).edgesIgnoringSafeArea(.all))
                .navigationBarTitle(Text(title), displayMode: .inline)
                .navigationBarItems(trailing: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Done")
                        .bold()
                        .foregroundColor(Color(red: 255/255, green: 90/255, blue: 121/255))
                })
        }
        .preferredColorScheme(.light)
    }
}

struct PrivacyWebView_Previews: PreviewProvider {
    static var previews: some View {
        LegalDocumentSheet(title: "Privacy Policy", resourceName: "PrivacyPolicy")
    }
}
