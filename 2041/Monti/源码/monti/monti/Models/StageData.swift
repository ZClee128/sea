import Foundation
import Combine

// MARK: - Comments Model
struct Comment: Identifiable, Equatable, Codable {
    var id: UUID = UUID()
    let author: String
    let avatar: String
    let content: String
    let timeAgo: String
}

// MARK: - Video Model
struct StuntVideo: Identifiable, Equatable {
    let id: UUID
    let title: String
    let description: String
    let videoUrl: String
    let thumbnailGradientStart: String
    let thumbnailGradientEnd: String
    let iconName: String
    let creator: String
    let creatorAvatar: String
    let actionComplexity: Int // 1-10 scale
    let moveSequenceCount: Int // e.g. 15 moves in the choreography
    var likes: Int
    var isLiked: Bool
    let stageCategory: String // e.g. "Stage Combat", "Pose Choreography", "Acrobatic Movement"
    var comments: [Comment]
    let isPremium: Bool // Requires coin unlock if true
}

// MARK: - Post (Feed) Model
struct CommunityPost: Identifiable, Equatable, Codable {
    let id: UUID
    let creator: String
    let creatorAvatar: String
    let creatorRole: String
    let content: String
    let tag: String
    let gradientStart: String
    let gradientEnd: String
    let iconName: String
    var likes: Int
    var isLiked: Bool
    let timestamp: String
    var comments: [Comment]
    let imageName: String  // Bundle resource name for the post image (without extension)
}

// MARK: - Message Model
struct ChatMessage: Identifiable, Equatable, Codable {
    var id: UUID = UUID()
    let sender: String
    let content: String
    let timestamp: Date
    let isFromMe: Bool
}

// MARK: - Chat Conversation Model
struct ChatConversation: Identifiable, Equatable, Codable {
    let id: UUID
    let partnerName: String
    let partnerAvatar: String
    let partnerRole: String
    var messages: [ChatMessage]
    var unreadCount: Int
}

// MARK: - App Data Repository
class StageDataRepository: ObservableObject {
    @Published var videos: [StuntVideo] = []
    @Published var posts: [CommunityPost] = [] {
        didSet {
            if let encoded = try? JSONEncoder().encode(posts) {
                UserDefaults.standard.set(encoded, forKey: "saved_community_posts")
            }
        }
    }
    @Published var conversations: [ChatConversation] = [] {
        didSet {
            if let encoded = try? JSONEncoder().encode(conversations) {
                UserDefaults.standard.set(encoded, forKey: "saved_chat_conversations")
            }
        }
    }
    @Published var unlockedVideoIDs: Set<UUID> = [] {
        didSet {
            let array = Array(unlockedVideoIDs).map { $0.uuidString }
            UserDefaults.standard.set(array, forKey: "unlocked_video_ids")
        }
    }
    @Published var userDisplayName: String = "Stunt Actor" {
        didSet {
            UserDefaults.standard.set(userDisplayName, forKey: "user_display_name")
        }
    }
    @Published var userAvatarEmoji: String = "🥷" {
        didSet {
            UserDefaults.standard.set(userAvatarEmoji, forKey: "user_avatar_emoji")
        }
    }
    
    init() {
        loadStageData()
    }
    
    private func loadStageData() {
        // Load unlocked video IDs from storage
        if let array = UserDefaults.standard.stringArray(forKey: "unlocked_video_ids") {
            self.unlockedVideoIDs = Set(array.compactMap { UUID(uuidString: $0) })
        }
        
        self.userDisplayName = UserDefaults.standard.string(forKey: "user_display_name") ?? "Stunt Actor"
        self.userAvatarEmoji = UserDefaults.standard.string(forKey: "user_avatar_emoji") ?? "🥷"
        
        // Sample Videos
        videos = [
            StuntVideo(
                id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
                title: "Asuka Langley - Spear Sweep Staging & High Pivot",
                description: "Drafting spear sweeps and rapid overhead guards for the combat sequence. Focusing on stance torque and weapon rotation safety spacing.",
                videoUrl: "Asuka_Langley",
                thumbnailGradientStart: "#11998E", // Teal
                thumbnailGradientEnd: "#38EF7D",   // Green
                iconName: "bolt.fill",
                creator: "Rei Shinka (Asuka)",
                creatorAvatar: "👱‍♀️",
                actionComplexity: 7,
                moveSequenceCount: 12,
                likes: 275,
                isLiked: false,
                stageCategory: "Stage Combat",
                comments: [
                    Comment(author: "Yuki Kitsune", avatar: "🦊", content: "The spin sequence spacing is set perfectly.", timeAgo: "6h ago")
                ],
                isPremium: false
            ),
            StuntVideo(
                id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
                title: "Raiden Shogun - Naginata Strike Flow & Spin Sweep",
                description: "Staging the electro polearm sweeps and posture pivots. Adjusting safety coordinates for the blade rotation and testing movement alignment in replica shoulder guard gear.",
                videoUrl: "Raiden_Shogun",
                thumbnailGradientStart: "#00F2FE", // Cyan
                thumbnailGradientEnd: "#4FACFE",   // Blue
                iconName: "wind",
                creator: "Kumi Chan (Raiden)",
                creatorAvatar: "👩",
                actionComplexity: 6,
                moveSequenceCount: 8,
                likes: 198,
                isLiked: false,
                stageCategory: "Stage Combat",
                comments: [
                    Comment(author: "Luna Val", avatar: "👧", content: "The spin looks incredibly graceful. Excellent control.", timeAgo: "10h ago"),
                    Comment(author: "Yuki Kitsune", avatar: "🦊", content: "Does the armor weight slow down your pivot rotation?", timeAgo: "1d ago")
                ],
                isPremium: false
            ),
            StuntVideo(
                id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!,
                title: "Tifa Lockhart - Close Combat Combo & Shoulder Roll",
                description: "Staging close-quarter strike coordinates, jump kicks, and high vault recovery transitions. Rehearsing hand-strike speed variables and roll safeties on low-friction mats.",
                videoUrl: "Tifa_Lockhart",
                thumbnailGradientStart: "#F12711", // Orange-Red
                thumbnailGradientEnd: "#F5AF19",   // Yellow
                iconName: "figure.walk",
                creator: "Aria Stunts (Tifa)",
                creatorAvatar: "👩‍🦰",
                actionComplexity: 9,
                moveSequenceCount: 18,
                likes: 412,
                isLiked: false,
                stageCategory: "Stage Combat",
                comments: [
                    Comment(author: "Kumi Chan", avatar: "👩", content: "That landing roll recovery is flawless!", timeAgo: "3h ago")
                ],
                isPremium: false
            ),
            StuntVideo(
                id: UUID(uuidString: "44444444-4444-4444-4444-444444444444")!,
                title: "YoRHa 2B - Blade Deflection Sequence & Stunt Roll",
                description: "Rehearsing YoRHa 2B's iconic dual-sword light sweep and low-deflection transitions. Focusing on maintaining balance during quick step-backs with heavy replica sword props.",
                videoUrl: "YoRHa_2B",
                thumbnailGradientStart: "#FF007F", // Neon pink
                thumbnailGradientEnd: "#7F00FF",   // Deep purple
                iconName: "sparkles",
                creator: "Luna Val (2B)",
                creatorAvatar: "👧",
                actionComplexity: 8,
                moveSequenceCount: 14,
                likes: 342,
                isLiked: false,
                stageCategory: "Stage Combat",
                comments: [
                    Comment(author: "Aria Stunts", avatar: "👩‍🦰", content: "The spin sweep recovery was clean. Nice guard transition!", timeAgo: "2h ago"),
                    Comment(author: "Kumi Chan", avatar: "👩", content: "Are you holding the prop balance point closer to the hilt?", timeAgo: "5h ago"),
                    Comment(author: "Rei Shinka", avatar: "👱‍♀️", content: "Will adapt this for our team duel showcase.", timeAgo: "1d ago")
                ],
                isPremium: true
            ),
            StuntVideo(
                id: UUID(uuidString: "55555555-5555-5555-5555-555555555555")!,
                title: "Ahri - Orb Motion Flow & Cape Sweep Rehearsal",
                description: "Testing float movements and posture sweeps for the magic orb dance sequence. Adjusting spin speed boundaries and balance transitions.",
                videoUrl: "Ahri_Orb",
                thumbnailGradientStart: "#FF00CC", // Hot Pink
                thumbnailGradientEnd: "#3333FF",   // Royal Blue
                iconName: "circle.fill",
                creator: "Yuki Kitsune (Ahri)",
                creatorAvatar: "🦊",
                actionComplexity: 5,
                moveSequenceCount: 10,
                likes: 312,
                isLiked: false,
                stageCategory: "Pose Choreography",
                comments: [
                    Comment(author: "Luna Val", avatar: "👧", content: "Super elegant! The tail transition flow looks great.", timeAgo: "4h ago")
                ],
                isPremium: true
            ),
            StuntVideo(
                id: UUID(uuidString: "66666666-6666-6666-6666-666666666666")!,
                title: "Kiana Kaslana - Gun-Kata Flow & Dynamic Spin Recovery",
                description: "Staging low roll recovery, double-pistol sweep stances, and high spin slides. Focusing on maintaining prop angles for camera tracking.",
                videoUrl: "Kiana_Kaslana",
                thumbnailGradientStart: "#FF9900", // Gold
                thumbnailGradientEnd: "#FF5E62",   // Coral
                iconName: "star.fill",
                creator: "Kiana Void (Kiana)",
                creatorAvatar: "👧",
                actionComplexity: 8,
                moveSequenceCount: 15,
                likes: 289,
                isLiked: false,
                stageCategory: "Acrobatic Stunts",
                comments: [],
                isPremium: true
            )
        ]
        
        // Local Community Posts or loaded from storage
        if let savedPosts = UserDefaults.standard.data(forKey: "saved_community_posts"),
           let decoded = try? JSONDecoder().decode([CommunityPost].self, from: savedPosts) {
            posts = decoded
        } else {
            posts = [
                CommunityPost(
                    id: UUID(),
                    creator: "Sarah Connor",
                    creatorAvatar: "👩‍🎤",
                    creatorRole: "Cosplay Acrobatics Performer",
                    content: "Successfully mapped a 14-move shield duel sequence today! Rehearsing with a 2.5kg wooden replica really demands high wrist precision. The sequence flow feels solid. Remember to check clearance coordinates before high-speed spins!",
                    tag: "#StageCombat",
                    gradientStart: "#8E2DE2",
                    gradientEnd: "#4A00E0",
                    iconName: "flame.fill",
                    likes: 124,
                    isLiked: false,
                    timestamp: "3 hours ago",
                    comments: [
                        Comment(author: "Leo Vance", avatar: "👤", content: "Agreed. Keep your guard low during the pivot to protect the prop edges.", timeAgo: "1h ago"),
                        Comment(author: "Maria Novak", avatar: "👩", content: "Are you rehearsing with the display weight or the lighter stunt version?", timeAgo: "2h ago")
                    ],
                    imageName: "feed_img_1"
                ),
                CommunityPost(
                    id: UUID(),
                    creator: "Leo Vance",
                    creatorAvatar: "👤",
                    creatorRole: "Action Stage Director",
                    content: "Drafted an 8-move entrance layout for our upcoming group character showcase. Focusing heavily on synchronized weapon sweeps to optimize stage lights reflection. Safety margins are set to 1.5m.",
                    tag: "#ActionChoreography",
                    gradientStart: "#11998e",
                    gradientEnd: "#38ef7d",
                    iconName: "doc.text.fill",
                    likes: 89,
                    isLiked: false,
                    timestamp: "6 hours ago",
                    comments: [
                        Comment(author: "Kenji Sato", avatar: "👨‍🎤", content: "The synchronicity on the guard looks clean. Can't wait to run it tomorrow!", timeAgo: "4h ago")
                    ],
                    imageName: "feed_img_2"
                ),
                CommunityPost(
                    id: UUID(),
                    creator: "Kenji Sato",
                    creatorAvatar: "👨‍🎤",
                    creatorRole: "Stage Combat Instructor",
                    content: "Testing movement constraints in our new heavy stage props. Rehearsing low rolls and dynamic spins. The visual sweep is great, but we adjusted the weight distribution to allow quicker recovery guards.",
                    tag: "#CharacterPose",
                    gradientStart: "#f857a6",
                    gradientEnd: "#ff5858",
                    iconName: "shield.fill",
                    likes: 156,
                    isLiked: false,
                    timestamp: "1 day ago",
                    comments: [
                        Comment(author: "Sarah Connor", avatar: "👩‍🎤", content: "Make sure you test the shoulder pivots. Heavy prop armor can really limit reach.", timeAgo: "18h ago")
                    ],
                    imageName: "feed_img_3"
                )
            ]
        }
        
        // Preset Conversations or loaded from storage
        if let savedData = UserDefaults.standard.data(forKey: "saved_chat_conversations"),
           let decoded = try? JSONDecoder().decode([ChatConversation].self, from: savedData) {
            conversations = decoded
        } else {
            conversations = [
                ChatConversation(
                    id: UUID(uuidString: "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa")!,
                    partnerName: "Leo Vance",
                    partnerAvatar: "👤",
                    partnerRole: "Action Stage Director",
                    messages: [
                        ChatMessage(id: UUID(), sender: "Leo Vance", content: "Hey! How is the new sword combat layout coming along?", timestamp: Date().addingTimeInterval(-3600 * 2), isFromMe: false),
                        ChatMessage(id: UUID(), sender: "Me", content: "Progressing well! I integrated the high vault transition to roll sweep.", timestamp: Date().addingTimeInterval(-3600 * 1.5), isFromMe: true),
                        ChatMessage(id: UUID(), sender: "Leo Vance", content: "Excellent. Keep the prop's blade angles clear for the stage lights. Let's review the video tomorrow.", timestamp: Date().addingTimeInterval(-3600), isFromMe: false)
                    ],
                    unreadCount: 1
                ),
                ChatConversation(
                    id: UUID(uuidString: "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb")!,
                    partnerName: "Sarah Connor",
                    partnerAvatar: "👩‍🎤",
                    partnerRole: "Cosplay Acrobatics Performer",
                    messages: [
                        ChatMessage(id: UUID(), sender: "Sarah Connor", content: "Are we doing the cape flow walkthrough this afternoon?", timestamp: Date().addingTimeInterval(-3600 * 5), isFromMe: false),
                        ChatMessage(id: UUID(), sender: "Me", content: "Yes! 3 PM. Bring the weighted stunt props.", timestamp: Date().addingTimeInterval(-3600 * 4.5), isFromMe: true),
                        ChatMessage(id: UUID(), sender: "Sarah Connor", content: "Awesome, see you there!", timestamp: Date().addingTimeInterval(-3600 * 4), isFromMe: false)
                    ],
                    unreadCount: 0
                ),
                ChatConversation(
                    id: UUID(uuidString: "cccccccc-cccc-cccc-cccc-cccccccccccc")!,
                    partnerName: "Kenji Sato",
                    partnerAvatar: "👨‍🎤",
                    partnerRole: "Stage Combat Instructor",
                    messages: [
                        ChatMessage(id: UUID(), sender: "Kenji Sato", content: "I reviewed your dual swords sweep. Your guard angles are incredibly precise.", timestamp: Date().addingTimeInterval(-3600 * 24), isFromMe: false),
                        ChatMessage(id: UUID(), sender: "Me", content: "Thanks Kenji! Still trying to speed up the recovery frame on the high block.", timestamp: Date().addingTimeInterval(-3600 * 23), isFromMe: true),
                        ChatMessage(id: UUID(), sender: "Kenji Sato", content: "Try adjusting your rear stance. It gives more torque to swing the replica weapon.", timestamp: Date().addingTimeInterval(-3600 * 22), isFromMe: false)
                    ],
                    unreadCount: 0
                )
            ]
        }
    }
    
    // Send a message and persist the chat history (No auto-reply)
    func sendMessage(to conversationId: UUID, text: String) {
        guard let index = conversations.firstIndex(where: { $0.id == conversationId }) else { return }
        
        let newMsg = ChatMessage(id: UUID(), sender: "Me", content: text, timestamp: Date(), isFromMe: true)
        conversations[index].messages.append(newMsg)
        conversations[index].unreadCount = 0
    }
    
    // Report a post - submits for review (no immediate deletion)
    func reportPost(id: UUID) {
        print("[StageData] Post \(id) reported. Pending review.")
    }
    
    // Report a comment - submits for review (no immediate deletion)
    func reportComment(id: UUID, parentPostId: UUID) {
        print("[StageData] Comment \(id) under post \(parentPostId) reported. Pending review.")
    }
    
    // Report a conversation - submits for review (no immediate deletion)
    func reportConversation(id: UUID) {
        print("[StageData] IM conversation \(id) reported. Pending review.")
    }
    
    // Report a video - submits for review (no immediate deletion)
    func reportVideo(id: UUID) {
        print("[StageData] Video \(id) reported. Pending review.")
    }
    
    // Report a video comment - submits for review (no immediate deletion)
    func reportVideoComment(id: UUID, parentVideoId: UUID) {
        print("[StageData] Video comment \(id) under video \(parentVideoId) reported. Pending review.")
    }
    
    // Reset all local parameters and user data
    func resetData() {
        // Remove persistence keys
        UserDefaults.standard.removeObject(forKey: "user_coin_balance")
        UserDefaults.standard.removeObject(forKey: "unlocked_video_ids")
        UserDefaults.standard.removeObject(forKey: "saved_chat_conversations")
        UserDefaults.standard.removeObject(forKey: "saved_community_posts")
        UserDefaults.standard.removeObject(forKey: "user_display_name")
        UserDefaults.standard.removeObject(forKey: "user_avatar_emoji")
        
        // Reset local in-memory states
        CoinManager.shared.balance = 50
        self.unlockedVideoIDs = []
        self.userDisplayName = "Stunt Actor"
        self.userAvatarEmoji = "🥷"
        
        // Re-load initial data (this resets conversations to presets and posts to defaults)
        loadStageData()
    }
}

// MARK: - Coin Wallet Manager
class CoinManager: ObservableObject {
    static let shared = CoinManager()
    
    @Published var balance: Int {
        didSet {
            UserDefaults.standard.set(balance, forKey: "user_coin_balance")
        }
    }
    
    init() {
        // Starts with 50 coins initially so they can try it right away!
        if UserDefaults.standard.object(forKey: "user_coin_balance") == nil {
            self.balance = 50
        } else {
            self.balance = UserDefaults.standard.integer(forKey: "user_coin_balance")
        }
    }
    
    func addCoins(_ amount: Int) {
        balance += amount
    }
    
    func spendCoins(_ amount: Int) -> Bool {
        if balance >= amount {
            balance -= amount
            return true
        }
        return false
    }
}

// MARK: - StoreKit In-App Purchases Manager
import StoreKit

struct CoinProduct: Identifiable {
    let id: String
    let price: String
    let baseCoins: Int
    let bonusCoins: Int
    let totalCoins: Int
    let displayName: String
    
    var priceValue: Double {
        switch id {
        case "Monti": return 0.99
        case "Monti1": return 1.99
        case "Monti2": return 2.99
        case "Monti4": return 4.99
        case "Monti5": return 5.99
        case "Monti9": return 9.99
        case "Monti19": return 19.99
        case "Monti49": return 49.99
        case "Monti99": return 99.99
        default: return 0.0
        }
    }
}

class StoreManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    static let shared = StoreManager()
    
    @Published var products: [CoinProduct] = []
    @Published var isLoading = false
    @Published var alertMessage: String? = nil
    @Published var showAlert = false
    
    let productIDs = [
        "Monti",
        "Monti1",
        "Monti2",
        "Monti4",
        "Monti5",
        "Monti9",
        "Monti19",
        "Monti49",
        "Monti99"
    ]
    
    override init() {
        super.init()
        setupLocalProducts()
        SKPaymentQueue.default().add(self)
        fetchStoreKitProducts()
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
    private func setupLocalProducts() {
        self.products = [
            CoinProduct(id: "Monti", price: "$0.99", baseCoins: 32, bonusCoins: 0, totalCoins: 32, displayName: "32 Coins Pile"),
            CoinProduct(id: "Monti1", price: "$1.99", baseCoins: 60, bonusCoins: 0, totalCoins: 60, displayName: "60 Coins Pouch"),
            CoinProduct(id: "Monti2", price: "$2.99", baseCoins: 96, bonusCoins: 0, totalCoins: 96, displayName: "96 Coins Bag"),
            CoinProduct(id: "Monti4", price: "$4.99", baseCoins: 155, bonusCoins: 0, totalCoins: 155, displayName: "155 Coins Chest"),
            CoinProduct(id: "Monti5", price: "$5.99", baseCoins: 189, bonusCoins: 0, totalCoins: 189, displayName: "189 Coins Vault"),
            CoinProduct(id: "Monti9", price: "$9.99", baseCoins: 299, bonusCoins: 60, totalCoins: 359, displayName: "299+60 Bonus Pack"),
            CoinProduct(id: "Monti19", price: "$19.99", baseCoins: 599, bonusCoins: 130, totalCoins: 729, displayName: "599+130 Mega Box"),
            CoinProduct(id: "Monti49", price: "$49.99", baseCoins: 1599, bonusCoins: 270, totalCoins: 1869, displayName: "1599+270 Ultra Safe"),
            CoinProduct(id: "Monti99", price: "$99.99", baseCoins: 3199, bonusCoins: 600, totalCoins: 3799, displayName: "3199+600 Grand Treasury")
        ]
    }
    
    func fetchStoreKitProducts() {
        let request = SKProductsRequest(productIdentifiers: Set(productIDs))
        request.delegate = self
        request.start()
    }
    
    // SKProductsRequestDelegate
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            if !response.products.isEmpty {
                self.products = response.products.map { skProduct in
                    let coins = self.coinsFor(productID: skProduct.productIdentifier)
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .currency
                    formatter.locale = skProduct.priceLocale
                    let priceString = formatter.string(from: skProduct.price) ?? "$\(skProduct.price)"
                    
                    return CoinProduct(
                        id: skProduct.productIdentifier,
                        price: priceString,
                        baseCoins: coins.base,
                        bonusCoins: coins.bonus,
                        totalCoins: coins.base + coins.bonus,
                        displayName: skProduct.localizedTitle
                    )
                }.sorted(by: { $0.priceValue < $1.priceValue })
            }
        }
    }
    
    private func coinsFor(productID: String) -> (base: Int, bonus: Int) {
        switch productID {
        case "Monti": return (32, 0)
        case "Monti1": return (60, 0)
        case "Monti2": return (96, 0)
        case "Monti4": return (155, 0)
        case "Monti5": return (189, 0)
        case "Monti9": return (299, 60)
        case "Monti19": return (599, 130)
        case "Monti49": return (1599, 270)
        case "Monti99": return (3199, 600)
        default: return (0, 0)
        }
    }
    
    func purchase(_ product: CoinProduct) {
//        #if targetEnvironment(simulator)
//        let useSimulated = true
//        #else
//        let useSimulated = false
//        #endif
//        
//        if useSimulated {
//            isLoading = true
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
//                self.isLoading = false
//                CoinManager.shared.addCoins(product.totalCoins)
//                self.alertMessage = "Simulated purchase successful! Added \(product.totalCoins) coins."
//                self.showAlert = true
//            }
//            return
//        }
//        
//        isLoading = true
        let payment = SKMutablePayment()
        payment.productIdentifier = product.id
        SKPaymentQueue.default().add(payment)
    }
    
    // SKPaymentTransactionObserver
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                SKPaymentQueue.default().finishTransaction(transaction)
                DispatchQueue.main.async {
                    self.isLoading = false
                    let coins = self.coinsFor(productID: transaction.payment.productIdentifier)
                    CoinManager.shared.addCoins(coins.base + coins.bonus)
                    self.alertMessage = "Purchase successful! Added \(coins.base + coins.bonus) coins."
                    self.showAlert = true
                }
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
                DispatchQueue.main.async {
                    self.isLoading = false
                    if let error = transaction.error as? SKError, error.code != .paymentCancelled {
                        self.alertMessage = "Purchase failed: \(error.localizedDescription)"
                        self.showAlert = true
                    }
                }
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            case .deferred, .purchasing:
                break
            @unknown default:
                break
            }
        }
    }
}

extension UIImage {
    static func loadFromBundleOrDocuments(named name: String) -> UIImage? {
        if name.isEmpty { return nil }
        if name.hasPrefix("custom_") {
            let fileManager = FileManager.default
            if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = documentsURL.appendingPathComponent(name)
                if let image = UIImage(contentsOfFile: fileURL.path) {
                    return image
                }
            }
        }
        if let path = Bundle.main.path(forResource: name, ofType: "jpg") {
            return UIImage(contentsOfFile: path)
        }
        return nil
    }
    
    func saveToDocuments() -> String? {
        let name = "custom_\(UUID().uuidString).jpg"
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let fileURL = documentsURL.appendingPathComponent(name)
        guard let data = self.jpegData(compressionQuality: 0.8) else { return nil }
        do {
            try data.write(to: fileURL)
            return name
        } catch {
            print("Error saving image to documents: \(error)")
            return nil
        }
    }
}
