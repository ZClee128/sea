import Foundation
import StoreKit
import SwiftUI
import Combine

// MARK: - Coin Manager
@available(iOS 14.0, *)
class CoinManager: ObservableObject {
    static let shared = CoinManager()
    
    // 永久存储用户的零钱包余额
    @AppStorage("Z_User_Coins") var balance: Int = 0
    
    func addCoins(_ amount: Int) {
        DispatchQueue.main.async {
            self.balance += amount
        }
    }
    
    // 尝试扣除金币，如果余额不足返回 false
    func spendCoins(_ amount: Int) -> Bool {
        if balance >= amount {
            DispatchQueue.main.async {
                self.balance -= amount
            }
            return true
        }
        return false
    }
}

// MARK: - StoreKit 2 IAP Manager
@available(iOS 15.0, *)
@MainActor
class StoreManager: ObservableObject {
    static let shared = StoreManager()
    
    @Published var products: [Product] = []
    
    // 金币充值映射表 (ProductID -> Coins)
    let productIDs: [String: Int] = [
        "Zippr":   32,
        "Zippr1":  60,
        "Zippr2":  96,
        "Zippr4":  155,
        "Zippr5":  189,
        "Zippr9":  359,
        "Zippr19": 729,
        "Zippr49": 1869,
        "Zippr99": 3799
    ]
    
    var updateListenerTask: Task<Void, Error>? = nil
    
    init() {
        updateListenerTask = listenForTransactions()
        Task {
            await requestProducts()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    func requestProducts() async {
        do {
            let storeProducts = try await Product.products(for: Array(productIDs.keys))
            // 按照价格从低到高排序
            self.products = storeProducts.sorted(by: { $0.price < $1.price })
        } catch {
            print("Failed product request: \(error)")
        }
    }
    
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await handle(transaction: transaction)
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
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in StoreKit.Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    await self.handle(transaction: transaction)
                    await transaction.finish()
                } catch {
                    print("Transaction failed verification")
                }
            }
        }
    }
    
    private func handle(transaction: StoreKit.Transaction) async {
        // 如果我们映射了对应的金币产物，则分发到零钱包
        if let coins = productIDs[transaction.productID] {
            CoinManager.shared.addCoins(coins)
        }
    }
}

enum StoreError: Error {
    case failedVerification
}
