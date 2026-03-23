import Foundation
import StoreKit
internal import Combine

class StoreManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    static let shared = StoreManager()
    
    @Published var myProducts = [SKProduct]()
    @Published var isPurchasing = false
    
    let productDict: [String: Int] = [
        "Junip": 32,
        "Junip1": 60,
        "Junip2": 96,
        "Junip4": 155,
        "Junip5": 189,
        "Junip9": 359,
        "Junip19": 729,
        "Junip49": 1869,
        "Junip99": 3799
    ]
    
    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
        getProducts()
    }
    
    func getProducts() {
        let productIDs = Set(productDict.keys)
        let request = SKProductsRequest(productIdentifiers: productIDs)
        request.delegate = self
        request.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            // Sort by price
            self.myProducts = response.products.sorted { $0.price.decimalValue < $1.price.decimalValue }
        }
    }
    
    func purchaseProduct(product: SKProduct) {
        guard SKPaymentQueue.canMakePayments() else { return }
        
        DispatchQueue.main.async {
            self.isPurchasing = true
        }
        
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                SKPaymentQueue.default().finishTransaction(transaction)
                handleSuccessfulPurchase(transaction.payment.productIdentifier)
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
                DispatchQueue.main.async {
                    self.isPurchasing = false
                }
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
            case .deferred, .purchasing:
                continue
            @unknown default:
                continue
            }
        }
    }
    
    private func handleSuccessfulPurchase(_ identifier: String) {
        DispatchQueue.main.async {
            self.isPurchasing = false
            if let coins = self.productDict[identifier] {
                // Add coins to user balance
                CoinManager.shared.addCoins(coins)
            }
        }
    }
}
