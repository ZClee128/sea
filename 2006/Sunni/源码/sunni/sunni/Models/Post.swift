//
//  Post.swift
//  Scenery
//
//  Created on 2026/1/14.
//

import Foundation

enum PostType: String, Codable {
    case image
    case video
}

struct Post: Codable, Identifiable, Hashable {
    let id: UUID
    let userId: UUID
    let type: PostType
    var caption: String
    var mediaURL: String
    var thumbnailURL: String?
    var location: String?
    var likeCount: Int
    var commentCount: Int
    var giftCount: Int
    var shareCount: Int // Added this property
    var isLiked: Bool
    var createdAt: Date
    var user: User
    
    init(
        id: UUID = UUID(),
        userId: UUID,
        type: PostType,
        caption: String,
        mediaURL: String,
        thumbnailURL: String? = nil,
        location: String? = nil,
        likeCount: Int = 0,
        commentCount: Int = 0,
        giftCount: Int = 0,
        shareCount: Int = 0,
        isLiked: Bool = false,
        createdAt: Date = Date(),
        user: User
    ) {
        self.id = id
        self.userId = userId
        self.type = type
        self.caption = caption
        self.mediaURL = mediaURL
        self.thumbnailURL = thumbnailURL
        self.location = location
        self.likeCount = likeCount
        self.commentCount = commentCount
        self.giftCount = giftCount
        self.shareCount = shareCount
        self.isLiked = isLiked
        self.createdAt = createdAt
        self.user = user
    }
}
