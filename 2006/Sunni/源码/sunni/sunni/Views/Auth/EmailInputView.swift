//
//  EmailInputView.swift
//  Scenery
//
//  Created on 2026/1/14.
//

import SwiftUI

@available(iOS 16.0, *)
struct EmailInputView: View {
    @State private var email: String = ""
    @State private var navigateToLogin: Bool = false
    @State private var navigateToRegister: Bool = false
    
    private let authService = AuthService.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "E8F5E9"),
                        Color(hex: "C8E6C9"),
                        Color(hex: "A5D6A7")
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    Spacer()
                    
                    // Logo
                    VStack(spacing: 8) {
                        Image(systemName: "mountain.2.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color(hex: "2ECC71"))
                        
                        Text("Sunni")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    // Email input
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.gray)
                            
                            TextField("Enter your email", text: $email)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .autocorrectionDisabled()
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        
                        // Continue button
                        Button(action: handleContinue) {
                            Text("Continue")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hex: "2ECC71"))
                        }
                        .cornerRadius(12)
                        .disabled(email.isEmpty)
                        .opacity(email.isEmpty ? 0.6 : 1.0)
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                    
                    // Sign up link
                    HStack(spacing: 4) {
                        Text("New to Scenery?")
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            navigateToRegister = true
                        }) {
                            Text("Sign up")
                                .fontWeight(.semibold)
                                .foregroundColor(Color(hex: "2ECC71"))
                        }
                    }
                    .padding(.bottom, 32)
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToLogin) {
                if #available(iOS 14.0, *) {
                    LoginView(email: email)
                } else {
                    EmptyView()
                }
            }
            .navigationDestination(isPresented: $navigateToRegister) {
                if #available(iOS 15.0, *) {
                    RegisterView(email: email)
                } else {
                    EmptyView()
                }
            }
        }
    }
    
    private func handleContinue() {
        let emailExists = authService.checkEmailExists(email)
        
        if emailExists {
            navigateToLogin = true
        } else {
            navigateToRegister = true
        }
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

@available(iOS 16.0, *)
struct EmailInputView_Previews: PreviewProvider {
    static var previews: some View {
        EmailInputView()
    }
}
