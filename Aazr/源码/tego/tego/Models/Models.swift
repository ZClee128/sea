//
//  Models.swift
//  tego
//

import Foundation
import SwiftUI

struct AppTrend: Identifiable {
    var id: String { title }
    let title: String
    let subtitle: String
    let description: String
    let colors: [Color]
    let iconName: String
    let poseTips: [String]
    let isPro: Bool
    let imageURLs: [String]
}

struct VideoClass: Identifiable {
    let id = UUID()
    let title: String
    let author: String
    let duration: String
    let videoURL: String
    let thumbnailColor: Color
    let isPro: Bool
}

struct MockData {
    static let trends: [AppTrend] = [
        AppTrend(title: "Y2K Aesthetic",
              subtitle: "Late 90s to early 2000s revival",
              description: "A futuristic yet nostalgic style featuring metallics, low-rise jeans, and vibrant colors inspired by the dot-com bubble era.",
              colors: [.pink, .purple, .blue],
              iconName: "desktopcomputer",
              poseTips: ["High angle selfie with flash", "Crouching street style pose", "Holding flip phone prop"],
              isPro: false,
              imageURLs: [
                  "https://images.unsplash.com/photo-1550614000-4b95d41bc3c1?w=800&q=80",
                  "https://images.unsplash.com/photo-1542314831-c6a4d14fffac?w=800&q=80"
              ]),
        
        AppTrend(title: "Old Money",
              subtitle: "Quiet luxury and timeless elegance",
              description: "Focuses on high-quality basics, neutral color palettes, tailored fits, and an understated presentation of wealth.",
              colors: [.gray, .white, Color(UIColor.systemBrown)],
              iconName: "leaf",
              poseTips: ["Walking away casually", "Reading a book at a cafe", "Slightly blurred candid style"],
              isPro: false,
              imageURLs: [
                  "https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=800&q=80",
                  "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&q=80",
                  "https://images.unsplash.com/photo-1509631179647-0177331693ae?w=800&q=80"
              ]),
              
        AppTrend(title: "Minimalist Chic",
              subtitle: "Less is undeniably more",
              description: "Clean lines, monochrome colors, and intentional white space. It focuses on the essentials to let the subject truly stand out.",
              colors: [.black, .white, .gray],
              iconName: "square.dashed",
              poseTips: ["Stand straight, look away from camera", "Keep hands in pockets", "Use stark lighting to create strong shadows"],
              isPro: false,
              imageURLs: [
                  "https://images.unsplash.com/photo-1445205170230-053b83016050?w=800&q=80",
                  "https://images.unsplash.com/photo-1495385794356-15371f348c31?w=800&q=80"
              ]),
              
        AppTrend(title: "Gothcore",
              subtitle: "Dark romance and edgy rebellion",
              description: "Embracing the shadows with dramatic silhouettes, leather details, heavy boots, and moody architectural backgrounds.",
              colors: [.black, .purple, .red],
              iconName: "moon.stars",
              poseTips: ["Low angle looking down over the camera", "Crossed arms with dramatic stare", "Leaning against a stone wall"],
              isPro: false,
              imageURLs: [
                  "https://images.unsplash.com/photo-1508742295594-8ceb1d3d623b?w=800&q=80",
                  "https://images.unsplash.com/photo-1512413914583-05b1e612edb9?w=800&q=80"
              ]),
        
        AppTrend(title: "Cyberpunk",
              subtitle: "High tech, low life",
              description: "A futuristic style incorporating dark techwear, neon accents, practical hardware, and utilitarian silhouettes.",
              colors: [.black, .green, .orange],
              iconName: "cpu",
              poseTips: ["Low angle under neon lights", "Looking over the shoulder", "Action stance with aggressive angles"],
              isPro: true,
              imageURLs: [
                  "https://images.unsplash.com/photo-1563452675059-efa1e2e7a787?w=800&q=80",
                  "https://images.unsplash.com/photo-1605806616949-1e87b487cb2a?w=800&q=80"
              ]),
              
        AppTrend(title: "Balletcore",
              subtitle: "Grace and delicate movement",
              description: "Inspired by classical dance, featuring pastels, tulle, wrap tops, leg warmers, and soft, ethereal lighting.",
              colors: [.pink, .white, .gray],
              iconName: "sparkles",
              poseTips: ["On tiptoes, looking up", "Stretching arm gracefully", "Sitting on the floor, adjusting shoes"],
              isPro: true,
              imageURLs: [
                  "https://images.unsplash.com/photo-1516477267152-16e511add3a3?w=800&q=80",
                  "https://images.unsplash.com/photo-1533939632420-5df1bafe1ffc?w=800&q=80"
              ]),
              
        AppTrend(title: "Gorpcore",
              subtitle: "Functional outdoor fashion",
              description: "Utilitarian outdoor wear styled for the street. Think windbreakers, cargo pants, trail shoes, and heavily layered tech fabrics.",
              colors: [.green, Color(UIColor.systemBrown), .orange],
              iconName: "mountain.2",
              poseTips: ["Mid-stride walking shot", "Looking off into the distance", "Crouching to adjust gear"],
              isPro: true,
              imageURLs: [
                  "https://images.unsplash.com/photo-1551698618-1dfe5d97d256?w=800&q=80",
                  "https://images.unsplash.com/photo-1521191560932-a56f082eabd1?w=800&q=80"
              ])
    ]
    
    static let videos: [VideoClass] = [
        VideoClass(title: "Mastering Natural Light", author: "Anna Dev", duration: "1:04", videoURL: "", thumbnailColor: .orange, isPro: false),
        VideoClass(title: "Advanced Posing Techniques", author: "John Smith", duration: "00:33", videoURL: "", thumbnailColor: .blue, isPro: true)
    ]
}
