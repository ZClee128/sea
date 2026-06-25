import SwiftUI

struct FeedListView: View {
    @EnvironmentObject var stageData: StageDataRepository
    @State private var reportedPost: CommunityPost? = nil
    @State private var showingNewPostSheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.08, green: 0.08, blue: 0.10)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Community Header
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Guild Feed")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            Text("Realtime logs from stunt and action choreographers")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        
                        // Posts Listing
                        if stageData.posts.isEmpty {
                            Text("No logs shared yet.")
                                .foregroundColor(.gray)
                                .padding(.top, 40)
                        } else {
                            VStack(spacing: 16) {
                                ForEach(stageData.posts) { post in
                                    NavigationLink(destination: FeedDetailView(post: post)) {
                                        PostCardView(post: post)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .contextMenu {
                                        Button(action: {
                                            self.reportedPost = post
                                        }) {
                                            Text("Report Post")
                                            Image(systemName: "flag")
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 30)
                        }
                    }
                }
            }
            .navigationBarTitle(Text("Monti Feed"), displayMode: .inline)
            .navigationBarItems(trailing:
                Button(action: {
                    showingNewPostSheet = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(red: 1.00, green: 0.00, blue: 0.50))
                }
            )
            .sheet(item: $reportedPost) { post in
                ReportView(
                    targetType: .post,
                    targetName: post.creator,
                    targetContent: post.content,
                    onSubmit: { reason in
                        self.stageData.reportPost(id: post.id)
                        self.reportedPost = nil
                    },
                    onCancel: {
                        self.reportedPost = nil
                    }
                )
            }
            .sheet(isPresented: $showingNewPostSheet) {
                NewPostView(stageData: self.stageData, isPresented: self.$showingNewPostSheet)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// Custom Premium Feed Card View
struct PostCardView: View {
    @EnvironmentObject var stageData: StageDataRepository
    let post: CommunityPost
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header: Author Avatar & Name
            HStack(spacing: 12) {
                Text(post.creatorAvatar)
                    .font(.system(size: 20))
                    .frame(width: 38, height: 38)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.creator)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    Text(post.creatorRole)
                        .font(.system(size: 10))
                        .foregroundColor(Color(red: 1.00, green: 0.00, blue: 0.50))
                }
                
                Spacer()
                
                Text(post.timestamp)
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
            
            // Text Body
            Text(post.content)
                .font(.system(size: 14))
                .lineSpacing(4)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.leading)
            
            // Cosplay image with overlay tag
            ZStack(alignment: .bottomTrailing) {
                if let uiImage = loadBundleImage(post.imageName) {
                    // Real cosplay photo
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(12)
                } else {
                    // Fallback gradient if image unavailable
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: post.gradientStart), Color(hex: post.gradientEnd)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 200)
                    .cornerRadius(12)
                    .overlay(
                        Image(systemName: post.iconName)
                            .font(.system(size: 32))
                            .foregroundColor(.white.opacity(0.9))
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

                // Tag badge
                Text(post.tag)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.55))
                    .cornerRadius(6)
                    .padding(10)
            }
            .frame(height: 200)
            .cornerRadius(12)
            .clipped()
            
            // Bottom Action buttons
            HStack(spacing: 20) {
                // Likes button
                HStack(spacing: 6) {
                    Image(systemName: post.isLiked ? "heart.fill" : "heart")
                        .font(.system(size: 14))
                        .foregroundColor(post.isLiked ? .red : .gray)
                    Text("\(post.likes)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // Comments count indicator
                HStack(spacing: 6) {
                    Image(systemName: "bubble.right")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Text("\(post.comments.count)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("Analyze log")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(red: 1.00, green: 0.00, blue: 0.50))
            }
            .padding(.top, 4)
        }
        .padding(16)
        .background(Color(red: 0.12, green: 0.12, blue: 0.15))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
    /// Load an image from bundle or Documents directory by filename
    private func loadBundleImage(_ name: String) -> UIImage? {
        return UIImage.loadFromBundleOrDocuments(named: name)
    }
}

struct FeedListView_Previews: PreviewProvider {
    static var previews: some View {
        FeedListView()
            .environmentObject(StageDataRepository())
    }
}

// Custom interactive post editor view for Side A loop closure (iOS 13 safe)
// Custom interactive post editor view for Side A loop closure (iOS 13 safe)
struct NewPostView: View {
    @ObservedObject var stageData: StageDataRepository
    @Binding var isPresented: Bool
    
    @State private var contentText: String = ""
    @State private var selectedTag: String = "#StageCombat"
    @State private var selectedStyleIndex: Int = 0
    @State private var useCustomImage: Bool = false
    @State private var selectedImage: UIImage? = nil
    @State private var showingImagePicker: Bool = false
    
    let tags = ["#StageCombat", "#ActionChoreography", "#CharacterPose", "#Conditioning"]
    
    let styles = [
        (start: "#8E2DE2", end: "#4A00E0", icon: "flame.fill"),
        (start: "#11998e", end: "#38ef7d", icon: "doc.text.fill"),
        (start: "#f857a6", end: "#ff5858", icon: "shield.fill"),
        (start: "#FF9900", end: "#FF5E62", icon: "star.fill")
    ]
    
    var isSubmitDisabled: Bool {
        let trimmed = contentText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return true }
        if useCustomImage && selectedImage == nil { return true }
        return false
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.08, blue: 0.10)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    hideKeyboard()
                }
            
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Cancel")
                            .foregroundColor(.gray)
                            .font(.system(size: 16))
                    }
                    
                    Spacer()
                    
                    Text("New Log Entry")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        submitPost()
                    }) {
                        Text("Post")
                            .foregroundColor(isSubmitDisabled ? .gray : Color(red: 1.00, green: 0.00, blue: 0.50))
                            .font(.system(size: 16, weight: .bold))
                    }
                    .disabled(isSubmitDisabled)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(Color(red: 0.12, green: 0.12, blue: 0.15))
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("CHOREOGRAPHY DESCRIPTION")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.gray)
                                .tracking(1)
                            
                            TextField("What sequence coordinates did you stage today?", text: $contentText)
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.white.opacity(0.04))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("TAG CATEGORY")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.gray)
                                .tracking(1)
                                .padding(.horizontal, 16)
                            
                            HStack(spacing: 10) {
                                ForEach(tags, id: \.self) { tag in
                                    Button(action: {
                                        selectedTag = tag
                                    }) {
                                        Text(tag)
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(selectedTag == tag ? .white : .gray)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(
                                                selectedTag == tag ?
                                                Color(red: 1.00, green: 0.00, blue: 0.50) :
                                                Color.white.opacity(0.06)
                                            )
                                            .cornerRadius(8)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("CARD VISUAL DESIGN")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.gray)
                                .tracking(1)
                                .padding(.horizontal, 16)
                            
                            HStack(spacing: 12) {
                                Button(action: {
                                    useCustomImage = false
                                }) {
                                    Text("Preset Neon Gradient")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(useCustomImage ? .gray : .white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(!useCustomImage ? Color(red: 1.00, green: 0.00, blue: 0.50) : Color.white.opacity(0.06))
                                        .cornerRadius(8)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Button(action: {
                                    useCustomImage = true
                                }) {
                                    Text("Custom Photo")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(!useCustomImage ? .gray : .white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(useCustomImage ? Color(red: 1.00, green: 0.00, blue: 0.50) : Color.white.opacity(0.06))
                                        .cornerRadius(8)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.horizontal, 16)
                            
                            if !useCustomImage {
                                HStack(spacing: 16) {
                                    ForEach(0..<styles.count, id: \.self) { index in
                                        Button(action: {
                                            selectedStyleIndex = index
                                        }) {
                                            let style = styles[index]
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color(hex: style.start), Color(hex: style.end)]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                            .frame(width: 50, height: 50)
                                            .cornerRadius(8)
                                            .overlay(
                                                Image(systemName: style.icon)
                                                    .font(.system(size: 16))
                                                    .foregroundColor(.white)
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.white, lineWidth: selectedStyleIndex == index ? 2 : 0)
                                            )
                                            .shadow(color: Color.black.opacity(0.3), radius: 4)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal, 16)
                            } else {
                                HStack(spacing: 12) {
                                    Button(action: {
                                        showingImagePicker = true
                                    }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "photo.on.rectangle.angled")
                                                .font(.system(size: 14))
                                            Text(selectedImage == nil ? "Choose Stunt Photo" : "Change Photo")
                                                .font(.system(size: 12, weight: .bold))
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(Color.white.opacity(0.1))
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    if let img = selectedImage {
                                        Image(uiImage: img)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 44, height: 44)
                                            .cornerRadius(8)
                                            .clipped()
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("PREVIEW CARD")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.gray)
                                .tracking(1)
                            
                            let style = styles[selectedStyleIndex]
                            VStack(alignment: .leading, spacing: 14) {
                                HStack(spacing: 12) {
                                    Text(stageData.userAvatarEmoji)
                                        .font(.system(size: 20))
                                        .frame(width: 38, height: 38)
                                        .background(Color.white.opacity(0.08))
                                        .clipShape(Circle())
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(stageData.userDisplayName)
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.white)
                                        Text("Cosplay Stunt Actor")
                                            .font(.system(size: 10))
                                            .foregroundColor(Color(red: 1.00, green: 0.00, blue: 0.50))
                                    }
                                    Spacer()
                                }
                                
                                Text(contentText.isEmpty ? "Stunt logging detail..." : contentText)
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineLimit(2)
                                
                                if useCustomImage {
                                    if let img = selectedImage {
                                        Image(uiImage: img)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height: 100)
                                            .cornerRadius(8)
                                            .clipped()
                                    } else {
                                        VStack(spacing: 8) {
                                            Image(systemName: "photo.on.rectangle")
                                                .font(.system(size: 20))
                                                .foregroundColor(.gray)
                                            Text("No photo selected")
                                                .font(.system(size: 11))
                                                .foregroundColor(.gray)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 100)
                                        .background(Color.white.opacity(0.03))
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                                        )
                                    }
                                } else {
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color(hex: style.start), Color(hex: style.end)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    .frame(height: 100)
                                    .cornerRadius(8)
                                    .overlay(
                                        Image(systemName: style.icon)
                                            .font(.system(size: 24))
                                            .foregroundColor(.white.opacity(0.8))
                                    )
                                }
                            }
                            .padding(14)
                            .background(Color(red: 0.12, green: 0.12, blue: 0.15))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 24)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        hideKeyboard()
                    }
                }
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $selectedImage)
        }
    }
    
    private func submitPost() {
        let trimmed = contentText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        var finalImageName = ""
        if useCustomImage, let img = selectedImage {
            if let savedName = img.saveToDocuments() {
                finalImageName = savedName
            }
        }
        
        let style = styles[selectedStyleIndex]
        let newPost = CommunityPost(
            id: UUID(),
            creator: stageData.userDisplayName,
            creatorAvatar: stageData.userAvatarEmoji,
            creatorRole: "Cosplay Stunt Actor",
            content: trimmed,
            tag: selectedTag,
            gradientStart: style.start,
            gradientEnd: style.end,
            iconName: style.icon,
            likes: 0,
            isLiked: false,
            timestamp: "Just now",
            comments: [],
            imageName: finalImageName
        )
        
        stageData.posts.insert(newPost, at: 0)
        isPresented = false
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true, completion: nil)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
