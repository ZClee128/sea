import Foundation
import StoreKit
import Combine

// StoreKit 2 requires iOS 15+
@available(iOS 15, *)
class StoreManager: ObservableObject {
    static let shared = StoreManager()

    // @Published so views automatically rerender when products load
    @Published private(set) var products: [Product] = []

    // Coins stored in UserDefaults; manually publish change for views that subscribe
    var coins: Int {
        get { UserDefaults.standard.integer(forKey: "user_coins") }
        set {
            DispatchQueue.main.async { self.objectWillChange.send() }
            UserDefaults.standard.set(newValue, forKey: "user_coins")
        }
    }

    var unlockedItemIDs: Set<String> {
        get {
            Set(UserDefaults.standard.stringArray(forKey: "unlocked_items_array") ?? [])
        }
        set {
            UserDefaults.standard.set(Array(newValue), forKey: "unlocked_items_array")
        }
    }

    let productDict: [String: Int] = [
        "Aazr": 32,
        "Aazr1": 60,
        "Aazr2": 96,
        "Aazr4": 155,
        "Aazr5": 189,
        "Aazr9": 359,
        "Aazr19": 729,
        "Aazr49": 1869,
        "Aazr99": 3799
    ]

    private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = Task { [weak self] in
            for await result in StoreKit.Transaction.updates {
                switch result {
                case .verified(let tx):
                    await self?.handle(tx)
                    await tx.finish()
                case .unverified:
                    print("StoreManager: unverified transaction")
                }
            }
        }
    }

    deinit { updatesTask?.cancel() }

    @MainActor
    func fetchProducts() async {
        do {
            let ids = Array(productDict.keys)
            let fetched = try await Product.products(for: ids)
            self.products = fetched.sorted {
                (productDict[$0.id] ?? 0) < (productDict[$1.id] ?? 0)
            }
        } catch {
            print("StoreManager: failed to fetch products: \(error)")
        }
    }

    @MainActor
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        if case .success(.verified(let tx)) = result {
            await handle(tx)
            await tx.finish()
        }
    }

    @MainActor
    private func handle(_ transaction: StoreKit.Transaction) async {
        guard transaction.revocationDate == nil,
              let amount = productDict[transaction.productID] else { return }
        let key = "processed_tx_\(transaction.id)"
        if !UserDefaults.standard.bool(forKey: key) {
            coins += amount
            UserDefaults.standard.set(true, forKey: key)
        }
    }

    // MARK: - Unlock

    func isUnlocked(_ itemID: String) -> Bool {
        unlockedItemIDs.contains(itemID)
    }

    @discardableResult
    func unlockItem(_ itemID: String, cost: Int) -> Bool {
        var ids = unlockedItemIDs
        if ids.contains(itemID) { return true }
        guard coins >= cost else { return false }
        coins -= cost
        ids.insert(itemID)
        unlockedItemIDs = ids
        return true
    }
}
