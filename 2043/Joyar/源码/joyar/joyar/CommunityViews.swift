//
//  CommunityViews.swift
//  joyar
//
//  Created by Antigravity on 01/06/2026.
//

import SwiftUI

// MARK: - Community List View
struct CommunityListView: View {
    @ObservedObject var dataService = DataService.shared
    @State private var searchQuery = ""
    @State private var showCreatePost = false
    @State private var selectedPostId: String? = nil
    
    var filteredPosts: [CommunityPost] {
        dataService.communityPosts.filter { post in
            searchQuery.isEmpty || post.content.localizedCaseInsensitiveContains(searchQuery) || post.tag.localizedCaseInsensitiveContains(searchQuery) || post.authorName.localizedCaseInsensitiveContains(searchQuery)
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 20) {
                    // Header block
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("JOYAR COMMUNITY")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color(red: 1.0, green: 0.37, blue: 0.23))
                                .tracking(2)
                            
                            Text("Share Your Progress")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                        Spacer()
                        
                        Button(action: { showCreatePost = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(Color(red: 1.0, green: 0.37, blue: 0.23))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // Search timeline
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search tag or content...", text: $searchQuery)
                            .foregroundColor(.white)
                            .font(.system(size: 15))
                        
                        if !searchQuery.isEmpty {
                            Button(action: { searchQuery = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(12)
                    .background(Color(red: 0.12, green: 0.12, blue: 0.14))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // UGC Feed Cards list safe for iOS 13
                    if filteredPosts.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "tray")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                                .padding(.top, 40)
                            Text("Timeline Empty")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            Text("Be the first to share your fitness logs!")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                    } else {
                        VStack(spacing: 20) {
                            ForEach(filteredPosts, id: \.id) { post in
                                FeedCardView(post: post, onCommentTapped: {
                                    selectedPostId = post.id
                                }, onModerationTapped: { target in
                                    dataService.activeModTarget = target
                                })
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 40)
                }
                .frame(minHeight: geometry.size.height, alignment: .top)
                .contentShape(Rectangle())
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }
        }
        .simultaneousGesture(
            DragGesture().onChanged { _ in
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        )
        .background(
            Color(red: 0.07, green: 0.07, blue: 0.08)
                .edgesIgnoringSafeArea(.all)
        )
        .background(
            ZStack {
                NavigationLink(
                    destination: Group {
                        if let postId = selectedPostId {
                            CommunityDetailView(postId: postId)
                        }
                    },
                    isActive: Binding(
                        get: { selectedPostId != nil },
                        set: { if !$0 { selectedPostId = nil } }
                    )
                ) {
                    EmptyView()
                }
                .hidden()
            }
            .frame(width: 0, height: 0)
        )
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
        .sheet(isPresented: $showCreatePost) {
            CreatePostView()
        }
    }
}

// MARK: - Beautiful Interactive Feed Card
struct FeedCardView: View {
    let post: CommunityPost
    var onCommentTapped: () -> Void
    var onModerationTapped: (ModerationTarget) -> Void
    @ObservedObject var dataService = DataService.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Profile row
            HStack(spacing: 10) {
                Image(systemName: post.authorAvatar)
                    .font(.system(size: 38))
                    .foregroundColor(.gray)
                
                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text(post.authorName)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(post.authorTitle)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(red: 1.0, green: 0.37, blue: 0.23))
                            .cornerRadius(4)
                    }
                    
                    Text(post.timeAgo)
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                Spacer()
                
                // UGC Ellipsis trigger
                Button(action: {
                    onModerationTapped(ModerationTarget(id: post.id, type: "Post", contentId: post.id, authorName: post.authorName))
                }) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.gray)
                        .padding(8)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Post content text
            Text(post.content)
                .font(.system(size: 14))
                .foregroundColor(.white)
                .lineLimit(4)
                .lineSpacing(3)
            
            // Tag bubble
            Text(post.tag)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(red: 1.0, green: 0.37, blue: 0.23))
            
            // Post image symbol display card (Upgraded to a stunning premium fitness lady photo, fully displayed)
            ZStack(alignment: .bottomLeading) {
                let useAsset = post.postImageName.hasPrefix("fitness_lady_")
                Group {
                    if useAsset {
                        Image(post.postImageName)
                            .resizable()
                    } else {
                        // Fallback/Default to fitness_lady_1 for user created posts
                        Image("fitness_lady_1")
                            .resizable()
                    }
                }
                .aspectRatio(contentMode: .fit)
                .cornerRadius(12)
                
                // Verified active logo badge overlay
                HStack(spacing: 6) {
                    let iconName: String = {
                        if post.postImageName.hasPrefix("fitness_lady_") {
                            return post.postImageName == "fitness_lady_1" ? "figure.strength.training.traditional" : (post.postImageName == "fitness_lady_2" ? "drop.fill" : "flame.fill")
                        }
                        return post.postImageName
                    }()
                    Image(systemName: iconName)
                        .font(.system(size: 11))
                        .foregroundColor(.black)
                    Text("Joyar verified post")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color(red: 1.0, green: 0.37, blue: 0.23))
                .cornerRadius(6)
                .padding(10)
            }
            
            // Interactive Like & Comment bar
            HStack(spacing: 24) {
                // Heart Like row
                Button(action: {
                    withAnimation(.spring()) {
                        dataService.toggleLike(postId: post.id)
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: post.isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(post.isLiked ? .red : .gray)
                        
                        Text("\(post.likesCount)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.gray)
                    }
                }
                
                // Comment row Button
                HStack(spacing: 6) {
                    Image(systemName: "bubble.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.gray)
                    
                    Text("\(post.comments.count)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.gray)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    onCommentTapped()
                }
                
                Spacer()
            }
            .padding(.top, 4)
        }
        .padding(16)
        .background(Color(red: 0.12, green: 0.12, blue: 0.14))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}

// MARK: - Community Post Detail View (Comment board)
struct CommunityDetailView: View {
    let postId: String
    @ObservedObject var dataService = DataService.shared
    @State private var commentText = ""
    @Environment(\.presentationMode) var presentationMode
    
    var post: CommunityPost? {
        dataService.communityPosts.firstNumerator(where: { $0.id == postId })
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation Bar Header
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color(red: 0.16, green: 0.16, blue: 0.18))
                        .clipShape(Circle())
                }
                Spacer()
                Text("Discussion Detail")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                // Spacer balance
                Circle().fill(Color.clear).frame(width: 36, height: 36)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(Color(red: 0.10, green: 0.10, blue: 0.12))
            
            if let postItem = post {
                GeometryReader { geometry in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            
                            // Header info
                            HStack(spacing: 12) {
                                Image(systemName: postItem.authorAvatar)
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(postItem.authorName)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                    Text(postItem.timeAgo)
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }
                            
                            // Content
                            Text(postItem.content)
                                .font(.system(size: 15))
                                .foregroundColor(.white)
                                .lineSpacing(4)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                }
                            
                            Text(postItem.tag)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Color(red: 1.0, green: 0.37, blue: 0.23))
                            
                            Divider().background(Color.white.opacity(0.1))
                            
                            // Comments Feed header
                            Text("Comments (\(postItem.comments.count))")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            
                            if postItem.comments.isEmpty {
                                VStack(spacing: 8) {
                                    Image(systemName: "bubble.left.and.bubble.right")
                                        .font(.system(size: 32))
                                        .foregroundColor(.gray)
                                        .padding(.top, 20)
                                    Text("No Comments Yet")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.gray)
                                    Text("Be the first to share your encouragement!")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity)
                            } else {
                                // Comments stack
                                VStack(spacing: 16) {
                                    ForEach(postItem.comments, id: \.id) { comm in
                                        HStack(alignment: .top, spacing: 12) {
                                            Image(systemName: comm.authorAvatar)
                                                .font(.system(size: 32))
                                                .foregroundColor(.gray)
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                HStack {
                                                    Text(comm.authorName)
                                                        .font(.system(size: 13, weight: .bold))
                                                        .foregroundColor(.white)
                                                    Spacer()
                                                    
                                                    // Ellipsis for Comment UGC moderation
                                                    Button(action: {
                                                        dataService.activeModTarget = ModerationTarget(id: comm.id, type: "Comment", contentId: comm.id, authorName: comm.authorName)
                                                    }) {
                                                        Image(systemName: "ellipsis")
                                                            .font(.system(size: 12))
                                                            .foregroundColor(.gray)
                                                            .padding(4)
                                                    }
                                                    .buttonStyle(PlainButtonStyle())
                                                    
                                                    Text(comm.timeAgo)
                                                        .font(.system(size: 11))
                                                        .foregroundColor(.gray)
                                                }
                                                Text(comm.content)
                                                    .font(.system(size: 13))
                                                    .foregroundColor(.gray)
                                                    .lineSpacing(2)
                                            }
                                        }
                                        .padding(12)
                                        .background(Color(red: 0.12, green: 0.12, blue: 0.14))
                                        .cornerRadius(10)
                                    }
                                }
                            }
                        }
                        .padding(16)
                        .frame(minHeight: geometry.size.height, alignment: .top)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    }
                }
                .simultaneousGesture(
                    DragGesture().onChanged { _ in
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                )
                
                // Bottom input editor
                HStack(spacing: 12) {
                    TextField("Add encouragement...", text: $commentText)
                        .foregroundColor(.white)
                        .font(.system(size: 14))
                        .padding(12)
                        .background(Color(red: 0.08, green: 0.08, blue: 0.10))
                        .cornerRadius(20)
                    
                    Button(action: {
                        dataService.addComment(postId: postItem.id, content: commentText)
                        commentText = ""
                    }) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            .padding(12)
                            .background(Color(red: 1.0, green: 0.37, blue: 0.23))
                            .clipShape(Circle())
                    }
                    .disabled(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(Color(red: 0.12, green: 0.12, blue: 0.14))
            } else {
                Text("Post not found.")
                    .foregroundColor(.white)
                Spacer()
            }
        }
        .background(
            Color(red: 0.07, green: 0.07, blue: 0.08)
                .edgesIgnoringSafeArea(.all)
        )
        .navigationBarHidden(true)
        .onReceive(dataService.$blockedUserNames) { blockedList in
            if let postItem = post, blockedList.contains(postItem.authorName) {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

// MARK: - Create Post Sheet View
struct CreatePostView: View {
    @ObservedObject var dataService = DataService.shared
    @Environment(\.presentationMode) var presentationMode
    
    @State private var postContent = ""
    @State private var tagInput = "Diet"
    @State private var selectedImageSymbol = "figure.run"
    
    let tagOptions = ["Diet", "Strength", "HIIT", "Cardio", "Yoga"]
    let imageOptions = ["figure.run", "flame.fill", "bolt.heart.fill", "figure.strength.training.traditional", "drop.fill", "leaf.fill"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.07, green: 0.07, blue: 0.08)
                    .edgesIgnoringSafeArea(.all)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                
                VStack(spacing: 20) {
                // Post Input Panel
                VStack(alignment: .leading, spacing: 8) {
                    Text("SHARE CAPTION")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray)
                        .tracking(1)
                    
                    // iOS 13 compatible Editor wrapping
                    TextViewWrapper(text: $postContent)
                        .frame(height: 140)
                        .background(Color(red: 0.12, green: 0.12, blue: 0.14))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.06), lineWidth: 1)
                        )
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Tag selection
                VStack(alignment: .leading, spacing: 10) {
                    Text("CHOOSE CATEGORY TAG")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray)
                        .tracking(1)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(tagOptions, id: \.self) { tag in
                                Button(action: {
                                    tagInput = tag
                                }) {
                                    Text("#\(tag)")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(tagInput == tag ? .black : .white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(tagInput == tag ? Color(red: 1.0, green: 0.37, blue: 0.23) : Color(red: 0.12, green: 0.12, blue: 0.14))
                                        .cornerRadius(16)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Icon layout selector (simulating local gallery photo picker)
                VStack(alignment: .leading, spacing: 12) {
                    Text("SELECT FITNESS PROGRESS LOGO")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray)
                        .tracking(1)
                        .padding(.horizontal)
                    
                    HStack(spacing: 12) {
                        ForEach(imageOptions, id: \.self) { sym in
                            Button(action: {
                                selectedImageSymbol = sym
                            }) {
                                Image(systemName: sym)
                                    .font(.system(size: 22))
                                    .foregroundColor(selectedImageSymbol == sym ? .black : .gray)
                                    .frame(width: 46, height: 46)
                                    .background(selectedImageSymbol == sym ? Color(red: 1.0, green: 0.37, blue: 0.23) : Color(red: 0.12, green: 0.12, blue: 0.14))
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.05), lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Post Share Button
                Button(action: {
                    dataService.createPost(content: postContent, tag: "#\(tagInput)", imageSymbol: selectedImageSymbol)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Share to Feed")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.37, blue: 0.23),
                                    Color(red: 1.0, green: 0.18, blue: 0.33)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(26)
                        .shadow(color: Color(red: 1.0, green: 0.18, blue: 0.33).opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal)
                .padding(.bottom, 25)
                .disabled(postContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .background(Color.clear)
            }
            .navigationBarTitle("Create Post", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Text("Cancel").foregroundColor(.gray)
                }
            )
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Safe iOS 13 UIKit Text View Wrapper
struct TextViewWrapper: UIViewRepresentable {
    @Binding var text: String
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.font = .systemFont(ofSize: 15)
        textView.textColor = .white
        textView.delegate = context.coordinator
        
        // Placeholders fallback
        textView.text = "Write about your active sets, nutrition, or motivation..."
        textView.textColor = .lightGray
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        if !text.isEmpty {
            uiView.text = text
            uiView.textColor = .white
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: TextViewWrapper
        
        init(_ parent: TextViewWrapper) {
            self.parent = parent
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.textColor == .lightGray {
                textView.text = ""
                textView.textColor = .white
            }
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.isEmpty {
                textView.text = "Write about your active sets, nutrition, or motivation..."
                textView.textColor = .lightGray
            }
        }
    }
}

// MARK: - App Store 1.2 UGC Compliance Custom Moderation View

struct CustomModerationOverlay: View {
    let target: ModerationTarget
    var onDismiss: () -> Void
    var onSubmitReport: (String, String) -> Void // reason, details
    var onBlockUser: (String) -> Void // username
    
    @State private var selectedReason = "Spam or misleading"
    @State private var reportDetails = ""
    @State private var showSuccess = false
    
    @ObservedObject var keyboard = KeyboardResponder()
    
    let reasons = [
        "Spam or misleading",
        "Harassment or cyberbullying",
        "Inappropriate or graphic content",
        "Hate speech or discrimination",
        "Intellectual property violation",
        "Other objectionable content"
    ]
    
    var body: some View {
        ZStack {
            // Dark dim overlay background
            Color.black.opacity(0.75)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    if !showSuccess {
                        onDismiss()
                    }
                }
            
            VStack {
                Spacer()
                
                // Sliding card container
                VStack(spacing: 20) {
                    // Header handle line
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray.opacity(0.4))
                        .frame(width: 40, height: 6)
                        .padding(.top, 10)
                    
                    if !showSuccess {
                        // Title row
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("UGC Safety & Moderation")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                Spacer()
                                Button(action: onDismiss) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            Text("Help us keep Joyar safe. Select an action for \(target.authorName)'s content.")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 16) {
                                // Block section
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("BLOCK USER")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(Color(red: 1.0, green: 0.37, blue: 0.23))
                                        .tracking(1)
                                    
                                    Button(action: {
                                        onBlockUser(target.authorName)
                                        showSuccess = true
                                    }) {
                                        HStack {
                                            Image(systemName: "person.crop.circle.badge.xmark")
                                                .font(.system(size: 18))
                                                .foregroundColor(.red)
                                            Text("Block \(target.authorName)")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(.red)
                                            Spacer()
                                            Text("Never see posts/messages")
                                                .font(.system(size: 11))
                                                .foregroundColor(.gray)
                                        }
                                        .padding()
                                        .background(Color.red.opacity(0.1))
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.red.opacity(0.2), lineWidth: 1)
                                        )
                                    }
                                }
                                .padding(.horizontal)
                                
                                // Divider
                                Divider().background(Color.white.opacity(0.08)).padding(.horizontal)
                                
                                // Report section
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("REPORT CONTENT")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(Color(red: 1.0, green: 0.37, blue: 0.23))
                                        .tracking(1)
                                    
                                    ForEach(reasons, id: \.self) { reason in
                                        Button(action: {
                                            selectedReason = reason
                                        }) {
                                            HStack {
                                                Text(reason)
                                                    .font(.system(size: 13, weight: selectedReason == reason ? .semibold : .regular))
                                                    .foregroundColor(selectedReason == reason ? .white : .gray)
                                                Spacer()
                                                if selectedReason == reason {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .foregroundColor(Color(red: 1.0, green: 0.37, blue: 0.23))
                                                } else {
                                                    Image(systemName: "circle")
                                                        .foregroundColor(.gray.opacity(0.5))
                                                }
                                            }
                                            .padding(.vertical, 12)
                                            .padding(.horizontal, 14)
                                            .background(Color(red: 0.16, green: 0.16, blue: 0.18))
                                            .cornerRadius(8)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                
                                // Additional context Input
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("DETAILS (OPTIONAL)")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.gray)
                                        .tracking(1)
                                    
                                    TextField("Provide more details or context here...", text: $reportDetails)
                                        .padding(12)
                                        .background(Color(red: 0.16, green: 0.16, blue: 0.18))
                                        .cornerRadius(10)
                                        .foregroundColor(.white)
                                        .font(.system(size: 13))
                                }
                                .padding(.horizontal)
                            }
                        }
                        .frame(maxHeight: keyboard.currentHeight > 0 ? 100 : 280)
                        
                        // Submit / Cancel Buttons
                        HStack(spacing: 12) {
                            Button(action: onDismiss) {
                                Text("Cancel")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(Color(red: 0.16, green: 0.16, blue: 0.18))
                                    .cornerRadius(24)
                            }
                            
                            Button(action: {
                                onSubmitReport(selectedReason, reportDetails)
                                showSuccess = true
                            }) {
                                Text("Submit Report")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(Color(red: 1.0, green: 0.37, blue: 0.23))
                                    .cornerRadius(24)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, keyboard.currentHeight > 0 ? 10 : 25)
                        
                    } else {
                        // Success confirmation view
                        VStack(spacing: 20) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.green)
                                .padding(.top, 20)
                            
                            Text("Action Completed Successfully")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Thank you for helping us keep Joyar safe! We have processed your request. Blocked users and reported items are immediately hidden and will be reviewed within 24 hours.")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                            
                            Button(action: onDismiss) {
                                Text("Done")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(Color(red: 1.0, green: 0.37, blue: 0.23))
                                    .cornerRadius(24)
                                    .padding(.horizontal, 40)
                            }
                            .padding(.bottom, 35)
                        }
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                .background(Color(red: 0.10, green: 0.10, blue: 0.12))
                .cornerRadius(25)
                .padding(.bottom, keyboard.currentHeight > 0 ? keyboard.currentHeight : 0)
                .animation(.easeOut(duration: 0.25))
                .transition(.move(edge: .bottom))
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

// MARK: - Reactive Combine Keyboard Responder for iOS 13+
import Combine

class KeyboardResponder: ObservableObject {
    @Published var currentHeight: CGFloat = 0
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        let willShow = NotificationCenter.default.publisher(for: UIWindow.keyboardWillShowNotification)
            .compactMap { notification -> CGFloat? in
                (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height
            }
        
        let willHide = NotificationCenter.default.publisher(for: UIWindow.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        
        Publishers.Merge(willShow, willHide)
            .receive(on: RunLoop.main)
            .assign(to: \.currentHeight, on: self)
            .store(in: &cancellables)
    }
}

struct CommunityViews_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CommunityListView()
        }
        .preferredColorScheme(.dark)
    }
}
