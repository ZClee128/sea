//
//  ClubManager.swift
//  vibble
//

import Foundation
import SwiftUI
import Combine

@available(iOS 14.0, *)
class ClubManager: ObservableObject {
    static let shared = ClubManager()
    
    @Published var joinedClubs: Set<String> = []
    private let storageKey = "vibble_joined_clubs"
    
    init() {
        loadClubs()
    }
    
    func toggleClub(name: String) {
        if joinedClubs.contains(name) {
            joinedClubs.remove(name)
        } else {
            joinedClubs.insert(name)
        }
        saveClubs()
    }
    
    func isJoined(_ name: String) -> Bool {
        joinedClubs.contains(name)
    }
    
    private func saveClubs() {
        let array = Array(joinedClubs)
        UserDefaults.standard.set(array, forKey: storageKey)
    }
    
    private func loadClubs() {
        if let array = UserDefaults.standard.stringArray(forKey: storageKey) {
            joinedClubs = Set(array)
        }
    }
    
    func reset() {
        joinedClubs.removeAll()
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
}
