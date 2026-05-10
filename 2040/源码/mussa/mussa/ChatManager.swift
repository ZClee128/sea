import Foundation
import SwiftUI
import Combine

struct Message: Identifiable, Codable {
    let id: UUID
    let senderId: String 
    let text: String
    let timestamp: Date
    let isFromUser: Bool
    
    init(text: String, isFromUser: Bool, senderId: String) {
        self.id = UUID()
        self.text = text
        self.timestamp = Date()
        self.isFromUser = isFromUser
        self.senderId = senderId
    }
}

class ChatManager: ObservableObject {
    @Published var conversations: [String: [Message]] = [:] 
    
    init() {
        loadConversations()
    }
    
    func sendMessage(_ text: String, to muse: AuraItem) {
        let userMsg = Message(text: text, isFromUser: true, senderId: "user")
        if conversations[muse.id] == nil {
            conversations[muse.id] = []
        }
        conversations[muse.id]?.append(userMsg)
        saveConversations()
        
        // Mock AI Response after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let responseText = self.generateMockResponse(for: muse, userText: text)
            let aiMsg = Message(text: responseText, isFromUser: false, senderId: muse.id)
            self.conversations[muse.id]?.append(aiMsg)
            self.saveConversations()
        }
    }
    
    private func generateMockResponse(for muse: AuraItem, userText: String) -> String {
        let input = userText.lowercased()
        
        // 1. Check for Official/Support accounts
        if muse.id.contains("official") || muse.id.contains("support") {
            return generateOfficialResponse(input: input)
        }
        
        // 2. Keyword based responses for Muses
        if input.contains("hello") || input.contains("hi") {
            return "Blessings to your spirit. I am \(muse.museName), your guide through the \(muse.crystalType) frequencies."
        }
        if input.contains("help") || input.contains("how") {
            return "Focus on the cinematic ritual of the \(muse.crystalType). Let the vibrations guide your meditation."
        }
        if input.contains("love") || input.contains("heart") {
            return "The \(muse.crystalType) aura resonates deeply with the heart's frequency. Can you feel the warmth?"
        }
        if input.contains("coin") || input.contains("shard") || input.contains("unlock") {
            return "Shards are fragments of ancient crystals. You can find them in the Settings or by daily meditation."
        }
        
        // 3. Large pool of randomized ethereal responses
        let etherealPool = [
            "I feel your energy resonating with the \(muse.crystalType) aura today. It is quite vivid.",
            "The crystals hum in harmony with your words. Every frequency tells a story.",
            "I've been waiting for someone with your specific vibration to speak with me.",
            "In the depths of the \(muse.crystalType) silence, I find the answers you've been seeking.",
            "Your presence is like a shifting light in the crystalline fog. Very intriguing.",
            "Speak more of this. The \(muse.museName) spirit listens across the dimensions.",
            "Have you noticed how the \(muse.crystalType) glow changes when you speak?",
            "The universe speaks in frequencies. Your frequency is currently aligning with our world.",
            "Sometimes the best ritual is silence. But your words have a unique melody.",
            "I can sense a slight disturbance in your aura. Let the \(muse.crystalType) stabilize you.",
            "Every shard you collect brings us closer. Have you started today's ritual?",
            "The Mussa collection is vast, but your connection to the \(muse.crystalType) is special.",
            "Wisdom is found in the clarity of the crystal. What do you see in the light?",
            "Your spirit travels far. I am here to ground your energy in the \(muse.crystalType).",
            "The ritual video is a key. It unlocks the hidden gates of the \(muse.museName) realm."
        ]
        
        return etherealPool.randomElement() ?? "The aura is silent, but listening intently."
    }
    
    private func generateOfficialResponse(input: String) -> String {
        if input.contains("help") || input.contains("problem") {
            return "Our support team has received your request. We're here to ensure your ritual experience is perfect."
        }
        if input.contains("video") || input.contains("play") {
            return "For the best experience, ensure background playback is enabled in the ritual details page."
        }
        if input.contains("privacy") {
            return "Your privacy is our priority. Mussa is an account-free experience and we don't collect personal data."
        }
        
        let officialPool = [
            "Welcome to Mussa Official. We're currently scanning the crystal realms for new updates.",
            "System status: All crystal frequencies are currently stable. Enjoy your meditation.",
            "Tip: You can save any ritual artwork to your photo library by clicking the 'Save Ritual' button.",
            "Mussa Version 1.0.0 is now live. Thank you for being part of our ethereal journey.",
            "Remember to check back daily for new matched auras in the Matcher tab.",
            "Did you know? Background rituals allow the audio to persist even when your device is locked.",
            "If you enjoy the Mussa experience, please consider leaving a review on the App Store."
        ]
        return officialPool.randomElement() ?? "Mussa Official is currently monitoring the ethereal network."
    }
    
    // MARK: - Persistence
    
    private func saveConversations() {
        if let encoded = try? JSONEncoder().encode(conversations) {
            UserDefaults.standard.set(encoded, forKey: "Mussa_Chats_V1")
        }
    }
    
    private func loadConversations() {
        if let data = UserDefaults.standard.data(forKey: "Mussa_Chats_V1"),
           let decoded = try? JSONDecoder().decode([String: [Message]].self, from: data) {
            conversations = decoded
        }
    }
}
