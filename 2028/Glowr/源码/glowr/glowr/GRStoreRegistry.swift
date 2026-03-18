import Foundation
import StoreKit
import Combine

class GRStoreRegistry: NSObject, ObservableObject {
    static let shared = GRStoreRegistry()
    
    @Published var coins: Int = UserDefaults.standard.integer(forKey: "gr_vault_credits") {
        didSet {
            UserDefaults.standard.set(coins, forKey: "gr_vault_credits")
        }
    }
    
    @Published var myProducts: [SKProduct] = []
    @Published var transactionState: SKPaymentTransactionState?
    
    let productIDs = [
        "Glowr", "Glowr1", "Glowr2", "Glowr4", "Glowr5", 
        "Glowr9", "Glowr19", "Glowr49", "Glowr99"
    ]
    
    private let coinMap: [String: Int] = [
        "Glowr": 32,
        "Glowr1": 60,
        "Glowr2": 96,
        "Glowr4": 155,
        "Glowr5": 189,
        "Glowr9": 359,
        "Glowr19": 729,
        "Glowr49": 1869,
        "Glowr99": 3799
    ]
    
    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
        fetchProducts()
    }
    
    func fetchProducts() {
        let request = SKProductsRequest(productIdentifiers: Set(productIDs))
        request.delegate = self
        request.start()
    }
    
    func purchaseProduct(product: SKProduct) {
        if SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        }
    }
    
    func spendCoins(_ amount: Int) -> Bool {
        if coins >= amount {
            coins -= amount
            return true
        }
        return false
    }
    
    func addCoins(for productID: String) {
        if let amount = coinMap[productID] {
            coins += amount
        }
    }
}

extension GRStoreRegistry: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.myProducts = response.products.sorted { $0.price.doubleValue < $1.price.doubleValue }
        }
    }
}

extension GRStoreRegistry: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                addCoins(for: transaction.payment.productIdentifier)
                SKPaymentQueue.default().finishTransaction(transaction)
                self.transactionState = .purchased
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
                self.transactionState = .failed
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
                self.transactionState = .restored
            default:
                break
            }
        }
    }
}
