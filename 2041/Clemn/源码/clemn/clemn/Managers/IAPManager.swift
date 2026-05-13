import Foundation
import StoreKit
import Combine

class IAPManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    static let shared = IAPManager()
    
    @Published var products: [SKProduct] = []
    @Published var coins: Int = UserDefaults.standard.integer(forKey: "clemn_coins") {
        didSet {
            UserDefaults.standard.set(coins, forKey: "clemn_coins")
        }
    }
    
    @Published var unlockedIDs: Set<String> = Set(UserDefaults.standard.stringArray(forKey: "clemn_unlocked") ?? []) {
        didSet {
            UserDefaults.standard.set(Array(unlockedIDs), forKey: "clemn_unlocked")
        }
    }
    
    let productIDs = ["Clemn", "Clemn1", "Clemn2", "Clemn4", "Clemn5", "Clemn9", "Clemn19", "Clemn49", "Clemn99"]
    
    private override init() {
        super.init()
        SKPaymentQueue.default().add(self)
        fetchProducts()
    }
    
    func fetchProducts() {
        let request = SKProductsRequest(productIdentifiers: Set(productIDs))
        request.delegate = self
        request.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.products = response.products.sorted { $0.price.decimalValue < $1.price.decimalValue }
        }
    }
    
    func purchase(product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                completePurchase(transaction)
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                break
            }
        }
    }
    
    private func completePurchase(_ transaction: SKPaymentTransaction) {
        let id = transaction.payment.productIdentifier
        let coinsToAdd: Int
        
        switch id {
        case "Clemn": coinsToAdd = 32
        case "Clemn1": coinsToAdd = 60
        case "Clemn2": coinsToAdd = 96
        case "Clemn4": coinsToAdd = 155
        case "Clemn5": coinsToAdd = 189
        case "Clemn9": coinsToAdd = 359
        case "Clemn19": coinsToAdd = 729
        case "Clemn49": coinsToAdd = 1869
        case "Clemn99": coinsToAdd = 3799
        default: coinsToAdd = 0
        }
        
        DispatchQueue.main.async {
            self.coins += coinsToAdd
            SKPaymentQueue.default().finishTransaction(transaction)
        }
    }
    
    func consume(amount: Int) -> Bool {
        if coins >= amount {
            coins -= amount
            return true
        }
        return false
    }
    
    func unlockID(_ id: String) {
        unlockedIDs.insert(id)
    }
}
