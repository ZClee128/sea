import Foundation
import StoreKit
import Combine

class StoreManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    static let shared = StoreManager()
    
    @Published var coinBalance: Int {
        didSet {
            UserDefaults.standard.set(coinBalance, forKey: "UserCoinBalance")
        }
    }
    
    @Published var availableProducts: [SKProduct] = []
    
    private let productDict: [String: Int] = [
        "Aazrr": 32,
        "Aazrr1": 60,
        "Aazrr2": 96,
        "Aazrr4": 155,
        "Aazrr5": 189,
        "Aazrr9": 359,
        "Aazrr19": 729,
        "Aazrr49": 1869,
        "Aazrr99": 3799
    ]
    
    override init() {
        self.coinBalance = UserDefaults.standard.integer(forKey: "UserCoinBalance")
        // Give new users 50 free coins to start
        if UserDefaults.standard.object(forKey: "UserCoinBalance") == nil {
            self.coinBalance = 50
        }
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    func fetchProducts() {
        let productIDs = Set(productDict.keys)
        let request = SKProductsRequest(productIdentifiers: productIDs)
        request.delegate = self
        request.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.availableProducts = response.products.sorted { p1, p2 in
                p1.price.decimalValue < p2.price.decimalValue
            }
        }
    }
    
    func purchase(_ product: SKProduct) {
        guard SKPaymentQueue.canMakePayments() else { return }
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                complete(transaction: transaction)
            case .failed:
                fail(transaction: transaction)
            case .restored, .deferred, .purchasing:
                break
            @unknown default:
                break
            }
        }
    }
    
    private func complete(transaction: SKPaymentTransaction) {
        if let productId = transaction.payment.productIdentifier as String?,
           let coinsToAdd = productDict[productId] {
            DispatchQueue.main.async {
                self.coinBalance += coinsToAdd
            }
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func fail(transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    func deductCoins(_ amount: Int) -> Bool {
        if coinBalance >= amount {
            coinBalance -= amount
            return true
        }
        return false
    }
}
