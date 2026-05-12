//
//  MessagesView.swift
//  Scenery
//
//  Created on 2026/1/14.
//

import SwiftUI

@available(iOS 16.0, *)
struct MessagesView: View {
    @StateObject private var authService = AuthService.shared
    @State private var showNewMessage = false
    @State private var showLogin = false
    
    var isAuthenticated: Bool {
        authService.authState.isAuthenticated
    }
    
    // Test accounts that have message data
    var testAccountEmails: Set<String> = ["alex@example.com", "sarah@example.com", "mike@example.com", "emma@example.com"]
    
    var hasMessages: Bool {
        guard let email = authService.authState.currentUser?.email else { return false }
        return testAccountEmails.contains(email)
    }
    
    var conversations: [Conversation] {
        hasMessages ? MockDataService.shared.mockConversations : []
    }
    
    var body: some View {
        NavigationView {
            Group {
                if isAuthenticated {
                    // Authenticated - show messages or empty state
                    if hasMessages {
                        messagesList
                    } else {
                        emptyMessagesView
                    }
                } else {
                    // Guest - show login prompt
                    loginPrompt
                }
            }
            .navigationTitle("Messages")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isAuthenticated && hasMessages {
                        Button(action: { showNewMessage = true }) {
                            Image(systemName: "square.and.pencil")
                                .foregroundColor(Color(hex: "2ECC71"))
                        }
                    }
                }
            }
            .sheet(isPresented: $showNewMessage) {
                Text("New Message (Not implemented)")
            }
            .sheet(isPresented: $showLogin) {
                EmailInputView()
            }
            .onChange(of: authService.authState.isAuthenticated) { newValue in
                if newValue && showLogin {
                    showLogin = false
                }
            }
        }
    }
    
    // MARK: - Messages List
    private var messagesList: some View {
        List {
            ForEach(conversations) { conversation in
                NavigationLink(destination: ChatView(conversation: conversation)) {
                    ConversationRow(conversation: conversation)
                }
            }
        }
        .listStyle(.plain)
    }
    
    // MARK: - Empty Messages
    private var emptyMessagesView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "message")
                .font(.system(size: 80))
                .foregroundColor(.gray.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("No Messages Yet")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Start connecting with others to see your conversations here")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Login Prompt
    private var loginPrompt: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "message.circle")
                .font(.system(size: 80))
                .foregroundColor(Color(hex: "2ECC71"))
            
            VStack(spacing: 8) {
                Text("Connect with Others")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Login to send messages and stay connected with the community")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Button(action: { showLogin = true }) {
                Text("Login / Sign Up")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "2ECC71"))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 32)
            .padding(.top, 16)
            
            Spacer()
        }
    }
}

@available(iOS 16.0, *)
struct ConversationRow: View {
    let conversation: Conversation
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(Color(hex: "2ECC71"))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(conversation.otherUser.displayName.prefix(1).uppercased())
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(conversation.otherUser.displayName)
                    .fontWeight(.semibold)
                
                if let lastMessage = conversation.lastMessage {
                    Text(lastMessage.content)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(timeAgo(conversation.updatedAt))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if conversation.unreadCount > 0 {
                    Text("\(conversation.unreadCount)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 20, height: 20)
                        .background(Color.red)
                        .clipShape(Circle())
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func timeAgo(_ date: Date) -> String {
        let seconds = Date().timeIntervalSince(date)
        
        if seconds < 3600 {
            let minutes = Int(seconds / 60)
            return "\(minutes)m"
        } else if seconds < 86400 {
            let hours = Int(seconds / 3600)
            return "\(hours)h"
        } else {
            let days = Int(seconds / 86400)
            return "\(days)d"
        }
    }
}

@available(iOS 16.0, *)
struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesView()
    }
}
