import Foundation
import StoreKit
import SwiftUI
import Combine

@available(iOS 15.0, *)
class StoreManager: ObservableObject {
    static let shared = StoreManager()
    
    @Published var products: [Product] = []
    
    private let productIDs = ["Trilo", "Trilo1", "Trilo2", "Trilo4", "Trilo5", "Trilo9", "Trilo19", "Trilo49", "Trilo99"]
    
    private var transactionListener: Task<Void, Error>?
    
    init() {
        transactionListener = listenForTransactions()
        Task {
            await fetchProducts()
        }
    }
    
    @MainActor
    func fetchProducts() async {
        do {
            products = try await Product.products(for: productIDs).sorted(by: { $0.price < $1.price })
            print("Successfully fetched \(products.count) products from App Store.")
        } catch {
            print("Failed to fetch products: \(error)")
        }
    }
    
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await finalizePurchase(transaction)
            await transaction.finish()
        case .userCancelled, .pending:
            break
        @unknown default:
            break
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    @MainActor
    private func finalizePurchase(_ transaction: StoreKit.Transaction) async {
        let coinsToAdd: Int
        switch transaction.productID {
        case "Trilo": coinsToAdd = 32
        case "Trilo1": coinsToAdd = 60
        case "Trilo2": coinsToAdd = 96
        case "Trilo4": coinsToAdd = 155
        case "Trilo5": coinsToAdd = 189
        case "Trilo9": coinsToAdd = 359
        case "Trilo19": coinsToAdd = 729
        case "Trilo49": coinsToAdd = 1869
        case "Trilo99": coinsToAdd = 3799
        default: coinsToAdd = 0
        }
        
        CoinManager.shared.addCoins(coinsToAdd)
    }
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in StoreKit.Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await self.finalizePurchase(transaction)
                    await transaction.finish()
                } catch {
                    print("Transaction update failed: \(error)")
                }
            }
        }
    }
    
    enum StoreError: Error {
        case failedVerification
    }
}
