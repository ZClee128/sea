import SwiftUI
import StoreKit
import Combine

@available(iOS 15.0, *)
class StoreManager: ObservableObject {
    static let shared = StoreManager()
    
    @Published var products: [ProductItem] = []
    
    init() {
        setupProducts()
    }
    
    private func setupProducts() {
        // Map the IDs provided by the user to their coin values
        self.products = [
            ProductItem(id: "Popla", name: "32 coins", price: "$0.99", coins: 32),
            ProductItem(id: "Popla1", name: "60 coins", price: "$1.99", coins: 60),
            ProductItem(id: "Popla2", name: "96 coins", price: "$2.99", coins: 96),
            ProductItem(id: "Popla4", name: "155 coins", price: "$4.99", coins: 155),
            ProductItem(id: "Popla5", name: "189 coins", price: "$5.99", coins: 189),
            ProductItem(id: "Popla9", name: "359 coins", price: "$9.99", coins: 359),
            ProductItem(id: "Popla19", name: "729 coins", price: "$19.99", coins: 729),
            ProductItem(id: "Popla49", name: "1869 coins", price: "$49.99", coins: 1869),
            ProductItem(id: "Popla99", name: "3799 coins", price: "$99.99", coins: 3799)
        ]
    }
    
    @MainActor
    func purchase(_ product: ProductItem) async {
        // Simulate a high-end StoreKit 2 transaction
        try? await Task.sleep(nanoseconds: 1_500_000_000) // Simulate network delay
        
        // On success, update the CollectionManager balance
        CollectionManager.shared.addCoins(product.coins)
    }
}

struct ProductItem: Identifiable {
    let id: String
    let name: String
    let price: String
    let coins: Int
}
