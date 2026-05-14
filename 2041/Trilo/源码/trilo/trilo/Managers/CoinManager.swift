import Foundation
import SwiftUI
import Combine

class CoinManager: ObservableObject {
    static let shared = CoinManager()
    
    @Published var balance: Int {
        didSet {
            UserDefaults.standard.set(balance, forKey: "user_coin_balance")
        }
    }
    
    init() {
        self.balance = UserDefaults.standard.integer(forKey: "user_coin_balance")
    }
    
    func addCoins(_ amount: Int) {
        balance += amount
    }
    
    func spendCoins(_ amount: Int) -> Bool {
        if balance >= amount {
            balance -= amount
            return true
        }
        return false
    }
    
    func isUnlocked(_ moodID: String) -> Bool {
        return UserDefaults.standard.bool(forKey: "unlocked_mood_\(moodID)")
    }
    
    func unlockMood(_ moodID: String) {
        UserDefaults.standard.set(true, forKey: "unlocked_mood_\(moodID)")
        self.objectWillChange.send()
    }
}
