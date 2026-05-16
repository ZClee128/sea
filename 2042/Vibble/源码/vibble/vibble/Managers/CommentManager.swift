//
//  CommentManager.swift
//  vibble
//

import Foundation
import SwiftUI
import Combine

@available(iOS 14.0, *)
class CommentManager: ObservableObject {
    static let shared = CommentManager()
    private let storageKeyPrefix = "vibble_comments_"
    
    @Published var currentComments: [Comment] = []
    
    func loadComments(for dramaTitle: String) {
        let key = storageKeyPrefix + dramaTitle
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([Comment].self, from: data) {
            self.currentComments = decoded
        } else {
            // 只有原始的 mock 视频才加载默认评论
            let isMockVideo = mockVideos.contains(where: { $0.dramaTitle == dramaTitle })
            
            if isMockVideo {
                let defaults = [
                    Comment(user: "Cinephile_Elena", text: "The cinematography in this scene of \(dramaTitle) is absolutely breathtaking. 10/10!", color: .blue),
                    Comment(user: "DramaGeek_99", text: "Wait, did anyone catch that subtle hint in the background? Season 2 incoming?", color: .purple),
                    Comment(user: "Lili_Watcher", text: "I've rewatched this 5 times already. The chemistry is unmatched.", color: .pink),
                    Comment(user: "ScriptReviewer", text: "This writing is so sharp. Every line serves a purpose. Love the depth.", color: .orange)
                ]
                self.currentComments = defaults
                saveComments(for: dramaTitle)
            } else {
                // 新发布的贴子初始评论为空
                self.currentComments = []
            }
        }
    }
    
    func addComment(to dramaTitle: String, text: String, user: String) {
        let newComment = Comment(user: user, text: text, color: Theme.primary)
        currentComments.append(newComment)
        saveComments(for: dramaTitle)
    }
    
    private func saveComments(for dramaTitle: String) {
        let key = storageKeyPrefix + dramaTitle
        if let encoded = try? JSONEncoder().encode(currentComments) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
}
