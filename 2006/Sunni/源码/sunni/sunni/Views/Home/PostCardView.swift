//
//  PostCardView.swift
//  Scenery
//
//  Created on 2026/1/14.
//

import SwiftUI

@available(iOS 15.0, *)
struct PostCardView: View {
    let post: Post
    @StateObject private var authService = AuthService.shared
    @State private var isLiked: Bool
    @State private var likeCount: Int
    @State private var showReportSheet = false
    @State private var showUserProfile = false
    @State private var showLoginPrompt = false
    
    init(post: Post) {
        self.post = post
        self._isLiked = State(initialValue: post.isLiked)
        self._likeCount = State(initialValue: post.likeCount)
    }
    
    var isAuthenticated: Bool {
        authService.authState.isAuthenticated
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // User header
            HStack {
                Button(action: { showUserProfile = true }) {
                    HStack(spacing: 12) {
                        // Avatar
                        Circle()
                            .fill(Color(hex: "2ECC71"))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text(post.user.displayName.prefix(1).uppercased())
                                    .foregroundColor(.white)
                                    .fontWeight(.semibold)
                            )
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(post.user.displayName)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            if let location = post.location {
                                HStack(spacing: 4) {
                                    Image(systemName: "mappin.circle.fill")
                                        .font(.caption2)
                                    Text(location)
                                        .font(.caption)
                                }
                                .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Spacer()
                
                // More menu
                if isAuthenticated {
                    Menu {
                        Button(action: { showReportSheet = true }) {
                            Label("Report Post", systemImage: "exclamationmark.triangle")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.gray)
                            .padding(8)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            .padding(.bottom, 8)
            
            // Media content
            if post.type == .video {
                VideoPlayerView(videoName: post.mediaURL)
                    .frame(height: 400)
                    .clipped()
            } else {
                // Network image
                AsyncImage(url: URL(string: post.mediaURL)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(height: 400)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 400)
                            .clipped()
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 400)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(height: 400)
            }
            
            // Action buttons
            HStack(spacing: 20) {
                Button(action: handleLike) {
                    HStack(spacing: 6) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundColor(isLiked ? .red : .primary)
                        Text("\(likeCount)")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                }
                
                Button(action: handleComment) {
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.right")
                        Text("\(post.commentCount)")
                            .font(.subheadline)
                    }
                }
                .foregroundColor(.primary)
                
                Button(action: {}) {
                    Image(systemName: "paperplane")
                }
                .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            // Caption
            Text(post.caption)
                .font(.subheadline)
                .lineLimit(3)
                .padding(.horizontal, 12)
            
            // Timestamp
            Text(timeAgoSince(post.createdAt))
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 12)
                .padding(.top, 4)
                .padding(.bottom, 12)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .sheet(isPresented: $showReportSheet) {
            ReportView(reportType: .post, targetId: post.id)
        }
        .sheet(isPresented: $showUserProfile) {
            OtherUserProfileView(user: post.user)
        }
        .alert("Login Required", isPresented: $showLoginPrompt) {
            Button("Cancel", role: .cancel) {}
            Button("Login") {
                // Navigate to login
            }
        } message: {
            Text("Please login to interact with posts")
        }
    }
    
    private func handleLike() {
        guard isAuthenticated else {
            showLoginPrompt = true
            return
        }
        isLiked.toggle()
        likeCount += isLiked ? 1 : -1
    }
    
    private func handleComment() {
        guard isAuthenticated else {
            showLoginPrompt = true
            return
        }
        // Navigate to comment view
    }
    
    private func timeAgoSince(_ date: Date) -> String {
        let seconds = Date().timeIntervalSince(date)
        
        if seconds < 60 {
            return "just now"
        } else if seconds < 3600 {
            let minutes = Int(seconds / 60)
            return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
        } else if seconds < 86400 {
            let hours = Int(seconds / 3600)
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        } else {
            let days = Int(seconds / 86400)
            return "\(days) day\(days == 1 ? "" : "s") ago"
        }
    }
}

@available(iOS 15.0, *)
struct PostCardView_Previews: PreviewProvider {
    static var previews: some View {
        PostCardView(post: MockDataService.shared.mockPosts[0])
            .padding()
    }
}
