import Foundation
import Combine

class CoinManager: ObservableObject {
    static let shared = CoinManager()
    
    @Published private(set) var balance: Int {
        didSet {
            UserDefaults.standard.set(balance, forKey: "user_coin_balance")
        }
    }
    
    private init() {
        // 初始给 0 个金币，或者你可以设置一些初始赠送
        self.balance = UserDefaults.standard.integer(forKey: "user_coin_balance")
    }
    
    func addCoins(_ amount: Int) {
        balance += amount
    }
    
    func spendCoins(_ amount: Int) -> Bool {
        guard balance >= amount else { return false }
        balance -= amount
        return true
    }
}
