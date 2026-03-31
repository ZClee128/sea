import Foundation
import Combine

struct ChatMessage: Identifiable, Codable {
    let id: UUID
    let senderId: String // 'user' or expert id
    let text: String
    let timestamp: Date
    let isUser: Bool
    
    init(text: String, isUser: Bool, senderId: String) {
        self.id = UUID()
        self.text = text
        self.isUser = isUser
        self.senderId = senderId
        self.timestamp = Date()
    }
}

class ChatSessionManager: ObservableObject {
    @Published var sessions: [UUID: [ChatMessage]] = [:]
    private let storageKey = "dazzl_chat_sessions_storage"
    
    init() {
        loadSessions()
    }
    
    func messages(for expertID: UUID) -> [ChatMessage] {
        return sessions[expertID] ?? []
    }
    
    func sendMessage(_ text: String, to expert: Expert) {
        let userMessage = ChatMessage(text: text, isUser: true, senderId: "user")
        
        if sessions[expert.id] == nil {
            sessions[expert.id] = []
        }
        
        sessions[expert.id]?.append(userMessage)
        saveSessions()
        
        // Mock expert auto-reply
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let replyText = self.generateMockReply(for: expert, userMessage: text)
            let expertMessage = ChatMessage(text: replyText, isUser: false, senderId: expert.id.uuidString)
            self.sessions[expert.id]?.append(expertMessage)
            self.saveSessions()
        }
    }
    
    private func generateMockReply(for expert: Expert, userMessage: String) -> String {
        let replies = [
            "That's a fascinating technique! Have you tried adjusting the contrast for better depth?",
            "I'd recommend using a 35mm lens for this specific aesthetic. It really captures the essence of \(expert.specialty).",
            "Great to hear from you! Looking at your latest reference, I think a more diffused主光 would work wonders.",
            "Minimalism is key here. Keep the background clean to emphasize the \(expert.specialty) textures.",
            "Interesting. I'll need to research that specific lighting setup, but it sounds promising for Dazzl's core styles."
        ]
        return replies.randomElement() ?? "Tell me more about your creative vision."
    }
    
    private func saveSessions() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    private func loadSessions() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([UUID: [ChatMessage]].self, from: data) {
            sessions = decoded
        }
    }
}
