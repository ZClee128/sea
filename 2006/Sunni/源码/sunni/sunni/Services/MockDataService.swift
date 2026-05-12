//
//  MockDataService.swift
//  Scenery
//
//  Created on 2026/1/14.
//

import Foundation
import UIKit

class MockDataService {
    static let shared = MockDataService()
    
    private init() {}
    
    // MARK: - Mock Users with Fixed IDs
    lazy var mockUsers: [User] = [
        User(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            email: "alex@example.com",
            username: "alexchen",
            displayName: "Alex Chen",
            avatarURL: nil,
            bio: "Landscape photographer | Mountain lover 🏔️",
            isVerified: false,
            isPremium: false,
            followerCount: 234,
            followingCount: 89,
            postCount: 3,
            coinBalance: 5000
        ),
        User(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
            email: "sarah@example.com",
            username: "sarahj",
            displayName: "Sarah Johnson",
            avatarURL: nil,
            bio: "Travel enthusiast | Ocean views 🌊",
            isVerified: false,
            isPremium: false,
            followerCount: 156,
            followingCount: 92,
            postCount: 3,
            coinBalance: 3000
        ),
        User(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
            email: "mike@example.com",
            username: "mikerodriguez",
            displayName: "Mike Rodriguez",
            avatarURL: nil,
            bio: "Nature explorer | Adventure seeker ⛰️",
            isVerified: false,
            isPremium: true,
            followerCount: 312,
            followingCount: 145,
            postCount: 1,
            coinBalance: 10000
        ),
        User(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
            email: "emma@example.com",
            username: "emmaw",
            displayName: "Emma Wilson",
            avatarURL: nil,
            bio: "Sunset chaser | Sky lover 🌅",
            isVerified: false,
            isPremium: false,
            followerCount: 198,
            followingCount: 67,
            postCount: 1,
            coinBalance: 1500
        )
    ]
    
    private func getLocalVideoURL(name: String) -> String {
        if let path = Bundle.main.path(forResource: name, ofType: "mp4") {
            return URL(fileURLWithPath: path).absoluteString
        }
        print("⚠️ Local video \(name).mp4 not found in bundle, using fallback.")
        return "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4"
    }

    // MARK: - Mock Posts
    lazy var mockPosts: [Post] = {
        var posts = [
            // --- VIDEO ---
            Post(
                userId: mockUsers[0].id,
                type: .video,
                caption: "Check out this video! 🎥 #Local #Video1",
                mediaURL: getLocalVideoURL(name: "1"),
                thumbnailURL: "https://images.unsplash.com/photo-1542281286-9e0a16bb7366?w=800&q=80",
                location: "Local Spot 1",
                likeCount: 89,
                commentCount: 5,
                user: mockUsers[0]
            ),
            Post(
                userId: mockUsers[1].id,
                type: .video,
                caption: "Another cool clip! 🔥 #Local #Video2",
                mediaURL: getLocalVideoURL(name: "2"),
                thumbnailURL: "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80",
                location: "Local Spot 2",
                likeCount: 124,
                commentCount: 12,
                user: mockUsers[1]
            ),
            // --- NATURE ---
            Post(
                userId: mockUsers[0].id,
                type: .image,
                caption: "Morning hike in Banff. The colors are incredible! 🏔️ #Nature",
                mediaURL: "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80",
                location: "Banff National Park, Canada",
                likeCount: 234,
                commentCount: 12,
                user: mockUsers[0]
            ),
            Post(
                userId: mockUsers[2].id,
                type: .image,
                caption: "Perfect morning at the lake. Still and peaceful. 🌅 #Nature",
                mediaURL: "https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=800&q=80",
                location: "Lake Louise, Canada",
                likeCount: 423,
                commentCount: 28,
                user: mockUsers[2]
            ),
            Post(
                userId: mockUsers[0].id,
                type: .image,
                caption: "Mountain stream flowing through the forest 🌲💧 #Nature",
                mediaURL: "https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=800&q=80",
                location: "Olympic National Park, USA",
                likeCount: 189,
                commentCount: 15,
                user: mockUsers[0]
            ),
            Post(
                userId: mockUsers[3].id,
                type: .image,
                caption: "Golden hour magic in the desert 🏜️✨ #Nature",
                mediaURL: "https://images.unsplash.com/photo-1501594907352-04cda38ebc29?w=800&q=80",
                location: "Monument Valley, Arizona",
                likeCount: 892,
                commentCount: 45,
                user: mockUsers[3]
            ),
            Post(
                userId: mockUsers[1].id,
                type: .image,
                caption: "Misty mountains in the morning light 🌄 #Nature",
                mediaURL: "https://images.unsplash.com/photo-1519681393784-d120267933ba?w=800&q=80",
                location: "Swiss Alps",
                likeCount: 654,
                commentCount: 22,
                user: mockUsers[1]
            ),
            
            // --- URBAN ---
            Post(
                userId: mockUsers[2].id,
                type: .image,
                caption: "City lights at night are mesmerizing 🌃 #Urban",
                mediaURL: "https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?w=800&q=80",
                location: "New York City, USA",
                likeCount: 1205,
                commentCount: 88,
                user: mockUsers[2]
            ),
            Post(
                userId: mockUsers[3].id,
                type: .image,
                caption: "Street photography in Tokyo 📸 #Urban",
                mediaURL: "https://images.unsplash.com/photo-1503899036084-c55cdd92da26?w=800&q=80",
                location: "Shibuya, Tokyo",
                likeCount: 743,
                commentCount: 56,
                user: mockUsers[3]
            ),
            Post(
                userId: mockUsers[1].id,
                type: .image,
                caption: "Architecture patterns in modern buildings 🏢 #Urban",
                mediaURL: "https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=800&q=80",
                location: "London, UK",
                likeCount: 342,
                commentCount: 14,
                user: mockUsers[1]
            ),
             Post(
                userId: mockUsers[0].id,
                type: .image,
                caption: "Rainy days in the city have a special vibe ☔️ #Urban",
                mediaURL: "https://images.unsplash.com/photo-1515162305285-0293e4767cc2?w=800&q=80",
                location: "Seattle, USA",
                likeCount: 211,
                commentCount: 9,
                user: mockUsers[0]
            ),
            
            // --- TRAVEL ---
            Post(
                userId: mockUsers[1].id,
                type: .image,
                caption: "Sunset over the Pacific. The golden hour is unreal! 🌊 #Travel",
                mediaURL: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&q=80",
                location: "Big Sur, California",
                likeCount: 567,
                commentCount: 34,
                user: mockUsers[1]
            ),
            Post(
                userId: mockUsers[2].id,
                type: .image,
                caption: "Exploring ancient ruins in Peru 🏛️ #Travel",
                mediaURL: "https://images.unsplash.com/photo-1526392060635-9d6019884377?w=800&q=80",
                location: "Machu Picchu, Peru",
                likeCount: 890,
                commentCount: 67,
                user: mockUsers[2]
            ),
            Post(
                userId: mockUsers[3].id,
                type: .image,
                caption: "Island hopping paradise 🏝️ #Travel",
                mediaURL: "https://images.unsplash.com/photo-1559128010-7c1ad6e1b6a5?w=800&q=80",
                location: "Phuket, Thailand",
                likeCount: 456,
                commentCount: 30,
                user: mockUsers[3]
            ),
            Post(
                userId: mockUsers[0].id,
                type: .image,
                caption: "Road trip down Route 66 🚗💨 #Travel",
                mediaURL: "https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=800&q=80",
                location: "Arizona, USA",
                likeCount: 321,
                commentCount: 18,
                user: mockUsers[0]
            ),
            
            // --- LIFESTYLE ---
            Post(
                userId: mockUsers[3].id,
                type: .image,
                caption: "Sunday brunch vibes 🥑☕️ #Lifestyle",
                mediaURL: "https://images.unsplash.com/photo-1493770348161-369560ae357d?w=800&q=80",
                location: "SoHo, NYC",
                likeCount: 289,
                commentCount: 15,
                user: mockUsers[3]
            ),
            Post(
                userId: mockUsers[2].id,
                type: .image,
                caption: "Cozy reading corner set up 📖✨ #Lifestyle",
                mediaURL: "https://images.unsplash.com/photo-1483985988355-763728e1935b?w=800&q=80",
                location: "Home Sweet Home",
                likeCount: 450,
                commentCount: 42,
                user: mockUsers[2]
            ),
            Post(
                userId: mockUsers[1].id,
                type: .image,
                caption: "Working from a cafe today 💻☕️ #Lifestyle",
                mediaURL: "https://images.unsplash.com/photo-1497935586351-b67a49e012bf?w=800&q=80",
                location: "Starbucks Reserve",
                likeCount: 156,
                commentCount: 8,
                user: mockUsers[1]
            ),
            Post(
                userId: mockUsers[0].id,
                type: .image,
                caption: "New fitness goals started! 💪 #Lifestyle",
                mediaURL: "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=800&q=80",
                location: "Equinox Gym",
                likeCount: 312,
                commentCount: 20,
                user: mockUsers[0]
            ),
            Post(
                userId: mockUsers[2].id,
                type: .image,
                caption: "Ocean waves at sunset 🌊🌅 #Nature",
                mediaURL: "https://images.unsplash.com/photo-1505142468610-359e7d316be0?w=800&q=80",
                location: "Malibu, California",
                likeCount: 245,
                commentCount: 19,
                user: mockUsers[2]
            ),
            Post(
                userId: mockUsers[1].id,
                type: .image,
                caption: "Desert sunset is something else! 🏜️✨ #Nature",
                mediaURL: "https://images.unsplash.com/photo-1509316785289-025f5b846b35?w=800&q=80",
                location: "Joshua Tree National Park",
                likeCount: 512,
                commentCount: 23,
                user: mockUsers[1]
            )
        ]
        
        // Load persisted user posts
        let userPosts = self.loadUserCreatedPosts()
        posts.insert(contentsOf: userPosts, at: 0)
        
        // Load saved gift counts for all posts
        for i in 0..<posts.count {
            posts[i].giftCount = self.loadGiftCount(for: posts[i].id)
        }
        
        return posts
    }()
    
    // MARK: - Mock Conversations
    lazy var mockConversations: [Conversation] = [
        Conversation(
            otherUser: mockUsers[1],
            lastMessage: Message(
                conversationId: "conv1",
                senderId: mockUsers[1].id,
                receiverId: mockUsers[0].id,
                content: "Hey, are we still on for dinner tonight? Let me know..."
            ),
            unreadCount: 3
        ),
        Conversation(
            otherUser: mockUsers[2],
            lastMessage: Message(
                conversationId: "conv2",
                senderId: mockUsers[0].id,
                receiverId: mockUsers[2].id,
                content: "Hey, you're very creative even for..."
            ),
            unreadCount: 0
        ),
        Conversation(
            otherUser: mockUsers[3],
            lastMessage: Message(
                conversationId: "conv3",
                senderId: mockUsers[3].id,
                receiverId: mockUsers[0].id,
                content: "Thanks for the follow! Love your landscape shots 📸"
            ),
            unreadCount: 1
        )
    ]
    
    // MARK: - Gift Count Persistence
    func saveGiftCount(_ count: Int, for postId: UUID) {
        let key = "gift_count_\(postId.uuidString)"
        UserDefaults.standard.set(count, forKey: key)
        UserDefaults.standard.synchronize()
        print("🎁 Saved gift count: \(count) for post: \(postId)")
    }
    
    func loadGiftCount(for postId: UUID) -> Int {
        let key = "gift_count_\(postId.uuidString)"
        return UserDefaults.standard.integer(forKey: key)
    }
    
    // MARK: - Email Check
    func checkEmailExists(_ email: String) -> Bool {
        return mockUsers.contains { $0.email.lowercased() == email.lowercased() }
    }
    
    // MARK: - Helper Methods
    func login(email: String, password: String) -> User? {
        return mockUsers.first { $0.email.lowercased() == email.lowercased() }
    }
    
    func register(email: String, username: String, displayName: String, password: String) -> User? {
        return User(email: email, username: username, displayName: displayName)
    }
    
    func addPost(_ post: Post) {
        mockPosts.insert(post, at: 0)
        saveUserCreatedPost(post)
        if let index = mockUsers.firstIndex(where: { $0.id == post.userId }) {
            mockUsers[index].postCount += 1
            if AuthService.shared.authState.currentUser?.id == post.userId {
                AuthService.shared.authState.currentUser?.postCount += 1
            }
        }
        NotificationCenter.default.post(name: NSNotification.Name("PostsUpdated"), object: nil)
    }
    
    func updatePost(_ post: Post) {
        // Update in-memory array
        if let index = mockPosts.firstIndex(where: { $0.id == post.id }) {
            mockPosts[index] = post
            
            // Persist specific fields if needed
            // For gift count, we already have saveGiftCount, but we can call it here or assume caller did
            // If the post passed in already has the new gift count, we should save it
             saveGiftCount(post.giftCount, for: post.id)
            
            // If it's a user created post, we might need to update that list too?
            // Currently saveUserCreatedPost() appends... we might need a better way to update
            // For now, gift counts are saved separately via saveGiftCount so that's fine.
            
            NotificationCenter.default.post(name: NSNotification.Name("PostsUpdated"), object: nil)
        }
    }
    
    func followUser(targetUserId: UUID, currentUserId: UUID) {
        if let targetIndex = mockUsers.firstIndex(where: { $0.id == targetUserId }) {
            mockUsers[targetIndex].followerCount += 1
        }
        if let currentIndex = mockUsers.firstIndex(where: { $0.id == currentUserId }) {
            mockUsers[currentIndex].followingCount += 1
            if AuthService.shared.authState.currentUser?.id == currentUserId {
                AuthService.shared.authState.currentUser?.followingCount += 1
            }
        }
        NotificationCenter.default.post(name: NSNotification.Name("UserDataUpdated"), object: nil)
    }
    
    func unfollowUser(targetUserId: UUID, currentUserId: UUID) {
        if let targetIndex = mockUsers.firstIndex(where: { $0.id == targetUserId }) {
            if mockUsers[targetIndex].followerCount > 0 {
                mockUsers[targetIndex].followerCount -= 1
            }
        }
        if let currentIndex = mockUsers.firstIndex(where: { $0.id == currentUserId }) {
            if mockUsers[currentIndex].followingCount > 0 {
                mockUsers[currentIndex].followingCount -= 1
            }
            if AuthService.shared.authState.currentUser?.id == currentUserId {
                if let count = AuthService.shared.authState.currentUser?.followingCount, count > 0 {
                    AuthService.shared.authState.currentUser?.followingCount -= 1
                }
            }
        }
        NotificationCenter.default.post(name: NSNotification.Name("UserDataUpdated"), object: nil)
    }

    // MARK: - Post Persistence
    
    func saveImage(_ image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        let fileName = UUID().uuidString + ".jpg"
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            return fileName // Return filename only to persist across app launches
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
    
    private func saveUserCreatedPost(_ post: Post) {
        var savedPosts = loadUserCreatedPosts()
        savedPosts.insert(post, at: 0)
        
        if let encoded = try? JSONEncoder().encode(savedPosts) {
            UserDefaults.standard.set(encoded, forKey: "user_created_posts")
            UserDefaults.standard.synchronize()
        }
    }
    
    private func loadUserCreatedPosts() -> [Post] {
        if let data = UserDefaults.standard.data(forKey: "user_created_posts"),
           let posts = try? JSONDecoder().decode([Post].self, from: data) {
            return posts
        }
        return []
    }
}
