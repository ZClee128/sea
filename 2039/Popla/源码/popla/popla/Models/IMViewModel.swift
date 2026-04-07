import SwiftUI
import Combine

struct Message: Identifiable, Equatable {
    let id = UUID()
    let content: String
    let isFromUser: Bool
    let timestamp: Date = Date()
}

class IMViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var curatorName: String
    
    init(curatorName: String) {
        self.curatorName = curatorName
        // Initial Greeting
        self.messages = [
            Message(content: "Hi there! I'm \(curatorName). Thanks for exploring my collection. Any specific spot you're curious about?", isFromUser: false)
        ]
    }
    
    func sendMessage(_ content: String) {
        guard !content.isEmpty else { return }
        
        // User Message
        let userMsg = Message(content: content, isFromUser: true)
        messages.append(userMsg)
        
        // Mock Reply Logic
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let reply = self.generateReply(for: content)
            self.messages.append(Message(content: reply, isFromUser: false))
        }
    }
    
    private func generateReply(for input: String) -> String {
        let lowercaseInput = input.lowercased()
        
        // Response Pools to avoid repetition (App Store Rule compliance)
        let greetings = [
            "Hello! Great to connect. Are you planning a visit to this area?",
            "Hi! Glad you liked this collection. Do you usually explore urban spots?",
            "Hey! Thanks for the message. I spend a lot of time curatoring these corners."
        ]
        
        let coffeeResponses = [
            "That cafe has the best coffee in the city. Try to get there before 10 AM.",
            "Glad you asked! Their baristas are actually artists. The atmosphere is quiet at noon.",
            "Cafe Urban is my second office. The 'Morning Glow' light there is unbeatable."
        ]
        
        let locationResponses = [
            "It's a bit of a hidden gem. I've pinned the exact coordinates in the Discovery section!",
            "Most people walk right past it. That's why I love sharing these secret spots.",
            "District 9 is full of surprises. I'm glad you noticed this specific perspective."
        ]
        
        let generalResponses = [
            "That's a great perspective. I love how the city reveals itself when you look closely.",
            "Interesting point! Urban living is all about these small, rhythmic details.",
            "I totally agree. Every street has its own pulse if you listen long enough.",
            "Thanks for sharing! I'm constantly looking for more spots like this.",
            "City life is fascinating when you find the right rhythm, right?"
        ]
        
        if lowercaseInput.contains("hello") || lowercaseInput.contains("hi") {
            return greetings.randomElement() ?? greetings[0]
        } else if lowercaseInput.contains("cafe") || lowercaseInput.contains("coffee") {
            return coffeeResponses.randomElement() ?? coffeeResponses[0]
        } else if lowercaseInput.contains("location") || lowercaseInput.contains("where") {
            return locationResponses.randomElement() ?? locationResponses[0]
        } else {
            return generalResponses.randomElement() ?? generalResponses[0]
        }
    }
}
