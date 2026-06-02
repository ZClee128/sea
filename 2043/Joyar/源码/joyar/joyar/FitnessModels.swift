//
//  FitnessModels.swift
//  joyar
//
//  Created by Antigravity on 01/06/2026.
//

import Foundation

// MARK: - Workout Models
struct WorkoutVideo: Identifiable, Hashable, Codable {
    var id: String
    var title: String
    var description: String
    var trainerName: String
    var trainerAvatar: String
    var durationMinutes: Int
    var caloriesBurned: Int
    var difficulty: String // "Beginner", "Intermediate", "Advanced"
    var category: String // "HIIT", "Strength", "Cardio", "Yoga"
    var videoURL: String // Remote MP4 loop url
    var thumbnailImage: String // Asset code or symbol
    var viewCount: Int
    var isFavorited: Bool
    var trainingPoints: [String] // Bullet steps
}

// MARK: - Social / Community Models
struct Comment: Identifiable, Hashable, Codable {
    var id: String
    var authorName: String
    var authorAvatar: String
    var content: String
    var timeAgo: String
}

struct CommunityPost: Identifiable, Hashable, Codable {
    var id: String
    var authorName: String
    var authorTitle: String // e.g. "Pro Coach", "Joyar member"
    var authorAvatar: String
    var content: String
    var tag: String // e.g. "#HIIT", "#Diet", "#Yoga"
    var postImageName: String // System symbol or custom visual representation
    var timeAgo: String
    var likesCount: Int
    var isLiked: Bool
    var comments: [Comment]
}

// MARK: - Chat / Messaging Models
struct Trainer: Identifiable, Hashable, Codable {
    var id: String
    var name: String
    var specialty: String // e.g., "Strength Coach", "Dietitian Expert"
    var avatar: String
    var lastMessage: String
    var lastMessageTime: String
    var isOnline: Bool
    var isTyping: Bool
}

struct ChatMessage: Identifiable, Hashable, Codable {
    var id: String
    var trainerId: String
    var content: String
    var timestamp: Date
    var isFromUser: Bool
}

// MARK: - User Progress / Settings Models
struct UserProfile: Codable {
    var username: String
    var avatar: String
    var goal: String // "Build Muscle", "Lose Weight", "Stay Fit"
    var age: Int
    var weightKg: Double
    var heightCm: Double
}

struct WorkoutHistoryItem: Identifiable, Codable {
    var id: String
    var title: String
    var caloriesBurned: Int
    var date: Date
}

// MARK: - UGC Safety Model
struct ModerationTarget: Identifiable, Hashable, Codable {
    var id: String
    var type: String // "Post", "Comment", or "Trainer Chat"
    var contentId: String
    var authorName: String
}
