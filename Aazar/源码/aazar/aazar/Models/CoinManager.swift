import Foundation

class CoinManager {
    static let shared = CoinManager()
    private let balanceKey = "com.aazar.coinBalance"
    
    // Default starting coins
    private let initialCoins = 0
    
    // Notify UI when balance changes
    static let balanceDidChangeNotification = Notification.Name("CoinBalanceDidChange")
    
    private init() {
        // Initialize with default coins if setting up for the first time
        if UserDefaults.standard.object(forKey: balanceKey) == nil {
            UserDefaults.standard.set(initialCoins, forKey: balanceKey)
        }
    }
    
    var currentBalance: Int {
        return UserDefaults.standard.integer(forKey: balanceKey)
    }
    
    func addCoins(_ amount: Int) {
        guard amount > 0 else { return }
        let newBalance = currentBalance + amount
        UserDefaults.standard.set(newBalance, forKey: balanceKey)
        NotificationCenter.default.post(name: CoinManager.balanceDidChangeNotification, object: nil)
    }
    
    func deductCoins(_ amount: Int) -> Bool {
        guard amount > 0 else { return false }
        let balance = currentBalance
        if balance >= amount {
            let newBalance = balance - amount
            UserDefaults.standard.set(newBalance, forKey: balanceKey)
            NotificationCenter.default.post(name: CoinManager.balanceDidChangeNotification, object: nil)
            return true
        }
        return false
    }
}
