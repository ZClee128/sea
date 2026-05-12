//
//  BlockService.swift
//  Scenery
//
//  Created on 2026/1/14.
//

import Foundation
import Combine

class BlockService: ObservableObject {
    static let shared = BlockService()
    
    @Published var blockedUserIds: Set<UUID> = []
    @Published var reportedPosts: Set<UUID> = []
    @Published var reportedUsers: Set<UUID> = []
    
    private init() {}
    
    func blockUser(_ userId: UUID) {
        blockedUserIds.insert(userId)
        // In a real app, this would call backend API
    }
    
    func unblockUser(_ userId: UUID) {
        blockedUserIds.remove(userId)
    }
    
    func isUserBlocked(_ userId: UUID) -> Bool {
        return blockedUserIds.contains(userId)
    }
    
    func reportPost(_ postId: UUID) {
        reportedPosts.insert(postId)
    }
    
    func reportUser(_ userId: UUID) {
        reportedUsers.insert(userId)
    }
    
    func submitReport(_ report: Report) {
        // In a real app, send to backend
        print("Report submitted: \\(report)")
    }
}
