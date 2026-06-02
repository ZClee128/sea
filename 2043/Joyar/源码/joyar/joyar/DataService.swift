//
//  DataService.swift
//  joyar
//
//  Created by Antigravity on 01/06/2026.
//

import Foundation
import Combine
import SwiftUI

class DataService: ObservableObject {
    static let shared = DataService()
    
    // MARK: - Published State
    @Published var workoutVideos: [WorkoutVideo] = []
    @Published var communityPosts: [CommunityPost] = []
    @Published var trainers: [Trainer] = []
    @Published var chatMessages: [ChatMessage] = []
    @Published var userProfile: UserProfile = UserProfile(
        username: DataService.generateRandomName(),
        avatar: "figure.run",
        goal: "Build Muscle",
        age: 26,
        weightKg: 78.5,
        heightCm: 182.0
    )
    
    static func generateRandomName() -> String {
        let firstNames = ["Alex", "Jordan", "Taylor", "Morgan", "Sam", "Chris", "Jamie", "Skyler", "Casey", "Robin"]
        let lastNames = ["Carter", "Stone", "Jenkins", "Miller", "Smith", "Davis", "Wilson", "Taylor", "Anderson", "Thomas"]
        let randomFirst = firstNames.randomElement() ?? "Alex"
        let randomLast = lastNames.randomElement() ?? "Carter"
        let randomID = Int.random(in: 100...999)
        return "\(randomFirst) \(randomLast) #\(randomID)"
    }
    @Published var workoutHistory: [WorkoutHistoryItem] = []
    
    // storekit IAP coin balance state
    @Published var coinBalance: Int = 120
    @Published var unlockedVideos: Set<String> = []
    @Published var unlockedTrainingPlans: Set<String> = []
    
    // UGC Moderation (App Store 1.2 Guidelines compliance)
    @Published var reportedContentIds: Set<String> = []
    @Published var blockedUserNames: Set<String> = []
    @Published var activeModTarget: ModerationTarget? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        loadInitialData()
    }
    
    // MARK: - Initializer Setup
    private func loadInitialData() {
        // 1. High Quality Fitness Videos
        workoutVideos = [
            WorkoutVideo(
                id: "vid_1",
                title: "Fat Burning HIIT Blast",
                description: "Ignite your metabolism with this high-intensity interval training designed to maximize calorie burn long after you finish. Ideal for quick fat loss.",
                trainerName: "Coach Dave Miller",
                trainerAvatar: "person.circle.fill",
                durationMinutes: 25,
                caloriesBurned: 350,
                difficulty: "Advanced",
                category: "HIIT",
                videoURL: "1",
                thumbnailImage: "bolt.heart.fill",
                viewCount: 15420,
                isFavorited: false,
                trainingPoints: [
                    "Warm up with jumping jacks for 3 minutes.",
                    "Complete 4 rounds: 40 seconds burpees, 20 seconds rest.",
                    "Transition into mountain climbers for 3 rounds.",
                    "Finish with a high-intensity plank hold to fatigue core muscles.",
                    "Cool down and stretch lower extremities thoroughly."
                ]
            ),
            WorkoutVideo(
                id: "vid_2",
                title: "Ultimate Chest & Arms Builder",
                description: "Sculpt and define your upper body muscles. Focuses heavily on progressive overload principles using target gym sets and pure strength mechanics.",
                trainerName: "Coach Marcus Stone",
                trainerAvatar: "person.circle.fill",
                durationMinutes: 40,
                caloriesBurned: 420,
                difficulty: "Intermediate",
                category: "Strength",
                videoURL: "2",
                thumbnailImage: "figure.strength.training.functional",
                viewCount: 22890,
                isFavorited: true,
                trainingPoints: [
                    "Perform barbell bench press: 4 sets of 8-10 reps.",
                    "Incline dumbbell presses: 3 sets of 12 reps focusing on the upper chest contraction.",
                    "Weighted dips to failure to engage the lower pectorals and triceps.",
                    "Bicep hammer curls: 3 sets of 15 reps targeting forearm and arm thickness."
                ]
            ),
            WorkoutVideo(
                id: "vid_3",
                title: "Core Power & Deep Stretch Yoga",
                description: "Unite physical stability with deep mindfulness. Strengthen your transverse abdominals while relieving daily joint tightness.",
                trainerName: "Sarah Jenkins (E-RYT)",
                trainerAvatar: "person.circle.fill",
                durationMinutes: 30,
                caloriesBurned: 180,
                difficulty: "Beginner",
                category: "Yoga",
                videoURL: "3",
                thumbnailImage: "leaf.fill",
                viewCount: 9812,
                isFavorited: false,
                trainingPoints: [
                    "Establish deep belly breathing in Child's pose.",
                    "Move through dynamic Cat-Cow sequences to free spinal columns.",
                    "Transition into Downward-Facing Dog, focusing on hamstring elongation.",
                    "Engage Warrior II pose to build endurance in stabilizing leg fibers."
                ]
            ),
            WorkoutVideo(
                id: "vid_4",
                title: "Athletic Agility & Speed Conditioning",
                description: "Boost your quickness, response rate, and functional athletic endurance. Perfect for runners and agility-focused athletes.",
                trainerName: "Coach Dave Miller",
                trainerAvatar: "person.circle.fill",
                durationMinutes: 20,
                caloriesBurned: 290,
                difficulty: "Advanced",
                category: "Cardio",
                videoURL: "4",
                thumbnailImage: "figure.run.circle.fill",
                viewCount: 8400,
                isFavorited: false,
                trainingPoints: [
                    "Fast-paced high knees for 2 minutes to elevate heart rate.",
                    "Lateral shuttle drills: 5 sets of 20 yards with active deceleration.",
                    "Ladder steps: in-out drills simulating fast footwork.",
                    "Finish with 5 rounds of maximum speed sprints."
                ]
            ),
            WorkoutVideo(
                id: "vid_masterclass",
                title: "Joyar Masterclass: Elite Core Shred",
                description: "PRO LOCK: Unlock Sarah's elite 6-pack core formulation and high-density deep yoga alignment. Learn advanced techniques to sculpt lean muscle fast.",
                trainerName: "Sarah Jenkins (E-RYT)",
                trainerAvatar: "person.circle.fill",
                durationMinutes: 45,
                caloriesBurned: 550,
                difficulty: "Advanced",
                category: "Yoga",
                videoURL: "5",
                thumbnailImage: "crown.fill", // A beautiful crown to signify locked masterclass
                viewCount: 42000,
                isFavorited: false,
                trainingPoints: [
                    "Perform 5 minutes of targeted belly breathing.",
                    "Advanced hollow-body holds: 4 sets of 60 seconds.",
                    "Hanging wind-shield wipers targeting deep obliques.",
                    "Complete deep spinal alignment twists to release transverse fatigue."
                ]
            )
        ]
        
        // 2. High Quality Community Feeds
        communityPosts = [
            CommunityPost(
                id: "post_1",
                authorName: "Coach Marcus Stone",
                authorTitle: "Joyar Strength Head",
                authorAvatar: "person.circle.fill",
                content: "Remember that muscle growth is NOT just what you do in the gym. If you lift heavy but sleep 5 hours and eat junk, you're spinning your wheels. Fuel up, prioritize 8 hours of sleep, and stay consistent! Drop a comment with your goals for this week!",
                tag: "#MuscleBuilding",
                postImageName: "fitness_lady_1",
                timeAgo: "2 hours ago",
                likesCount: 142,
                isLiked: false,
                comments: [
                    Comment(id: "c_1", authorName: "Jake Turner", authorAvatar: "person.crop.circle", content: "Absolutely true Marcus! I started prioritizing sleep and my bench press shot up by 10lbs in a week.", timeAgo: "1 hour ago"),
                    Comment(id: "c_2", authorName: "Emma Watson", authorAvatar: "person.crop.circle", content: "Is it okay to eat fast food if I hit my daily protein targets?", timeAgo: "45 mins ago")
                ]
            ),
            CommunityPost(
                id: "post_2",
                authorName: "Sarah Jenkins (E-RYT)",
                authorTitle: "Yoga & Nutrition Coach",
                authorAvatar: "person.circle.fill",
                content: "Morning hydration challenge! Try starting your day with 500ml of room temperature water before reaching for coffee. Your joints, brain, and digestion will thank you! Who is in?",
                tag: "#HydrationChallenge",
                postImageName: "fitness_lady_2",
                timeAgo: "5 hours ago",
                likesCount: 98,
                isLiked: true,
                comments: [
                    Comment(id: "c_3", authorName: "Coach Dave Miller", authorAvatar: "person.crop.circle", content: "Crucial advice! Done this every day for 10 years, game changer.", timeAgo: "4 hours ago")
                ]
            ),
            CommunityPost(
                id: "post_3",
                authorName: "Lisa Kudrow",
                authorTitle: "Joyar Premium Member",
                authorAvatar: "person.circle.fill",
                content: "Just completed the 'Fat Burning HIIT Blast' video by Coach Dave! Literally drenched in sweat. That core finisher plank at the end was brutal but felt so satisfying. 10/10 recommend!",
                tag: "#HIITBlast",
                postImageName: "fitness_lady_3",
                timeAgo: "1 day ago",
                likesCount: 56,
                isLiked: false,
                comments: []
            )
        ]
        
        // 3. Personal Trainers
        trainers = [
            Trainer(
                id: "coach_marcus",
                name: "Coach Marcus Stone",
                specialty: "Hypertrophy & Strength Expert",
                avatar: "person.circle.fill",
                lastMessage: "Make sure you log your bench workout today!",
                lastMessageTime: "2:40 PM",
                isOnline: true,
                isTyping: false
            ),
            Trainer(
                id: "coach_sarah",
                name: "Sarah Jenkins",
                specialty: "Certified Dietitian & Yoga Expert",
                avatar: "person.circle.fill",
                lastMessage: "Water is just as important as clean food. Keep hydrating!",
                lastMessageTime: "Yesterday",
                isOnline: false,
                isTyping: false
            ),
            Trainer(
                id: "coach_ai",
                name: "Joyar AI Fitness Trainer",
                specialty: "24/7 Virtual Fitness Assistant",
                avatar: "cpu.fill",
                lastMessage: "Hey! Ask me any questions about abs, chest, muscle, diet, or cardio!",
                lastMessageTime: "Online",
                isOnline: true,
                isTyping: false
            )
        ]
        
        // 4. Base Messaging history (Only initial greetings from trainers, no user replies for a new account)
        chatMessages = [
            ChatMessage(id: "m_1", trainerId: "coach_marcus", content: "Hey Alex! Welcome to Joyar! Ready to build some serious muscle?", timestamp: Date().addingTimeInterval(-86400 * 2), isFromUser: false),
            ChatMessage(id: "m_4", trainerId: "coach_sarah", content: "Hi Alex! How has your morning energy levels been lately?", timestamp: Date().addingTimeInterval(-86400 * 3), isFromUser: false),
            ChatMessage(id: "m_7", trainerId: "coach_ai", content: "Hello! I am your Joyar AI assistant. Ask me anything about diet, weight loss, building abs, chest gains, or fitness tracking!", timestamp: Date().addingTimeInterval(-600), isFromUser: false)
        ]
        
        // 5. Initial Workout history logs
        workoutHistory = [
            WorkoutHistoryItem(id: "h_1", title: "Ultimate Chest & Arms Builder", caloriesBurned: 420, date: Date().addingTimeInterval(-86400)),
            WorkoutHistoryItem(id: "h_2", title: "Core Power & Deep Stretch Yoga", caloriesBurned: 180, date: Date().addingTimeInterval(-86400 * 2))
        ]
    }
    
    // MARK: - Interactive Actions
    
    func toggleFavorite(videoId: String) {
        if let index = workoutVideos.firstIndex(where: { $0.id == videoId }) {
            workoutVideos[index].isFavorited.toggle()
        }
    }
    
    func completeWorkout(videoId: String) {
        guard let video = workoutVideos.firstNumerator(where: { $0.id == videoId }) else { return }
        
        let newHistory = WorkoutHistoryItem(id: UUID().uuidString, title: video.title, caloriesBurned: video.caloriesBurned, date: Date())
        workoutHistory.insert(newHistory, at: 0)
        
        // Increments video stats dynamically
        if let idx = workoutVideos.firstIndex(where: { $0.id == videoId }) {
            workoutVideos[idx].viewCount += 1
        }
    }
    
    func toggleLike(postId: String) {
        if let index = communityPosts.firstIndex(where: { $0.id == postId }) {
            communityPosts[index].isLiked.toggle()
            communityPosts[index].likesCount += communityPosts[index].isLiked ? 1 : -1
        }
    }
    
    func addComment(postId: String, content: String) {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let newComment = Comment(
            id: UUID().uuidString,
            authorName: userProfile.username,
            authorAvatar: "person.crop.circle.fill",
            content: content,
            timeAgo: "Just now"
        )
        
        if let index = communityPosts.firstIndex(where: { $0.id == postId }) {
            communityPosts[index].comments.append(newComment)
        }
    }
    
    func createPost(content: String, tag: String, imageSymbol: String) {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let newPost = CommunityPost(
            id: UUID().uuidString,
            authorName: userProfile.username,
            authorTitle: "Joyar Premium Member",
            authorAvatar: "person.crop.circle.fill",
            content: content,
            tag: tag.hasPrefix("#") ? tag : "#\(tag)",
            postImageName: imageSymbol.isEmpty ? "figure.run.circle" : imageSymbol,
            timeAgo: "Just now",
            likesCount: 0,
            isLiked: false,
            comments: []
        )
        
        communityPosts.insert(newPost, at: 0)
    }
    
    // MARK: - Smart Intelligent Chat Engine
    func sendUserChatMessage(trainerId: String, content: String) {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // 1. Append user's message
        let userMsg = ChatMessage(id: UUID().uuidString, trainerId: trainerId, content: content, timestamp: Date(), isFromUser: true)
        chatMessages.append(userMsg)
        
        // Update last message in active trainer item
        if let idx = trainers.firstIndex(where: { $0.id == trainerId }) {
            trainers[idx].lastMessage = content
            trainers[idx].lastMessageTime = "Now"
            trainers[idx].isTyping = true
        }
        
        // 2. Schedule trainer reply (AI Engine)
        let processedQuery = content.lowercased()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            guard let self = self else { return }
            
            // Turn off typing indicator
            if let idx = self.trainers.firstIndex(where: { $0.id == trainerId }) {
                self.trainers[idx].isTyping = false
            }
            
            let replyText = self.generateTrainerReply(query: processedQuery, trainerId: trainerId)
            
            let trainerMsg = ChatMessage(id: UUID().uuidString, trainerId: trainerId, content: replyText, timestamp: Date(), isFromUser: false)
            self.chatMessages.append(trainerMsg)
            
            if let idx = self.trainers.firstIndex(where: { $0.id == trainerId }) {
                self.trainers[idx].lastMessage = replyText
                self.trainers[idx].lastMessageTime = "Now"
            }
        }
    }
    
    private func generateTrainerReply(query: String, trainerId: String) -> String {
        // Coach Stone specific responses
        if trainerId == "coach_marcus" {
            if query.contains("chest") || query.contains("bench") || query.contains("pushup") {
                return "For building a powerful chest, bench presses and deep dips are king. Keep your scapula retracted, pack your shoulders, and control the eccentric phase for 3 full seconds. Hit 4 sets of 8-12 reps with progressive overload!"
            }
            if query.contains("grow") || query.contains("muscle") || query.contains("strength") || query.contains("arm") {
                return "To pack on size, you must eat in a slight caloric surplus (200-300 kcal over maintenance) and hit 1.6 to 2.2 grams of protein per kilogram of bodyweight. Prioritize heavy compound movements and track your weights!"
            }
        }
        
        // Coach Sarah specific responses
        if trainerId == "coach_sarah" {
            if query.contains("diet") || query.contains("eat") || query.contains("food") || query.contains("protein") {
                return "Here is my core diet rule: build every meal around a high-quality protein source (chicken, salmon, tofu or eggs) alongside complex carbs like sweet potatoes or oats, and lots of greens. Also, stay fully hydrated: aim for 3-4 liters daily!"
            }
            if query.contains("yoga") || query.contains("stretch") || query.contains("tight") || query.contains("joint") {
                return "To release deep tension, try doing a 10-minute hip and hamstring routine every single evening. Hold Pigeon pose and Downward Dog for at least 10 slow, deep breaths each. Breathing sends a signal to your nervous system to relax."
            }
        }
        
        // Standard General AI response tree
        if query.contains("diet") || query.contains("eat") || query.contains("food") || query.contains("fat") {
            return "🥑 **Joyar Nutrition Advisor**: A clean diet is the foundation of energy! Aim for a daily calorie target based on your workout goals. Consume 45% complex carbohydrates, 35% lean proteins, and 20% healthy fats. Avoid refined sugar and log your training metrics in Settings!"
        }
        if query.contains("abs") || query.contains("core") || query.contains("belly") {
            return "🔥 **Joyar AI Abs Routine**: Abs are built in the kitchen but hardened in training! Perform this circuit: \n1. Hanging Leg Raises (3x15)\n2. Planks with Shoulder Taps (3x45 seconds)\n3. Russian twists with weight (3x30 reps). Perform this 3 times a week after cardio!"
        }
        if query.contains("hiit") || query.contains("cardio") || query.contains("lose weight") || query.contains("calorie") {
            return "🏃 **Joyar Agility Booster**: High-Intensity Interval Training is incredible for fat burning! Try our 'Fat Burning HIIT Blast' workout video. Perform 40 seconds of maximum effort (sprints/burpees), followed by 20 seconds of walking rest. 4 cycles will spike your metabolic rate!"
        }
        if query.contains("muscle") || query.contains("chest") || query.contains("grow") {
            return "💪 **Joyar Muscle Coach**: To build lean skeletal muscle, prioritize progressive overload. Gradually increase the resistance weights or weekly repetitions. Target 4 sets of 8 to 12 reps on bench press, squats, and pullups, and ensure you get 8 hours of sleep for cellular repair."
        }
        
        // Default fallbacks
        if trainerId == "coach_marcus" {
            return "Keep pushing boundaries, Alex! Muscle growth requires consistency in lifting and high protein. Make sure you log your active sessions and aim to increase weight weekly. What specific muscle group are we focusing on next?"
        } else if trainerId == "coach_sarah" {
            return "Mindful eating and high hydration are keys to recovery, Alex. Listen to your body, incorporate stretches after high intensity cardios, and let me know if you need a customized meal schedule!"
        } else {
            return "That is an excellent fitness question! The secret to reaching your goals is daily consistency. Explore our high-quality workout videos in the Video Tab, log your training histories, and write down posts in the Community to get active support. How can I help you next?"
        }
    }
    
    // MARK: - Profile Settings Actions
    func updateProfile(username: String, goal: String, age: Int, weight: Double, height: Double) {
        userProfile.username = username
        userProfile.goal = goal
        userProfile.age = age
        userProfile.weightKg = weight
        userProfile.heightCm = height
    }
    
    // MARK: - StoreKit IAP Coin Purchases & Unlocks
    func purchaseCoins(amount: Int) {
        coinBalance += amount
    }
    
    func unlockVideo(videoId: String, cost: Int) -> Bool {
        if coinBalance >= cost {
            coinBalance -= cost
            unlockedVideos.insert(videoId)
            return true
        }
        return false
    }
    
    func unlockTrainingPlan(planId: String, cost: Int) -> Bool {
        if coinBalance >= cost {
            coinBalance -= cost
            unlockedTrainingPlans.insert(planId)
            return true
        }
        return false
    }
    
    // MARK: - UGC Moderation Actions (App Store 1.2 Compliance)
    func reportContent(type: String, id: String, reason: String, details: String) {
        reportedContentIds.insert(id)
        
        // Dynamic UI filtering: instantly hide reported content
        if type == "Post" {
            communityPosts.removeAll(where: { $0.id == id })
        } else if type == "Comment" {
            for i in 0..<communityPosts.count {
                communityPosts[i].comments.removeAll(where: { $0.id == id })
            }
        }
    }
    
    func blockUser(username: String) {
        blockedUserNames.insert(username)
        
        // Dynamic UI filtering: instantly hide all content from this blocked user
        communityPosts.removeAll(where: { $0.authorName == username })
        for i in 0..<communityPosts.count {
            communityPosts[i].comments.removeAll(where: { $0.authorName == username })
        }
    }
    
    func resetAllData() {
        userProfile = UserProfile(
            username: DataService.generateRandomName(),
            avatar: "figure.run",
            goal: "Build Muscle",
            age: 26,
            weightKg: 78.5,
            heightCm: 182.0
        )
        coinBalance = 120
        unlockedVideos.removeAll()
        unlockedTrainingPlans.removeAll()
        reportedContentIds.removeAll()
        blockedUserNames.removeAll()
        activeModTarget = nil
        
        loadInitialData()
    }
}

// Swift Array helper for iOS 13 compiler safety
extension Array {
    func firstNumerator(where predicate: (Element) -> Bool) -> Element? {
        return self.first(where: predicate)
    }
}
