import Foundation
import StoreKit
import Combine

class IAPManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    static let shared = IAPManager()
    
    @Published var products: [SKProduct] = []
    @Published var isPurchasing: Bool = false
    
    // The exact 9 Product IDs requested by the user
    private let productIDs: Set<String> = [
        "Bexi", "Bexi1", "Bexi2", "Bexi4", "Bexi5", "Bexi9", "Bexi19", "Bexi49", "Bexi99"
    ]
    
    // Map product IDs to their respective coin values
    let coinMap: [String: Int] = [
        "Bexi": 32,
        "Bexi1": 60,
        "Bexi2": 96,
        "Bexi4": 155,
        "Bexi5": 189,
        "Bexi9": 359,
        "Bexi19": 729,
        "Bexi49": 1869,
        "Bexi99": 3799
    ]
    
    private var completionHandler: ((Bool) -> Void)?
    
    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
    // Request products from App Store
    func fetchProducts() {
        let request = SKProductsRequest(productIdentifiers: productIDs)
        request.delegate = self
        request.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            // Sort products by price
            self.products = response.products.sorted(by: { $0.price.decimalValue < $1.price.decimalValue })
            print("Loaded \(self.products.count) products from App Store.")
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Failed to load products: \(error.localizedDescription)")
    }
    
    // Purchase a product
    func purchase(product: SKProduct, completion: @escaping (Bool) -> Void) {
        guard SKPaymentQueue.canMakePayments() else {
            completion(false)
            return
        }
        
        self.completionHandler = completion
        self.isPurchasing = true
        
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    // SKPaymentTransactionObserver
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                handlePurchased(transaction)
            case .failed:
                handleFailed(transaction)
            case .restored:
                handleRestored(transaction)
            case .deferred, .purchasing:
                // Still in progress
                break
            @unknown default:
                break
            }
        }
    }
    
    private func handlePurchased(_ transaction: SKPaymentTransaction) {
        let productID = transaction.payment.productIdentifier
        
        if let coinsToAdd = coinMap[productID] {
            DispatchQueue.main.async {
                // We add coins to the user's StorageManager via notification or directly if injected.
                // For cleanly updating StorageManager, we will post a Notification.
                NotificationCenter.default.post(name: NSNotification.Name("CoinsPurchased"), object: nil, userInfo: ["coins": coinsToAdd])
            }
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
        
        DispatchQueue.main.async {
            self.isPurchasing = false
            self.completionHandler?(true)
        }
    }
    
    private func handleFailed(_ transaction: SKPaymentTransaction) {
        if let error = transaction.error as? SKError {
            print("Transaction failed: \(error.localizedDescription)")
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
        
        DispatchQueue.main.async {
            self.isPurchasing = false
            self.completionHandler?(false)
        }
    }
    
    private func handleRestored(_ transaction: SKPaymentTransaction) {
        // For consumable coins, restore doesn't typically re-grant coins, but we'll finish the transaction
        SKPaymentQueue.default().finishTransaction(transaction)
    }
}
