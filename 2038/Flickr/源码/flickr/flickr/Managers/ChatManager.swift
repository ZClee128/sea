import Foundation
import Combine

class ChatManager: ObservableObject {
    @Published var activeSessions: [ChatSession] = []
    
    private let savePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("ChatSessions.json")
    
    static let shared = ChatManager()
    
    init() {
        self.loadChats()
    }
    
    private func loadChats() {
        if let data = try? Data(contentsOf: savePath),
           let decoded = try? JSONDecoder().decode([ChatSession].self, from: data) {
            self.activeSessions = decoded
        } else {
            self.loadInitialChats()
        }
    }
    
    func saveChats() {
        if let encoded = try? JSONEncoder().encode(activeSessions) {
            try? encoded.write(to: savePath)
        }
    }
    
    private func loadInitialChats() {
        let muse1 = MuseItem(id: UUID(), title: "Golden Hour Guide", imageName: "Golden Hour", description: "Expert in warm, dawn-inspired aesthetics.", category: "Harmony", isEditorialFeatured: true)
        let muse2 = MuseItem(id: UUID(), title: "Stillness Curator", imageName: "Nature's Embrace", description: "Specializing in minimalist nature photography.", category: "Stillness", isEditorialFeatured: false)
        
        activeSessions = [
            ChatSession(id: UUID(), partner: muse1, lastMessage: "How can I help you refine your daily morning vision?", messages: [
                ChatMessage(id: UUID(), text: "Hello! I love the Golden Hour series.", sender: .me, timestamp: Date().addingTimeInterval(-3600)),
                ChatMessage(id: UUID(), text: "How can I help you refine your daily morning vision?", sender: .partner, timestamp: Date().addingTimeInterval(-3500))
            ]),
            ChatSession(id: UUID(), partner: muse2, lastMessage: "Nature's embrace is always open for reflection.", messages: [
                ChatMessage(id: UUID(), text: "Nature's embrace is always open for reflection.", sender: .partner, timestamp: Date().addingTimeInterval(-7200))
            ])
        ]
        saveChats()
    }
    
    func sendMessage(_ text: String, to sessionId: UUID) {
        guard let index = activeSessions.firstIndex(where: { $0.id == sessionId }) else { return }
        
        // Block check
        if activeSessions[index].isBlocked { return }
        
        let newMessage = ChatMessage(id: UUID(), text: text, sender: .me, timestamp: Date())
        activeSessions[index].messages.append(newMessage)
        activeSessions[index].lastMessage = text
        saveChats()
        
        // Mock reply logic
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Re-check block before replying
            guard let updatedIndex = self.activeSessions.firstIndex(where: { $0.id == sessionId }),
                  !self.activeSessions[updatedIndex].isBlocked else { return }
            
            let reply = self.generateMockReply(for: text)
            let replyMessage = ChatMessage(id: UUID(), text: reply, sender: .partner, timestamp: Date())
            self.activeSessions[updatedIndex].messages.append(replyMessage)
            self.activeSessions[updatedIndex].lastMessage = reply
            self.saveChats()
        }
    }
    
    private func generateMockReply(for message: String) -> String {
        let lower = message.lowercased()
        if lower.contains("hello") || lower.contains("hi") {
            return "Greetings! I'm here to help you find your aesthetic center."
        } else if lower.contains("help") {
            return "I can suggest color palettes or studio presets that match your current mood. What are you looking for?"
        } else if lower.contains("studio") {
            return "The Studio tools are perfect for capturing your vision. Have you tried the Wall Studio yet?"
        } else {
            return "That's an interesting perspective. Let's explore how we can visualize that together."
        }
    }
    
    func reportSession(_ sessionId: UUID) {
        print("REPORTED: Session \(sessionId)")
    }
    
    func blockSession(_ sessionId: UUID) {
        guard let index = activeSessions.firstIndex(where: { $0.id == sessionId }) else { return }
        activeSessions[index].isBlocked = true
        activeSessions[index].lastMessage = "Session Blocked"
        saveChats()
    }
}
