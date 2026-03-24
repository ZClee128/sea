import StoreKit
import SwiftUI
import Combine

@available(iOS 15.0, *)
class StoreManager: ObservableObject {
    @Published var myProducts = [Product]()
    private var updates: Task<Void, Never>? = nil
    
    let productIDs = ["Candyr", "Candyr1", "Candyr2", "Candyr4", "Candyr5", "Candyr9", "Candyr19", "Candyr49", "Candyr99"]
    
    let coinMap: [String: Int] = [
        "Candyr": 32,
        "Candyr1": 60,
        "Candyr2": 96,
        "Candyr4": 155,
        "Candyr5": 189,
        "Candyr9": 359,
        "Candyr19": 729,
        "Candyr49": 1869,
        "Candyr99": 3799
    ]
    
    static let shared = StoreManager()
    
    private init() {
        updates = observeTransactionUpdates()
    }
    
    deinit {
        updates?.cancel()
    }
    
    @MainActor
    func getProducts() {
        Task {
            do {
                let storeProducts = try await Product.products(for: productIDs)
                self.myProducts = storeProducts.sorted { self.coinMap[$0.id] ?? 0 < self.coinMap[$1.id] ?? 0 }
            } catch {
                print("Failed to fetch products: \(error)")
            }
        }
    }
    
    func purchaseProduct(product: Product) {
        Task {
            do {
                let result = try await product.purchase()
                switch result {
                case .success(let verification):
                    switch verification {
                    case .verified(let transaction):
                        await handleTransaction(transaction)
                        await transaction.finish()
                    case .unverified:
                        print("Transaction unverified")
                    }
                case .userCancelled, .pending:
                    break
                @unknown default:
                    break
                }
            } catch {
                print("Purchase failed: \(error)")
            }
        }
    }
    
    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) {
            for await verification in StoreKit.Transaction.updates {
                switch verification {
                case .verified(let transaction):
                    await handleTransaction(transaction)
                    await transaction.finish()
                case .unverified:
                    break
                }
            }
        }
    }
    
    @MainActor
    private func handleTransaction(_ transaction: StoreKit.Transaction) async {
        let productID = transaction.productID
        if let amount = coinMap[productID] {
            CoinManager.shared.addCoins(amount)
        }
    }
}
