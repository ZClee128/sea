//
//  StoreManager.swift
//  vibble
//

import Foundation
import StoreKit
import SwiftUI
import Combine

@available(iOS 15.0, *)
class StoreManager: ObservableObject {
    static let shared = StoreManager()
    
    // 所有的产品ID (严格按照你的图片提供)
    let productIDs = [
        "Vibble", "Vibble1", "Vibble2", "Vibble4", 
        "Vibble5", "Vibble9", "Vibble19", "Vibble49", "Vibble99"
    ]
    
    @Published var storeProducts: [Product] = []
    @Published var isPurchasing = false
    
    private var transactionListener: Task<Void, Error>?
    
    init() {
        // 开始监听交易状态
        transactionListener = listenForTransactions()
        
        // 异步加载产品信息
        Task {
            await fetchProducts()
        }
    }
    
    deinit {
        transactionListener?.cancel()
    }
    
    // 1. 从苹果服务器拉取真实产品信息
    @MainActor
    func fetchProducts() async {
        do {
            let fetchedProducts = try await Product.products(for: productIDs)
            // 按照价格或特定顺序排序
            self.storeProducts = fetchedProducts.sorted(by: { $0.price < $1.price })
        } catch {
            print("Failed to fetch products from App Store: \(error)")
        }
    }
    
    // 2. 发起真实购买流程
    @MainActor
    func purchase(_ product: Product) async {
        guard !isPurchasing else { return }
        isPurchasing = true
        
        defer { isPurchasing = false }
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                // 验证交易
                let transaction = try checkVerified(verification)
                
                // --- 业务逻辑：发放金币 ---
                await deliverCoins(for: transaction)
                
                // 完成交易
                await transaction.finish()
                
            case .userCancelled:
                print("User cancelled the purchase.")
            case .pending:
                print("Purchase is pending (e.g., Ask to Buy).")
            @unknown default:
                break
            }
        } catch {
            print("Purchase failed: \(error)")
        }
    }
    
    // 恢复购买 (StoreKit 2 标准做法)
    @MainActor
    func restorePurchases() async {
        do {
            try await AppStore.sync()
            print("Purchases restored successfully.")
        } catch {
            print("Failed to restore purchases: \(error)")
        }
    }
    
    // 3. 验证交易凭证
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    // 4. 发放金币 (根据产品ID对应金币数)
    @MainActor
    private func deliverCoins(for transaction: StoreKit.Transaction) async {
        let coinsMap: [String: Int] = [
            "Vibble": 32, "Vibble1": 60, "Vibble2": 96, "Vibble4": 155,
            "Vibble5": 189, "Vibble9": 359, "Vibble19": 729, "Vibble49": 1869, "Vibble99": 3799
        ]
        
        if let count = coinsMap[transaction.productID] {
            AuthManager.shared.coinsCount += count
            print("Delivered \(count) coins for product \(transaction.productID)")
        }
    }
    
    // 5. 持续监听外部交易 (如下单后闪退、多端同步等)
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in StoreKit.Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await self.deliverCoins(for: transaction)
                    await transaction.finish()
                } catch {
                    print("Transaction update failed verification.")
                }
            }
        }
    }
}

enum StoreError: Error {
    case failedVerification
}
