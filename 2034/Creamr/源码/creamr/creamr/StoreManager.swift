import StoreKit
import Combine

// MARK: - Coin Package Definition
struct CoinPackage: Identifiable {
    let id: String          // product identifier (must match App Store Connect)
    let price: String       // display price
    let baseCoins: Int
    let bonusCoins: Int
    let badge: String?      // e.g. "Most Popular"

    var totalCoins: Int { baseCoins + bonusCoins }

    var description: String {
        bonusCoins > 0
            ? "\(baseCoins) + \(bonusCoins) Bonus Coins"
            : "\(baseCoins) Coins"
    }
}

let coinPackages: [CoinPackage] = [
    CoinPackage(id: "Creamr",   price: "$0.99",  baseCoins: 32,   bonusCoins: 0,   badge: nil),
    CoinPackage(id: "Creamr1",  price: "$1.99",  baseCoins: 60,   bonusCoins: 0,   badge: nil),
    CoinPackage(id: "Creamr2",  price: "$2.99",  baseCoins: 96,   bonusCoins: 0,   badge: nil),
    CoinPackage(id: "Creamr4",  price: "$4.99",  baseCoins: 155,  bonusCoins: 0,   badge: "Best Value"),
    CoinPackage(id: "Creamr5",  price: "$5.99",  baseCoins: 189,  bonusCoins: 0,   badge: nil),
    CoinPackage(id: "Creamr9",  price: "$9.99",  baseCoins: 299,  bonusCoins: 60,  badge: "Popular"),
    CoinPackage(id: "Creamr19", price: "$19.99", baseCoins: 599,  bonusCoins: 130, badge: nil),
    CoinPackage(id: "Creamr49", price: "$49.99", baseCoins: 1599, bonusCoins: 270, badge: nil),
    CoinPackage(id: "Creamr99", price: "$99.99", baseCoins: 3199, bonusCoins: 600, badge: "Max Value"),
]

// MARK: - StoreKit 2 Manager
@available(iOS 15.0, *)
@MainActor
class StoreManager: ObservableObject {
    static let shared = StoreManager()

    @Published var products: [Product] = []
    @Published var purchaseInProgress = false
    @Published var lastError: String? = nil

    private var updateTask: Task<Void, Never>?

    private init() {
        updateTask = listenForTransactions()
        Task { await loadProducts() }
    }

    deinit { updateTask?.cancel() }

    // MARK: Load Products
    func loadProducts() async {
        let ids = coinPackages.map(\.id)
        do {
            products = try await Product.products(for: ids)
            products.sort { lhs, rhs in
                (lhs.price as Decimal) < (rhs.price as Decimal)
            }
        } catch {
            lastError = "Could not load products: \(error.localizedDescription)"
        }
    }

    // MARK: Purchase
    func purchase(_ product: Product) async {
        guard !purchaseInProgress else { return }
        purchaseInProgress = true
        lastError = nil
        defer { purchaseInProgress = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await grantCoins(for: transaction.productID)
                await transaction.finish()
            case .userCancelled:
                break
            case .pending:
                lastError = "Purchase is pending approval."
            @unknown default:
                break
            }
        } catch {
            lastError = error.localizedDescription
        }
    }

    // MARK: Restore
    func restorePurchases() async {
        do {
            try await AppStore.sync()
        } catch {
            lastError = "Restore failed: \(error.localizedDescription)"
        }
    }

    // MARK: Helpers
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified: throw StoreError.failedVerification
        case .verified(let value): return value
        }
    }

    private func grantCoins(for productID: String) async {
        guard let pkg = coinPackages.first(where: { $0.id == productID }) else { return }
        CoinStore.shared.addCoins(pkg.totalCoins)
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    await self.grantCoins(for: transaction.productID)
                    await transaction.finish()
                } catch {
                    // Ignore unverified
                }
            }
        }
    }

    // Product by package ID
    func product(for packageId: String) -> Product? {
        products.first { $0.id == packageId }
    }
}

enum StoreError: Error {
    case failedVerification
}
