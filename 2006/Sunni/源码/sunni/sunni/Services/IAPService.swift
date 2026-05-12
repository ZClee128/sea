//
//  IAPService.swift
//  Scenery
//
//  Created on 2026/1/14.
//

import Foundation
import StoreKit

@available(iOS 15.0, *)
class IAPService: NSObject {
    static let shared = IAPService()
    
    // MARK: - Properties
    private var products: [Product] = []
    private var purchaseTask: Task<Void, Never>?
    
    private override init() {
        super.init()
        setupTransactionObserver()
    }
    
    deinit {
        purchaseTask?.cancel()
    }
    
    // MARK: - Device Detection
    private var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    // MARK: - Product IDs
    private let productIds: Set<String> = [
        "Sunni",
        "Sunni1", 
        "Sunni2",
        "Sunni4",
        "Sunni5",
        "Sunni9",
        "Sunni19",
        "Sunni49",
        "Sunni99"
    ]
    
    // MARK: - Setup
    private func setupTransactionObserver() {
        purchaseTask = Task {
            for await result in Transaction.updates {
                do {
                    let transaction = try checkVerified(result)
                    await handleTransaction(transaction)
                    await transaction.finish()
                } catch {
                    print("Transaction verification failed: \(error)")
                }
            }
        }
    }
    
    // MARK: - Fetch Products
    func fetchProducts() async throws -> [Product] {
        print("Connecting to App Store (or Local StoreKit Config)...")
        do {
            let storeProducts = try await Product.products(for: productIds)
            self.products = storeProducts
            print("✅ Fetched \(storeProducts.count) products")
            return storeProducts
        } catch {
            print("Failed to fetch products: \(error)")
            throw error
        }
    }
    
    // MARK: - Purchase
    func purchase(productId: String) async throws -> Bool {
        guard let product = products.first(where: { $0.id == productId }) else {
            print("❌ Product not found: \(productId) (Make sure .storekit config matches these IDs)")
            throw IAPError.productNotFound
        }
        
        do {
            print("initiating purchase for \(product.id)")
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await handleTransaction(transaction)
                await transaction.finish()
                return true
                
            case .userCancelled:
                print("User cancelled purchase")
                return false
                
            case .pending:
                print("Purchase pending")
                return false
                
            @unknown default:
                return false
            }
        } catch {
            print("Purchase failed: \(error)")
            throw error
        }
    }
    
    // MARK: - Restore Purchases
    func restorePurchases() async throws {
        try await AppStore.sync()
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                await handleTransaction(transaction)
                await transaction.finish()
            } catch {
                print("Restore failed for transaction: \(error)")
            }
        }
    }

    
    // MARK: - Helper Methods
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw IAPError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }
    
    private func handleTransaction(_ transaction: Transaction) async {
        // Add coins to user based on product ID
        let coins = getCoinsForProductId(transaction.productID)
        await addCoinsToUser(coins)
        
        print("✅ Transaction completed: \(transaction.productID) - Added \(coins) coins")
    }
    
    private func getCoinsForProductId(_ productId: String) -> Int {
        switch productId {
        case "Sunni0": return 32
        case "Sunni1": return 60
        case "Sunni2": return 96
        case "Sunni3": return 165
        case "Sunni5": return 189
        case "Sunni9": return 359 // 299 + 60 bonus
        case "Sunni19": return 729 // 599 + 130 bonus
        case "Sunni49": return 1869 // 1599 + 270 bonus
        case "Sunni99": return 3799 // 3199 + 600 bonus
        default: return 0
        }
    }
    
    private func addCoinsToUser(_ coins: Int) async {
        await MainActor.run {
            guard var user = AuthService.shared.authState.currentUser else { return }
            user.coinBalance += coins
            AuthService.shared.authState.currentUser = user
            
            // Save coin balance persistently
            AuthService.shared.saveCoinBalance(user.coinBalance, for: user.id)
            
            // Notify UI to update
            NotificationCenter.default.post(name: NSNotification.Name("UserDataUpdated"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name("PurchaseSuccess"), object: coins)
        }
    }
    
    // MARK: - Mock Products for Simulator
    private func createMockProducts() -> [Product] {
        // Return empty array - we'll handle purchases directly in simulator mode
        return []
    }
}

// MARK: - IAP Errors
enum IAPError: Error {
    case productNotFound
    case verificationFailed
    case purchaseFailed
    
    var localizedDescription: String {
        switch self {
        case .productNotFound:
            return "Product not found"
        case .verificationFailed:
            return "Transaction verification failed"
        case .purchaseFailed:
            return "Purchase failed"
        }
    }
}
