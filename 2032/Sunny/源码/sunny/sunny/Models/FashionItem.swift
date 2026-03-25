import Foundation

struct Designer: Identifiable {
    let id = UUID()
    let name: String
    let avatarName: String
    let specialty: String
    let bio: String
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let timestamp: Date
    let isFromUser: Bool
}

struct FashionItem: Identifiable {
    enum SubCategory: String, CaseIterable {
        case top = "Top"
        case bottom = "Bottom"
        case shoes = "Shoes"
        case accessory = "Accessory"
    }
    
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
    let category: String
    let subCategory: SubCategory
    let views: Int
    let column: Int
    let designer: Designer
}



struct FashionData {
    static let designers: [Designer] = [
        Designer(name: "Elena Rossi", avatarName: "Elena Rossi", specialty: "Italian Luxury", bio: "With over 15 years in Milan, Elena brings classic elegance to modern silhouettes."),
        Designer(name: "Marcus Chen", avatarName: "Marcus Chen", specialty: "Streatwear", bio: "Marcus focuses on sustainable materials and urban aesthetics."),
        Designer(name: "Sophie Laurent", avatarName: "Sophie Laurent", specialty: "Bohemian Chic", bio: "Sophie's designs are inspired by her travels through Provence and Bali.")
    ]
    
    static let sampleItems: [FashionItem] = [
        FashionItem(
            title: "Summer Breeze Dress",
            description: "Light and airy summer dress perfect for warm days. Features breathable fabric and vibrant floral patterns.",
            imageName: "Summer Breeze Dress",
            category: "Dress",
            subCategory: .top,
            views: 15420,
            column: 0,
            designer: designers[0]
        ),
        FashionItem(
            title: "Bohemian Dream",
            description: "Free-spirited boho style with flowing fabrics, earthy tones, and romantic details.",
            imageName: "Bohemian Dream",
            category: "Bohemian",
            subCategory: .top,
            views: 9870,
            column: 1,
            designer: designers[2]
        ),
        FashionItem(
            title: "Vintage Romance",
            description: "Romantic vintage-inspired dress with classic silhouettes and elegant details.",
            imageName: "Vintage Romance",
            category: "Vintage",
            subCategory: .top,
            views: 7600,
            column: 0,
            designer: designers[0]
        ),
        FashionItem(
            title: "Minimalist White",
            description: "Clean and chic all-white outfit for modern women who love simplicity.",
            imageName: "Minimalist White",
            category: "Minimal",
            subCategory: .top,
            views: 11200,
            column: 1,
            designer: designers[1]
        ),
        FashionItem(
            title: "Spring Blossom",
            description: "Fresh spring outfit with soft pastels and floral accents for the new season.",
            imageName: "Spring Blossom",
            category: "Spring",
            subCategory: .top,
            views: 9200,
            column: 0,
            designer: designers[2]
        ),
        FashionItem(
            title: "Night Out Glamour",
            description: "Show-stopping party outfit with sparkling details for unforgettable nights.",
            imageName: "Night Out Glamour",
            category: "Party",
            subCategory: .top,
            views: 13800,
            column: 1,
            designer: designers[1]
        ),
        FashionItem(
            title: "Office Professional",
            description: "Polished business attire for career women. Sophisticated and confident style.",
            imageName: "Office Professional",
            category: "Business",
            subCategory: .top,
            views: 8900,
            column: 0,
            designer: designers[0]
        ),
        FashionItem(
            title: "Beach Paradise",
            description: "Tropical beachwear perfect for resort vacations and seaside getaways.",
            imageName: "Beach Paradise",
            category: "Beach",
            subCategory: .top,
            views: 14500,
            column: 1,
            designer: designers[2]
        ),
        FashionItem(
            title: "Natural Beauty",
            description: "Minimalist makeup looks that enhance your natural beauty with soft tones.",
            imageName: "Natural Beauty",
            category: "Beauty",
            subCategory: .accessory,
            views: 16500,
            column: 0,
            designer: designers[1]
        ),
        FashionItem(
            title: "Hairstyle Inspiration",
            description: "Beautiful hairstyles for every occasion, from casual to elegant updos.",
            imageName: "Hairstyle Inspiration",
            category: "Hair",
            subCategory: .accessory,
            views: 9900,
            column: 1,
            designer: designers[0]
        ),
        FashionItem(
            title: "Elegant Evening Look",
            description: "Sophisticated evening ensemble for special occasions and formal events.",
            imageName: "Elegant Evening Look",
            category: "Evening",
            subCategory: .top,
            views: 12350,
            column: 0,
            designer: designers[0]
        ),
        FashionItem(
            title: "Casual Denim Style",
            description: "Relaxed everyday look with denim jacket, perfect for casual outings.",
            imageName: "Casual Denim Style",
            category: "Casual",
            subCategory: .top,
            views: 18200,
            column: 1,
            designer: designers[1]
        ),
        FashionItem(
            title: "High-Waist Trousers",
            description: "Chic high-waisted trousers that elongate the silhouette. Versatile for office or casual wear.",
            imageName: "High-Waist Trousers",
            category: "Business",
            subCategory: .bottom,
            views: 5400,
            column: 0,
            designer: designers[0]
        ),
        FashionItem(
            title: "Pleated Midi Skirt",
            description: "Elegant pleated skirt with a soft metallic sheen. Perfect for pairing with simple tops.",
            imageName: "Pleated Midi Skirt",
            category: "Minimal",
            subCategory: .bottom,
            views: 6700,
            column: 1,
            designer: designers[2]
        ),
        FashionItem(
            title: "Classic Stilettos",
            description: "Timeless black stilettos that add a touch of sophistication to any outfit.",
            imageName: "Classic Stilettos",
            category: "Evening",
            subCategory: .shoes,
            views: 4300,
            column: 0,
            designer: designers[0]
        ),
        FashionItem(
            title: "Urban Sneakers",
            description: "Minimalist white sneakers for a clean and comfortable street style look.",
            imageName: "Urban Sneakers",
            category: "Casual",
            subCategory: .shoes,
            views: 12500,
            column: 1,
            designer: designers[1]
        )
    ]


    
    static let categories = [
        "All", "Dress", "Casual", "Business", "Beach",
        "Bohemian", "Vintage", "Athleisure", "Evening", "Minimal",
        "Party", "Beauty", "Hair"
    ]
}
