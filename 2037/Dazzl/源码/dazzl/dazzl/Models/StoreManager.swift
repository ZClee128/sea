import Foundation
import StoreKit
import Combine

@available(iOS 15.0, *)
class StoreManager: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs = Set<String>()
    
    private let productIDs = [
        "Dazzl", "Dazzl1", "Dazzl2", "Dazzl4", "Dazzl5", 
        "Dazzl9", "Dazzl19", "Dazzl49", "Dazzl99"
    ]
    
    var updateTask: Task<Void, Never>? = nil
    
    init() {
        updateTask = listenForTransactions()
        Task {
            await fetchProducts()
        }
    }
    
    deinit {
        updateTask?.cancel()
    }
    
    @MainActor
    func fetchProducts() async {
        print("[StoreManager] Starting product fetch for: \(productIDs.joined(separator: ", "))")
        do {
            let fetchedProducts = try await Product.products(for: productIDs)
            print("[StoreManager] Successfully fetched \(fetchedProducts.count) products from App Store.")
            for p in fetchedProducts {
                print(" - \(p.id): \(p.displayName) (\(p.displayPrice))")
            }
            // Sort by product name or price
            self.products = fetchedProducts.sorted { $0.price < $1.price }
        } catch {
            print("[StoreManager] FAILED to fetch products: \(error)")
        }
    }
    
    func purchase(_ product: Product, dataStore: MuseDataStore) async throws {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            
            // Add coins based on product ID
            let coins = getCoins(for: transaction.productID)
            await MainActor.run {
                dataStore.addCoins(coins)
            }
            
            await transaction.finish()
        case .userCancelled, .pending:
            break
        @unknown default:
            break
        }
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    func listenForTransactions() -> Task<Void, Never> {
        Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    // Verification logic would go here if needed for persistence
                    await transaction.finish()
                } catch {
                    print("Transaction verification failed")
                }
            }
        }
    }
    
    private func getCoins(for productID: String) -> Int {
        switch productID {
        case "Dazzl": return 32
        case "Dazzl1": return 60
        case "Dazzl2": return 96
        case "Dazzl4": return 155
        case "Dazzl5": return 189
        case "Dazzl9": return 359
        case "Dazzl19": return 729
        case "Dazzl49": return 1869
        case "Dazzl99": return 3799
        default: return 0
        }
    }
}

enum StoreError: Error {
    case failedVerification
}
