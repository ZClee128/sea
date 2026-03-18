import Foundation
import StoreKit
import Combine

class StoreManager: NSObject, ObservableObject {
    static let shared = StoreManager()
    
    @Published var products: [SKProduct] = []
    @Published var coinBalance: Int = UserDefaults.standard.integer(forKey: "user_coin_balance") {
        didSet {
            UserDefaults.standard.set(coinBalance, forKey: "user_coin_balance")
        }
    }
    
    @Published var unlockedVideoIDs: Set<String> = Set(UserDefaults.standard.stringArray(forKey: "unlocked_video_ids") ?? []) {
        didSet {
            UserDefaults.standard.set(Array(unlockedVideoIDs), forKey: "unlocked_video_ids")
        }
    }
    
    private let productIDs = ["Revo", "Revo1", "Revo2", "Revo4", "Revo5", "Revo9", "Revo19", "Revo49", "Revo99"]
    
    private override init() {
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
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func addCoins(_ count: Int) {
        coinBalance += count
    }
    
    func spendCoins(_ count: Int) -> Bool {
        if coinBalance >= count {
            coinBalance -= count
            return true
        }
        return false
    }
    
    func unlockVideo(videoID: String) {
        unlockedVideoIDs.insert(videoID)
    }
    
    func isUnlocked(videoID: String) -> Bool {
        return unlockedVideoIDs.contains(videoID)
    }
}

extension StoreManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.products = response.products.sorted { $0.price.doubleValue < $1.price.doubleValue }
        }
    }
}

extension StoreManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                complete(transaction: transaction)
            case .failed:
                fail(transaction: transaction)
            case .restored:
                restore(transaction: transaction)
            case .deferred, .purchasing:
                break
            @unknown default:
                break
            }
        }
    }
    
    private func complete(transaction: SKPaymentTransaction) {
        let productID = transaction.payment.productIdentifier
        deliverProduct(productID: productID)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func restore(transaction: SKPaymentTransaction) {
        let productID = transaction.original?.payment.productIdentifier ?? transaction.payment.productIdentifier
        deliverProduct(productID: productID)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func fail(transaction: SKPaymentTransaction) {
        if let error = transaction.error as? SKError, error.code != .paymentCancelled {
            print("Transaction failed: \(error.localizedDescription)")
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func deliverProduct(productID: String) {
        let coinsToAdd: Int
        switch productID {
        case "Revo": coinsToAdd = 32
        case "Revo1": coinsToAdd = 60
        case "Revo2": coinsToAdd = 96
        case "Revo4": coinsToAdd = 155
        case "Revo5": coinsToAdd = 189
        case "Revo9": coinsToAdd = 359 // 299 + 60
        case "Revo19": coinsToAdd = 729 // 599 + 130
        case "Revo49": coinsToAdd = 1869 // 1599 + 270
        case "Revo99": coinsToAdd = 3799 // 3199 + 600
        default: coinsToAdd = 0
        }
        
        DispatchQueue.main.async {
            self.addCoins(coinsToAdd)
        }
    }
}
