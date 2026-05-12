//
//  OtherUserProfileView.swift
//  Scenery
//
//  Created on 2026/1/14.
//

import SwiftUI

@available(iOS 15.0, *)
struct OtherUserProfileView: View {
    let user: User
    @State private var isFollowing: Bool
    @State private var showReportSheet = false
    @State private var showBlockConfirm = false
    @State private var isBlocked: Bool
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var blockService = BlockService.shared
    
    init(user: User) {
        self.user = user
        self._isFollowing = State(initialValue: user.isFollowing)
        self._isBlocked = State(initialValue: BlockService.shared.isUserBlocked(user.id))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile header
                    VStack(spacing: 16) {
                        // Avatar
                        Circle()
                            .fill(Color(hex: "2ECC71"))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Text(user.displayName.prefix(1).uppercased())
                                    .font(.system(size: 40, weight: .semibold))
                                    .foregroundColor(.white)
                            )
                        
                        VStack(spacing: 4) {
                            Text(user.displayName)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("@\(user.username)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            if let bio = user.bio {
                                Text(bio)
                                    .font(.subheadline)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 4)
                            }
                        }
                        
                        // Stats
                        HStack(spacing: 32) {
                            StatView(count: user.postCount, label: "Posts")
                            StatView(count: user.followerCount, label: "Followers")
                            StatView(count: user.followingCount, label: "Following")
                        }
                        
                        // Action buttons
                        HStack(spacing: 12) {
                            Button(action: toggleFollow) {
                                Text(isFollowing ? "Following" : "Follow")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(isFollowing ? .primary : .white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(isFollowing ? Color(.systemGray5) : Color(hex: "2ECC71"))
                                    .cornerRadius(8)
                            }
                            
                            Button(action: {}) {
                                Text("Message")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(hex: "2ECC71"))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(Color(hex: "2ECC71").opacity(0.1))
                                    .cornerRadius(8)
                            }
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
                        ForEach(MockDataService.shared.mockPosts.filter { $0.userId == user.id }) { post in
                            Image(post.mediaURL)
                                .resizable()
                                .aspectRatio(1, contentMode: .fill)
                                .clipped()
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(role: .destructive, action: { showBlockConfirm = true }) {
                            Label(isBlocked ? "Unblock User" : "Block User", systemImage: "hand.raised")
                        }
                        
                        Button(action: { showReportSheet = true }) {
                            Label("Report User", systemImage: "exclamationmark.triangle")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.primary)
                    }
                }
            }
            .alert("Block User", isPresented: $showBlockConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Block", role: .destructive) {
                    toggleBlock()
                }
            } message: {
                Text("Are you sure you want to block @\(user.username)? They won't be able to see your posts or contact you.")
            }
            .sheet(isPresented: $showReportSheet) {
                ReportView(reportType: .user, targetId: user.id)
            }
        }
    }
    
    private func toggleFollow() {
        isFollowing.toggle()
    }
    
    private func toggleBlock() {
        if isBlocked {
            blockService.unblockUser(user.id)
            isBlocked = false
        } else {
            blockService.blockUser(user.id)
            isBlocked = true
            dismiss()
        }
    }
}

@available(iOS 15.0, *)
struct OtherUserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        OtherUserProfileView(user: MockDataService.shared.mockUsers[1])
    }
}
