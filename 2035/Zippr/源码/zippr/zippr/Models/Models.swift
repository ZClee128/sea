import Foundation

// MARK: - Content Category
enum FitnessCategory: String, CaseIterable, Identifiable {
    case all        = "All"
    case abs        = "Abs & Core"
    case glutes     = "Glutes"
    case fullBody   = "Full Body"
    case hiit       = "HIIT"
    case stretch    = "Stretch"
    case arms       = "Arms & Shoulders"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .all:      return "square.grid.2x2"
        case .abs:      return "bolt.circle"
        case .glutes:   return "figure.walk"
        case .fullBody: return "figure.strengthtraining.traditional"
        case .hiit:     return "flame"
        case .stretch:  return "figure.flexibility"
        case .arms:     return "dumbbell"
        }
    }
}

// MARK: - Content Item Model
struct ContentItem: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let category: String
    let imageURL: String
    let duration: String        // e.g. "12 min"
    let calories: Int
    let difficulty: Difficulty
    let tags: [String]
    var isFeatured: Bool
    
    // 动态生成属于该课程的专属教练名字，增加丰富度
    var coachName: String {
        switch category {
        case FitnessCategory.abs.rawValue: return "Coach Mike"
        case FitnessCategory.glutes.rawValue: return "Coach Sarah"
        case FitnessCategory.fullBody.rawValue: return "Coach Alex"
        case FitnessCategory.hiit.rawValue: return "Coach Emma"
        case FitnessCategory.stretch.rawValue: return "Master Li"
        case FitnessCategory.arms.rawValue: return "Coach Jay"
        default: return "Coach Zippr"
        }
    }

    enum Difficulty: String, Codable {
        case beginner     = "Beginner"
        case intermediate = "Intermediate"
        case advanced     = "Advanced"

        var color: String {
            switch self {
            case .beginner:     return "#4CAF50"
            case .intermediate: return "#FF9800"
            case .advanced:     return "#F44336"
            }
        }
    }
}

// MARK: - Program Model
struct FitnessProgram: Identifiable {
    let id: String
    let title: String
    let description: String
    let duration: String       // e.g. "4 Weeks"
    let sessionsCount: Int
    let coverImageURL: String
    let category: String
    let level: ContentItem.Difficulty
    var completedDays: Set<Int>
}

// MARK: - Sample Data
struct SampleData {
    static let items: [ContentItem] = [
        ContentItem(id: "1", title: "Booty Burn", subtitle: "Sculpt & lift your glutes", category: FitnessCategory.glutes.rawValue, imageURL: "https://images.unsplash.com/photo-1518614368389-9d3f2b7e2f4a?w=800", duration: "20 min", calories: 180, difficulty: .beginner, tags: ["Glutes", "No Equipment"], isFeatured: true),
        ContentItem(id: "2", title: "Core Crusher", subtitle: "Flat abs in 15 minutes", category: FitnessCategory.abs.rawValue, imageURL: "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800", duration: "15 min", calories: 140, difficulty: .intermediate, tags: ["Core", "Abs"], isFeatured: false),
        ContentItem(id: "3", title: "Full Body Glow", subtitle: "Head-to-toe transformation", category: FitnessCategory.fullBody.rawValue, imageURL: "https://images.unsplash.com/photo-1552196563-55cd4e45efb3?w=800", duration: "30 min", calories: 280, difficulty: .intermediate, tags: ["Full Body", "Cardio"], isFeatured: true),
        ContentItem(id: "4", title: "HIIT Ignite", subtitle: "Burn fat in record time", category: FitnessCategory.hiit.rawValue, imageURL: "https://images.unsplash.com/photo-1599058917212-d750089bc07e?w=800", duration: "25 min", calories: 350, difficulty: .advanced, tags: ["HIIT", "Fat Burn"], isFeatured: false),
        ContentItem(id: "5", title: "Sunrise Stretch", subtitle: "Lengthen & tone your body", category: FitnessCategory.stretch.rawValue, imageURL: "https://images.unsplash.com/photo-1506629082955-511b1aa562c8?w=800", duration: "18 min", calories: 90, difficulty: .beginner, tags: ["Flexibility", "Morning"], isFeatured: false),
        ContentItem(id: "6", title: "Arm Sculptor", subtitle: "Define your arms & shoulders", category: FitnessCategory.arms.rawValue, imageURL: "https://images.unsplash.com/photo-1581009137042-c552e485697a?w=800", duration: "22 min", calories: 200, difficulty: .intermediate, tags: ["Arms", "Toning"], isFeatured: false),
        ContentItem(id: "7", title: "Glute & Leg Day", subtitle: "Power up your lower body", category: FitnessCategory.glutes.rawValue, imageURL: "https://images.unsplash.com/photo-1574680178050-55c6a6a96e0a?w=800", duration: "35 min", calories: 300, difficulty: .advanced, tags: ["Legs", "Glutes", "Strength"], isFeatured: true),
        ContentItem(id: "8", title: "Sweat & Sculpt", subtitle: "Tone every muscle group", category: FitnessCategory.fullBody.rawValue, imageURL: "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=800", duration: "28 min", calories: 260, difficulty: .intermediate, tags: ["Full Body", "Toning"], isFeatured: false),
        ContentItem(id: "9", title: "Abs on Fire", subtitle: "Intense core conditioning", category: FitnessCategory.abs.rawValue, imageURL: "https://images.unsplash.com/photo-1584735935682-2f2b69dff9d2?w=800", duration: "12 min", calories: 120, difficulty: .advanced, tags: ["Core", "Intense"], isFeatured: false),
        ContentItem(id: "10", title: "Power Stretch", subtitle: "Recovery & flexibility flow", category: FitnessCategory.stretch.rawValue, imageURL: "https://images.unsplash.com/photo-1518611012118-696072aa579a?w=800", duration: "20 min", calories: 80, difficulty: .beginner, tags: ["Recovery", "Stretch"], isFeatured: false),
        ContentItem(id: "11", title: "Cardio Kickstart", subtitle: "Get your heart pumping", category: FitnessCategory.hiit.rawValue, imageURL: "https://images.unsplash.com/photo-1552674605-db6ffd4facb5?w=800", duration: "20 min", calories: 310, difficulty: .intermediate, tags: ["Cardio", "Energy"], isFeatured: true),
        ContentItem(id: "12", title: "Shoulder & Back", subtitle: "Strong posture workout", category: FitnessCategory.arms.rawValue, imageURL: "https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?w=800", duration: "25 min", calories: 220, difficulty: .intermediate, tags: ["Back", "Posture"], isFeatured: false),
    ]

    static let programs: [FitnessProgram] = [
        FitnessProgram(id: "p1", title: "28-Day Booty Challenge", description: "Transform your glutes with daily targeted workouts designed to lift, sculpt and strengthen.", duration: "4 Weeks", sessionsCount: 28, coverImageURL: "https://images.unsplash.com/photo-1518614368389-9d3f2b7e2f4a?w=800", category: FitnessCategory.glutes.rawValue, level: .beginner, completedDays: []),
        FitnessProgram(id: "p2", title: "Total Body Transformation", description: "A complete 6-week body sculpting program covering every muscle group for a full makeover.", duration: "6 Weeks", sessionsCount: 42, coverImageURL: "https://images.unsplash.com/photo-1552196563-55cd4e45efb3?w=800", category: FitnessCategory.fullBody.rawValue, level: .intermediate, completedDays: []),
        FitnessProgram(id: "p3", title: "HIIT Fat Blaster", description: "High-intensity interval training program to maximize calorie burn and boost your metabolism.", duration: "3 Weeks", sessionsCount: 21, coverImageURL: "https://images.unsplash.com/photo-1599058917212-d750089bc07e?w=800", category: FitnessCategory.hiit.rawValue, level: .advanced, completedDays: []),
        FitnessProgram(id: "p4", title: "Core & Abs Sculptor", description: "Build a strong, defined core with progressive daily ab workouts over 3 weeks.", duration: "3 Weeks", sessionsCount: 21, coverImageURL: "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800", category: FitnessCategory.abs.rawValue, level: .intermediate, completedDays: []),
    ]

    static let videoItems: [VideoItem] = [
        VideoItem(id: "v1", title: "Full Glute Activation", subtitle: "15-min activation routine", thumbnailURL: "https://images.unsplash.com/photo-1518614368389-9d3f2b7e2f4a?w=800", videoURL: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4", duration: "00:16", category: FitnessCategory.glutes.rawValue),
    ]
}

// MARK: - Video Item Model
struct VideoItem: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let thumbnailURL: String
    let videoURL: String
    let duration: String
    let category: String
}

// MARK: - Article Item Model (For Wellness / Guides)
struct ArticleItem: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let readTime: String
    let coverImageURL: String
    let category: String
}

// MARK: - Chat Message Model
struct ChatMessage: Identifiable, Codable, Equatable {
    let id: String
    let text: String
    let isCurrentUser: Bool
    let timestamp: String
    var isGift: Bool = false
}

extension SampleData {
    static let articles: [ArticleItem] = [
        ArticleItem(id: "a1", title: "The Ultimate Guide to Pre-Workout Nutrition", subtitle: "Fuel your body for maximum explosive performance.", readTime: "5 min read", coverImageURL: "https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=800", category: "Nutrition"),
        ArticleItem(id: "a2", title: "3 Morning Stretches for Better Posture", subtitle: "Undo the damage of sitting at a desk all day.", readTime: "3 min read", coverImageURL: "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=800", category: "Recovery"),
        ArticleItem(id: "a3", title: "Understanding Macronutrients", subtitle: "Proteins, fats, and carbs explained simply.", readTime: "7 min read", coverImageURL: "https://images.unsplash.com/photo-1505253716362-afaea1d3d1af?w=800", category: "Nutrition"),
        ArticleItem(id: "a4", title: "How Sleep Affects Muscle Growth", subtitle: "Why getting 8 hours is just as important as lifting heavy.", readTime: "4 min read", coverImageURL: "https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?w=800", category: "Lifestyle")
    ]

    static let chatHistory: [ChatMessage] = [
        ChatMessage(id: "c1", text: "Hi there! I'm Coach Alex. Let me know if you have any questions before starting this session.", isCurrentUser: false, timestamp: "10:00 AM"),
        ChatMessage(id: "c2", text: "Hey! Should I stretch before or after this one?", isCurrentUser: true, timestamp: "10:05 AM"),
        ChatMessage(id: "c3", text: "Great question. Do a dynamic warmup before, and static stretching after to prevent injury. Let's crush it! 💪", isCurrentUser: false, timestamp: "10:07 AM")
    ]
}
