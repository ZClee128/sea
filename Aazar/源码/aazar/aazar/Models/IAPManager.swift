import Foundation
import StoreKit

class IAPManager: NSObject {
    static let shared = IAPManager()
    
    // Provided Product IDs
    private let productIdentifiers: Set<String> = [
        "Aazar", "Aazar1", "Aazar2", "Aazar4", "Aazar5",
        "Aazar9", "Aazar19", "Aazar49", "Aazar99"
    ]
    
    // Mapping product ID to coin reward
    private let coinRewards: [String: Int] = [
        "Aazar": 32,
        "Aazar1": 60,
        "Aazar2": 96,
        "Aazar4": 155,
        "Aazar5": 189,
        "Aazar9": 359,
        "Aazar19": 729,
        "Aazar49": 1869,
        "Aazar99": 3799
    ]
    
    private var availableProducts: [SKProduct] = []
    
    // Callbacks
    var onProductsFetched: (([SKProduct]) -> Void)?
    var onPurchaseResult: ((Bool, String?) -> Void)?
    
    private override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    func fetchProducts() {
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        request.start()
    }
    
    func purchase(product: SKProduct) {
        guard SKPaymentQueue.canMakePayments() else {
            onPurchaseResult?(false, "In-App Purchases are disabled on your device.")
            return
        }
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    // Only needed for non-consumables/subscriptions, but good practice
    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    private func handlePurchased(_ transaction: SKPaymentTransaction) {
        let pid = transaction.payment.productIdentifier
        if let reward = coinRewards[pid] {
            CoinManager.shared.addCoins(reward)
        }
        SKPaymentQueue.default().finishTransaction(transaction)
        onPurchaseResult?(true, "Successfully purchased coins!")
    }
    
    private func handleFailed(_ transaction: SKPaymentTransaction) {
        var errorMsg = "Purchase failed."
        if let err = transaction.error as? SKError, err.code == .paymentCancelled {
            errorMsg = "Purchase cancelled."
        } else if let error = transaction.error {
            errorMsg = error.localizedDescription
        }
        SKPaymentQueue.default().finishTransaction(transaction)
        onPurchaseResult?(false, errorMsg)
    }
}

// MARK: - SKProductsRequestDelegate
extension IAPManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.availableProducts = response.products
        
        // Sort by price ascending
        self.availableProducts.sort { p1, p2 in
            return p1.price.decimalValue < p2.price.decimalValue
        }
        
        DispatchQueue.main.async {
            self.onProductsFetched?(self.availableProducts)
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Failed to fetch products: \(error)")
        DispatchQueue.main.async {
            self.onProductsFetched?([])
        }
    }
}

// MARK: - SKPaymentTransactionObserver
extension IAPManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                handlePurchased(transaction)
            case .failed:
                handleFailed(transaction)
            case .restored:
                // For consumable coins, restore usually doesn't apply, but handling for safety
                SKPaymentQueue.default().finishTransaction(transaction)
            case .deferred, .purchasing:
                break
            @unknown default:
                break
            }
        }
    }
}
