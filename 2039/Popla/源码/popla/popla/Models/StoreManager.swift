import SwiftUI
import StoreKit
import Combine

@available(iOS 15.0, *)
class StoreManager: ObservableObject {
    static let shared = StoreManager()
    
    @Published var products: [Product] = []
    @Published var isLoading = false
    
    private var updatesTask: Task<Void, Never>?
    
    private let productIDs = [
        "PoplaGold", "PoplaGold1", "PoplaGold2", "PoplaGold4",
        "PoplaGold5", "PoplaGold9", "PoplaGold19", "PoplaGold49", "PoplaGold99"
    ]
    
    // Mapping IDs to coins for internal logic
    private let coinMap: [String: Int] = [
        "PoplaGold": 32, "PoplaGold1": 60, "PoplaGold2": 96, "PoplaGold4": 155,
        "PoplaGold5": 189, "PoplaGold9": 359, "PoplaGold19": 729, "PoplaGold49": 1869, "PoplaGold99": 3799
    ]
    
    init() {
        // Start listening for transaction updates (e.g., successful purchases)
        updatesTask = listenForTransactions()
        
        Task {
            await requestProducts()
        }
    }
    
    deinit {
        updatesTask?.cancel()
    }
    
    @MainActor
    func requestProducts() async {
        isLoading = true
        do {
            // Fetch real products from App Store
            let fetchedProducts = try await Product.products(for: productIDs)
            // Sort by price to keep the store organized
            self.products = fetchedProducts.sorted(by: { $0.price < $1.price })
        } catch {
            print("Failed product request from App Store: \(error)")
        }
        isLoading = false
    }
    
    @MainActor
    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                // Check if the transaction is verified/valid
                let transaction = try checkVerified(verification)
                
                // Deliver the coins to the user
                if let coins = coinMap[transaction.productID] {
                    CollectionManager.shared.addCoins(coins)
                }
                
                // Always finish the transaction
                await transaction.finish()
                
            case .userCancelled:
                print("User cancelled the purchase.")
            case .pending:
                print("Purchase is pending (e.g., parental approval required).")
            @unknown default:
                break
            }
        } catch {
            print("Failed to complete purchase: \(error)")
        }
    }
    
    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    
                    // Deliver content for unfinished transactions that completed in background
                    if let coins = self.coinMap[transaction.productID] {
                        await MainActor.run {
                            CollectionManager.shared.addCoins(coins)
                        }
                    }
                    
                    await transaction.finish()
                } catch {
                    print("Transaction update failed JWS verification.")
                }
            }
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        // Safe check for JWS verification (native to StoreKit 2)
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

enum StoreError: Error {
    case failedVerification
}
