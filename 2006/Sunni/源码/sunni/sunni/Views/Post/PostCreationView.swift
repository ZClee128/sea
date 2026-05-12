//
//  PostCreationView.swift
//  Scenery
//
//  Created on 2026/1/14.
//

import SwiftUI
import PhotosUI

@available(iOS 16.0, *)
struct PostCreationView: View {
    @StateObject private var authService = AuthService.shared
    @State private var selectedItem: PhotosPickerItem?
    @State private var caption: String = ""
    @State private var location: String = ""
    @State private var showingImagePicker = false
    @State private var isUploading = false
    @State private var showLogin = false
    @Environment(\.dismiss) var dismiss
    
    var isAuthenticated: Bool {
        authService.authState.isAuthenticated
    }
    
    var body: some View {
        NavigationView {
            Group {
                if isAuthenticated {
                    // Authenticated - show post creation
                    postCreationForm
                } else {
                    // Guest - show login prompt
                    loginPrompt
                }
            }
            .navigationTitle("Create Post")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showLogin) {
                EmailInputView()
            }
            .onChange(of: authService.authState.isAuthenticated) { newValue in
                if newValue && showLogin {
                    showLogin = false
                }
            }
        }
    }
    
    // MARK: - Post Creation Form
    private var postCreationForm: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Media picker
                PhotosPicker(selection: $selectedItem, matching: .any(of: [.images, .videos])) {
                    VStack(spacing: 16) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 60))
                            .foregroundColor(Color(hex: "2ECC71"))
                        
                        Text("Select Photo or Video")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding()
                
                // Caption
                VStack(alignment: .leading, spacing: 8) {
                    Text("Caption")
                        .font(.headline)
                    
                    TextEditor(text: $caption)
                        .frame(height: 100)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                // Location
                VStack(alignment: .leading, spacing: 8) {
                    Text("Location (Optional)")
                        .font(.headline)
                    
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(Color(hex: "2ECC71"))
                        
                        TextField("Add location", text: $location)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                .padding(.horizontal)
                
                // Post button
                Button(action: handlePost) {
                    if isUploading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Share Post")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "2ECC71"))
                .cornerRadius(12)
                .padding()
                .disabled(caption.isEmpty || isUploading)
                .opacity(caption.isEmpty ? 0.6 : 1.0)
            }
        }
    }
    
    // MARK: - Login Prompt
    private var loginPrompt: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "plus.circle")
                .font(.system(size: 80))
                .foregroundColor(Color(hex: "2ECC71"))
            
            VStack(spacing: 8) {
                Text("Share Your Journey")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Login to share beautiful landscapes with the community")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Button(action: { showLogin = true }) {
                Text("Login / Sign Up")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "2ECC71"))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 32)
            .padding(.top, 16)
            
            Spacer()
        }
    }
    
    private func handlePost() {
        isUploading = true
        
        // Simulate upload
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isUploading = false
            // Reset form
            caption = ""
            location = ""
            selectedItem = nil
        }
    }
}

@available(iOS 16.0, *)
struct PostCreationView_Previews: PreviewProvider {
    static var previews: some View {
        PostCreationView()
    }
}
