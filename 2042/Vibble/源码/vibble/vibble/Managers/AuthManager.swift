//
//  AuthManager.swift
//  vibble
//

import Foundation
import SwiftUI
import Combine

@available(iOS 14.0, *)
@available(iOS 14.0, *)
class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    // 使用 willSet 发送对象变更通知，确保 UI 能够监听到 AppStorage 的变化
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false {
        willSet {
            objectWillChange.send()
        }
    }
    
    @AppStorage("currentUserEmail") var currentUserEmail: String = "" {
        willSet {
            objectWillChange.send()
        }
    }
    
    @AppStorage("userNickname") var nickname: String = "Vibble Explorer" {
        willSet {
            objectWillChange.send()
        }
    }
    
    @AppStorage("userBio") var bio: String = "Drama enthusiast and story hunter." {
        willSet {
            objectWillChange.send()
        }
    }
    
    // 增加头像数据持久化 (改为非可选 Data)
    @AppStorage("userAvatarData") var avatarData: Data = Data() {
        willSet {
            objectWillChange.send()
        }
    }
    
    @AppStorage("followersCount") var followersCount: Int = 0 {
        willSet {
            objectWillChange.send()
        }
    }
    
    @AppStorage("likesCount") var likesCount: Int = 0 {
        willSet {
            objectWillChange.send()
        }
    }
    
    @AppStorage("coinsCount") var coinsCount: Int = 100 { // 默认给新用户100金币测试
        willSet {
            objectWillChange.send()
        }
    }
    
    // 模拟本地存储：邮箱 -> 密码
    private let userDefaultsKey = "vibble_mock_users"
    
    init() {
        // 预设苹果审核测试账号 (仅在应用首次安装时注册一次，防止注销后无限复活)
        let hasInitialized = UserDefaults.standard.bool(forKey: "hasInitializedTestAccount")
        if !hasInitialized {
            var users = UserDefaults.standard.dictionary(forKey: userDefaultsKey) as? [String: String] ?? [:]
            users["test@vibble.com"] = "123456"
            UserDefaults.standard.set(users, forKey: userDefaultsKey)
            UserDefaults.standard.set(true, forKey: "hasInitializedTestAccount")
        }
    }
    
    func loginOrRegister(email: String, password: String) -> (success: Bool, message: String) {
        guard !email.isEmpty, !password.isEmpty else {
            return (false, "Please fill in all fields.")
        }
        
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        var users = UserDefaults.standard.dictionary(forKey: userDefaultsKey) as? [String: String] ?? [:]
        
        if let storedPassword = users[trimmedEmail] {
            // 已存在，执行登录
            if storedPassword == password {
                DispatchQueue.main.async {
                    self.isLoggedIn = true
                    self.currentUserEmail = trimmedEmail
                }
                return (true, "Welcome back!")
            } else {
                return (false, "Incorrect password.")
            }
        } else {
            // 不存在，执行注册
            users[trimmedEmail] = password
            UserDefaults.standard.set(users, forKey: userDefaultsKey)
            DispatchQueue.main.async {
                self.isLoggedIn = true
                self.currentUserEmail = trimmedEmail
            }
            return (true, "Account created successfully!")
        }
    }
    
    func logout() {
        DispatchQueue.main.async {
            self.isLoggedIn = false
            self.currentUserEmail = ""
        }
    }
    
    func deleteAccount() {
        let trimmedEmail = currentUserEmail.lowercased()
        var users = UserDefaults.standard.dictionary(forKey: userDefaultsKey) as? [String: String] ?? [:]
        
        // 1. 从用户库中移除
        users.removeValue(forKey: trimmedEmail)
        UserDefaults.standard.set(users, forKey: userDefaultsKey)
        
        // 2. 清空持久化资料
        nickname = "Vibble Explorer"
        bio = "Drama enthusiast and story hunter."
        avatarData = Data()
        followersCount = 0
        likesCount = 0
        coinsCount = 0
        
        // 3. 重置俱乐部、帖子和聊天记录
        ClubManager.shared.reset()
        DramaManager.shared.reset()
        VibbleChatManager.shared.reset()
        
        // 4. 登出
        logout()
    }
}
