//
//  User.swift
//  Scenery
//
//  Created on 2026/1/14.
//

import Foundation

struct User: Codable, Identifiable, Hashable {
    let id: UUID
    var email: String
    var username: String
    var displayName: String
    var avatarURL: String?
    var bio: String?
    var isVerified: Bool
    var followerCount: Int
    var followingCount: Int
    var postCount: Int
    var isPremium: Bool
    var isBlocked: Bool
    var isFollowing: Bool
    var coinBalance: Int
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        email: String,
        username: String,
        displayName: String,
        avatarURL: String? = nil,
        bio: String? = nil,
        isVerified: Bool = false,
        isPremium: Bool = false,
        followerCount: Int = 0,
        followingCount: Int = 0,
        postCount: Int = 0,
        isBlocked: Bool = false,
        isFollowing: Bool = false,
        coinBalance: Int = 0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.email = email
        self.username = username
        self.displayName = displayName
        self.avatarURL = avatarURL
        self.bio = bio
        self.isVerified = isVerified
        self.isPremium = isPremium
        self.followerCount = followerCount
        self.followingCount = followingCount
        self.postCount = postCount
        self.isBlocked = isBlocked
        self.isFollowing = isFollowing
        self.coinBalance = coinBalance
        self.createdAt = createdAt
    }
}

// MARK: - Authentication State
struct AuthState {
    var isAuthenticated: Bool = false
    var currentUser: User?
    var authToken: String?
}
