import Foundation
import Combine

/// Singleton that persists coin balance and unlocked premium filter packs.
class CoinStore: ObservableObject {
    static let shared = CoinStore()

    @Published var coinBalance: Int
    @Published var unlockedPacks: Set<String>

    private init() {
        coinBalance = UserDefaults.standard.integer(forKey: "coinBalance")
        let saved = UserDefaults.standard.stringArray(forKey: "unlockedPacks") ?? []
        unlockedPacks = Set(saved)
    }

    func addCoins(_ amount: Int) {
        coinBalance += amount
        UserDefaults.standard.set(coinBalance, forKey: "coinBalance")
    }

    func spendCoins(_ amount: Int) -> Bool {
        guard coinBalance >= amount else { return false }
        coinBalance -= amount
        UserDefaults.standard.set(coinBalance, forKey: "coinBalance")
        return true
    }

    func unlockPack(_ packId: String, cost: Int) -> Bool {
        guard !unlockedPacks.contains(packId) else { return true }
        guard spendCoins(cost) else { return false }
        unlockedPacks.insert(packId)
        UserDefaults.standard.set(Array(unlockedPacks), forKey: "unlockedPacks")
        return true
    }

    func isPackUnlocked(_ packId: String) -> Bool {
        unlockedPacks.contains(packId)
    }
}
