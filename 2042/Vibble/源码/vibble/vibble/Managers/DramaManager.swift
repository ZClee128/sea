//
//  DramaManager.swift
//  vibble
//

import Foundation
import SwiftUI
import Combine
// 用于持久化的 Codable 包装
struct UserPost: Codable {
    let id: UUID
    let userName: String
    let description: String
    let dramaTitle: String
    let category: String
    let imageData: Data?
}

@available(iOS 14.0, *)
class DramaManager: ObservableObject {
    static let shared = DramaManager()
    
    @Published var allDramas: [Video] = mockVideos
    private let storageKey = "vibble_user_posts_v2"
    
    init() {
        loadUserPosts()
    }
    
    func addPost(title: String, description: String, category: String, image: UIImage?) {
        let imageData = image?.jpegData(compressionQuality: 0.8)
        
        let newDrama = Video(
            videoName: "", 
            userName: "You",
            description: description,
            dramaTitle: title,
            category: category,
            userImage: image
        )
        
        allDramas.insert(newDrama, at: 0)
        saveUserPosts()
    }
    
    private func saveUserPosts() {
        // 过滤出非 mock 的用户贴子进行持久化
        let userPosts = allDramas.filter { drama in
            !mockVideos.contains(where: { $0.id == drama.id })
        }.map { drama in
            UserPost(
                id: drama.id,
                userName: drama.userName,
                description: drama.description,
                dramaTitle: drama.dramaTitle,
                category: drama.category,
                imageData: drama.userImage?.jpegData(compressionQuality: 0.8)
            )
        }
        
        if let encoded = try? JSONEncoder().encode(userPosts) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    private func loadUserPosts() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([UserPost].self, from: data) else { return }
        
        let savedVideos = decoded.map { post in
            Video(
                id: post.id,
                videoName: "",
                userName: post.userName,
                description: post.description,
                dramaTitle: post.dramaTitle,
                category: post.category,
                userImage: post.imageData != nil ? UIImage(data: post.imageData!) : nil
            )
        }
        
        // 合并本地 mock 和持久化数据
        allDramas = savedVideos + mockVideos
    }
    
    func reset() {
        UserDefaults.standard.removeObject(forKey: storageKey)
        allDramas = mockVideos
    }
}
