import Foundation
import StoreKit
import Combine

@available(iOS 15.0, *)
class StoreManager: ObservableObject {
    static let shared = StoreManager()
    
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs = Set<String>()
    
    private let productIDs = ["Sunny", "Sunny1", "Sunny2", "Sunny4", "Sunny5", "Sunny9", "Sunny19", "Sunny49", "Sunny99"]
    
    private let productIdToCoins: [String: Int] = [
        "Sunny": 32,
        "Sunny1": 60,
        "Sunny2": 96,
        "Sunny4": 155,
        "Sunny5": 189,
        "Sunny9": 359,
        "Sunny19": 729,
        "Sunny49": 1869,
        "Sunny99": 3799
    ]
    
    var updateListenerTask: Task<Void, Error>? = nil
    
    private init() {
        updateListenerTask = listenForTransactions()
        
        Task {
            await fetchProducts()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await self.updateCustomerProductStatus()
                    await transaction.finish()
                } catch {
                    print("Transaction failed verification")
                }
            }
        }
    }
    
    @MainActor
    func fetchProducts() async {
        do {
            self.products = try await Product.products(for: productIDs)
            // 排序以便在 UI 中按价格显示
            self.products.sort { $0.price < $1.price }
        } catch {
            print("Failed to fetch products: \(error)")
        }
    }
    
    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            
            // 购买成功，发放金币
            if let coins = productIdToCoins[transaction.productID] {
                await MainActor.run {
                    CoinManager.shared.addCoins(coins)
                }
            }
            
            await updateCustomerProductStatus()
            await transaction.finish()
            return transaction
        case .userCancelled, .pending:
            return nil
        default:
            return nil
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
    
    @MainActor
    func updateCustomerProductStatus() async {
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try self.checkVerified(result)
                // 对于 Consumables，entitlements 通常不包含已完成的交易，
                // 但为了严谨，我们可以在这里同步状态。
                self.purchasedProductIDs.insert(transaction.productID)
            } catch {
                print("Failed to verify entitlement")
            }
        }
    }
}

public enum StoreError: Error {
    case failedVerification
}
