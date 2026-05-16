//
//  WebView.swift
//  vibble
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let htmlContent: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.backgroundColor = .clear
        webView.isOpaque = false
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // 使用针对深色模式优化的 CSS
        let styledHtml = """
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
                    background-color: transparent;
                    color: white;
                    padding: 20px;
                    line-height: 1.6;
                }
                h1 { color: #FF2D55; font-size: 24px; }
                h2 { color: #FF2D55; font-size: 18px; margin-top: 30px; }
                p { color: #CCCCCC; font-size: 14px; }
                .footer { margin-top: 50px; font-size: 12px; color: #666666; text-align: center; }
            </style>
        </head>
        <body>
            \(htmlContent)
        </body>
        </html>
        """
        uiView.loadHTMLString(styledHtml, baseURL: nil)
    }
}
