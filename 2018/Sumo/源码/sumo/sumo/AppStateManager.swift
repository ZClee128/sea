import Foundation
import SwiftUI
import Combine

class AppStateManager: ObservableObject {
    @Published var hasAgreedToTerms: Bool {
        didSet {
            UserDefaults.standard.set(hasAgreedToTerms, forKey: "hasAgreedToTerms")
        }
    }

    @Published var savedLookIDs: Set<String> {
        didSet {
            if let data = try? JSONEncoder().encode(savedLookIDs) {
                UserDefaults.standard.set(data, forKey: "savedLookIDs")
            }
        }
    }

    @Published var blockedUsernames: Set<String> {
        didSet {
            if let data = try? JSONEncoder().encode(blockedUsernames) {
                UserDefaults.standard.set(data, forKey: "blockedUsernames")
            }
        }
    }

    @Published var coinBalance: Int {
        didSet {
            UserDefaults.standard.set(coinBalance, forKey: "coinBalance")
        }
    }

    init() {
        self.hasAgreedToTerms = UserDefaults.standard.bool(forKey: "hasAgreedToTerms")

        if let data = UserDefaults.standard.data(forKey: "savedLookIDs"),
           let saved = try? JSONDecoder().decode(Set<String>.self, from: data) {
            self.savedLookIDs = saved
        } else {
            self.savedLookIDs = []
        }

        self.coinBalance = UserDefaults.standard.integer(forKey: "coinBalance")

        if let data = UserDefaults.standard.data(forKey: "blockedUsernames"),
           let blocked = try? JSONDecoder().decode(Set<String>.self, from: data) {
            self.blockedUsernames = blocked
        } else {
            self.blockedUsernames = []
        }

        // Restore any AI-generated looks so they survive app restarts
        if let data = UserDefaults.standard.data(forKey: "aiGeneratedLooks"),
           let aiLooks = try? JSONDecoder().decode([Look].self, from: data) {
            for look in aiLooks {
                if !ContentLibrary.looks.contains(where: { $0.id == look.id }) {
                    ContentLibrary.looks.append(look)
                }
            }
        }
    }

    // MARK: - AI Look Persistence

    /// Call this after appending a new look to ContentLibrary.looks to persist it.
    func saveAIGeneratedLook(_ look: Look) {
        var aiLooks = loadAILooks()
        if !aiLooks.contains(where: { $0.id == look.id }) {
            aiLooks.append(look)
        }
        if let data = try? JSONEncoder().encode(aiLooks) {
            UserDefaults.standard.set(data, forKey: "aiGeneratedLooks")
        }
    }

    private func loadAILooks() -> [Look] {
        guard let data = UserDefaults.standard.data(forKey: "aiGeneratedLooks"),
              let looks = try? JSONDecoder().decode([Look].self, from: data) else {
            return []
        }
        return looks
    }

    // MARK: - Coins
    func addCoins(_ amount: Int) {
        coinBalance += amount
    }

    /// Returns true if the spend succeeded, false if insufficient balance.
    func spendCoins(_ amount: Int) -> Bool {
        guard coinBalance >= amount else { return false }
        coinBalance -= amount
        return true
    }

    // MARK: - Saves
    func toggleSave(look: Look) {
        if savedLookIDs.contains(look.id) {
            savedLookIDs.remove(look.id)
        } else {
            savedLookIDs.insert(look.id)
        }
    }

    func isSaved(look: Look) -> Bool {
        return savedLookIDs.contains(look.id)
    }

    var savedLooks: [Look] {
        ContentLibrary.looks.filter { savedLookIDs.contains($0.id) && !blockedUsernames.contains($0.author) }
    }

    // MARK: - UGC Compliance
    func blockUser(_ username: String) {
        blockedUsernames.insert(username)
    }

    func unblockUser(_ username: String) {
        blockedUsernames.remove(username)
    }

    func isBlocked(_ username: String) -> Bool {
        return blockedUsernames.contains(username)
    }
}
