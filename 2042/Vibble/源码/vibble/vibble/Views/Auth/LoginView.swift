//
//  LoginView.swift
//  vibble
//

import SwiftUI

@available(iOS 14.0, *)
struct LoginView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            // 背景渐变
            Theme.background.edgesIgnoringSafeArea(.all)
            
            // 装饰性背景球
            Circle()
                .fill(Theme.primary.opacity(0.1))
                .frame(width: 400, height: 400)
                .blur(radius: 80)
                .offset(x: -150, y: -250)
            
            VStack(spacing: 40) {
                VStack(spacing: 15) {
                    Image(systemName: "v.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(Theme.primary)
                        .shadow(color: Theme.primary.opacity(0.5), radius: 20)
                    
                    Text("Vibble")
                        .font(.system(size: 40, weight: .black))
                        .foregroundColor(Color.white)
                    
                    Text("Discover your next obsession.")
                        .font(.subheadline)
                        .foregroundColor(Color.gray)
                }
                .padding(.top, 50)
                
                VStack(spacing: 20) {
                    CustomTextField(icon: "envelope.fill", placeholder: "Email", text: $email)
                    CustomTextField(icon: "lock.fill", placeholder: "Password", text: $password, isSecure: true)
                }
                .padding(.horizontal, 30)
                
                Button(action: handleLogin) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white)) // iOS 14 兼容写法
                        } else {
                            Text("Enter Vibble").font(.headline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(Theme.Gradients.primaryGradient)
                    .foregroundColor(Color.white)
                    .cornerRadius(15)
                    .shadow(color: Theme.primary.opacity(0.3), radius: 10, y: 5)
                }
                .padding(.horizontal, 30)
                .disabled(isLoading)
                
                Text("Login or Register automatically with email.")
                    .font(.caption)
                    .foregroundColor(Color.gray)
                
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture { UIApplication.shared.endEditing() }
        }
        .alert(isPresented: $showError) {
            Alert(title: Text("Auth Message"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func handleLogin() {
        withAnimation {
            isLoading = true
            let result = authManager.loginOrRegister(email: email, password: password)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                isLoading = false
                if !result.success {
                    errorMessage = result.message
                    showError = true
                }
            }
        }
    }
}

@available(iOS 14.0, *)
struct CustomTextField: View {
    let icon: String; let placeholder: String; @Binding var text: String; var isSecure: Bool = false
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon).foregroundColor(Theme.primary).frame(width: 20)
            if isSecure {
                SecureField("", text: $text)
                    .placeholder(when: text.isEmpty) { 
                        Text(placeholder).foregroundColor(Color.gray.opacity(0.7)) 
                    }
                    .foregroundColor(Color.white)
            } else {
                TextField("", text: $text)
                    .placeholder(when: text.isEmpty) { 
                        Text(placeholder).foregroundColor(Color.gray.opacity(0.7)) 
                    }
                    .foregroundColor(Color.white).autocapitalization(.none)
            }
        }
        .padding().background(Theme.cardBackground).cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
    }
}
