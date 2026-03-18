import Foundation

struct GRModelProfile: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let agency: String
    let height: String
    let bust: String
    let waist: String
    let hips: String
    let shoes: String
    let eyes: String
    let hair: String
    let imageNames: [String]
    let videoUrl: String?
    let bio: String
    let isFeatured: Bool
}

struct GRModelRegistry {
    static let samples: [GRModelProfile] = [
        GRModelProfile(name: "Elena Rossi", agency: "Elite Milan", height: "178cm", bust: "82cm", waist: "60cm", hips: "88cm", shoes: "39", eyes: "Blue", hair: "Blonde", imageNames: ["m1"], videoUrl: "v1", bio: "Elena has walked for Prada, Gucci and Versace. Known for her striking gaze and professional runway walk.", isFeatured: true),
        GRModelProfile(name: "Julian Chen", agency: "Next London", height: "188cm", bust: "96cm", waist: "78cm", hips: "94cm", shoes: "44", eyes: "Brown", hair: "Black", imageNames: ["m4"], videoUrl: nil, bio: "A rising star in the menswear scene, Julian has been featured in Vogue Man and GQ.", isFeatured: true),
        GRModelProfile(name: "Sofia Vilar", agency: "Ford Paris", height: "175cm", bust: "84cm", waist: "62cm", hips: "90cm", shoes: "38", eyes: "Green", hair: "Brown", imageNames: ["m7"], videoUrl: "v2", bio: "Sofia's versatile look makes her a favorite for both high-fashion editorials and commercial campaigns.", isFeatured: false),
        GRModelProfile(name: "Amara Okeke", agency: "IMG New York", height: "180cm", bust: "81cm", waist: "59cm", hips: "87cm", shoes: "40", eyes: "Dark Brown", hair: "Natural", imageNames: ["m10"], videoUrl: "v3", bio: "Discovered in Lagos, Amara's career exploded after her debut at Paris Fashion Week.", isFeatured: false),
        GRModelProfile(name: "Lukas Weber", agency: "Mega Berlin", height: "187cm", bust: "98cm", waist: "80cm", hips: "96cm", shoes: "45", eyes: "Grey", hair: "Light Brown", imageNames: ["m13"], videoUrl: nil, bio: "Lukas brings a strong architectural feel to his poses, making him perfect for avant-garde labels.", isFeatured: false),
        GRModelProfile(name: "Mina Sato", agency: "Donna Tokyo", height: "176cm", bust: "80cm", waist: "58cm", hips: "86cm", shoes: "37", eyes: "Brown", hair: "Black", imageNames: ["m16"], videoUrl: "v4", bio: "With a background in contemporary dance, Mina's movement in front of the camera is fluid and expressive.", isFeatured: false)
    ]
}

struct GRRunwayReel: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let thumbnailName: String
    let videoFileName: String
    let duration: String
}

struct GRReelRegistry {
    static let samples: [GRRunwayReel] = [
        GRRunwayReel(title: "Milan Fashion Week SS26", description: "Exclusive highlights from the runway of the season.", thumbnailName: "Milan Fashion Week SS26", videoFileName: "Milan Fashion Week SS26", duration: "00:45"),
        GRRunwayReel(title: "Elena Rossi- Creative Shoot", description: "Behind the scenes with Elena Rossi in Rome.", thumbnailName: "Elena Rossi- Creative Shoot", videoFileName: "Elena Rossi- Creative Shoot", duration: "01:20"),
        GRRunwayReel(title: "The Art of the Walk", description: "Mastering the runway with our top talent coaches.", thumbnailName: "The Art of the Walk", videoFileName: "The Art of the Walk", duration: "00:30"),
        GRRunwayReel(title: "Fashion Editorial- Neon Dreams", description: "A cinematic capture of our latest editorial feature.", thumbnailName: "Fashion Editorial- Neon Dreams", videoFileName: "Fashion Editorial- Neon Dreams", duration: "02:15")
    ]
}
