//
//  PrivacyPolicyView.swift
//  joyar
//
//  Created by Antigravity on 01/06/2026.
//

import SwiftUI
import WebKit

struct HTMLWebView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.backgroundColor = .clear
        webView.isOpaque = false
        
        // Load local HTML file
        if let path = Bundle.main.path(forResource: "privacy_policy", ofType: "html") {
            let url = URL(fileURLWithPath: path)
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        } else {
            // Fallback content in case resource is missing
            let fallbackHTML = "<html><body style='background-color:#121214;color:#CBD5E0;font-family:sans-serif;'><h2>Privacy Policy not found</h2></body></html>"
            webView.loadHTMLString(fallbackHTML, baseURL: nil)
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

struct PrivacyPolicyView: View {
    @Binding var isAccepted: Bool
    @State private var hasCheckedTerms = false
    @State private var showAlert = false
    
    var body: some View {
        ZStack {
            // Deep premium dark background
            Color(red: 0.07, green: 0.07, blue: 0.08)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Header brand logo & title
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 48))
                        .foregroundColor(Color(red: 1.0, green: 0.37, blue: 0.23)) // #FF5E3A Brand color
                        .padding(.top, 30)
                    
                    Text("Welcome to Joyar")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Your Premium Fitness Partner")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                }
                
                // HTML Web View block
                VStack(alignment: .leading) {
                    Text("Privacy Terms & EULA Agreement")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.gray)
                        .padding(.horizontal, 16)
                        .padding(.top, 10)
                    
                    HTMLWebView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(red: 0.12, green: 0.12, blue: 0.14))
                        .cornerRadius(12)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 10)
                }
                .background(Color(red: 0.10, green: 0.10, blue: 0.12))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
                .padding(.horizontal, 16)
                
                // Agreement control panel
                VStack(spacing: 16) {
                    // Checkbox row
                    Button(action: {
                        withAnimation {
                            hasCheckedTerms.toggle()
                        }
                    }) {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: hasCheckedTerms ? "checkmark.square.fill" : "square")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(hasCheckedTerms ? Color(red: 1.0, green: 0.37, blue: 0.23) : .gray)
                            
                            Text("I agree to the End User License Agreement (EULA), Privacy Policy and certify that I consult my physical trainer before physical workout programs.")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.leading)
                                .lineLimit(3)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 20)
                    
                    // Interaction CTA button
                    Button(action: {
                        if hasCheckedTerms {
                            // Automatically register / log in the user via unique device IDFV as UDID
                            let udid = UIDevice.current.identifierForVendor?.uuidString ?? "JOYAR-DEV-ID-" + UUID().uuidString.prefix(12)
                            UserDefaults.standard.set(udid, forKey: "device_udid")
                            
                            // Persist acceptance in UserDefaults
                            UserDefaults.standard.set(true, forKey: "privacy_accepted")
                            withAnimation {
                                isAccepted = true
                            }
                        } else {
                            showAlert = true
                        }
                    }) {
                        Text("Agree & Continue")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 1.0, green: 0.37, blue: 0.23), // #FF5E3A
                                        Color(red: 1.0, green: 0.18, blue: 0.33)  // #FF2D55
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(26)
                            .shadow(color: Color(red: 1.0, green: 0.18, blue: 0.33).opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 25)
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Agreement Required"),
                message: Text("Please read and check the checkbox to agree to the Privacy Policy and EULA before accessing the application."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct PrivacyPolicyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyPolicyView(isAccepted: .constant(false))
            .preferredColorScheme(.dark)
    }
}
