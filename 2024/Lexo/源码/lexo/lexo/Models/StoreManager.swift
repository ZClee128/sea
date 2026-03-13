import Foundation
import StoreKit
import Combine

struct CoinPackage: Identifiable {
    let id: String
    let price: String
    let baseCoins: Int
    let bonusCoins: Int
    let title: String
    
    var totalCoins: Int {
        return baseCoins + bonusCoins
    }
}

class StoreManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    @Published var myProducts = [SKProduct]()
    @Published var transactionState: SKPaymentTransactionState?
    
    // According to the provided chart
    let packages: [CoinPackage] = [
        CoinPackage(id: "Lexo", price: "$0.99", baseCoins: 32, bonusCoins: 0, title: "32 coins"),
        CoinPackage(id: "Lexo1", price: "$1.99", baseCoins: 60, bonusCoins: 0, title: "60 coins"),
        CoinPackage(id: "Lexo2", price: "$2.99", baseCoins: 96, bonusCoins: 0, title: "96 coins"),
        CoinPackage(id: "Lexo4", price: "$4.99", baseCoins: 155, bonusCoins: 0, title: "155 coins"),
        CoinPackage(id: "Lexo5", price: "$5.99", baseCoins: 189, bonusCoins: 0, title: "189 coins"),
        CoinPackage(id: "Lexo9", price: "$9.99", baseCoins: 299, bonusCoins: 60, title: "359 coins"),
        CoinPackage(id: "Lexo19", price: "$19.99", baseCoins: 599, bonusCoins: 130, title: "729 coins"),
        CoinPackage(id: "Lexo49", price: "$49.99", baseCoins: 1599, bonusCoins: 270, title: "1869 coins"),
        CoinPackage(id: "Lexo99", price: "$99.99", baseCoins: 3199, bonusCoins: 600, title: "3799 coins")
    ]
    
    var request: SKProductsRequest!
    var successCallback: ((Int) -> Void)?
    var currentProcessingPackage: CoinPackage?
    
    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
    func getProducts() {
        let productIDs = Set(packages.map { $0.id })
        request = SKProductsRequest(productIdentifiers: productIDs)
        request.delegate = self
        request.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.myProducts = response.products.sorted { p1, p2 in
                p1.price.decimalValue < p2.price.decimalValue
            }
            print("Loaded \(self.myProducts.count) products from App Store.")
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Failed to load products: \(error.localizedDescription)")
    }
    
    func purchase(_ package: CoinPackage, onSuccess: @escaping (Int) -> Void) {
        if SKPaymentQueue.canMakePayments() {
            currentProcessingPackage = package
            successCallback = onSuccess
            
            // Force real App Store workflow
            if let product = myProducts.first(where: { $0.productIdentifier == package.id }) {
                let payment = SKPayment(product: product)
                SKPaymentQueue.default().add(payment)
            } else {
                print("Error: SKProduct not found for \(package.id). Ensure App Store Connect is setup.")
                DispatchQueue.main.async {
                    // Fail gracefully. In a real environment, product availability must be synchronized.
                    self.successCallback = nil
                    self.currentProcessingPackage = nil
                }
            }
        } else {
            print("Purchases are disabled on this device.")
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            DispatchQueue.main.async {
                self.transactionState = transaction.transactionState
            }
            switch transaction.transactionState {
            case .purchasing:
                break
            case .purchased, .restored:
                if let pkg = currentProcessingPackage {
                    DispatchQueue.main.async {
                        self.successCallback?(pkg.totalCoins)
                        self.successCallback = nil
                        self.currentProcessingPackage = nil
                    }
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
                self.successCallback = nil
                self.currentProcessingPackage = nil
            case .deferred:
                break
            @unknown default:
                break
            }
        }
    }
    
    func restoreProducts() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}
