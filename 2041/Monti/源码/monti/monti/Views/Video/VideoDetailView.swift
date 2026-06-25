import SwiftUI

struct VideoDetailView: View {
    @EnvironmentObject var stageData: StageDataRepository
    @Environment(\.presentationMode) var presentationMode
    @State var video: StuntVideo
    @State private var commentText: String = ""
    @State private var localComments: [Comment] = []
    
    @State private var showingShopAlert = false
    @State private var isUnlocking = false
    
    @State private var showingReportVideoSheet = false
    @State private var reportedComment: Comment? = nil
    @State private var showingReportSuccessAlert = false
    @State private var alertMessage = ""
    
    var isLocked: Bool {
        video.isPremium && !stageData.unlockedVideoIDs.contains(video.id)
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.08, blue: 0.10)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if isLocked {
                        // Locked Video Card & Unlock View
                        VStack(spacing: 20) {
                            ZStack {
                                // Locked gradient card
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: video.thumbnailGradientStart), Color(hex: video.thumbnailGradientEnd)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                .frame(height: 250)
                                .cornerRadius(12)
                                
                                VStack(spacing: 12) {
                                    if isUnlocking {
                                        SimpleActivityIndicator()
                                            .foregroundColor(.yellow)
                                        Text("Unlocking Rehearsal...")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.yellow)
                                    } else {
                                        Image(systemName: "lock.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.yellow)
                                            .padding(16)
                                            .background(Color.black.opacity(0.6))
                                            .clipShape(Circle())
                                        
                                        Text("PREMIUM CHOREOGRAPHY REEL")
                                            .font(.system(size: 11, weight: .black))
                                            .foregroundColor(.yellow)
                                            .tracking(1.5)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 10)
                            
                            // Info & Action
                            VStack(spacing: 16) {
                                Text(video.title)
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 16)
                                
                                Text("This premium choreographic breakdown and safety sequence requires unlocking. Once unlocked, you will have lifetime access to the full video, sequence breakdown, choreo notes, and community feedback log.")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                                    .lineSpacing(4)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 24)
                                
                                // Unlock Button
                                Button(action: {
                                    unlockVideo()
                                }) {
                                    HStack {
                                        Image(systemName: "dollarsign.circle.fill")
                                            .font(.system(size: 16, weight: .bold))
                                        Text("Unlock Reel for 20 Coins")
                                            .font(.system(size: 15, weight: .bold))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color(red: 1.00, green: 0.00, blue: 0.50), Color(red: 0.50, green: 0.00, blue: 1.00)]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(14)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal, 24)
                                .disabled(isUnlocking)
                                
                                // Balance Row
                                HStack(spacing: 6) {
                                    Text("Your Wallet Balance:")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                    Text("\(CoinManager.shared.balance) Coins")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.yellow)
                                }
                            }
                        }
                        .padding(.vertical, 10)
                    } else {
                        // Video Player (Normal content when unlocked or free)
                        VideoPlayerWrapper(videoUrl: video.videoUrl)
                            .frame(height: 250)
                            .cornerRadius(12)
                            .padding(.horizontal, 16)
                            .padding(.top, 10)
                        
                        // Metadata & Title
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(video.stageCategory.uppercased())
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(Color(red: 1.00, green: 0.00, blue: 0.50))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color(red: 1.00, green: 0.00, blue: 0.50).opacity(0.1))
                                    .cornerRadius(4)
                                
                                Spacer()
                                
                                // Like button
                                Button(action: {
                                    toggleLike()
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: video.isLiked ? "heart.fill" : "heart")
                                            .foregroundColor(video.isLiked ? .red : .gray)
                                        Text("\(video.likes)")
                                            .foregroundColor(.white)
                                    }
                                    .font(.system(size: 13, weight: .medium))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.white.opacity(0.08))
                                    .cornerRadius(12)
                                }
                            }
                            
                            Text(video.title)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                            
                            // Performer info row
                            HStack(spacing: 12) {
                                Text(video.creatorAvatar)
                                    .font(.system(size: 24))
                                    .frame(width: 40, height: 40)
                                    .background(Color.white.opacity(0.1))
                                    .clipShape(Circle())
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(video.creator)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                    Text("Choreographer & Athlete")
                                        .font(.system(size: 11))
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                            }
                            .padding(.vertical, 6)
                            .border(edges: [.top, .bottom], color: Color.white.opacity(0.08), width: 1)
                            
                            // Action Attributes
                            HStack(spacing: 20) {
                                // Complexity attribute
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("COMPLEXITY")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(.gray)
                                    HStack(spacing: 3) {
                                        Image(systemName: "sparkles")
                                            .foregroundColor(.yellow)
                                        Text("\(video.actionComplexity)/10")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                                
                                // Move Sequence count
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("SEQUENCE STEPS")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(.gray)
                                    HStack(spacing: 3) {
                                        Image(systemName: "doc.text.fill")
                                            .foregroundColor(.customCyan)
                                        Text("\(video.moveSequenceCount) Seqs")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                                
                                // Tempo index
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("TEMPO INDEX")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(.gray)
                                    HStack(spacing: 3) {
                                        Image(systemName: "speedometer")
                                            .foregroundColor(.green)
                                        Text("High")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                            
                            // Description
                            Text("REHEARSAL NOTES")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.gray)
                            Text(video.description)
                                .font(.system(size: 14))
                                .lineSpacing(5)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.horizontal, 16)
                        
                        // Comments Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("FEEDBACK (\(localComments.count))")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.gray)
                                .padding(.horizontal, 16)
                            
                            // Post comment input
                            HStack(spacing: 12) {
                                TextField("Add action feedback...", text: $commentText)
                                    .font(.system(size: 14))
                                    .padding(12)
                                    .background(Color.white.opacity(0.06))
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                                
                                Button(action: {
                                    addComment()
                                }) {
                                    Image(systemName: "paperplane.fill")
                                        .foregroundColor(.white)
                                        .padding(12)
                                        .background(Color(red: 1.00, green: 0.00, blue: 0.50))
                                        .clipShape(Circle())
                                }
                                .disabled(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            }
                            .padding(.horizontal, 16)
                            
                            // Comments listing
                            if localComments.isEmpty {
                                Text("No feedback yet. Be the first to analyze this reel!")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 16)
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
                                        .padding(.horizontal, 16)
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 40)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }
        }
        .navigationBarTitle(Text("Rehearsal Details"), displayMode: .inline)
        .navigationBarItems(trailing:
            Button(action: {
                showingReportVideoSheet = true
            }) {
                Image(systemName: "flag")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }
        )
        .sheet(isPresented: $showingReportVideoSheet) {
            ReportView(
                targetType: .video,
                targetName: video.creator,
                targetContent: video.title + "\n" + video.description,
                onSubmit: { reason in
                    showingReportVideoSheet = false
                    stageData.reportVideo(id: video.id)
                    alertMessage = "Video reported successfully. It has been submitted for moderation review."
                    showingReportSuccessAlert = true
                },
                onCancel: {
                    showingReportVideoSheet = false
                }
            )
        }
        .sheet(item: $reportedComment) { comment in
            ReportView(
                targetType: .comment,
                targetName: comment.author,
                targetContent: comment.content,
                onSubmit: { reason in
                    stageData.reportVideoComment(id: comment.id, parentVideoId: video.id)
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
        .alert(isPresented: $showingShopAlert) {
            Alert(
                title: Text("Insufficient Stunt Coins"),
                message: Text("You need 20 stunt coins to unlock this premium sequence. Please visit the Coin Shop in Settings to recharge."),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            self.localComments = video.comments
        }
    }
    
    private func toggleLike() {
        if video.isLiked {
            video.likes -= 1
            video.isLiked = false
        } else {
            video.likes += 1
            video.isLiked = true
        }
        // Update model repository reference
        if let idx = stageData.videos.firstIndex(where: { $0.id == video.id }) {
            stageData.videos[idx].likes = video.likes
            stageData.videos[idx].isLiked = video.isLiked
        }
    }
    
    private func unlockVideo() {
        let coinCost = 20
        if CoinManager.shared.spendCoins(coinCost) {
            isUnlocking = true
            // Play unlock animation delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                self.isUnlocking = false
                // Add to unlocked IDs
                self.stageData.unlockedVideoIDs.insert(video.id)
            }
        } else {
            showingShopAlert = true
        }
    }
    
    private func addComment() {
        let trimmed = commentText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let newComment = Comment(author: stageData.userDisplayName, avatar: stageData.userAvatarEmoji, content: trimmed, timeAgo: "Just now")
        localComments.insert(newComment, at: 0)
        commentText = ""
        
        // Update in repository data source
        if let idx = stageData.videos.firstIndex(where: { $0.id == video.id }) {
            var updatedComments = stageData.videos[idx].comments
            updatedComments.insert(newComment, at: 0)
            stageData.videos[idx] = StuntVideo(
                id: video.id,
                title: video.title,
                description: video.description,
                videoUrl: video.videoUrl,
                thumbnailGradientStart: video.thumbnailGradientStart,
                thumbnailGradientEnd: video.thumbnailGradientEnd,
                iconName: video.iconName,
                creator: video.creator,
                creatorAvatar: video.creatorAvatar,
                actionComplexity: video.actionComplexity,
                moveSequenceCount: video.moveSequenceCount,
                likes: video.likes,
                isLiked: video.isLiked,
                stageCategory: video.stageCategory,
                comments: updatedComments,
                isPremium: video.isPremium
            )
        }
    }
}

// SwiftUI custom border helper for iOS 13 view customization
extension View {
    func border(edges: [Edge], color: Color, width: CGFloat = 1) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
}

struct EdgeBorder: Shape {
    var width: CGFloat
    var edges: [Edge]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        for edge in edges {
            var x: CGFloat {
                switch edge {
                case .top, .bottom, .leading: return rect.minX
                case .trailing: return rect.maxX - width
                }
            }

            var y: CGFloat {
                switch edge {
                case .top, .leading, .trailing: return rect.minY
                case .bottom: return rect.maxY - width
                }
            }

            var w: CGFloat {
                switch edge {
                case .top, .bottom: return rect.width
                case .leading, .trailing: return width
                }
            }

            var h: CGFloat {
                switch edge {
                case .top, .bottom: return width
                case .leading, .trailing: return rect.height
                }
            }

            path.addRect(CGRect(x: x, y: y, width: w, height: h))
        }
        return path
    }
}

struct VideoDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let repo = StageDataRepository()
        return VideoDetailView(video: repo.videos[0])
            .environmentObject(repo)
    }
}
