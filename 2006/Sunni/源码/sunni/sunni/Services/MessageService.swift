//
//  MessageService.swift
//  Scenery
//
//  Created on 2026/1/14.
//

import Foundation

class MessageService {
    static let shared = MessageService()
    
    // In-memory storage (persisted to UserDefaults)
    private var conversations: [Conversation] = []
    private var messageStorage: [String: [Message]] = [:]
    
    private let userDefaults = UserDefaults.standard
    private let conversationsKey = "saved_conversations"
    private let messagesKey = "saved_message_storage"
    
    private init() {
        // Try to load persisted data first
        loadData()
        
        // Data Consistency Check: If conversations exist but messageStorage is empty/partial, try to repair
        if !conversations.isEmpty && messageStorage.isEmpty {
            print("MessageService: Detected inconsistent state (Conversations loaded but MessageStorage empty). Attempting repair.")
            for conversation in conversations {
                messageStorage[conversation.id.uuidString] = []
                if let lastMsg = conversation.lastMessage {
                    messageStorage[conversation.id.uuidString]?.append(lastMsg)
                }
            }
            saveData()
        }
        
        // If no conversations exist (first launch), load mock data
        if conversations.isEmpty {
            conversations = MockDataService.shared.mockConversations
            
            // Initialize storage for existing conversations
            for conversation in conversations {
                messageStorage[conversation.id.uuidString] = []
                if let lastMsg = conversation.lastMessage {
                    messageStorage[conversation.id.uuidString]?.append(lastMsg)
                }
            }
            // Save initial mock data
            saveData()
        }
    }
    
    private func saveData() {
        do {
            let encodedConversations = try JSONEncoder().encode(conversations)
            userDefaults.set(encodedConversations, forKey: conversationsKey)
            
            let encodedMessages = try JSONEncoder().encode(messageStorage)
            userDefaults.set(encodedMessages, forKey: messagesKey)
            userDefaults.synchronize() // Force save
        } catch {
            print("Error saving message data: \(error)")
        }
    }
    
    private func loadData() {
        if let conversationsData = userDefaults.data(forKey: conversationsKey),
           let decodedConversations = try? JSONDecoder().decode([Conversation].self, from: conversationsData) {
            self.conversations = decodedConversations
        }
        
        if let messagesData = userDefaults.data(forKey: messagesKey),
           let decodedMessages = try? JSONDecoder().decode([String: [Message]].self, from: messagesData) {
            self.messageStorage = decodedMessages
        }
    }
    
    func getConversations() -> [Conversation] {
        return conversations
    }
    
    func getMessages(for user: User) -> [Message] {
        // Find existing conversation
        if let conversation = conversations.first(where: { $0.otherUser.id == user.id }) {
            return messageStorage[conversation.id.uuidString] ?? []
        }
        return []
    }
    
    func sendMessage(to user: User, content: String) {
        let currentUser = AuthService.shared.authState.currentUser
        
        let newMessage: Message
        let conversationId: String
        
        // 1. Check if conversation exists
        if let index = conversations.firstIndex(where: { $0.otherUser.id == user.id }) {
            // Update existing conversation (bring to top, update last message)
            var conversation = conversations[index]
            conversationId = conversation.id.uuidString
            
            newMessage = Message(
                conversationId: conversationId,
                senderId: currentUser?.id ?? UUID(),
                receiverId: user.id,
                content: content,
                type: .text,
                isRead: true, // Auto-read own messages
                createdAt: Date()
            )
            
            conversation.lastMessage = newMessage
            conversation.unreadCount = 0 // Sent by me
            conversation.updatedAt = Date()
            
            conversations.remove(at: index)
            conversations.insert(conversation, at: 0)
            
        } else {
            // Create new conversation
            let newId = UUID()
            conversationId = newId.uuidString
            
            newMessage = Message(
                conversationId: conversationId,
                senderId: currentUser?.id ?? UUID(),
                receiverId: user.id,
                content: content,
                type: .text,
                isRead: true,
                createdAt: Date()
            )
            
            let newConversation = Conversation(
                id: newId,
                otherUser: user,
                lastMessage: newMessage,
                unreadCount: 0,
                updatedAt: Date()
            )
            conversations.insert(newConversation, at: 0)
        }
        
        // 2. Persist message
        if messageStorage[conversationId] == nil {
            messageStorage[conversationId] = []
        }
        messageStorage[conversationId]?.append(newMessage)
        
        // Save changes
        saveData()
        
        // Notify UI to update
        NotificationCenter.default.post(name: NSNotification.Name("MessagesUpdated"), object: nil)
    }
}
