import SwiftUI
import StoreKit

@available(iOS 15.0, *)
struct CoinShopView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataStore: MuseDataStore
    @StateObject private var storeManager = StoreManager()
    
    let coinPackages = [
        ("Dazzl", 32, "Pocket Pack"),
        ("Dazzl1", 60, "Starter Pack"),
        ("Dazzl2", 96, "Light Pack"),
        ("Dazzl4", 155, "Standard Bundle"),
        ("Dazzl5", 189, "Plus Bundle"),
        ("Dazzl9", 359, "Classic Collection"),
        ("Dazzl19", 729, "Popular Choice"),
        ("Dazzl49", 1869, "Studio Pack"),
        ("Dazzl99", 3799, "Ultimate Collection")
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 10) {
                        // Header
                        VStack(spacing: 8) {
                            Text("Dazzl Wallet")
                                .font(.system(size: 38, weight: .black))
                                .foregroundColor(.white)
                            
                            HStack(spacing: 8) {
                                Image(systemName: "sparkles")
                                    .foregroundColor(.yellow)
                                Text("\(dataStore.coinBalance)")
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundColor(.white)
                                Text("Available Coins")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 5)
                            .padding(.horizontal, 20)
                            .background(Color.white.opacity(0.05))
                            .clipShape(Capsule())
                        }
                        .padding(.top, 10)
                        
                        // Shop Grid
                        VStack(spacing: 4) {
                            ForEach(productsWithMetadata, id: \.id) { item in
                                CoinPackageCard(
                                    name: item.displayName,
                                    coins: item.coins,
                                    price: item.priceStr,
                                    isPopular: item.id == "Dazzl19",
                                    isBestValue: item.id == "Dazzl99"
                                ) {
                                    if let product = item.product {
                                        Task {
                                            do {
                                                try await storeManager.purchase(product, dataStore: dataStore)
                                            } catch {
                                                print("Purchase failed: \(error)")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        Text("All purchases are securely handled by Apple. Unused coins are stored locally on your device.")
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.top, 20)
                    }
                    .padding(.bottom, 50)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await storeManager.fetchProducts()
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.blue)
                            .font(.headline)
                            .padding(8)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
            }
        }
    }
    
    // Helper to join StoreKit products with our metadata
    private var productsWithMetadata: [PackageItem] {
        return coinPackages.compactMap { (id, coins, displayName) in
            let product = storeManager.products.first(where: { $0.id == id })
            return PackageItem(
                id: id,
                coins: coins,
                displayName: displayName,
                priceStr: product?.displayPrice ?? defaultPrice(for: id),
                product: product
            )
        }
    }
    
    private func defaultPrice(for id: String) -> String {
        switch id {
        case "Dazzl": return "$0.99"
        case "Dazzl1": return "$1.99"
        case "Dazzl2": return "$2.99"
        case "Dazzl4": return "$4.99"
        case "Dazzl5": return "$5.49"
        case "Dazzl9": return "$9.99"
        case "Dazzl19": return "$19.99"
        case "Dazzl49": return "$49.99"
        case "Dazzl99": return "$99.99"
        default: return "--"
        }
    }
}

@available(iOS 15.0, *)
struct PackageItem: Identifiable {
    let id: String
    let coins: Int
    let displayName: String
    let priceStr: String
    let product: Product?
}

@available(iOS 15.0, *)
struct CoinPackageCard: View {
    let name: String
    let coins: Int
    let price: String
    var isPopular: Bool = false
    var isBestValue: Bool = false
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(name)
                            .font(.headline)
                        if isPopular {
                            Text("POPULAR")
                                .font(.system(size: 8, weight: .black))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 1)
                                .background(Color.blue)
                                .cornerRadius(4)
                        }
                        if isBestValue {
                            Text("BEST VALUE")
                                .font(.system(size: 8, weight: .black))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 1)
                                .background(Color.orange)
                                .cornerRadius(4)
                        }
                    }
                    .foregroundColor(.white)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .foregroundColor(.yellow)
                            .font(.title3)
                        Text("\(coins)")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        Text("Coins")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                Text(price)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    .background(isPopular || isBestValue ? Color.blue : Color.white.opacity(0.1))
                    .cornerRadius(12)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(isPopular || isBestValue ? Color.blue.opacity(0.5) : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
