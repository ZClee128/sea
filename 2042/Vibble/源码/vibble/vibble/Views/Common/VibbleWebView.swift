//
//  VibbleWebView.swift
//  vibble
//

import SwiftUI
import WebKit

struct VibbleWebView: UIViewRepresentable {
    let fileName: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.backgroundColor = .clear
        webView.isOpaque = false
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // 纯净读取逻辑：不再包裹任何 Swift 里的 CSS 样式，完全尊重 HTML 文件原样
        
        // 1. 优先从 Bundle 读取
        if let bundleUrl = Bundle.main.url(forResource: fileName, withExtension: "html") {
            uiView.loadFileURL(bundleUrl, allowingReadAccessTo: bundleUrl.deletingLastPathComponent())
            return
        }
    }
}
