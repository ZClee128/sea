//
//  ProfileView.swift
//  Scenery
//
//  Created on 2026/1/14.
//

import SwiftUI

@available(iOS 16.0, *)
struct ProfileView: View {
    @StateObject private var authService = AuthService.shared
    @State private var posts: [Post] = []
    @State private var showSettings = false
    @State private var showLogin = false
    @State private var showIAP = false
    
    var currentUser: User? {
        authService.authState.currentUser
    }
    
    var isAuthenticated: Bool {
        authService.authState.isAuthenticated
    }
    
    var body: some View {
        NavigationView {
            Group {
                if isAuthenticated {
                    // Authenticated user profile
                    authenticatedProfileView
                } else {
                    // Guest user - show login prompt
                    guestProfileView
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isAuthenticated {
                        Button(action: { showSettings = true }) {
                            Image(systemName: "gearshape")
                                .foregroundColor(Color(hex: "2ECC71"))
                        }
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showLogin) {
                EmailInputView()
            }
            .sheet(isPresented: $showIAP) {
                InAppPurchaseView()
            }
            .onChange(of: authService.authState.isAuthenticated) { newValue in
                if newValue && showLogin {
                    showLogin = false
                }
            }
        }
    }
    
    // MARK: - Authenticated Profile
    private var authenticatedProfileView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile header
                VStack(spacing: 16) {
                    // Avatar
                    Circle()
                        .fill(Color(hex: "2ECC71"))
                        .frame(width: 100, height: 100)
                        .overlay(
                            Text(currentUser?.displayName.prefix(1).uppercased() ?? "U")
                                .font(.system(size: 40, weight: .semibold))
                                .foregroundColor(.white)
                        )
                    
                    VStack(spacing: 4) {
                        Text(currentUser?.displayName ?? "User")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("@\(currentUser?.username ?? "username")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if let bio = currentUser?.bio {
                            Text(bio)
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .padding(.top, 4)
                        }
                    }
                    
                    // Stats
                    HStack(spacing: 32) {
                        StatView(count: currentUser?.postCount ?? 0, label: "Posts")
                        StatView(count: currentUser?.followerCount ?? 0, label: "Followers")
                        StatView(count: currentUser?.followingCount ?? 0, label: "Following")
                    }
                    
                    // IAP button
                    Button(action: { showIAP = true }) {
                        HStack {
                            Image(systemName: "circle.grid.cross.fill")
                                .foregroundColor(Color(hex: "2ECC71"))
                            Text("Buy Coins")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color(hex: "2ECC71"))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color(hex: "2ECC71").opacity(0.1))
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                }
                .padding()
                
                // Posts grid
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 2),
                    GridItem(.flexible(), spacing: 2),
                    GridItem(.flexible(), spacing: 2)
                ], spacing: 2) {
                    ForEach(MockDataService.shared.mockPosts.filter { $0.userId == currentUser?.id }) { post in
                        AsyncImage(url: URL(string: post.mediaURL)) { phase in
                            switch phase {
                            case .empty:
                                Color.gray.opacity(0.3)
                                    .aspectRatio(1, contentMode: .fill)
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fill)
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fit)
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .clipped()
                    }
                }
            }
        }
    }
    
    // MARK: - Guest Profile
    private var guestProfileView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "person.crop.circle")
                .font(.system(size: 80))
                .foregroundColor(Color(hex: "2ECC71"))
            
            VStack(spacing: 8) {
                Text("Welcome to Sunni")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Login to view your profile, save posts, and connect with others")
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
}

@available(iOS 15.0, *)
struct StatView: View {
    let count: Int
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.headline)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

@available(iOS 16.0, *)
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
