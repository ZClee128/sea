//
//  LoginView.swift
//  Scenery
//
//  Created on 2026/1/14.
//

import SwiftUI

@available(iOS 16.0, *)
struct LoginView: View {
    let email: String
    
    @StateObject private var authService = AuthService.shared
    @State private var password: String = ""
    @State private var rememberMe: Bool = true
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
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
                    
                    Text("Welcome Back")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(email)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Login form
                VStack(spacing: 16) {
                    // Password field
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.gray)
                        
                        SecureField("Password", text: $password)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    // Remember me
                    Toggle("Remember me", isOn: $rememberMe)
                        .tint(Color(hex: "2ECC71"))
                    
                    // Login button
                    Button(action: handleLogin) {
                        Text("Login")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "2ECC71"))
                            .cornerRadius(12)
                    }
                    .disabled(password.isEmpty)
                    .opacity(password.isEmpty ? 0.6 : 1.0)
                    
                    // Forgot password
                    Button("Forgot Password?") {
                        // TODO: Implement forgot password
                    }
                    .foregroundColor(Color(hex: "3498DB"))
                    
                    if showError {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(false)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: authService.authState.isAuthenticated) { newValue in
            if newValue {
                // Dismiss entire navigation stack by popping to root
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    private func handleLogin() {
        errorMessage = ""
        showError = false
        
        authService.login(email: email, password: password, rememberMe: rememberMe) { success in
            if !success {
                errorMessage = "Invalid email or password"
                showError = true
            }
        }
    }
}

@available(iOS 16.0, *)
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LoginView(email: "alex@example.com")
        }
    }
}
