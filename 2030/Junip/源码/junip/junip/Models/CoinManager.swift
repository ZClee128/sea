import Foundation
internal import Combine

class CoinManager: ObservableObject {
    static let shared = CoinManager()
    
    @Published var balance: Int = 0
    private let defaults = UserDefaults.standard
    private let balanceKey = "junip_coins_balance"
    private let unlockedItemsKey = "junip_unlocked_items"
    
    @Published var unlockedItems: Set<String> = []
    
    init() {
        self.balance = defaults.integer(forKey: balanceKey)
        if let unlockedArray = defaults.stringArray(forKey: unlockedItemsKey) {
            self.unlockedItems = Set(unlockedArray)
        }
    }
    
    func addCoins(_ amount: Int) {
        balance += amount
        defaults.set(balance, forKey: balanceKey)
    }
    
    func spendCoins(_ amount: Int) -> Bool {
        if balance >= amount {
            balance -= amount
            defaults.set(balance, forKey: balanceKey)
            return true
        }
        return false
    }
    
    func unlockItem(_ id: String) {
        unlockedItems.insert(id)
        defaults.set(Array(unlockedItems), forKey: unlockedItemsKey)
    }
    
    func isUnlocked(_ id: String) -> Bool {
        return unlockedItems.contains(id)
    }
}
