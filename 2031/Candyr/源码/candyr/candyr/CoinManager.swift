import SwiftUI
import Combine

@available(iOS 14.0, *)
class CoinManager: ObservableObject {
    @AppStorage("userCoinBalance") var balance: Int = 0
    
    static let shared = CoinManager()
    
    private init() {}
    
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
    
    // Formatting helper
    var balanceString: String {
        return "\(balance)"
    }
}
