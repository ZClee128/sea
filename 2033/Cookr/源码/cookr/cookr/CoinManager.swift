import Foundation
import Combine

class CoinManager: ObservableObject {
    static let shared = CoinManager()
    
    @Published var balance: Int = 0
    @Published var unlockedRecipeIds: Set<String> = []
    
    private let coinsKey = "user_coins_balance"
    private let unlockedKey = "unlocked_recipes_list"
    
    private init() {
        self.balance = UserDefaults.standard.integer(forKey: coinsKey)
        if let saved = UserDefaults.standard.stringArray(forKey: unlockedKey) {
            self.unlockedRecipeIds = Set(saved)
        }
    }
    
    func addCoins(_ amount: Int) {
        balance += amount
        save()
    }
    
    func spendCoins(_ amount: Int) -> Bool {
        if balance >= amount {
            balance -= amount
            save()
            return true
        }
        return false
    }
    
    func unlockRecipe(_ id: String, cost: Int = 30) -> Bool {
        if isUnlocked(id) { return true }
        if spendCoins(cost) {
            unlockedRecipeIds.insert(id)
            save()
            return true
        }
        return false
    }
    
    func isUnlocked(_ id: String) -> Bool {
        return unlockedRecipeIds.contains(id)
    }
    
    private func save() {
        UserDefaults.standard.set(balance, forKey: coinsKey)
        UserDefaults.standard.set(Array(unlockedRecipeIds), forKey: unlockedKey)
    }
}
