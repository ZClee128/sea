import Foundation
import StoreKit
import Combine

class StoreManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    static let shared = StoreManager()
    
    @Published var products: [SKProduct] = []
    @Published var coins: Int = UserDefaults.standard.integer(forKey: "user_coins")
    @Published var unlockedDesignIDs: Set<String> = Set(UserDefaults.standard.stringArray(forKey: "unlocked_designs") ?? [])
    
    private let productIdentifiers: Set<String> = [
        "Twinr", "Twinr1", "Twinr2", "Twinr4", "Twinr5", "Twinr9", "Twinr19", "Twinr49", "Twinr99"
    ]
    
    private let coinMap: [String: Int] = [
        "Twinr": 32,
        "Twinr1": 60,
        "Twinr2": 96,
        "Twinr4": 155,
        "Twinr5": 189,
        "Twinr9": 359,
        "Twinr19": 729,
        "Twinr49": 1869,
        "Twinr99": 3799
    ]
    
    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
        fetchProducts()
    }
    
    func fetchProducts() {
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        request.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("[IAP] Loaded \(response.products.count) products")
        if !response.invalidProductIdentifiers.isEmpty {
            print("[IAP] ⚠️ Invalid product IDs (not found in App Store Connect): \(response.invalidProductIdentifiers)")
        }
        DispatchQueue.main.async {
            self.products = response.products.sorted { $0.price.doubleValue < $1.price.doubleValue }
        }
    }
    
    func buyProduct(_ product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                handlePurchase(transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                break
            }
        }
    }
    
    private func handlePurchase(_ transaction: SKPaymentTransaction) {
        let productId = transaction.payment.productIdentifier
        if let coinAmount = coinMap[productId] {
            addCoins(coinAmount)
        }
    }
    
    func addCoins(_ amount: Int) {
        coins += amount
        UserDefaults.standard.set(coins, forKey: "user_coins")
    }
    
    func spendCoins(_ amount: Int) -> Bool {
        if coins >= amount {
            coins -= amount
            UserDefaults.standard.set(coins, forKey: "user_coins")
            return true
        }
        return false
    }
    
    func unlockDesign(_ id: String) {
        unlockedDesignIDs.insert(id)
        UserDefaults.standard.set(Array(unlockedDesignIDs), forKey: "unlocked_designs")
    }
    
    func isUnlocked(_ id: String) -> Bool {
        return unlockedDesignIDs.contains(id)
    }
    
    // For debugging/demo purposes
    func addDemoCoins() {
        addCoins(100)
    }
}
