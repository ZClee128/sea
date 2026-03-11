import Foundation

/// Manages the user's coin balance using UserDefaults.
final class CoinManager {
    
    static let shared = CoinManager()
    private init() {}
    
    private let balanceKey = "azra_coin_balance"
    static let balanceChangedNotification = Notification.Name("CoinBalanceChanged")
    
    /// Current coin balance
    var balance: Int {
        get { UserDefaults.standard.integer(forKey: balanceKey) }
        set {
            UserDefaults.standard.set(max(0, newValue), forKey: balanceKey)
            NotificationCenter.default.post(name: CoinManager.balanceChangedNotification, object: nil)
        }
    }
    
    /// Try to spend coins. Returns true if successful.
    func spend(_ amount: Int) -> Bool {
        guard balance >= amount else { return false }
        balance -= amount
        return true
    }
    
    /// Add coins to balance (from IAP or bonus).
    func add(_ amount: Int) {
        balance += amount
    }
}
