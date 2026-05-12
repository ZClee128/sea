//
//  ChatView.swift
//  Scenery
//
//  Created on 2026/1/14.
//

import SwiftUI

@available(iOS 15.0, *)
struct ChatView: View {
    let conversation: Conversation
    @State private var messages: [Message] = []
    @State private var newMessage: String = ""
    @StateObject private var authService = AuthService.shared
    
    private var currentUserId: UUID {
        authService.authState.currentUser?.id ?? UUID()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages list
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(messages) { message in
                        MessageBubble(
                            message: message,
                            isFromCurrentUser: message.senderId == currentUserId
                        )
                    }
                }
                .padding()
            }
            
            // Input bar
            HStack(spacing: 12) {
                TextField("Message...", text: $newMessage)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(newMessage.isEmpty ? .gray : Color(hex: "2ECC71"))
                }
                .disabled(newMessage.isEmpty)
            }
            .padding()
            .background(Color.white)
        }
        .navigationTitle(conversation.otherUser.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadMessages()
        }
    }
    
    private func loadMessages() {
        // Load mock messages
        messages = [
            Message(
                conversationId: conversation.id.uuidString,
                senderId: conversation.otherUser.id,
                receiverId: currentUserId,
                content: "Hey! Did you see that sunset post?",
                type: .text,
                createdAt: Date().addingTimeInterval(-3600)
            ),
            Message(
                conversationId: conversation.id.uuidString,
                senderId: currentUserId,
                receiverId: conversation.otherUser.id,
                content: "Yes! Amazing colors 🌅",
                type: .text,
                createdAt: Date().addingTimeInterval(-3500)
            ),
            Message(
                conversationId: conversation.id.uuidString,
                senderId: conversation.otherUser.id,
                receiverId: currentUserId,
                content: "We should go there together sometime!",
                type: .text,
                createdAt: Date().addingTimeInterval(-3400)
            )
        ]
    }
    
    private func sendMessage() {
        guard !newMessage.isEmpty else { return }
        
        let message = Message(
            conversationId: conversation.id.uuidString,
            senderId: currentUserId,
            receiverId: conversation.otherUser.id,
            content: newMessage,
            type: .text
        )
        
        messages.append(message)
        newMessage = ""
    }
}

struct MessageBubble: View {
    let message: Message
    let isFromCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer()
            }
            
            Text(message.content)
                .padding(12)
                .background(isFromCurrentUser ? Color(hex: "2ECC71") : Color(.systemGray5))
                .foregroundColor(isFromCurrentUser ? .white : .primary)
                .cornerRadius(16)
                .frame(maxWidth: 250, alignment: isFromCurrentUser ? .trailing : .leading)
            
            if !isFromCurrentUser {
                Spacer()
            }
        }
    }
}

@available(iOS 15.0, *)
#Preview {
    NavigationView {
        ChatView(conversation: MockDataService.shared.mockConversations[0])
    }
}
