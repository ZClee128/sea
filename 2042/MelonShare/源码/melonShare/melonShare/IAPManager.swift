//
//  IAPManager.swift
//  melonShare
//
//  Created by zclee on 2026/5/19.
//

import SwiftUI
import Combine
import StoreKit

struct IAPProduct: Identifiable, Hashable {
    let id: String         // Product ID, e.g. "MelonShare", "MelonShare1"
    let price: String      // Display Price e.g. "$0.99"
    let coins: Int         // Base Coin count e.g. 32
    let bonus: Int         // Bonus Coin count e.g. 0
    let displayName: String // e.g. "32 coins"
    let priceNumber: Double
    
    var totalCoins: Int {
        return coins + bonus
    }
}

enum IAPTransactionState: Equatable {
    case idle
    case purchasing
    case success
    case failed
}

class IAPManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    static let shared = IAPManager()
    
    @Published var melonCoins: Int = 0
    @Published var unlockedDramaIds: Set<String> = []
    @Published var transactionState: IAPTransactionState = .idle
    
    // Configured exact product mappings matching App Store product guidelines
    let products: [IAPProduct] = [
        IAPProduct(id: "MelonShare", price: "$0.99", coins: 32, bonus: 0, displayName: "32 coins", priceNumber: 0.99),
        IAPProduct(id: "MelonShare1", price: "$1.99", coins: 60, bonus: 0, displayName: "60 coins", priceNumber: 1.99),
        IAPProduct(id: "MelonShare2", price: "$2.99", coins: 96, bonus: 0, displayName: "96 coins", priceNumber: 2.99),
        IAPProduct(id: "MelonShare4", price: "$4.99", coins: 155, bonus: 0, displayName: "155 coins", priceNumber: 4.99),
        IAPProduct(id: "MelonShare5", price: "$5.99", coins: 189, bonus: 0, displayName: "189 coins", priceNumber: 5.99),
        IAPProduct(id: "MelonShare9", price: "$9.99", coins: 299, bonus: 60, displayName: "359 coins", priceNumber: 9.99),
        IAPProduct(id: "MelonShare19", price: "$19.99", coins: 599, bonus: 130, displayName: "729 coins", priceNumber: 19.99),
        IAPProduct(id: "MelonShare49", price: "$49.99", coins: 1599, bonus: 270, displayName: "1869 coins", priceNumber: 49.99),
        IAPProduct(id: "MelonShare99", price: "$99.99", coins: 3199, bonus: 600, displayName: "3799 coins", priceNumber: 99.99)
    ]
    
    private let coinsKey = "melonshare_coins_balance"
    private let unlockedDramasKey = "melonshare_unlocked_dramas"
    
    private override init() {
        super.init()
        
        // Read coins balance, default to 20 welcome gift coins for a brand new account
        if UserDefaults.standard.object(forKey: coinsKey) == nil {
            self.melonCoins = 20
            UserDefaults.standard.set(20, forKey: coinsKey)
        } else {
            self.melonCoins = UserDefaults.standard.integer(forKey: coinsKey)
        }
        
        // Read unlocked dramas array
        if let array = UserDefaults.standard.stringArray(forKey: unlockedDramasKey) {
            self.unlockedDramaIds = Set(array)
        }
        UserDefaults.standard.synchronize()
        
        // Register this manager with StoreKit Payment Queue
        SKPaymentQueue.default().add(self)
        
        // Asynchronously request real App Store product specs
        self.requestAppleProducts()
    }
    
    deinit {
        // Clean up StoreKit observer
        SKPaymentQueue.default().remove(self)
    }
    
    // Request localized product specifications directly from App Store servers
    func requestAppleProducts() {
        let identifiers = Set(products.map { $0.id })
        print("IAPManager: [StoreKit] Requesting \(identifiers.count) products from Apple App Store: \(identifiers)")
        let request = SKProductsRequest(productIdentifiers: identifiers)
        request.delegate = self
        request.start()
    }
    
    // SKProductsRequestDelegate callback
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let validProducts = response.products
        let invalidIdentifiers = response.invalidProductIdentifiers
        
        print("IAPManager: [StoreKit] Received response from Apple App Store.")
        print("IAPManager: - Valid products received: \(validProducts.count)")
        for product in validProducts {
            print("  * Product ID: \(product.productIdentifier), Title: \(product.localizedTitle), Price: \(product.price)")
        }
        print("IAPManager: - Invalid product identifiers: \(invalidIdentifiers.count)")
        if !invalidIdentifiers.isEmpty {
            print("  * Invalid IDs: \(invalidIdentifiers)")
        }
        
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    // Triggers real App Store checkout sheets via StoreKit Payment Queue
    func buyProduct(_ product: IAPProduct) {
        DispatchQueue.main.async {
            self.transactionState = .purchasing
        }
        
        if SKPaymentQueue.canMakePayments() {
            let payment = SKMutablePayment()
            payment.productIdentifier = product.id
            SKPaymentQueue.default().add(payment)
        } else {
            // Devices with payment restrictions cannot proceed
            DispatchQueue.main.async {
                self.transactionState = .failed
            }
        }
    }
    
    // SKPaymentTransactionObserver required callbacks
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                self.completeTransaction(transaction)
            case .failed:
                self.failTransaction(transaction)
            case .restored:
                self.restoreTransaction(transaction)
            case .deferred, .purchasing:
                break
            @unknown default:
                break
            }
        }
    }
    
    private func completeTransaction(_ transaction: SKPaymentTransaction) {
        let productId = transaction.payment.productIdentifier
        if let product = products.first(where: { $0.id == productId }) {
            self.addCoins(product.totalCoins)
        } else {
            self.addCoins(60) // Standard fallback bonus
        }
        
        DispatchQueue.main.async {
            self.transactionState = .success
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func failTransaction(_ transaction: SKPaymentTransaction) {
        // Strict verification: When payment is failed or cancelled, we DO NOT credit any coins.
        // It strictly updates state to failed to notify the UI of cancellation.
        DispatchQueue.main.async {
            self.transactionState = .failed
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func restoreTransaction(_ transaction: SKPaymentTransaction) {
        DispatchQueue.main.async {
            self.transactionState = .success
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func addCoins(_ amount: Int) {
        DispatchQueue.main.async {
            self.melonCoins += amount
            UserDefaults.standard.set(self.melonCoins, forKey: self.coinsKey)
            UserDefaults.standard.synchronize()
            self.objectWillChange.send()
        }
    }
    
    // Unlocks premium mini-drama content
    func spendCoins(amount: Int, dramaId: String) -> Bool {
        if self.melonCoins >= amount {
            self.melonCoins -= amount
            UserDefaults.standard.set(self.melonCoins, forKey: coinsKey)
            
            self.unlockedDramaIds.insert(dramaId)
            UserDefaults.standard.set(Array(self.unlockedDramaIds), forKey: unlockedDramasKey)
            
            UserDefaults.standard.synchronize()
            self.objectWillChange.send()
            return true
        }
        return false
    }
    
    func isUnlocked(dramaId: String) -> Bool {
        return unlockedDramaIds.contains(dramaId)
    }
    
    // Purges coin metrics on profile registration wipes
    func reset() {
        self.melonCoins = 20
        self.unlockedDramaIds.removeAll()
        UserDefaults.standard.set(20, forKey: coinsKey)
        UserDefaults.standard.removeObject(forKey: unlockedDramasKey)
        UserDefaults.standard.synchronize()
        DispatchQueue.main.async {
            self.transactionState = .idle
            self.objectWillChange.send()
        }
    }
}
