import SwiftUI

struct FeedDetailView: View {
    @EnvironmentObject var stageData: StageDataRepository
    @Environment(\.presentationMode) var presentationMode
    @State var post: CommunityPost
    @State private var commentText: String = ""
    @State private var localComments: [Comment] = []
    
    @State private var showingReportPostSheet = false
    @State private var reportedComment: Comment? = nil
    @State private var showingReportSuccessAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.08, blue: 0.10)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Detailed card of the post
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 12) {
                            Text(post.creatorAvatar)
                                .font(.system(size: 20))
                                .frame(width: 40, height: 40)
                                .background(Color.white.opacity(0.1))
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(post.creator)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)
                                Text(post.creatorRole)
                                    .font(.system(size: 11))
                                    .foregroundColor(Color(red: 1.00, green: 0.00, blue: 0.50))
                            }
                            
                            Spacer()
                            
                            Text(post.timestamp)
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                            
                            Button(action: {
                                showingReportPostSheet = true
                            }) {
                                Image(systemName: "flag")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                                    .padding(6)
                            }
                        }
                        
                        Text(post.content)
                            .font(.system(size: 15))
                            .lineSpacing(6)
                            .foregroundColor(.white.opacity(0.95))
                        
                        // Graphic visual coordinates card / Cosplay photo
                        ZStack(alignment: .bottomTrailing) {
                            if let uiImage = loadBundleImage(post.imageName) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 220)
                                    .clipped()
                                    .cornerRadius(12)
                            } else {
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: post.gradientStart), Color(hex: post.gradientEnd)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                .frame(height: 180)
                                .cornerRadius(12)
                                .overlay(
                                    VStack(spacing: 10) {
                                        Image(systemName: post.iconName)
                                            .font(.system(size: 40))
                                            .foregroundColor(.white)
                                        
                                        Text("STAGE COORDINATES MAP")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(.white.opacity(0.9))
                                            .tracking(2)
                                    }
                                )
                            }
                            
                            // Bottom gradient scrim for tag readability
                            LinearGradient(
                                gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.55)]),
                                startPoint: .center,
                                endPoint: .bottom
                            )
                            .frame(height: 80)
                            .cornerRadius(12)
                            
                            Text(post.tag)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(6)
                                .padding(12)
                        }
                        .frame(height: loadBundleImage(post.imageName) != nil ? 220 : 180)
                        .cornerRadius(12)
                        .clipped()
                        
                        // Action row
                        HStack(spacing: 24) {
                            Button(action: {
                                toggleLike()
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: post.isLiked ? "heart.fill" : "heart")
                                        .foregroundColor(post.isLiked ? .red : .gray)
                                    Text("\(post.likes) Likes")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                            
                            HStack(spacing: 6) {
                                Image(systemName: "bubble.right")
                                    .foregroundColor(.gray)
                                Text("\(localComments.count) Feedback")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                        }
                        .padding(.top, 8)
                    }
                    .padding(20)
                    .background(Color(red: 0.12, green: 0.12, blue: 0.15))
                    .cornerRadius(16)
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    
                    // Comments block
                    VStack(alignment: .leading, spacing: 16) {
                        Text("FEEDBACK LOGS")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 20)
                        
                        // Text input for adding comment
                        HStack(spacing: 12) {
                            TextField("Add feedback description...", text: $commentText)
                                .font(.system(size: 14))
                                .padding(12)
                                .background(Color.white.opacity(0.06))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                            
                            Button(action: {
                                submitComment()
                            }) {
                                Image(systemName: "paperplane.fill")
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background(Color(red: 1.00, green: 0.00, blue: 0.50))
                                    .clipShape(Circle())
                            }
                            .disabled(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                        .padding(.horizontal, 20)
                        
                        // Listing comments
                        if localComments.isEmpty {
                            Text("No discussions logged. Be the first to add details!")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                        } else {
                            VStack(spacing: 16) {
                                ForEach(localComments) { comment in
                                    HStack(alignment: .top, spacing: 12) {
                                        Text(comment.avatar)
                                            .font(.system(size: 20))
                                            .frame(width: 32, height: 32)
                                            .background(Color.white.opacity(0.1))
                                            .clipShape(Circle())
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack {
                                                Text(comment.author)
                                                    .font(.system(size: 12, weight: .semibold))
                                                    .foregroundColor(.white)
                                                Spacer()
                                                Text(comment.timeAgo)
                                                    .font(.system(size: 10))
                                                    .foregroundColor(.gray)
                                                
                                                Button(action: {
                                                    self.reportedComment = comment
                                                }) {
                                                    Image(systemName: "flag")
                                                        .font(.system(size: 10))
                                                        .foregroundColor(.gray)
                                                        .padding(4)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                            
                                            Text(comment.content)
                                                .font(.system(size: 13))
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 40)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }
        }
        .sheet(isPresented: $showingReportPostSheet) {
            ReportView(
                targetType: .post,
                targetName: post.creator,
                targetContent: post.content,
                onSubmit: { reason in
                    showingReportPostSheet = false
                    stageData.reportPost(id: post.id)
                    alertMessage = "Post reported successfully. It has been submitted for moderation review."
                    showingReportSuccessAlert = true
                },
                onCancel: {
                    showingReportPostSheet = false
                }
            )
        }
        .sheet(item: $reportedComment) { comment in
            ReportView(
                targetType: .comment,
                targetName: comment.author,
                targetContent: comment.content,
                onSubmit: { reason in
                    stageData.reportComment(id: comment.id, parentPostId: post.id)
                    reportedComment = nil
                    alertMessage = "Comment reported successfully. It has been submitted for moderation review."
                    showingReportSuccessAlert = true
                },
                onCancel: {
                    reportedComment = nil
                }
            )
        }
        .alert(isPresented: $showingReportSuccessAlert) {
            Alert(
                title: Text("Report Submitted"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .navigationBarTitle(Text("Log Details"), displayMode: .inline)
        .onAppear {
            self.localComments = post.comments
        }
    }
    
    private func toggleLike() {
        if post.isLiked {
            post.likes -= 1
            post.isLiked = false
        } else {
            post.likes += 1
            post.isLiked = true
        }
        // Update in shared repo
        if let idx = stageData.posts.firstIndex(where: { $0.id == post.id }) {
            stageData.posts[idx].likes = post.likes
            stageData.posts[idx].isLiked = post.isLiked
        }
    }
    
    private func submitComment() {
        let trimmed = commentText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let newComment = Comment(author: stageData.userDisplayName, avatar: stageData.userAvatarEmoji, content: trimmed, timeAgo: "Just now")
        localComments.insert(newComment, at: 0)
        commentText = ""
        
        // Update in data environment
        if let idx = stageData.posts.firstIndex(where: { $0.id == post.id }) {
            var updatedComments = stageData.posts[idx].comments
            updatedComments.insert(newComment, at: 0)
            stageData.posts[idx] = CommunityPost(
                id: post.id,
                creator: post.creator,
                creatorAvatar: post.creatorAvatar,
                creatorRole: post.creatorRole,
                content: post.content,
                tag: post.tag,
                gradientStart: post.gradientStart,
                gradientEnd: post.gradientEnd,
                iconName: post.iconName,
                likes: post.likes,
                isLiked: post.isLiked,
                timestamp: post.timestamp,
                comments: updatedComments,
                imageName: post.imageName
            )
        }
    }
    
    /// Load an image from bundle or Documents directory by filename
    private func loadBundleImage(_ name: String) -> UIImage? {
        return UIImage.loadFromBundleOrDocuments(named: name)
    }
}

struct FeedDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let repo = StageDataRepository()
        return FeedDetailView(post: repo.posts[0])
            .environmentObject(repo)
    }
}
