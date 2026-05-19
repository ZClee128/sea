//
//  Drama.swift
//  melonShare
//
//  Created by zclee on 2026/5/19.
//

import SwiftUI

struct DramaCharacter: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let role: String
    let description: String
}

struct DramaReview: Identifiable, Hashable {
    let id = UUID()
    let username: String
    let rating: Int
    let date: String
    let content: String
}

struct Drama: Identifiable, Hashable {
    let id: UUID
    let title: String
    let category: String
    let episodesCount: Int
    let rating: Double
    let summary: String
    let recommendationReason: String
    let characters: [DramaCharacter]
    var reviews: [DramaReview]
    
    // Abstract stylized covers built via gradients
    let startColorHex: String
    let endColorHex: String
    let iconName: String
    
    var isPremium: Bool
    var coinCost: Int
    
    init(
        id: UUID,
        title: String,
        category: String,
        episodesCount: Int,
        rating: Double,
        summary: String,
        recommendationReason: String,
        characters: [DramaCharacter],
        reviews: [DramaReview],
        startColorHex: String,
        endColorHex: String,
        iconName: String,
        isPremium: Bool = false,
        coinCost: Int = 0
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.episodesCount = episodesCount
        self.rating = rating
        self.summary = summary
        self.recommendationReason = recommendationReason
        self.characters = characters
        self.reviews = reviews
        self.startColorHex = startColorHex
        self.endColorHex = endColorHex
        self.iconName = iconName
        self.isPremium = isPremium
        self.coinCost = coinCost
    }
    
    var startColor: Color { Color(hexString: startColorHex) }
    var endColor: Color { Color(hexString: endColorHex) }
    
    var gradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [startColor, endColor]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// Global shared mock database
struct DramaDatabase {
    static var list: [Drama] = [
        Drama(
            id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
            title: "The Rebirth of Heiress Bella",
            category: "Action & Revenge",
            episodesCount: 80,
            rating: 4.9,
            summary: "After being betrayed by her fiance and half-sister, Bella falls into a frozen river. Inexplicably, she wakes up three years in the past on the exact day of her engagement party. Armed with future knowledge, she orchestrates a masterful scheme to reclaim her grandfather's company, expose the schemers, and find true love with a mysterious tycoon who has been silently guarding her.",
            recommendationReason: "Bella's strategic schemes are brilliant! Perfect pacing, incredibly satisfying payback, and exceptional chemistry between the leads. This is a must-track revenge masterpiece.",
            characters: [
                DramaCharacter(name: "Bella Vance", role: "Protagonist", description: "The reborn heiress of the Vance Group. Cold, calculated, but deeply protective of her loved ones."),
                DramaCharacter(name: "Leo Sterling", role: "Male Lead", description: "A reclusive billionaire tycoon who has been secretly in love with Bella for years."),
                DramaCharacter(name: "Chloe Vance", role: "Antagonist", description: "Bella's jealous half-sister who hides a venomous heart behind an innocent smile.")
            ],
            reviews: [
                DramaReview(username: "DramaLover99", rating: 5, date: "May 15, 2026", content: "I watched all 80 episodes in one sitting! Bella is the ultimate queen! No stupid misunderstandings!"),
                DramaReview(username: "RevengeFanatic", rating: 5, date: "May 12, 2026", content: "The engagement scene in Episode 12 is absolute cinema. I couldn't stop cheering! Highly recommended!")
            ],
            startColorHex: "FF5070",
            endColorHex: "781E5A",
            iconName: "crown.fill"
        ),
        Drama(
            id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
            title: "My Secret Billionaire Husband",
            category: "CEO Romance",
            episodesCount: 100,
            rating: 4.7,
            summary: "To pay for her grandmother's medical bills, Natalie agrees to a blind marriage with a seemingly ordinary office worker named Eric. Little does she know, Eric is actually the mysterious sole heir to the Sterling conglomerate—the most powerful corporation in the city. Eric conceals his identity to find true love free from gold-diggers, leading to hilarious, sweet, and dramatic daily encounters.",
            recommendationReason: "Pure sugary sweetness with zero bitter filler! Eric's protective nature and Natalie's hardworking optimism make this an exceptionally heartwarming romance. Extremely high production value.",
            characters: [
                DramaCharacter(name: "Natalie Brooks", role: "Protagonist", description: "A kind, independent designer who works multiple jobs to support her grandmother."),
                DramaCharacter(name: "Eric Sterling", role: "Male Lead", description: "The CEO of Sterling Group. Pretends to be an average assembly worker around Natalie."),
                DramaCharacter(name: "Mrs. Brooks", role: "Supporting", description: "Natalie's loving grandmother whose wisdom keeps Natalie grounded.")
            ],
            reviews: [
                DramaReview(username: "SugarRush", rating: 5, date: "May 18, 2026", content: "So sweet I got cavities! Eric's double identity creates so many funny and cute situations."),
                DramaReview(username: "BingeWatcher", rating: 4, date: "May 16, 2026", content: "Great pacing, although the misunderstanding around episode 60 could have been resolved faster. Overall 9/10!")
            ],
            startColorHex: "FF8C5A",
            endColorHex: "FF5082",
            iconName: "heart.text.square.fill"
        ),
        Drama(
            id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!,
            title: "Back to 1985: Golden Age",
            category: "Time Travel & Retro",
            episodesCount: 90,
            rating: 4.8,
            summary: "Arthur, an unhappy 45-year-old mid-level salaryman in 2026, falls asleep after a disappointing work promotion. He wakes up in 1985 as a 20-year-old university student. Recognizing this as the golden decade of rapid economic rise, Arthur utilizes his knowledge of modern technology and market trends to build an electronics empire while rectifying his past regrets regarding family and friendships.",
            recommendationReason: "A brilliant blend of retro nostalgia, business strategies, and family values. It makes you feel inspired, nostalgic, and excited about the future all at once. Highly motivating!",
            characters: [
                DramaCharacter(name: "Arthur Pendelton", role: "Protagonist", description: "Reborn into his 1985 self. Brilliant, futuristic, but humble and caring."),
                DramaCharacter(name: "Samantha Cole", role: "Female Lead", description: "Arthur's college classmate who assists him in launching his first tech startup."),
                DramaCharacter(name: "Gordon Pendelton", role: "Supporting", description: "Arthur's father. Arthur strives to fix his relationship with him in this second chance.")
            ],
            reviews: [
                DramaReview(username: "RetroVibe", rating: 5, date: "May 10, 2026", content: "The soundtrack, costumes, and old-school tech are spot on! Arthur's business ideas are pure genius."),
                DramaReview(username: "InspireMe", rating: 5, date: "May 08, 2026", content: "Such an emotional ride! Arthur correcting his relationship with his father made me cry. Masterful.")
            ],
            startColorHex: "FFB450",
            endColorHex: "C87828",
            iconName: "hourglass",
            isPremium: true,
            coinCost: 30
        ),
        Drama(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444444444")!,
            title: "The Dragon King's Rise",
            category: "Urban Fantasy & Power",
            episodesCount: 110,
            rating: 4.6,
            summary: "After five years in exile guarding the frozen northern borders as the supreme military commander known as the 'Dragon King', Austin return home in plain clothes to see his wife. He discovers his wife's family is mocking her and attempting to force her into marrying a wealthy local playboy. Austin conceals his overwhelming authority, setting up a thrilling series of counterstrikes to crush the corrupt elites.",
            recommendationReason: "The ultimate power fantasy! If you love seeing arrogant bullies get their immediate, absolute comeuppance, this high-energy, action-driven drama is your absolute golden ticket.",
            characters: [
                DramaCharacter(name: "Austin Sterling", role: "Protagonist", description: "The legendary supreme commander of the army, hiding his status under a humble soldier facade."),
                DramaCharacter(name: "Seraphina Vance", role: "Female Lead", description: "Austin's loyal wife who endured countless hardships for him during his five years of exile."),
                DramaCharacter(name: "Master Blake", role: "Antagonist", description: "A wealthy, arrogant heir who uses bribes to mock Austin's military background.")
            ],
            reviews: [
                DramaReview(username: "ActionPacked", rating: 5, date: "May 14, 2026", content: "I love the reveal scenes when his generals arrive. Pure epic energy! Def worth checking out."),
                DramaReview(username: "AlphaMale", rating: 4, date: "May 11, 2026", content: "Extremely entertaining, Austin's martial arts and authority are so cool. Some dialogue is cheesy but highly satisfying.")
            ],
            startColorHex: "5078FF",
            endColorHex: "1E2878",
            iconName: "bolt.fill",
            isPremium: true,
            coinCost: 50
        ),
        Drama(
            id: UUID(uuidString: "55555555-5555-5555-5555-555555555555")!,
            title: "Destined Love of the CEO",
            category: "CEO Romance",
            episodesCount: 95,
            rating: 4.8,
            summary: "Clara, a talented chef working at a high-end luxury resort, inadvertently knocks over a tray of red wine onto the reclusive hotel magnate, Xavier Sterling. Xavier, who suffers from a rare psychological condition that makes him lose his sense of taste, discovers that Clara's dishes are the only food he can taste. He hires her as his personal chef, initiating a sweet culinary love story.",
            recommendationReason: "An incredibly sweet and cozy drama with beautiful food presentations, satisfying romantic tropes, and wonderful character development that focuses on emotional healing and mutual support.",
            characters: [
                DramaCharacter(name: "Clara Thorne", role: "Protagonist", description: "A cheerful, passionate chef with an extraordinary culinary talent and a heart of gold."),
                DramaCharacter(name: "Xavier Sterling", role: "Male Lead", description: "The cold, perfectionist billionaire CEO of Sterling Hotels, seeking psychological healing."),
                DramaCharacter(name: "Vivian Cole", role: "Antagonist", description: "A snobbish socialite who wants to become Xavier's personal investor at all costs.")
            ],
            reviews: [
                DramaReview(username: "FoodieJunkie", rating: 5, date: "May 17, 2026", content: "I love the culinary battles and the chemistry! Xavier is so incredibly supportive of Clara's dreams."),
                DramaReview(username: "SweetTooth", rating: 5, date: "May 13, 2026", content: "This is my absolute comfort drama. Xavier smiling when eating Clara's dessert makes my heart melt!")
            ],
            startColorHex: "FF78B4",
            endColorHex: "C83C64",
            iconName: "flame.fill"
        )
    ]
}

// Extends Color to support Hex conversions safely
extension Color {
    init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Extends UIColor to support Hex conversions safely on iOS 13
extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            red: CGFloat(r) / 255.0,
            green: CGFloat(g) / 255.0,
            blue: CGFloat(b) / 255.0,
            alpha: CGFloat(a) / 255.0
        )
    }
}
