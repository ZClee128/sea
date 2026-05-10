import Foundation
import StoreKit
import Combine

struct CoinPackage: Identifiable {
    let id: String
    let name: String
    let coins: String
    let price: String
    let amount: Int 
}

extension CoinPackage {
    static func amount(for productId: String) -> Int {
        switch productId {
        case "Mussa": return 32
        case "Mussa1": return 60
        case "Mussa2": return 96
        case "Mussa4": return 155
        case "Mussa5": return 189
        case "Mussa9": return 359
        case "Mussa19": return 729
        case "Mussa49": return 1869
        case "Mussa99": return 3799
        default: return 0
        }
    }
}

class StoreManager: NSObject, ObservableObject {
    @Published var packages: [CoinPackage] = [
        CoinPackage(id: "Mussa", name: "32 coins", coins: "32+0", price: "$0.99", amount: 32),
        CoinPackage(id: "Mussa1", name: "60 coins", coins: "60+0", price: "$1.99", amount: 60),
        CoinPackage(id: "Mussa2", name: "96 coins", coins: "96+0", price: "$2.99", amount: 96),
        CoinPackage(id: "Mussa4", name: "155 coins", coins: "155+0", price: "$4.99", amount: 155),
        CoinPackage(id: "Mussa5", name: "189 coins", coins: "189+0", price: "$5.99", amount: 189),
        CoinPackage(id: "Mussa9", name: "359 coins", coins: "299+60", price: "$9.99", amount: 359),
        CoinPackage(id: "Mussa19", name: "729 coins", coins: "599+130", price: "$19.99", amount: 729),
        CoinPackage(id: "Mussa49", name: "1869 coins", coins: "1599+270", price: "$49.99", amount: 1869),
        CoinPackage(id: "Mussa99", name: "3799 coins", coins: "3199+600", price: "$99.99", amount: 3799)
    ]
    
    @Published var fetchedProducts: [SKProduct] = []
    @Published var isPurchasing = false
    @Published var transactionError: String?
    
    var purchaseCompletion: ((Bool, Int) -> Void)?
    
    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
        fetchProducts()
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
    func fetchProducts() {
        let productIdentifiers = Set(packages.map { $0.id })
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        request.start()
    }
    
    func purchase(package: CoinPackage, completion: @escaping (Bool, Int) -> Void) {
        guard SKPaymentQueue.canMakePayments() else {
            self.transactionError = "Purchase failed."
            completion(false, 0)
            return
        }
        
        guard let product = fetchedProducts.first(where: { $0.productIdentifier == package.id }) else {
            // Log technical detail to console for you, but generic message for user
            print("LOG: Product '\(package.id)' not found in StoreKit.")
            self.transactionError = "Purchase failed. Please try again."
            completion(false, 0)
            return
        }
        
        self.isPurchasing = true
        self.transactionError = nil
        self.purchaseCompletion = completion
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
}

extension StoreManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.fetchedProducts = response.products
        }
    }
}

extension StoreManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                handleSuccessfulPurchase(transaction)
            case .failed:
                handleFailedPurchase(transaction)
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
            case .deferred, .purchasing:
                break
            @unknown default:
                break
            }
        }
    }
    
    private func handleSuccessfulPurchase(_ transaction: SKPaymentTransaction) {
        let productId = transaction.payment.productIdentifier
        let amount = CoinPackage.amount(for: productId)
        
        DispatchQueue.main.async {
            self.isPurchasing = false
            self.purchaseCompletion?(true, amount)
            self.purchaseCompletion = nil
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func handleFailedPurchase(_ transaction: SKPaymentTransaction) {
        DispatchQueue.main.async {
            self.isPurchasing = false
            self.transactionError = "Transaction failed."
            self.purchaseCompletion?(false, 0)
            self.purchaseCompletion = nil
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
}
