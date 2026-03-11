import Foundation
import StoreKit

class StoreManager: NSObject {
    static let shared = StoreManager()
    
    // As requested from the user's product table
    let productDict: [String: Int] = [
        "Jolo": 32,
        "Jolo1": 60,
        "Jolo2": 96,
        "Jolo4": 155,
        "Jolo5": 189,
        "Jolo9": 359,
        "Jolo19": 729,
        "Jolo49": 1869,
        "Jolo99": 3799
    ]
    
    var products: [SKProduct] = [] {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name("ProductsFetched"), object: nil)
        }
    }
    
    var coinBalance: Int {
        get {
            return UserDefaults.standard.integer(forKey: "userCoinBalance")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "userCoinBalance")
            NotificationCenter.default.post(name: NSNotification.Name("CoinBalanceChanged"), object: nil)
        }
    }
    
    override private init() {
        super.init()
        // If first launch, could give some free coins, but let's start at 0
        SKPaymentQueue.default().add(self)
        fetchProducts()
    }
    
    func fetchProducts() {
        let request = SKProductsRequest(productIdentifiers: Set(productDict.keys))
        request.delegate = self
        request.start()
    }
    
    func purchase(_ product: SKProduct) {
        if SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        }
    }
    
    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

extension StoreManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            // Sort by price ascending or by coin amount
            self.products = response.products.sorted { p1, p2 in
                let coins1 = self.productDict[p1.productIdentifier] ?? 0
                let coins2 = self.productDict[p2.productIdentifier] ?? 0
                return coins1 < coins2
            }
        }
    }
}

extension StoreManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                handlePurchased(transaction.payment.productIdentifier)
                queue.finishTransaction(transaction)
            case .restored:
                // Consumables typically aren't restored, but just in case
                queue.finishTransaction(transaction)
            case .failed:
                queue.finishTransaction(transaction)
            case .purchasing, .deferred:
                break
            @unknown default:
                break
            }
        }
    }
    
    private func handlePurchased(_ productId: String) {
        if let coinsToAdd = productDict[productId] {
            DispatchQueue.main.async {
                self.coinBalance += coinsToAdd
                NotificationCenter.default.post(name: NSNotification.Name("PurchaseSuccessful"), object: nil)
            }
        }
    }
}
