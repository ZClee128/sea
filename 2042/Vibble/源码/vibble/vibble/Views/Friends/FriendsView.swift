//
//  FriendsView.swift
//  vibble
//

import SwiftUI

@available(iOS 14.0, *)
struct FriendsView: View {
    @StateObject private var friendManager = FriendManager.shared
    @State private var searchText = ""
    private let screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.edgesIgnoringSafeArea(.all)
                    .onTapGesture { UIApplication.shared.endEditing() }
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("Friends")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.top, 20)
                    
                    // 搜索框
                    HStack {
                        Image(systemName: "magnifyingglass").foregroundColor(.gray)
                        TextField("Search friends...", text: $searchText)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Theme.cardBackground)
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    ScrollView {
                        VStack(spacing: 15) {
                            // 只显示真正关注的用户
                            let followedFriends = friendManager.friends.filter {
                                friendManager.isFollowing($0.name) &&
                                (searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText))
                            }
                            
                            if followedFriends.isEmpty {
                                VStack {
                                    Spacer()
                                    VStack(spacing: 20) {
                                        Image(systemName: "person.2.fill")
                                            .font(.system(size: 60))
                                            .foregroundColor(.gray.opacity(0.3))
                                        Text("No friends yet")
                                            .font(.headline)
                                            .foregroundColor(.gray)
                                        Text("Follow creators in Discovery to see them here.")
                                            .font(.subheadline)
                                            .foregroundColor(.gray.opacity(0.6))
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, 40)
                                    }
                                    Spacer()
                                }
                                .frame(height: 500) // 给予足够的高度用于居中
                                .frame(maxWidth: .infinity)
                            } else {
                                ForEach(followedFriends) { friend in
                                    FriendRow(friend: friend)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .onTapGesture { UIApplication.shared.endEditing() }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

@available(iOS 14.0, *)
struct FriendRow: View {
    let friend: Friend
    @ObservedObject private var friendManager = FriendManager.shared // 核心：观察单例变化
    private let screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
        HStack(spacing: 15) {
            // 点击头像进入个人主页
            NavigationLink(destination: FriendProfileView(username: friend.name)) {
                ZStack(alignment: .bottomTrailing) {
                    Circle()
                        .fill(Theme.Gradients.primaryGradient)
                        .frame(width: 60, height: 60)
                        .overlay(Text(String(friend.name.prefix(1)).uppercased()).foregroundColor(.white).font(.headline))
                    
                    Circle()
                        .fill(Color.green)
                        .frame(width: 14, height: 14)
                        .overlay(Circle().stroke(Theme.background, lineWidth: 2))
                }
            }
            
            // 点击文字区域进入聊天
            NavigationLink(destination: ChatView(friendName: friend.name)) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("@\(friend.name)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    Text("Recently posted a new drama clip")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                Spacer()
                
                let isFollowing = friendManager.isFollowing(friend.name)
                Button(action: {
                    withAnimation {
                        friendManager.toggleFollow(friend.name)
                    }
                }) {
                    Text(isFollowing ? "Following" : "Follow")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                        .background(isFollowing ? Color.gray.opacity(0.3) : Theme.primary)
                        .cornerRadius(15)
                }
            }
        }
        .padding()
        .frame(width: screenWidth - 30)
        .background(Theme.cardBackground.opacity(0.5))
        .cornerRadius(20)
    }
}
