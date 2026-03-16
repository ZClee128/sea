import Foundation
import StoreKit
import Combine

class StoreManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    @Published var products: [SKProduct] = []
    @Published var transactionState: SKPaymentTransactionState?
    
    // Product IDs from the provided image
    static let productIdentifiers: Set<String> = [
        "Zayo", "Zayo1", "Zayo2", "Zayo4", "Zayo5", "Zayo9", "Zayo19", "Zayo49", "Zayo99"
    ]
    
    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
        fetchProducts()
    }
    
    func fetchProducts() {
        let request = SKProductsRequest(productIdentifiers: StoreManager.productIdentifiers)
        request.delegate = self
        request.start()
    }
    
    func purchase(product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    // MARK: - SKProductsRequestDelegate
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.products = response.products.sorted { $0.price.doubleValue < $1.price.doubleValue }
        }
        
        for invalidIdentifier in response.invalidProductIdentifiers {
            print("Invalid product identifier: \(invalidIdentifier)")
        }
    }
    
    // MARK: - SKPaymentTransactionObserver
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
            
            DispatchQueue.main.async {
                self.transactionState = transaction.transactionState
            }
        }
    }
    
    private func complete(transaction: SKPaymentTransaction) {
        print("Purchase complete")
        provideContent(for: transaction.payment.productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func restore(transaction: SKPaymentTransaction) {
        print("Restore complete")
        provideContent(for: transaction.original?.payment.productIdentifier ?? transaction.payment.productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func fail(transaction: SKPaymentTransaction) {
        if let error = transaction.error as? SKError, error.code != .paymentCancelled {
            print("Transaction error: \(error.localizedDescription)")
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func provideContent(for productIdentifier: String) {
        // Add coins based on the product ID
        var coinsToAdd = 0
        switch productIdentifier {
        case "Zayo": coinsToAdd = 32
        case "Zayo1": coinsToAdd = 60
        case "Zayo2": coinsToAdd = 96
        case "Zayo4": coinsToAdd = 155
        case "Zayo5": coinsToAdd = 189
        case "Zayo9": coinsToAdd = 359
        case "Zayo19": coinsToAdd = 729
        case "Zayo49": coinsToAdd = 1869
        case "Zayo99": coinsToAdd = 3799
        default: break
        }
        
        if coinsToAdd > 0 {
            CoinManager.shared.addCoins(coinsToAdd)
        }
    }
}

class CoinManager: ObservableObject {
    static let shared = CoinManager()
    
    @Published var balance: Int {
        didSet {
            UserDefaults.standard.set(balance, forKey: "UserCoinBalance")
        }
    }
    
    @Published var unlockedVideoIds: Set<String> {
        didSet {
            UserDefaults.standard.set(Array(unlockedVideoIds), forKey: "UnlockedVideoIds")
        }
    }
    
    private init() {
        self.balance = UserDefaults.standard.integer(forKey: "UserCoinBalance")
        let savedUnlocked = UserDefaults.standard.stringArray(forKey: "UnlockedVideoIds") ?? []
        self.unlockedVideoIds = Set(savedUnlocked)
    }
    
    func addCoins(_ count: Int) {
        balance += count
    }
    
    func spendCoins(_ count: Int) -> Bool {
        if balance >= count {
            balance -= count
            return true
        }
        return false
    }
    
    func unlockVideo(id: String, cost: Int) -> Bool {
        if unlockedVideoIds.contains(id) { return true }
        if spendCoins(cost) {
            unlockedVideoIds.insert(id)
            return true
        }
        return false
    }
    
    func isVideoUnlocked(_ id: String) -> Bool {
        return unlockedVideoIds.contains(id)
    }
}
