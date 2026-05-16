//
//  ProfileView.swift
//  vibble
//

import SwiftUI

@available(iOS 14.0, *)
struct ProfileView: View {
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var clubManager = ClubManager.shared
    @State private var showDeleteAlert = false
    private let screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // 1. 用户基本信息
                        VStack(spacing: 15) {
                            ZStack {
                                Circle().fill(Theme.Gradients.primaryGradient).frame(width: 120, height: 120)
                                if !authManager.avatarData.isEmpty, let uiImage = UIImage(data: authManager.avatarData) {
                                    Image(uiImage: uiImage).resizable().scaledToFill().frame(width: 120, height: 120).clipShape(Circle())
                                } else {
                                    Text(authManager.nickname.prefix(1).uppercased()).font(.system(size: 40, weight: .bold)).foregroundColor(.white)
                                }
                            }
                            
                            VStack(spacing: 4) {
                                Text(authManager.nickname.isEmpty ? "User" : authManager.nickname).font(.system(size: 20, weight: .bold)).foregroundColor(.white)
                                Text("Premium Member").font(.system(size: 14, weight: .semibold)).foregroundColor(Theme.primary)
                            }
                            
                            HStack(spacing: 40) {
                                ProfileStat(label: "Clubs", value: "\(clubManager.joinedClubs.count)")
                                ProfileStat(label: "Followers", value: "\(authManager.followersCount)")
                                ProfileStat(label: "Likes", value: "\(authManager.likesCount)")
                            }.padding(.top, 10)
                            
                            if #available(iOS 15.0, *) {
                                NavigationLink(destination: CoinStoreView()) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Vibble Coins").font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                                            HStack(spacing: 4) {
                                                Image(systemName: "circle.fill").foregroundColor(.yellow).font(.system(size: 10))
                                                Text("\(authManager.coinsCount)").font(.system(size: 18, weight: .bold)).foregroundColor(Theme.primary)
                                            }
                                        }
                                        Spacer()
                                        Text("Top Up").font(.system(size: 12, weight: .bold)).foregroundColor(.white).padding(.horizontal, 15).padding(.vertical, 8).background(Theme.Gradients.primaryGradient).cornerRadius(15)
                                    }.padding().frame(width: screenWidth - 40).background(Theme.cardBackground).cornerRadius(20).overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.1), lineWidth: 1))
                                }
                            }
                            
                            Divider().background(Color.gray.opacity(0.3)).padding(.horizontal, 25).padding(.top, 10)
                        }.padding(.top, 40)
                        
                        // 2. 我的俱乐部
                        VStack(alignment: .leading, spacing: 15) {
                            Text("My Drama Clubs").font(.headline).foregroundColor(.white).padding(.horizontal, 25)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(Array(clubManager.joinedClubs), id: \.self) { club in
                                        ClubMiniCard(name: club)
                                    }
                                }.padding(.horizontal, 25)
                            }
                        }
                        
                        // 3. 设置列表
                        VStack(spacing: 1) {
                            NavigationLink(destination: AccountSettingsView()) {
                                SettingsRow(icon: "gearshape.fill", title: "Account Settings", color: .white)
                            }
                            NavigationLink(destination: FeedbackView()) {
                                SettingsRow(icon: "bubble.left.fill", title: "Report a Problem", color: .white)
                            }
                            NavigationLink(destination: PrivacyView()) {
                                SettingsRow(icon: "doc.text.fill", title: "Legal & Privacy", color: .white)
                            }
                            Button(action: { showDeleteAlert = true }) {
                                SettingsRow(icon: "trash.fill", title: "Delete Account", color: .red)
                            }
                        }.background(Theme.cardBackground.opacity(0.5)).cornerRadius(20).padding(.horizontal, 20)
                        
                        Button(action: { authManager.logout() }) {
                            Text("Log Out").font(.headline).foregroundColor(.white).frame(height: 55).frame(width: screenWidth - 40).background(Color.red.opacity(0.8)).cornerRadius(15)
                        }.padding(.bottom, 100)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .alert(isPresented: $showDeleteAlert) {
            Alert(title: Text("Delete Account?"), message: Text("All data will be erased."), primaryButton: .destructive(Text("Delete")) { authManager.deleteAccount() }, secondaryButton: .cancel())
        }
    }
}

// MARK: - Privacy View (极简 WebView 版本)

@available(iOS 14.0, *)
struct PrivacyView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 1. 标准导航栏
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                    }
                    Spacer()
                    Text("Privacy Policy")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Color.clear.frame(width: 40)
                }
                .frame(height: 40)
                .padding(.horizontal)
                .padding(.top, 10)
                .background(Theme.cardBackground)
                
                // 2. WebView 紧跟其后 (不再 ignoresSafeArea)
                VibbleWebView(fileName: "Privacy")
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Account Settings View

@available(iOS 14.0, *)
struct AccountSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var authManager = AuthManager.shared
    @State private var tempNickname = ""
    @State private var tempBio = ""
    @State private var tempAvatar: UIImage? = nil
    @State private var showImagePicker = false
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left").font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                    }
                    Spacer()
                    Text("Account Settings").font(.headline).foregroundColor(.white)
                    Spacer()
                    Button("Save") {
                        authManager.nickname = tempNickname
                        authManager.bio = tempBio
                        if let img = tempAvatar { authManager.avatarData = img.jpegData(compressionQuality: 0.8) ?? Data() }
                        presentationMode.wrappedValue.dismiss()
                    }.foregroundColor(Theme.primary).font(.headline)
                }.padding().background(Theme.cardBackground.opacity(0.5))
                
                ScrollView {
                    VStack(spacing: 30) {
                        Button(action: { showImagePicker = true }) {
                            VStack(spacing: 15) {
                                ZStack(alignment: .bottomTrailing) {
                                    if let img = tempAvatar { Image(uiImage: img).resizable().scaledToFill().frame(width: 100, height: 100).clipShape(Circle()) }
                                    else if !authManager.avatarData.isEmpty, let uiImage = UIImage(data: authManager.avatarData) { Image(uiImage: uiImage).resizable().scaledToFill().frame(width: 100, height: 100).clipShape(Circle()) }
                                    else { Circle().fill(Theme.Gradients.primaryGradient).frame(width: 100, height: 100).overlay(Text(tempNickname.prefix(1).uppercased()).font(.title).foregroundColor(.white).bold()) }
                                    Image(systemName: "camera.fill").font(.system(size: 12)).foregroundColor(.white).padding(8).background(Theme.primary).clipShape(Circle()).overlay(Circle().stroke(Theme.background, lineWidth: 2))
                                }
                                Text("Change Photo").font(.caption).foregroundColor(Theme.primary)
                            }
                        }.padding(.top, 30)
                        VStack(alignment: .leading, spacing: 20) {
                            SettingsInputField(label: "Nickname", text: $tempNickname)
                            SettingsInputField(label: "Bio", text: $tempBio)
                        }.padding(.horizontal, 25)
                    }
                }
            }
        }.navigationBarHidden(true)
        .onAppear { tempNickname = authManager.nickname; tempBio = authManager.bio }
        .sheet(isPresented: $showImagePicker) { ImagePicker(image: $tempAvatar) }
    }
}

struct SettingsInputField: View {
    let label: String; @Binding var text: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).font(.caption).foregroundColor(.gray)
            TextField("", text: $text).padding().background(Theme.cardBackground).foregroundColor(.white).cornerRadius(12).overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
        }
    }
}

struct SettingsRow: View {
    let icon: String; let title: String; let color: Color
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon).foregroundColor(color).frame(width: 30)
            Text(title).foregroundColor(color)
            Spacer()
            Image(systemName: "chevron.right").font(.caption).foregroundColor(.gray)
        }.padding().contentShape(Rectangle())
    }
}

struct ClubMiniCard: View {
    let name: String
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 15).fill(Theme.cardBackground)
                Image(systemName: "person.crop.circle.badge.checkmark.fill").font(.system(size: 30)).foregroundColor(Theme.primary)
            }.frame(width: 80, height: 80)
            Text(name).font(.system(size: 10, weight: .bold)).foregroundColor(.white).lineLimit(1)
        }.frame(width: 100)
    }
}
