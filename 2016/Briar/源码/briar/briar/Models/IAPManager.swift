import Foundation
import StoreKit
import Combine

struct StorePackage: Identifiable {
    let id: String
    let name: String
    let coins: Int
    let price: String
}

class IAPManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    static let shared = IAPManager()
    
    @Published var products: [SKProduct] = []
    @Published var coins: Int {
        didSet {
            UserDefaults.standard.set(coins, forKey: "user_coins")
        }
    }
    
    // Exact mapping provided by User
    let productIdentifiers: Set<String> = [
        "Briar", "Briar1", "Briar2", "Briar4", "Briar5", "Briar9", "Briar19", "Briar49", "Briar99"
    ]
    
    @Published var mockPackages: [StorePackage] = [
        StorePackage(id: "Briar", name: "32 coins", coins: 32, price: "$0.99"),
        StorePackage(id: "Briar1", name: "60 coins", coins: 60, price: "$1.99"),
        StorePackage(id: "Briar2", name: "96 coins", coins: 96, price: "$2.99"),
        StorePackage(id: "Briar4", name: "155 coins", coins: 155, price: "$4.99"),
        StorePackage(id: "Briar5", name: "189 coins", coins: 189, price: "$5.99"),
        StorePackage(id: "Briar9", name: "359 coins", coins: 359, price: "$9.99"),
        StorePackage(id: "Briar19", name: "729 coins", coins: 729, price: "$19.99"),
        StorePackage(id: "Briar49", name: "1869 coins", coins: 1869, price: "$49.99"),
        StorePackage(id: "Briar99", name: "3799 coins", coins: 3799, price: "$99.99")
    ]
    
    private override init() {
        self.coins = UserDefaults.standard.integer(forKey: "user_coins")
        super.init()
        SKPaymentQueue.default().add(self)
        fetchProducts()
    }
    
    func fetchProducts() {
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        request.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.products = response.products.sorted { $0.price.decimalValue < $1.price.decimalValue }
        }
    }
    
    func buy(product: SKProduct) {
        if SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                handlePurchased(transaction.payment.productIdentifier)
                SKPaymentQueue.default().finishTransaction(transaction)
            case .failed, .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                break
            }
        }
    }
    
    func handlePurchased(_ id: String) {
        let added = mockPackages.first(where: { $0.id == id })?.coins ?? 0
        DispatchQueue.main.async {
            self.coins += added
        }
    }
}
