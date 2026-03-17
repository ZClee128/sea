import Foundation
import StoreKit
import Combine

struct CoinProduct: Identifiable {
    let id: String
    let coins: Int
    let price: String
    let displayName: String
}

@available(iOS 14.0, *)
class StoreManager: NSObject, ObservableObject, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    static let shared = StoreManager()
    
    // Detailed Legal Content
    static let termsOfService = """
    Last Updated: March 17, 2026

    1. Agreement to Terms
    By accessing or using Mexo (“the App”), you agree to be bound by these Terms of Service. If you do not agree, do not use the App.

    2. Virtual Currency (Coins)
    - The App uses a virtual currency called "Coins".
    - Coins have no real-world monetary value and cannot be exchanged for cash.
    - Purchases of Coins are final and non-refundable, except as required by law or Apple's policies.
    - User balance is stored locally and may be lost if the App is deleted or the device is reset.

    3. Content Unlocking
    - High-value editorial magazines and video tutorials may require Coins to unlock.
    - Once unlocked, content is tied to the local device data.

    4. User Conduct
    You agree not to use the App for any illegal purposes or to violate any laws in your jurisdiction.

    5. Intellectual Property
    All content within the App, including images, videos, and pose guides, is protected by copyright and intellectual property laws.

    6. Termination
    We reserve the right to terminate or suspend access to our App immediately, without prior notice, for conduct that we believe violates these Terms.

    7. Standard Apple EULA
    In addition to these terms, the standard Apple Licensed Application End User License Agreement applies to your use of this application.
    """

    static let privacyPolicy = """
    Last Updated: March 17, 2026

    1. Introduction
    Mexo ("we", "us", or "our") respects your privacy. This Privacy Policy explains how we handle information.

    2. Information We Do NOT Collect
    - We do NOT store your personal data on any servers.
    - We do NOT collect your name, email, or contact information.
    - We do NOT use third-party tracking or analytics that identify you personally.

    3. Local Storage
    - All your app preferences, coin balance, and unlocked content IDs are stored locally on your device via UserDefaults.
    - This information never leaves your device and is not shared with us or any third parties.

    4. System Camera Access
    - The App requests access to your camera for the "Pose Camera Overlay" feature.
    - Photos taken using this feature are saved directly to your system photo library and are never transmitted to our servers.

    5. In-App Purchases
    All financial transactions are handled securely by Apple through the App Store. We do not have access to your credit card or payment information.

    6. Changes to This Policy
    We may update our Privacy Policy from time to time. You are advised to review this policy periodically for any changes.
    """
    
    @Published var coins: Int = UserDefaults.standard.integer(forKey: "user_coins_balance") {
        didSet {
            UserDefaults.standard.set(coins, forKey: "user_coins_balance")
        }
    }
    
    @Published var purchasedProductIDs: Set<String> = [] {
        didSet {
            UserDefaults.standard.set(Array(purchasedProductIDs), forKey: "purchased_content_ids")
        }
    }
    
    @Published var skProducts: [SKProduct] = []
    
    private let productIDs = Set([
        "Mexo", "Mexo1", "Mexo2", "Mexo4", "Mexo5", "Mexo9", "Mexo19", "Mexo49", "Mexo99"
    ])
    
    let coinsMap: [String: Int] = [
        "Mexo": 32, "Mexo1": 60, "Mexo2": 96, "Mexo4": 155, "Mexo5": 189,
        "Mexo9": 359, "Mexo19": 729, "Mexo49": 1869, "Mexo99": 3799
    ]
    
    let products: [CoinProduct] = [
        CoinProduct(id: "Mexo", coins: 32, price: "$0.99", displayName: "32 coins"),
        CoinProduct(id: "Mexo1", coins: 60, price: "$1.99", displayName: "60 coins"),
        CoinProduct(id: "Mexo2", coins: 96, price: "$2.99", displayName: "96 coins"),
        CoinProduct(id: "Mexo4", coins: 155, price: "$4.99", displayName: "155 coins"),
        CoinProduct(id: "Mexo5", coins: 189, price: "$5.99", displayName: "189 coins"),
        CoinProduct(id: "Mexo9", coins: 359, price: "$9.99", displayName: "359 coins"),
        CoinProduct(id: "Mexo19", coins: 729, price: "$19.99", displayName: "729 coins"),
        CoinProduct(id: "Mexo49", coins: 1869, price: "$49.99", displayName: "1869 coins"),
        CoinProduct(id: "Mexo99", coins: 3799, price: "$99.99", displayName: "3799 coins")
    ]
    
    override init() {
        super.init()
        let savedIDs = UserDefaults.standard.stringArray(forKey: "purchased_content_ids") ?? []
        self.purchasedProductIDs = Set(savedIDs)
        
        // Initial gift if new user
        if !UserDefaults.standard.bool(forKey: "has_received_initial_gift") {
            self.coins = 50
            UserDefaults.standard.set(true, forKey: "has_received_initial_gift")
        }
        
        SKPaymentQueue.default().add(self)
        fetchSKProducts()
    }
    
    func fetchSKProducts() {
        let request = SKProductsRequest(productIdentifiers: productIDs)
        request.delegate = self
        request.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.skProducts = response.products
            for product in response.products {
                print("Found product: \(product.productIdentifier) \(product.localizedTitle) \(product.price.floatValue)")
            }
        }
    }
    
    func purchase(productID: String) {
        if SKPaymentQueue.canMakePayments() {
            let payment = SKMutablePayment()
            payment.productIdentifier = productID
            SKPaymentQueue.default().add(payment)
        } else {
            print("User is unable to make payments")
        }
    }
    
    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
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
        if let coinReward = coinsMap[productID] {
            DispatchQueue.main.async {
                self.coins += coinReward
            }
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func restore(transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func fail(transaction: SKPaymentTransaction) {
        if let error = transaction.error as? SKError, error.code != .paymentCancelled {
            print("Transaction Error: \(error.localizedDescription)")
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    func unlockContent(id: String, price: Int) -> Bool {
        if coins >= price {
            coins -= price
            purchasedProductIDs.insert(id)
            return true
        }
        return false
    }
    
    func isContentUnlocked(id: String) -> Bool {
        return purchasedProductIDs.contains(id)
    }
}
