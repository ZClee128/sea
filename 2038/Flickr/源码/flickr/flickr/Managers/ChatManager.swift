import Foundation
import Combine

@available(iOS 14.0, *)
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
        let persona = PersonaManager.shared.currentPersona
        let lower = message.lowercased()
        
        // Define Response Pools
        let greetings = [
            "I'm here to help you refine your unique aesthetic vision.",
            "Ready to explore some new visual directions together?",
            "It's a beautiful day to create something meaningful.",
            "How can I assist your creative journey today?"
        ]
        
        let aestheticTalk = [
            "That's a fascinating perspective on visual harmony.",
            "I love how you're thinking about the balance of light and shadow.",
            "Exploring the emotional depth of a composition is key.",
            "Your eye for detail is becoming quite refined.",
            "The way you perceive texture and form is very unique."
        ]
        
        let colorTalk = [
            "Color stories are the soul of any great work. What palette are you feeling?",
            "Have you considered a more muted, monochromatic approach?",
            "Vibrant accents can really make a minimalist piece pop.",
            "Pastels often evoke a sense of calm and clarity.",
            "Darker tones can add a layer of mystery and sophistication."
        ]
        
        let studioTalk = [
            "The Studio is where your vision truly comes to life. Try the Wall Studio for custom lockscreens!",
            "Have you experimented with the Inspo Card templates yet?",
            "Exporting your favorite compositions is a great way to track your style evolution.",
            "The Studio tools are designed for deep focus and creative flow.",
            "Each Studio session is a chance to discover a new facet of your style."
        ]
        
        let helpTalk = [
            "I can suggest specific palettes or studio templates that match your vibe.",
            "If you're stuck, try randomizing a composition in the Inspo Studio.",
            "Looking for inspiration? The Explore tab features some truly amazing muses.",
            "Need help with a specific tool or feature? I'm all ears.",
            "I'm your guide to navigating the Fickr creative ecosystem."
        ]
        
        let fallbacks = [
            "Tell me more about what you're trying to achieve visually.",
            "That's an interesting thought. How does it fit into your current project?",
            "Let's look at this from a different angle together.",
            "Every creative spark is worth exploring.",
            "I'm intrigued by that idea. What's the next step in your process?"
        ]
        
        // Response Construction
        var intro = ""
        if persona != .undiagnosed {
            let prefixes = [
                "As an \(persona.rawValue) perspective, ",
                "Following your \(persona.rawValue) energy, ",
                "In line with your \(persona.rawValue) style, ",
                "For a \(persona.rawValue) like yourself, "
            ]
            intro = prefixes.randomElement() ?? ""
        }
        
        // Intent Detection
        if lower.contains("hello") || lower.contains("hi") || lower.contains("hey") {
            return intro + (greetings.randomElement() ?? "")
        } else if lower.contains("color") || lower.contains("palette") || lower.contains("shade") {
            return intro + (colorTalk.randomElement() ?? "")
        } else if lower.contains("aesthetic") || lower.contains("style") || lower.contains("vibe") {
            return intro + (aestheticTalk.randomElement() ?? "")
        } else if lower.contains("studio") || lower.contains("wall") || lower.contains("card") {
            return intro + (studioTalk.randomElement() ?? "")
        } else if lower.contains("help") || lower.contains("how") || lower.contains("what") {
            return intro + (helpTalk.randomElement() ?? "")
        } else {
            return intro + (fallbacks.randomElement() ?? "")
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
