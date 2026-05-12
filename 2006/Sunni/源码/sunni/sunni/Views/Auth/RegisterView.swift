//
//  RegisterView.swift
//  Scenery
//
//  Created on 2026/1/14.
//

import SwiftUI

@available(iOS 15.0, *)
struct RegisterView: View {
    let email: String
    
    @StateObject private var authService = AuthService.shared
    @State private var username: String = ""
    @State private var displayName: String = ""
    @State private var password: String = ""
    @State private var agreedToTerms: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var showTerms = false
    @State private var showPrivacy = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "F5F5F5")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Title
                    VStack(spacing: 8) {
                        Text("Create Account")
                            .font(.system(size: 32, weight: .bold))
                            .padding(.top, 40)
                        
                        Text(email)
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    
                    // Form fields
                    VStack(spacing: 16) {
                        // Username
                        HStack {
                            Image(systemName: "at")
                                .foregroundColor(.gray)
                            TextField("Username", text: $username)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 3)
                        
                        // Display name
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(.gray)
                            TextField("Display Name", text: $displayName)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 3)
                        
                        // Password
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.gray)
                            SecureField("Password", text: $password)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 3)
                        
                        // Terms agreement
                        VStack(alignment: .leading, spacing: 8) {
                            Toggle(isOn: $agreedToTerms) {
                                Text("I agree to the")
                                    .font(.caption)
                            }
                            .tint(Color(hex: "2ECC71"))
                            
                            HStack(spacing: 4) {
                                Button("Terms of Service") {
                                    showTerms = true
                                }
                                .font(.caption)
                                .foregroundColor(Color(hex: "3498DB"))
                                
                                Text("and")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Button("Privacy Policy") {
                                    showPrivacy = true
                                }
                                .font(.caption)
                                .foregroundColor(Color(hex: "3498DB"))
                            }
                        }
                        .padding(.top, 8)
                        
                        // Register button
                        Button(action: handleRegister) {
                            Text("Create Account")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hex: "2ECC71"))
                                .cornerRadius(12)
                        }
                        .disabled(!isFormValid)
                        .opacity(isFormValid ? 1.0 : 0.6)
                        
                        if showError {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer(minLength: 40)
                }
            }
            .sheet(isPresented: $showTerms) {
                TermsView()
            }
            .sheet(isPresented: $showPrivacy) {
                PrivacyView()
            }
            .onChange(of: authService.authState.isAuthenticated) { newValue in
                if newValue {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !username.isEmpty &&
        !displayName.isEmpty &&
        !password.isEmpty &&
        agreedToTerms
    }
    
    private func validateForm() -> Bool {
        if password.count < 6 {
            errorMessage = "Password must be at least 6 characters"
            showError = true
            return false
        }
        return true
    }
    
    private func handleRegister() {
        errorMessage = ""
        
        guard validateForm() else { return }
        
        authService.register(email: email, username: username, displayName: displayName, password: password) { success in
            if !success {
                errorMessage = "Registration failed. Email may already exist."
                showError = true
            }
        }
    }
}

// MARK: - Terms & Privacy Views
@available(iOS 15.0, *)
struct TermsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text("Terms of Service")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                
                Text("""
                Welcome to Scenery!
                
                By using our app, you agree to these terms...
                
                [Full terms would go here]
                """)
                .padding()
            }
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}

@available(iOS 15.0, *)
struct PrivacyView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text("Privacy Policy")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                
                Text("""
                Your privacy is important to us.
                
                [Full privacy policy would go here]
                """)
                .padding()
            }
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}

@available(iOS 15.0, *)
struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RegisterView(email: "newuser@example.com")
        }
    }
}
