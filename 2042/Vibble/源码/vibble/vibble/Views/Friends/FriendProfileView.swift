//
//  FriendProfileView.swift
//  vibble
//

import SwiftUI

@available(iOS 14.0, *)
struct FriendProfileView: View {
    let username: String
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var dramaManager = DramaManager.shared
    
    private let screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // 1. 顶部背景与头像
                    ZStack(alignment: .bottom) {
                        Theme.Gradients.primaryGradient
                            .frame(height: 150)
                            .opacity(0.3)
                        
                        ZStack {
                            Circle().fill(Theme.background).frame(width: 100, height: 100)
                            Circle().fill(Theme.Gradients.primaryGradient).frame(width: 90, height: 90)
                            Text(username.replacingOccurrences(of: "@", with: "").prefix(1).uppercased())
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .offset(y: 50)
                    }
                    .padding(.bottom, 50)
                    
                    // 2. 基本信息
                    VStack(spacing: 8) {
                        Text("@\(username.replacingOccurrences(of: "@", with: ""))")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        Text("Vibble Creator • Movie Lover")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    // 3. 统计数据
                    HStack(spacing: 40) {
                        ProfileStat(label: "Followers", value: "1.2K")
                        ProfileStat(label: "Following", value: "340")
                        ProfileStat(label: "Posts", value: "12")
                    }
                    
                    Divider().background(Color.gray.opacity(0.3)).padding(.horizontal, 25)
                    
                    // 4. 好友的动态/讨论 (增强过滤逻辑)
                    VStack(alignment: .leading, spacing: 20) {
                        Text("RECENT DISCUSSIONS")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 25)
                        
                        let targetName = username.replacingOccurrences(of: "@", with: "").lowercased()
                        let userVideos = dramaManager.allDramas.filter { 
                            $0.userName.replacingOccurrences(of: "@", with: "").lowercased() == targetName 
                        }
                        
                        if userVideos.isEmpty {
                            Text("No posts yet.")
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .padding(.top, 20)
                        } else {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                                ForEach(userVideos) { video in
                                    NavigationLink(destination: VideoDetailView(video: video)) {
                                        ExploreVideoCard(video: video)
                                    }
                                }
                            }
                            .padding(.horizontal, 25)
                        }
                    }
                    
                    Spacer(minLength: 50)
                }
            }
            
            // 顶部返回按钮
            VStack {
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    .padding(.top, 50)
                    .padding(.leading, 20)
                    Spacer()
                }
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
}

@available(iOS 14.0, *)
struct ProfileStat: View {
    let label: String; let value: String
    var body: some View {
        VStack(spacing: 4) {
            Text(value).font(.headline).foregroundColor(.white)
            Text(label).font(.caption).foregroundColor(.gray)
        }
    }
}
