import Foundation
import StoreKit
import SwiftUI
import Combine

@available(iOS 15.0, *)
class StoreManager: ObservableObject {
    @AppStorage("coinBalance") var coinBalance: Int = 0
    @Published var products: [Product] = []
    
    static let shared = StoreManager()
    
    private let productIDs = [
        "Flickr", "Flickr1", "Flickr2", "Flickr4", 
        "Flickr5", "Flickr9", "Flickr19", "Flickr49", "Flickr99"
    ]
    
    // Hardcoded local package info for UI fallback and coin amounts
    let coinPackages: [CoinPackage] = [
        CoinPackage(id: "Flickr", name: "32 coins", amount: 32, price: "$0.99"),
        CoinPackage(id: "Flickr1", name: "60 coins", amount: 60, price: "$1.99"),
        CoinPackage(id: "Flickr2", name: "96 coins", amount: 96, price: "$2.99"),
        CoinPackage(id: "Flickr4", name: "155 coins", amount: 155, price: "$4.99"),
        CoinPackage(id: "Flickr5", name: "189 coins", amount: 189, price: "$5.99"),
        CoinPackage(id: "Flickr9", name: "359 coins", amount: 359, price: "$9.99"),
        CoinPackage(id: "Flickr19", name: "729 coins", amount: 729, price: "$19.99"),
        CoinPackage(id: "Flickr49", name: "1869 coins", amount: 1869, price: "$49.99"),
        CoinPackage(id: "Flickr99", name: "3799 coins", amount: 3799, price: "$99.99")
    ]
    
    init() {
        Task {
            await fetchProducts()
        }
    }
    
    @MainActor
    func fetchProducts() async {
        do {
            let fetchedProducts = try await Product.products(for: productIDs)
            self.products = fetchedProducts.sorted(by: { $0.price < $1.price })
        } catch {
            print("Failed to fetch products: \(error)")
        }
    }
    
    func purchase(_ productID: String) async throws {
        // Find the matching package to get the amount to add
        guard let package = coinPackages.first(where: { $0.id == productID }) else { return }
        
        // In a real environment, we use StoreKit 2:
        /*
        if let product = products.first(where: { $0.id == productID }) {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await addCoins(package.amount)
                await transaction.finish()
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        }
        */
        
        // MOCK for demonstration/development if StoreKit unavailable
        DispatchQueue.main.async {
            self.coinBalance += package.amount
        }
    }
    
    func spendCoins(_ amount: Int) -> Bool {
        if coinBalance >= amount {
            coinBalance -= amount
            return true
        }
        return false
    }
    
    // Check if the transaction is verified
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
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
