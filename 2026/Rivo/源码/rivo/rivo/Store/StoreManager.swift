import Foundation
import StoreKit
import Combine

class StoreManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    @Published var coinBalance: Int {
        didSet {
            UserDefaults.standard.set(coinBalance, forKey: "user_coin_balance")
        }
    }
    
    @Published var products: [SKProduct] = []
    @Published var transactionState: SKPaymentTransactionState?
    
    private let productIDs = [
        "Rivo", "Rivo1", "Rivo2", "Rivo4", "Rivo5", 
        "Rivo9", "Rivo19", "Rivo49", "Rivo99"
    ]
    
    private let coinMap: [String: Int] = [
        "Rivo": 32, "Rivo1": 60, "Rivo2": 96, "Rivo4": 155, "Rivo5": 189,
        "Rivo9": 359, "Rivo19": 729, "Rivo49": 1869, "Rivo99": 3799
    ]
    
    override init() {
        self.coinBalance = UserDefaults.standard.integer(forKey: "user_coin_balance")
        super.init()
        SKPaymentQueue.default().add(self)
        fetchProducts()
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
    func fetchProducts() {
        print("DEBUG: Requesting products: \(productIDs)")
        let request = SKProductsRequest(productIdentifiers: Set(productIDs))
        request.delegate = self
        request.start()
    }
    
    func purchase(productID: String) {
        print("DEBUG: Attempting purchase for: \(productID)")
        guard SKPaymentQueue.canMakePayments() else { return }
        
        if let product = products.first(where: { $0.productIdentifier == productID }) {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        }
    }
    
    func spend(amount: Int) -> Bool {
        if coinBalance >= amount {
            coinBalance -= amount
            return true
        }
        return false
    }
    
    // MARK: - SKProductsRequestDelegate
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("DEBUG: Received \(response.products.count) products from App Store.")
        for product in response.products {
            print("DEBUG: Found Product: \(product.productIdentifier) - \(product.localizedTitle)")
        }
        if !response.invalidProductIdentifiers.isEmpty {
            print("DEBUG: Invalid Product IDs: \(response.invalidProductIdentifiers)")
        }
        
        DispatchQueue.main.async {
            self.products = response.products.sorted { 
                self.productIDs.firstIndex(of: $0.productIdentifier) ?? 0 < 
                self.productIDs.firstIndex(of: $1.productIdentifier) ?? 0 
            }
        }
    }
    
    // MARK: - SKPaymentTransactionObserver
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                handlePurchased(transaction)
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                break
            }
            
            DispatchQueue.main.async {
                self.transactionState = transaction.transactionState
            }
        }
    }
    
    private func handlePurchased(_ transaction: SKPaymentTransaction) {
        let productID = transaction.payment.productIdentifier
        if let coins = coinMap[productID] {
            DispatchQueue.main.async {
                self.coinBalance += coins
            }
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }
}
