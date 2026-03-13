import Foundation
import StoreKit
import Combine

class StoreManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    static let shared = StoreManager()
    
    @Published var myProducts = [SKProduct]()
    var request: SKProductsRequest!
    
    @Published var transactionState: SKPaymentTransactionState?
    
    let productDict: [String: Int] = [
        "Quvo": 32,
        "Quvo1": 60,
        "Quvo2": 96,
        "Quvo4": 155,
        "Quvo5": 189,
        "Quvo9": 359,
        "Quvo19": 729,
        "Quvo49": 1869,
        "Quvo99": 3799
    ]
    
    func getProducts() {
        let productIDs = Set(productDict.keys)
        request = SKProductsRequest(productIdentifiers: productIDs)
        request.delegate = self
        request.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if !response.products.isEmpty {
            DispatchQueue.main.async {
                // Sort by price, or a predefined order
                self.myProducts = response.products.sorted { $0.price.decimalValue < $1.price.decimalValue }
            }
        }
        for invalidIdentifier in response.invalidProductIdentifiers {
            print("Invalid identifiers found: \(invalidIdentifier)")
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Request did fail: \(error)")
    }
    
    func purchaseProduct(product: SKProduct) {
        if SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        } else {
            print("User can't make payment.")
        }
    }
    
    func restoreProducts() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                transactionState = .purchasing
            case .purchased:
                UserDefaults.standard.set(true, forKey: transaction.payment.productIdentifier)
                
                // Add coins based on the product purchased
                if let coinsToAdd = productDict[transaction.payment.productIdentifier] {
                    DispatchQueue.main.async {
                        AppState.shared.coinBalance += coinsToAdd
                    }
                }
                
                queue.finishTransaction(transaction)
                transactionState = .purchased
            case .restored:
                UserDefaults.standard.set(true, forKey: transaction.payment.productIdentifier)
                queue.finishTransaction(transaction)
                transactionState = .restored
            case .failed, .deferred:
                print("Payment Queue Error: \(String(describing: transaction.error))")
                queue.finishTransaction(transaction)
                transactionState = .failed
            default:
                queue.finishTransaction(transaction)
            }
        }
    }
}
