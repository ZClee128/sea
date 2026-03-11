import UIKit

struct MoodImage {
    let id: String
    let localImageName: String // Using local image name instead of URL
    let author: String
    let tags: [String]
    let aspectRatio: CGFloat
}

class InspirationDataService {
    static let shared = InspirationDataService()
    
    func fetchImages() -> [MoodImage] {
        var images = [MoodImage]()
        let tagsPool = [
            ["Portrait", "Cyberpunk", "Neon"],
            ["Cinematic", "Melancholy"],
            ["Y2K", "Fashion", "OOTD"],
            ["Cosplay", "Fantasy", "Ethereal"],
            ["Minimalist", "Studio", "High-End"],
            ["Street Photography", "Fashion"],
            ["Vintage", "Film Look"],
        ]
        
        let authors = ["Alex Rivera", "Sophia Liu", "Ethan Hunt", "Chloe Zhang", "Mia Wong"]
        
        for i in 1...15 {
            let tags = tagsPool.randomElement()!
            let author = authors.randomElement()!
            
            // Randomize aspect ratio to make the waterfall layout look organic
            let aspectRatios: [CGFloat] = [1.0, 4.0/5.0, 3.0/4.0, 2.0/3.0, 9.0/16.0]
            let ratio = aspectRatios.randomElement()!
            
            let image = MoodImage(
                id: "\(i)",
                localImageName: "trend_image_\(i)",
                author: author,
                tags: tags,
                aspectRatio: ratio
            )
            images.append(image)
        }
        return images
    }
    
    // MARK: - Video Masterclass Data
    
    func fetchVideos() -> [VideoLesson] {
        return [
            VideoLesson(
                id: "vid_01",
                title: "Cinematic Lighting Basics",
                subtitle: "Master the art of shadows and neon contrast.",
                videoUrlString: "Cinematic Lighting Basics",
                thumbnailName: "Cinematic Lighting Basics.jpg",
                duration: "00:15"
            ),
            VideoLesson(
                id: "vid_02",
                title: "Color Grading with CoreImage",
                subtitle: "Learn how to build custom photo filters.",
                videoUrlString: "Color Grading with CoreImage",
                thumbnailName: "Color Grading with CoreImage.jpg",
                duration: "00:20"
            )
        ]
    }
}
