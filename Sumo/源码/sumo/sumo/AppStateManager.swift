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
    
    init() {
        self.hasAgreedToTerms = UserDefaults.standard.bool(forKey: "hasAgreedToTerms")
        
        if let data = UserDefaults.standard.data(forKey: "savedLookIDs"),
           let saved = try? JSONDecoder().decode(Set<String>.self, from: data) {
            self.savedLookIDs = saved
        } else {
            self.savedLookIDs = []
        }
        
        if let data = UserDefaults.standard.data(forKey: "blockedUsernames"),
           let blocked = try? JSONDecoder().decode(Set<String>.self, from: data) {
            self.blockedUsernames = blocked
        } else {
            self.blockedUsernames = []
        }
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
        MockData.looks.filter { savedLookIDs.contains($0.id) && !blockedUsernames.contains($0.author) }
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
