import Foundation
import Combine
import StoreKit
import SwiftUI

// MARK: - Product metadata (coin amounts & bonus per product ID)

struct CoinProduct {
    let productID: String
    let baseCoins: Int
    let bonusCoins: Int
    var totalCoins: Int { baseCoins + bonusCoins }
    var displayName: String { "\(totalCoins) coins" }
    var hasBonus: Bool { bonusCoins > 0 }
}

extension CoinProduct {
    static let all: [CoinProduct] = [
        CoinProduct(productID: "Sumo",   baseCoins: 32,   bonusCoins: 0),
        CoinProduct(productID: "Sumo1",  baseCoins: 60,   bonusCoins: 0),
        CoinProduct(productID: "Sumo2",  baseCoins: 96,   bonusCoins: 0),
        CoinProduct(productID: "Sumo4",  baseCoins: 155,  bonusCoins: 0),
        CoinProduct(productID: "Sumo5",  baseCoins: 189,  bonusCoins: 0),
        CoinProduct(productID: "Sumo9",  baseCoins: 299,  bonusCoins: 60),
        CoinProduct(productID: "Sumo19", baseCoins: 599,  bonusCoins: 130),
        CoinProduct(productID: "Sumo49", baseCoins: 1599, bonusCoins: 270),
        CoinProduct(productID: "Sumo99", baseCoins: 3199, bonusCoins: 600),
    ]

    static func meta(for productID: String) -> CoinProduct? {
        all.first { $0.productID == productID }
    }
}

// MARK: - StoreKit 2 Manager

@available(iOS 15.0, *)
@MainActor
class StoreManager: ObservableObject {
    static let shared = StoreManager()

    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isPurchasing = false
    @Published var errorMessage: String? = nil

    private var updateListenerTask: Task<Void, Error>?

    init() {
        updateListenerTask = listenForTransactions()
        Task { await fetchProducts() }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Fetch

    func fetchProducts() async {
        let ids = CoinProduct.all.map { $0.productID }
        do {
            let fetched = try await Product.products(for: ids)
            // Sort by price ascending
            products = fetched.sorted { $0.price < $1.price }
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
        }
    }

    // MARK: - Purchase

    func purchase(_ product: Product, appState: AppStateManager) async {
        isPurchasing = true
        errorMessage = nil
        defer { isPurchasing = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await creditCoins(for: product.id, appState: appState)
                await transaction.finish()
            case .userCancelled:
                break
            case .pending:
                errorMessage = "Purchase is pending approval."
            @unknown default:
                break
            }
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
        }
    }

    // MARK: - Restore

    func restorePurchases(appState: AppStateManager) async {
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            try await AppStore.sync()
        } catch {
            errorMessage = "Restore failed: \(error.localizedDescription)"
        }
    }

    // MARK: - Transaction Listener

    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    await transaction.finish()
                } catch {
                    // Invalid transaction
                }
            }
        }
    }

    // MARK: - Helpers

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let value):
            return value
        }
    }

    private func creditCoins(for productID: String, appState: AppStateManager) async {
        guard let meta = CoinProduct.meta(for: productID) else { return }
        await MainActor.run {
            appState.addCoins(meta.totalCoins)
        }
    }
}

enum StoreError: Error {
    case failedVerification
}
