//
//  AuthWelcomeView.swift
//  melonShare
//
//  Created by zclee on 2026/5/19.
//

import SwiftUI

struct AuthWelcomeView: View {
    @ObservedObject private var auth = AuthManager.shared
    
    @State private var isRegistering = false
    @State private var emailInput = ""
    @State private var passwordInput = ""
    @State private var nicknameInput = ""
    @State private var confirmPasswordInput = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showingPrivacySheet = false
    
    var body: some View {
        ZStack {
            Theme.backgroundGray.edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Visual Branding
                    VStack(spacing: 8) {
                        Circle()
                            .fill(Theme.accentGradient)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: "sparkles.tv")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white)
                            )
                            .shadow(color: Theme.accentPink.opacity(0.3), radius: 12, x: 0, y: 6)
                        
                        Text("MelonShare")
                            .font(.title)
                            .bold()
                            .foregroundColor(Theme.textDark)
                        
                        Text("Short Drama Recommendations & Trackers")
                            .font(.caption)
                            .foregroundColor(Theme.textMedium)
                    }
                    .padding(.top, 60)
                    .padding(.bottom, 10)
                    
                    // Auth Inputs Card
                    GlassCard(padding: 20) {
                        VStack(spacing: 16) {
                            Text(isRegistering ? "Create New Profile" : "User System Access")
                                .font(.headline)
                                .bold()
                                .foregroundColor(Theme.textDark)
                            
                            if isRegistering {
                                TextField("Author Nickname", text: $nicknameInput)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                            TextField("Email Address", text: $emailInput)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            SecureField("Account Password", text: $passwordInput)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            if isRegistering {
                                SecureField("Confirm Password", text: $confirmPasswordInput)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                            PrimaryButton(title: isRegistering ? "Sign Up" : "Log In") {
                                handleAuthAction()
                            }
                            
                            Button(action: {
                                withAnimation {
                                    isRegistering.toggle()
                                    // Reset inputs
                                    emailInput = ""
                                    passwordInput = ""
                                    nicknameInput = ""
                                    confirmPasswordInput = ""
                                }
                            }) {
                                Text(isRegistering ? "Already have an account? Log In" : "Don't have an account? Register Here")
                                    .font(.caption)
                                    .bold()
                                    .foregroundColor(Theme.primaryPeach)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Local Privacy check footer
                    Button(action: { showingPrivacySheet = true }) {
                        Text("By accessing MelonShare, you agree to our Privacy Policy.")
                            .font(.caption2)
                            .foregroundColor(Theme.textLight)
                            .underline()
                    }
                    .sheet(isPresented: $showingPrivacySheet) {
                        LegalDocumentSheet(title: "Privacy Policy", resourceName: "PrivacyPolicy")
                    }
                    
                    Spacer()
                }
            }
            .background(Theme.backgroundGray)
            .simultaneousGesture(
                TapGesture().onEnded {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            )
        }
        .onAppear {
            emailInput = ""
            passwordInput = ""
            nicknameInput = ""
            confirmPasswordInput = ""
            isRegistering = false
        }
        .preferredColorScheme(.light)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Authentication Failed"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func handleAuthAction() {
        if emailInput.isEmpty || passwordInput.isEmpty {
            alertMessage = "Please complete all credentials."
            showAlert = true
            return
        }
        
        if isRegistering {
            if nicknameInput.isEmpty {
                alertMessage = "Please specify a nickname for your author profile."
                showAlert = true
                return
            }
            if passwordInput != confirmPasswordInput {
                alertMessage = "Passwords do not match."
                showAlert = true
                return
            }
            auth.signup(email: emailInput, name: nicknameInput, password: passwordInput)
        } else {
            let success = auth.login(email: emailInput, password: passwordInput)
            if !success {
                let lowercasedEmail = emailInput.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                if UserDefaults.standard.string(forKey: "melonshare_password_\(lowercasedEmail)") == nil && lowercasedEmail != "melon@melon.com" {
                    alertMessage = "Account does not exist. Please register first!"
                } else {
                    alertMessage = "Incorrect password. Please try again!"
                }
                showAlert = true
            }
        }
    }
}
