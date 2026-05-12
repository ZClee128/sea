//
//  Message.swift
//  Scenery
//
//  Created on 2026/1/14.
//

import Foundation

enum MessageType: String, Codable {
    case text
    case image
    case video
   case audio
}

struct Message: Codable, Identifiable, Hashable {
    let id: UUID
    let conversationId: String
    let senderId: UUID
    let receiverId: UUID
    var content: String
    var type: MessageType
    var isRead: Bool
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        conversationId: String,
        senderId: UUID,
        receiverId: UUID,
        content: String,
        type: MessageType = .text,
        isRead: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.conversationId = conversationId
        self.senderId = senderId
        self.receiverId = receiverId
        self.content = content
        self.type = type
        self.isRead = isRead
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct Conversation: Codable, Identifiable, Hashable {
    let id: UUID
    let otherUser: User
    var lastMessage: Message?
    var unreadCount: Int
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        otherUser: User,
        lastMessage: Message? = nil,
        unreadCount: Int = 0,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.otherUser = otherUser
        self.lastMessage = lastMessage
        self.unreadCount = unreadCount
        self.updatedAt = updatedAt
    }
}
