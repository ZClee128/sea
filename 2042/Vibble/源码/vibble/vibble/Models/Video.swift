//
//  Video.swift
//  vibble
//

import Foundation
import SwiftUI

struct Video: Identifiable, Hashable {
    let id: UUID
    let videoName: String
    let userName: String
    let description: String
    let dramaTitle: String
    let category: String
    var userImage: UIImage? = nil // 新增：支持用户从相册选择的实时图片
    
    // 自定义 Hashable 以跳过 UIImage (UIImage 不原生支持 Hashable)
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Video, rhs: Video) -> Bool {
        lhs.id == rhs.id
    }
    
    init(id: UUID = UUID(), videoName: String, userName: String, description: String, dramaTitle: String, category: String, userImage: UIImage? = nil) {
        self.id = id
        self.videoName = videoName
        self.userName = userName
        self.description = description
        self.dramaTitle = dramaTitle
        self.category = category
        self.userImage = userImage
    }
}

// 保持原有的 10 个本地视频数据
let mockVideos = [
    Video(videoName: "0515 (1)", userName: "DramaHunter", description: "The tension between them in this scene is absolutely breathtaking! Must watch.", dramaTitle: "Midnight Silence", category: "K-Drama"),
    Video(videoName: "0515 (1)(1)", userName: "K_Queen", description: "I didn't see that plot twist coming! Best episode so far.", dramaTitle: "Love in Seoul", category: "K-Drama"),
    Video(videoName: "0515 (1)(2)", userName: "Vibble_Fan", description: "This plot twist changed everything I knew about this character. Brilliant writing!", dramaTitle: "Shadow Protocol", category: "K-Drama"),
    
    Video(videoName: "0515 (1)(3)", userName: "Cinephile_Pro", description: "A beautifully shot historical piece. The costume design is historically accurate.", dramaTitle: "The Last Dynasty", category: "C-Drama"),
    Video(videoName: "0515 (1)(4)", userName: "WuxiaFan", description: "The martial arts choreography here is top-notch. Truly a masterpiece.", dramaTitle: "Sword of Destiny", category: "C-Drama"),
    
    Video(videoName: "0515 (1)(5)", userName: "TrendSetter", description: "The ultimate recommendation for a weekend binge-watch session.", dramaTitle: "Urban Legends", category: "Netflix"),
    Video(videoName: "0515 (1)(6)", userName: "BingeWatcher", description: "This thriller keeps you on the edge of your seat until the very last second.", dramaTitle: "Dark Corridor", category: "Netflix"),
    
    Video(videoName: "0515 (1)(7)", userName: "DramaLover", description: "The character development in this drama is simply phenomenal.", dramaTitle: "Beyond Limits", category: "Trending"),
    Video(videoName: "0515 (1)(8)", userName: "Series_Buff", description: "Can't wait for the next season. The cliffhanger is killing me!", dramaTitle: "The Unknown", category: "Trending"),
    Video(videoName: "0515 (1)(9)", userName: "Reviewer_X", description: "A solid 10/10. Everything from acting to music is perfect.", dramaTitle: "Grand Finale", category: "Netflix")
]
