import Foundation

struct Post: Identifiable, Codable {
    let id: String
    let title: String
    let content: String
    let author: String
    let category: Category
    let imageName: String
    let videoURLString: String?
    let date: String
    
    enum Category: String, Codable, CaseIterable {
        case skincare = "Skincare Tuto"
        case makeup = "Makeup Art"
        case styling = "Daily Styling"
        case news = "Beauty News"
    }
}

// Mock Data
let mockPosts: [Post] = [
    Post(
        id: "1",
        title: "How to Achieve the Perfect Glass Skin",
        content: "Glass skin is all about a meticulously hydrated and radiant complexion. In this post, I will share the exact 5-step morning routine to achieve this luminous look...",
        author: "Briar Beauty",
        category: .skincare,
        imageName: "post1_glass_skin",
        videoURLString: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
        date: "Today"
    ),
    Post(
        id: "2",
        title: "Top 10 Fall Makeup Trends",
        content: "As the leaves change, so should our palettes. This season, we are seeing a huge resurgence of warm terracotta and burnt orange tones.",
        author: "Emma Styles",
        category: .makeup,
        imageName: "post2_fall_makeup",
        videoURLString: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
        date: "Yesterday"
    ),
    Post(
        id: "3",
        title: "The Return of the 90s Blowout",
        content: "Big, bouncy hair is back! Here is how you can recreate the iconic 90s supermodel blowout at home using just a round brush and some heat protectant.",
        author: "Hair By Laura",
        category: .styling,
        imageName: "post3_blowout",
        videoURLString: nil,
        date: "2 Days Ago"
    ),
    Post(
        id: "4",
        title: "Dermatologists Share Their Holy Grail SPF",
        content: "Sun protection is the most important step in any routine. We asked 5 top dermatologists what they actually use on their own faces every day.",
        author: "Skin Science Mag",
        category: .skincare,
        imageName: "post4_spf",
        videoURLString: nil,
        date: "Mar 20"
    ),
    Post(
        id: "5",
        title: "Editorial Makeup: From Runway to Real Life",
        content: "Sometimes runway looks are just too avant-garde for the grocery store. Learn how to tone down high-fashion editorial looks for everyday wear.",
        author: "Nina Glam",
        category: .makeup,
        imageName: "post5_editorial",
        videoURLString: nil,
        date: "Mar 18"
    ),
    Post(
        id: "6",
        title: "Clean Beauty: What Does It Really Mean?",
        content: "The term 'clean beauty' is everywhere, but it lacks regulation. Let's break down the ingredients you should actually avoid and the ones that are perfectly safe.",
        author: "Eco Chic",
        category: .news,
        imageName: "post6_clean_beauty",
        videoURLString: nil,
        date: "Mar 15"
    )
]
