import Foundation
import StoreKit

struct CoinProduct {
    let productID: String
    let price: String      // Display price e.g. "$0.99"
    let coins: Int         // Base coins
    let bonusCoins: Int    // Bonus coins (may be 0)
    var totalCoins: Int { coins + bonusCoins }
    var displayName: String {
        if bonusCoins > 0 { return "\(coins) + \(bonusCoins) Bonus Coins" }
        return "\(coins) Coins"
    }
}

/// All IAP products, in the exact order from your App Store Connect setup.
let allCoinProducts: [CoinProduct] = [
    CoinProduct(productID: "Azra",   price: "$0.99",  coins: 32,   bonusCoins: 0),
    CoinProduct(productID: "Azra1",  price: "$1.99",  coins: 60,   bonusCoins: 0),
    CoinProduct(productID: "Azra2",  price: "$2.99",  coins: 96,   bonusCoins: 0),
    CoinProduct(productID: "Azra4",  price: "$4.99",  coins: 155,  bonusCoins: 0),
    CoinProduct(productID: "Azra5",  price: "$5.99",  coins: 189,  bonusCoins: 0),
    CoinProduct(productID: "Azra9",  price: "$9.99",  coins: 299,  bonusCoins: 60),
    CoinProduct(productID: "Azra19", price: "$19.99", coins: 599,  bonusCoins: 130),
    CoinProduct(productID: "Azra49", price: "$49.99", coins: 1599, bonusCoins: 270),
    CoinProduct(productID: "Azra99", price: "$99.99", coins: 3199, bonusCoins: 600),
]

final class StoreManager: NSObject {
    
    static let shared = StoreManager()
    private override init() { super.init() }
    
    /// Called once at launch to register with the payment queue.
    func start() {
        SKPaymentQueue.default().add(self)
    }
    
    var skProducts: [SKProduct] = []
    
    /// Completion called after fetchProducts succeeds or fails.
    var productsCompletion: (([SKProduct]) -> Void)?
    
    // MARK: - Fetch products from App Store
    func fetchProducts(completion: @escaping ([SKProduct]) -> Void) {
        self.productsCompletion = completion
        let ids = Set(allCoinProducts.map { $0.productID })
        let request = SKProductsRequest(productIdentifiers: ids)
        request.delegate = self
        request.start()
    }
    
    // MARK: - Purchase
    func purchase(product: SKProduct) {
        guard SKPaymentQueue.canMakePayments() else { return }
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    // MARK: - Restore
    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    // MARK: - Fulfil after successful purchase
    private func fulfil(productID: String) {
        if let product = allCoinProducts.first(where: { $0.productID == productID }) {
            CoinManager.shared.add(product.totalCoins)
            NotificationCenter.default.post(name: .iapPurchaseSucceeded, object: productID)
        }
    }
}

// MARK: - SKProductsRequestDelegate
extension StoreManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.skProducts = response.products
            self.productsCompletion?(response.products)
            self.productsCompletion = nil
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.productsCompletion?([])
            self.productsCompletion = nil
        }
    }
}

// MARK: - SKPaymentTransactionObserver
extension StoreManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                fulfil(productID: transaction.payment.productIdentifier)
                SKPaymentQueue.default().finishTransaction(transaction)
            case .restored:
                // Consumables are not restored; only allow non-consumables here.
                SKPaymentQueue.default().finishTransaction(transaction)
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
                if let error = transaction.error as? SKError, error.code != .paymentCancelled {
                    NotificationCenter.default.post(name: .iapPurchaseFailed, object: error.localizedDescription)
                } else {
                    NotificationCenter.default.post(name: .iapPurchaseFailed, object: "cancelled")
                }
            default:
                break
            }
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let iapPurchaseSucceeded = Notification.Name("iapPurchaseSucceeded")
    static let iapPurchaseFailed    = Notification.Name("iapPurchaseFailed")
}
