//
//  ExploreView.swift
//  vibble
//

import SwiftUI

@available(iOS 14.0, *)
struct ExploreView: View {
    @State private var searchText = ""
    @State private var selectedCategory = "K-Drama"
    @ObservedObject private var clubManager = ClubManager.shared
    @ObservedObject private var dramaManager = DramaManager.shared
    @State private var showPostView = false
    
    let categories = [
        ("sparkles.fill", "K-Drama"),
        ("star.fill", "C-Drama"),
        ("play.tv.fill", "Netflix"),
        ("flame.fill", "Trending")
    ]
    
    var filteredVideos: [Video] {
        dramaManager.allDramas.filter { video in
            let matchesCategory = video.category == selectedCategory
            let matchesSearch = searchText.isEmpty || 
                               video.dramaTitle.localizedCaseInsensitiveContains(searchText) || 
                               video.description.localizedCaseInsensitiveContains(searchText)
            return matchesCategory && matchesSearch
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 25) {
                        Text("Find Your Next Favorite")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField("Search titles or descriptions...", text: $searchText)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Theme.cardBackground)
                        .cornerRadius(15)
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(categories, id: \.1) { icon, name in
                                    CategoryButton(icon: icon, name: name, isSelected: selectedCategory == name) {
                                        withAnimation { selectedCategory = name }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Text("Trending Drama Clubs")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                                Text("See All").font(.caption).foregroundColor(Theme.primary)
                            }
                            .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ClubCard(name: "K-Drama Queen", fans: "12k fans", icon: "checkmark.circle.fill")
                                    ClubCard(name: "Cinephile Mike", fans: "Expert Reviewer", icon: "person.circle.fill")
                                    ClubCard(name: "Drama Seeker", fans: "Daily Blogger", icon: "person.fill")
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Results for \(selectedCategory)")
                                .font(.title3.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            if filteredVideos.isEmpty {
                                VStack(spacing: 20) {
                                    Image(systemName: "doc.text.magnifyingglass")
                                        .font(.system(size: 60))
                                        .foregroundColor(.gray.opacity(0.5))
                                    Text("No dramas found matching your search.")
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, 40)
                            } else {
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                                    ForEach(filteredVideos) { video in
                                        NavigationLink(destination: VideoDetailView(video: video)) {
                                            ExploreVideoCard(video: video)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.top, 20)
                }
                
                // Floating Action Button for Posting
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showPostView = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Theme.Gradients.primaryGradient)
                                .clipShape(Circle())
                                .shadow(color: Theme.primary.opacity(0.4), radius: 10, x: 0, y: 5)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .fullScreenCover(isPresented: $showPostView) {
            PostView()
        }
    }
}

@available(iOS 14.0, *)
struct CategoryButton: View {
    let icon: String; let name: String; let isSelected: Bool; let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                Text(name).fontWeight(.semibold)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(isSelected ? AnyView(Theme.Gradients.primaryGradient) : AnyView(Theme.cardBackground))
            .foregroundColor(.white)
            .cornerRadius(25)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

@available(iOS 14.0, *)
struct ClubCard: View {
    let name: String; let fans: String; let icon: String
    @ObservedObject private var clubManager = ClubManager.shared
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle().fill(Theme.cardBackground).frame(width: 60, height: 60)
                Image(systemName: icon).font(.title).foregroundColor(Theme.primary)
            }
            
            Text(name).font(.system(size: 14, weight: .bold)).foregroundColor(.white).lineLimit(1)
            Text(fans).font(.system(size: 10)).foregroundColor(.gray)
            
            Button(action: {
                ClubManager.shared.toggleClub(name: name)
            }) {
                Text(ClubManager.shared.isJoined(name) ? "Joined" : "Join Club")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(ClubManager.shared.isJoined(name) ? AnyView(Color.gray.opacity(0.5)) : AnyView(Theme.Gradients.primaryGradient))
                    .cornerRadius(15)
            }
        }
        .padding()
        .frame(width: 140)
        .background(Theme.cardBackground.opacity(0.5))
        .cornerRadius(20)
    }
}

@available(iOS 14.0, *)
struct ExploreVideoCard: View {
    let video: Video
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .bottomLeading) {
                // 顶级容器锁定：强制 0.75 比例且不可溢出
                Color.black
                    .aspectRatio(0.75, contentMode: .fill)
                    .overlay(
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
                    )
                    .clipped() // 物理裁剪，绝不溢出
                    .cornerRadius(12)
                
                LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                    .cornerRadius(12)
                VStack(alignment: .leading, spacing: 2) {
                    Text(video.dramaTitle).font(.system(size: 14, weight: .bold)).foregroundColor(.white).lineLimit(1)
                    Text("@\(video.userName)").font(.system(size: 10)).foregroundColor(.white.opacity(0.8))
                }
                .padding(8)
            }
            .cornerRadius(15)
            .shadow(radius: 5)
        }
    }
}
