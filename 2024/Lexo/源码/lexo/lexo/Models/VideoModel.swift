import Foundation

struct VideoModel: Identifiable {
    var id: String { urlString }
    let urlString: String
    let title: String
    let duration: String
    let imageName: String
    
    // Premium features
    var isPremium: Bool = false
    var coinCost: Int = 0
}

let mockVideos = [
    VideoModel(urlString: "\(Bundle.main.url(forResource: "1", withExtension: "mp4")!)", title: "Soft Pink Blush Technique", duration: "00:10", imageName: "1", isPremium: false, coinCost: 0),
    VideoModel(urlString: "\(Bundle.main.url(forResource: "2", withExtension: "mp4")!)", title: "Everyday Contour Guide", duration: "00:42", imageName: "2", isPremium: true, coinCost: 60),
    VideoModel(urlString: "\(Bundle.main.url(forResource: "3", withExtension: "mp4")!)", title: "Vintage Ruby Lips Tutorial", duration: "00:38",imageName: "3", isPremium: true, coinCost: 155)
]
