import SwiftUI
import Combine

/// A centralized manager for user-collected city moments with deep persistence.
class CollectionManager: ObservableObject {
    static let shared = CollectionManager()
    
    private let userDefaults = UserDefaults.standard
    private let SAVED_TITLES_KEY = "popla_saved_titles"
    private let CONTRIBUTIONS_KEY = "popla_contributions"
    private let CHECKLIST_KEY = "popla_checklist"
    private let COINS_KEY = "popla_coin_balance"
    
    @Published var coinBalance: Int = 0 {
        didSet { userDefaults.set(coinBalance, forKey: COINS_KEY) }
    }
    
    @Published var savedMomentTitles: Set<String> = [] {
        didSet { saveSavedTitles() }
    }
    
    @Published var contributedSpots: [DiscoverySpot] = [] {
        didSet { saveContributions() }
    }
    
    @Published var checklist: [PlannerItem] = [] {
        didSet { saveChecklist() }
    }
    
    // Gamification: Calculate progress based on activity
    var curatorProgress: Double {
        let savedCount = Double(savedMomentTitles.count) * 0.05
        let suggestionCount = Double(contributedSpots.count) * 0.1
        let completedTasks = Double(checklist.filter { $0.isCompleted }.count) * 0.05
        let economyBonus = Double(coinBalance) * 0.0001 // Smal bonus for having coins
        return min(savedCount + suggestionCount + completedTasks + economyBonus, 1.0)
    }
    
    init() {
        self.coinBalance = userDefaults.integer(forKey: COINS_KEY)
        loadSavedTitles()
        loadContributions()
        loadChecklist()
    }
    
    // MARK: - Core Actions
    
    func toggleCollection(_ title: String) {
        withAnimation(.spring()) {
            if savedMomentTitles.contains(title) {
                savedMomentTitles.remove(title)
            } else {
                savedMomentTitles.insert(title)
            }
        }
    }
    
    func isSaved(_ title: String) -> Bool {
        return savedMomentTitles.contains(title)
    }
    
    func addSuggestion(_ title: String, category: String, imageData: Data? = nil) {
        let newSpot = DiscoverySpot(title: title, imageName: "user_upload", category: category, imageData: imageData)
        withAnimation(.spring()) {
            contributedSpots.insert(newSpot, at: 0)
        }
    }
    
    func toggleTask(_ id: UUID) {
        if let index = checklist.firstIndex(where: { $0.id == id }) {
            withAnimation(.spring()) {
                checklist[index].isCompleted.toggle()
            }
        }
    }
    
    func boostSpot(id: UUID) {
        if let index = contributedSpots.firstIndex(where: { $0.id == id }) {
            if coinBalance >= 100 {
                withAnimation(.spring()) {
                    coinBalance -= 100
                    contributedSpots[index].isBoosted = true
                    contributedSpots[index].boostCount += 1
                }
            }
        }
    }
    
    func addCoins(_ amount: Int) {
        withAnimation(.spring()) {
            coinBalance += amount
        }
    }
    
    // MARK: - Persistence Logic
    
    private func saveSavedTitles() {
        let array = Array(savedMomentTitles)
        userDefaults.set(array, forKey: SAVED_TITLES_KEY)
    }
    
    private func loadSavedTitles() {
        if let array = userDefaults.stringArray(forKey: SAVED_TITLES_KEY) {
            savedMomentTitles = Set(array)
        }
    }
    
    private func saveContributions() {
        if let data = try? JSONEncoder().encode(contributedSpots) {
            userDefaults.set(data, forKey: CONTRIBUTIONS_KEY)
        }
    }
    
    private func loadContributions() {
        if let data = userDefaults.data(forKey: CONTRIBUTIONS_KEY),
           let decoded = try? JSONDecoder().decode([DiscoverySpot].self, from: data) {
            contributedSpots = decoded
        }
    }
    
    private func saveChecklist() {
        if let data = try? JSONEncoder().encode(checklist) {
            userDefaults.set(data, forKey: CHECKLIST_KEY)
        }
    }
    
    private func loadChecklist() {
        if let data = userDefaults.data(forKey: CHECKLIST_KEY),
           let decoded = try? JSONDecoder().decode([PlannerItem].self, from: data) {
            checklist = decoded
        } else {
            // Initial Seed Tasks (8 Items for 4.2 compliance & depth)
            checklist = [
                PlannerItem(title: "Pick up new vinyl at Archive", isCompleted: false),
                PlannerItem(title: "Draft editorial for Street Pulse", isCompleted: true),
                PlannerItem(title: "Find the hidden SOHO design studio", isCompleted: false),
                PlannerItem(title: "Catch the morning glow at Cafe Urban", isCompleted: false),
                PlannerItem(title: "Map the Bauhaus walk route", isCompleted: false),
                PlannerItem(title: "Capture neon reflections in Neon District", isCompleted: false),
                PlannerItem(title: "Record bird songs at Central Park oasis", isCompleted: false),
                PlannerItem(title: "Visit the Library St. Archive", isCompleted: false)
            ]
        }
    }
}
