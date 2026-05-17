//
//  PostView.swift
//  vibble
//

import SwiftUI
import PhotosUI

@available(iOS 14.0, *)
struct PostView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var dramaTitle = ""
    @State private var content = ""
    @State private var selectedCategory = "K-Drama"
    @State private var isPosting = false
    @State private var showSuccess = false
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage? = nil
    
    @State private var showLowBalanceAlert = false
    @State private var navigateToStore = false
    
    let postCost = 50 // 发帖消耗金币数

    
    let categories = ["K-Drama", "C-Drama", "Netflix", "Trending", "Review"]
    private let screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 1. 顶部导航栏
                HStack {
                    Text("New Discussion")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: { resetForm() }) {
                        Text("Clear").foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 25)
                .padding(.top, 20)
                .frame(width: screenWidth)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        // 2. 视频选择预览
                        VStack(alignment: .leading, spacing: 12) {
                            Text("ATTACH VIDEO/COVER")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.gray)
                            
                            Button(action: { showImagePicker = true }) {
                                ZStack {
                                    if let image = selectedImage {
                                        Image(uiImage: image)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(height: 180)
                                            .frame(width: screenWidth - 50)
                                            .cornerRadius(20)
                                            .clipped()
                                    } else {
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [10]))
                                            .frame(height: 180)
                                        
                                        VStack(spacing: 12) {
                                            Image(systemName: "video.badge.plus")
                                                .font(.system(size: 40))
                                                .foregroundColor(Theme.primary)
                                            Text("Tap to select from library")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 25)
                        
                        // 3. 输入区域
                        VStack(alignment: .leading, spacing: 20) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("DRAMA TITLE")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.gray)
                                TextField("e.g. Midnight Silence", text: $dramaTitle)
                                    .padding()
                                    .background(Theme.cardBackground)
                                    .cornerRadius(15)
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("DISCUSSION CONTENT")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.gray)
                                TextEditor(text: $content)
                                    .frame(height: 150)
                                    .padding(10)
                                    .background(Theme.cardBackground)
                                    .cornerRadius(15)
                                    .foregroundColor(.white)
                                    .overlay(
                                        Group {
                                            if content.isEmpty {
                                                Text("What's on your mind about this drama?")
                                                    .foregroundColor(.gray.opacity(0.5))
                                                    .padding(.leading, 15)
                                                    .padding(.top, 18)
                                            }
                                        }, alignment: .topLeading
                                    )
                            }
                        }
                        .padding(.horizontal, 25)
                        
                        // 4. 分类选择
                        VStack(alignment: .leading, spacing: 12) {
                            Text("SELECT CATEGORY")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.gray)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(categories, id: \.self) { cat in
                                        CategoryChip(name: cat, isSelected: selectedCategory == cat) {
                                            selectedCategory = cat
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 25)
                        
                        // 5. 发布按钮及价格提示
                        VStack(spacing: 8) {
                            Button(action: postDiscussion) {
                                ZStack {
                                    Theme.Gradients.primaryGradient
                                    if isPosting {
                                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        HStack {
                                            Text("Post to Community")
                                                .font(.headline)
                                            Spacer()
                                            Image(systemName: "circle.fill")
                                                .foregroundColor(.yellow)
                                                .font(.system(size: 10))
                                            Text("\(postCost)")
                                                .font(.headline)
                                        }
                                        .padding(.horizontal, 30)
                                        .foregroundColor(.white)
                                    }
                                }
                                .frame(height: 55)
                                .frame(width: screenWidth - 50)
                                .cornerRadius(27)
                                .shadow(color: Theme.primary.opacity(0.3), radius: 10, y: 5)
                            }
                            .disabled(dramaTitle.isEmpty || content.isEmpty || isPosting)
                            
                            HStack(spacing: 4) {
                                Text("Balance:")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                                Image(systemName: "circle.fill")
                                    .foregroundColor(.yellow)
                                    .font(.system(size: 8))
                                Text("\(authManager.coinsCount)")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal, 25)
                        .padding(.top, 10)
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.top, 20)
                }
                .frame(width: screenWidth)
                .onTapGesture { UIApplication.shared.endEditing() }
            }
            
            if showSuccess {
                SuccessOverlay()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation { showSuccess = false; resetForm() }
                        }
                    }
            }
            
        }
        .fullScreenCover(isPresented: $navigateToStore) {
            if #available(iOS 15.0, *) {
                CoinStoreView()
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage)
        }
        .alert(isPresented: $showLowBalanceAlert) {
            Alert(
                title: Text("Insufficient Balance"),
                message: Text("Posting costs \(postCost) coins. Please top up to continue."),
                primaryButton: .default(Text("Top Up")) {
                    navigateToStore = true
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func postDiscussion() {
        if authManager.coinsCount >= postCost {
            authManager.coinsCount -= postCost
            isPosting = true
            
            // 真实存入数据管理器
            DramaManager.shared.addPost(
                title: dramaTitle,
                description: content,
                category: selectedCategory,
                image: selectedImage
            )
            
            // 模拟网络请求延迟
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                isPosting = false
                withAnimation { showSuccess = true }
            }
        } else {
            showLowBalanceAlert = true
        }
    }
    
    private func resetForm() {
        dramaTitle = ""
        content = ""
        selectedCategory = "K-Drama"
        selectedImage = nil
    }
}

@available(iOS 14.0, *)
struct CategoryChip: View {
    let name: String; let isSelected: Bool; let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(name)
                .font(.system(size: 14, weight: .semibold))
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(isSelected ? AnyView(Theme.Gradients.primaryGradient) : AnyView(Theme.cardBackground))
                .foregroundColor(.white)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

@available(iOS 14.0, *)
struct SuccessOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.8).ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 70))
                    .foregroundColor(.green)
                Text("Posted Successfully!")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                Text("Your discussion is now live in the community.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .padding(40)
            .background(Theme.cardBackground)
            .cornerRadius(30)
            .padding(.horizontal, 40)
        }
        .transition(.opacity.combined(with: .scale))
    }
}
