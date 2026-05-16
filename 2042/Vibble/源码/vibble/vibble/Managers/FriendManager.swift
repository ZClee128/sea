//
//  FriendManager.swift
//  vibble
//

import Foundation
import SwiftUI
import Combine

struct Friend: Identifiable {
    let id = UUID()
    let name: String
    let status: String
}

@available(iOS 14.0, *)
class FriendManager: ObservableObject {
    static let shared = FriendManager()
    
    @Published var followedUsers: Set<String> = []
    @Published var blockedUsers: Set<String> = []
    @Published var friends: [Friend] = [
        Friend(name: "DramaHunter", status: "Recently posted a new drama clip"),
        Friend(name: "Vibble_Fan", status: "Recently posted a new drama clip"),
        Friend(name: "Cinephile_Mike", status: "Watching 'My Demon'"),
        Friend(name: "K_Queen", status: "Online")
    ]
    
    private let storageKey = "vibble_followed_users"
    private let blockKey = "vibble_blocked_users"
    
    init() {
        loadFollowedUsers()
        loadBlockedUsers()
    }
    
    func toggleFollow(_ username: String) {
        objectWillChange.send() // 显式通知所有观察者：我要变了！
        if followedUsers.contains(username) {
            followedUsers.remove(username)
        } else {
            followedUsers.insert(username)
        }
        saveFollowedUsers()
    }
    
    func isFollowing(_ username: String) -> Bool {
        followedUsers.contains(username)
    }
    
    func toggleBlock(_ username: String) {
        objectWillChange.send()
        if blockedUsers.contains(username) {
            blockedUsers.remove(username)
        } else {
            blockedUsers.insert(username)
            followedUsers.remove(username) // 拉黑自动取消关注
        }
        saveBlockedUsers()
    }
    
    func isBlocked(_ username: String) -> Bool {
        blockedUsers.contains(username)
    }
    
    private func saveFollowedUsers() {
        let array = Array(followedUsers)
        UserDefaults.standard.set(array, forKey: storageKey)
    }
    
    private func loadFollowedUsers() {
        if let array = UserDefaults.standard.stringArray(forKey: storageKey) {
            followedUsers = Set(array)
        }
    }
    
    private func saveBlockedUsers() {
        UserDefaults.standard.set(Array(blockedUsers), forKey: blockKey)
    }
    
    private func loadBlockedUsers() {
        if let array = UserDefaults.standard.stringArray(forKey: blockKey) {
            blockedUsers = Set(array)
        }
    }
}

// MARK: - Chat Persistence (合并至此确保可见性)

struct Message: Identifiable, Codable {
    var id = UUID()
    let text: String
    let isFromMe: Bool
    let timestamp: Date
}

@available(iOS 14.0, *)
class VibbleChatManager: ObservableObject {
    static let shared = VibbleChatManager()
    
    @Published var chatHistory: [String: [Message]] = [:]
    private let storageKey = "vibble_chat_history_v1"
    
    init() {
        loadHistory()
    }
    
    func getMessages(for friend: String) -> [Message] {
        return chatHistory[friend] ?? []
    }
    
    func sendMessage(_ text: String, to friend: String) {
        let newMessage = Message(text: text, isFromMe: true, timestamp: Date())
        if chatHistory[friend] == nil {
            chatHistory[friend] = []
        }
        chatHistory[friend]?.append(newMessage)
        saveHistory()
    }
    
    func saveHistory() {
        if let encoded = try? JSONEncoder().encode(chatHistory) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([String: [Message]].self, from: data) {
            chatHistory = decoded
        }
    }
    
    func reset() {
        chatHistory.removeAll()
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
}
