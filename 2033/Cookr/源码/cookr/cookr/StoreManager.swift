import StoreKit
import Combine

@available(iOS 15.0, *)
@MainActor
class StoreManager: ObservableObject {
    static let shared = StoreManager()
    
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs = Set<String>()
    
    private let productIDs = [
        "Cookr", "Cookr1", "Cookr2", "Cookr4", "Cookr5",
        "Cookr9", "Cookr19", "Cookr49", "Cookr99"
    ]
    
    private var updates: Task<Void, Never>? = nil

    private init() {
        self.updates = Task {
            for await result in Transaction.updates {
                await self.handle(transaction: result)
            }
        }
    }
    
    deinit {
        self.updates?.cancel()
    }
    
    func fetchProducts() async {
        do {
            let fetched = try await Product.products(for: productIDs)
            self.products = fetched.sorted { $0.price < $1.price }
        } catch {
            print("Failed to fetch products: \(error)")
        }
    }
    
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            
            // Add coins based on product ID
            let coinAmount = getCoinAmount(for: transaction.productID)
            CoinManager.shared.addCoins(coinAmount)
            
            await transaction.finish()
        case .userCancelled:
            break
        case .pending:
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
    
    private func handle(transaction verification: VerificationResult<Transaction>) async {
        guard case .verified(let transaction) = verification else { return }
        
        if transaction.revocationDate != nil {
            // Handle revocation if needed
        } else if let expirationDate = transaction.expirationDate, expirationDate < Date() {
            // Handle expiration
        } else {
            // Consumable transactions aren't usually in history, 
            // but we can track non-consumables here if any.
        }
        
        await transaction.finish()
    }
    
    func restorePurchases() async {
        try? await AppStore.sync()
    }
    
    private func getCoinAmount(for productID: String) -> Int {
        switch productID {
        case "Cookr": return 32
        case "Cookr1": return 60
        case "Cookr2": return 96
        case "Cookr4": return 155
        case "Cookr5": return 189
        case "Cookr9": return 359
        case "Cookr19": return 729
        case "Cookr49": return 1869
        case "Cookr99": return 3799
        default: return 0
        }
    }
    
    enum StoreError: Error {
        case failedVerification
    }
}
