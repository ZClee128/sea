import Foundation
import StoreKit
import Combine

class StoreManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    static let shared = StoreManager()
    
    @Published var products: [SKProduct] = []
    @Published var transactionState: SKPaymentTransactionState?
    @Published var userCoins: Int {
        didSet {
            UserDefaults.standard.set(userCoins, forKey: "user_coins_balance")
        }
    }
    
    private let productIDs = ["Ruvo", "Ruvo1", "Ruvo2", "Ruvo4", "Ruvo5", "Ruvo9", "Ruvo19", "Ruvo49", "Ruvo99"]
    
    private let coinMapping: [String: Int] = [
        "Ruvo": 32,
        "Ruvo1": 60,
        "Ruvo2": 96,
        "Ruvo4": 155,
        "Ruvo5": 189,
        "Ruvo9": 359,
        "Ruvo19": 729,
        "Ruvo49": 1869,
        "Ruvo99": 3799
    ]
    
    override init() {
        self.userCoins = UserDefaults.standard.integer(forKey: "user_coins_balance")
        super.init()
        SKPaymentQueue.default().add(self)
        fetchProducts()
    }
    
    func fetchProducts() {
        let request = SKProductsRequest(productIdentifiers: Set(productIDs))
        request.delegate = self
        request.start()
    }
    
    func purchase(product: SKProduct) {
        if SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        }
    }
    
    // MARK: - SKProductsRequestDelegate
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.products = response.products.sorted { $0.price.doubleValue < $1.price.doubleValue }
        }
    }
    
    // MARK: - SKPaymentTransactionObserver
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                complete(transaction: transaction)
            case .failed:
                failed(transaction: transaction)
            case .restored:
                restore(transaction: transaction)
            default:
                break
            }
            self.transactionState = transaction.transactionState
        }
    }
    
    private func complete(transaction: SKPaymentTransaction) {
        let productID = transaction.payment.productIdentifier
        if let coins = coinMapping[productID] {
            userCoins += coins
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func restore(transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func failed(transaction: SKPaymentTransaction) {
        if let error = transaction.error as NSError?, error.code != SKError.paymentCancelled.rawValue {
            print("Transaction failed: \(error.localizedDescription)")
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }
}
