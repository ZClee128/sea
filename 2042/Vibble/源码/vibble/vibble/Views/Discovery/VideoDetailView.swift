//
//  VideoDetailView.swift
//  vibble
//

import SwiftUI
import AVFoundation

@available(iOS 14.0, *)
struct VideoDetailView: View {
    let video: Video
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var commentManager = CommentManager.shared
    @StateObject private var clubManager = ClubManager.shared
    @State private var newCommentText = ""
    @State private var showReport = false
    
    private let screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 1. 顶部视频封面 (优先显示用户选中的图)
                ZStack(alignment: .topLeading) {
                    Group {
                        if let uiImage = video.userImage {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                        } else {
                            VideoThumbnailView(videoName: video.videoName)
                                .scaledToFill()
                        }
                    }
                    .aspectRatio(16/9, contentMode: .fill)
                    .frame(width: screenWidth - 40)
                    .frame(height: 250)
                    .background(Color.black)
                    .cornerRadius(20)
                    .clipped()
                    .padding(.top, 40)
                    
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    .padding(.top, 50)
                    .padding(.leading, 15)
                }
                .frame(width: screenWidth)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // 2. 剧集讨论标题
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(alignment: .top) {
                                Text(video.dramaTitle)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 8) {
                                    Text("#\(video.category) Club")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(Theme.primary)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Theme.primary.opacity(0.1))
                                        .cornerRadius(8)
                                    
                                    // 帖子举报按钮
                                    Button(action: { showReport = true }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "exclamationmark.triangle")
                                            Text("Report Post")
                                        }
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.gray.opacity(0.8))
                                    }
                                }
                            }
                            
                            Text(video.description)
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.horizontal, 25)
                        .padding(.top, 20)
                        .frame(width: screenWidth, alignment: .leading)
                        
                        Divider().background(Color.gray.opacity(0.3)).padding(.horizontal, 25)
                        
                        // 3. 论坛讨论列表
                        VStack(alignment: .leading, spacing: 15) {
                            Text("COMMUNITY DISCUSSION")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.gray)
                                .padding(.horizontal, 25)
                            
                            if commentManager.currentComments.isEmpty {
                                VStack(spacing: 20) {
                                    Image(systemName: "bubble.left.and.bubble.right")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray.opacity(0.4))
                                    Text("Be the first to start the discussion!")
                                        .foregroundColor(.gray)
                                }
                                .frame(width: screenWidth)
                                .padding(.vertical, 40)
                            } else {
                                ForEach(commentManager.currentComments) { comment in
                                    ForumPostView(comment: comment, screenWidth: screenWidth) {
                                        showReport = true
                                    }
                                }
                            }
                        }
                        
                        Spacer(minLength: 120)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                .frame(width: screenWidth)
            }
            
            // 4. 底部评论输入框
            VStack(spacing: 0) {
                Divider().background(Color.gray.opacity(0.3))
                HStack(spacing: 15) {
                    TextField("Share your thoughts...", text: $newCommentText)
                        .padding(12)
                        .background(Theme.cardBackground)
                        .cornerRadius(20)
                        .foregroundColor(.white)
                    
                    Button(action: {
                        if !newCommentText.isEmpty {
                            commentManager.addComment(to: video.dramaTitle, text: newCommentText, user: "You")
                            newCommentText = ""
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    }) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Theme.primary)
                            .padding(10)
                            .background(Theme.primary.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Theme.background.opacity(0.95))
            }
            .frame(width: screenWidth)
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showReport) {
            ReportView(targetUsername: video.userName)
        }
        .onAppear {
            commentManager.loadComments(for: video.dramaTitle)
        }
    }
}

// MARK: - 精简版论坛贴子 (仅举报)

@available(iOS 14.0, *)
struct ForumPostView: View {
    let comment: Comment
    let screenWidth: CGFloat
    let onReport: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Circle()
                    .fill(comment.color.opacity(0.2))
                    .frame(width: 36, height: 36)
                    .overlay(Text(String(comment.user.first!)).foregroundColor(comment.color).bold())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(comment.user)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    Text("Top Contributor")
                        .font(.system(size: 10))
                        .foregroundColor(Theme.primary)
                }
                Spacer()
                
                Button(action: onReport) {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.bubble")
                        Text("Report")
                    }
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.gray.opacity(0.7))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(10)
                }
            }
            
            Text(comment.text)
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(4)
                .padding(.leading, 48)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(width: screenWidth - 40)
        .background(Theme.cardBackground.opacity(0.4))
        .cornerRadius(15)
        .padding(.horizontal, 20)
    }
}
