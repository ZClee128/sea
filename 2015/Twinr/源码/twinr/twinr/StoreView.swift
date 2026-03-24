import SwiftUI
import StoreKit

@available(iOS 14.0, *)
struct StoreView: View {
    @ObservedObject var storeManager = StoreManager.shared
    @State private var showLoadingAlert = false
    
    let coinPacks = [
        ("Twinr", "32 Coins", "0.99"),
        ("Twinr1", "60 Coins", "1.99"),
        ("Twinr2", "96 Coins", "2.99"),
        ("Twinr4", "155 Coins", "4.99"),
        ("Twinr5", "189 Coins", "5.99"),
        ("Twinr9", "359 Coins", "9.99"),
        ("Twinr19", "729 Coins", "19.99"),
        ("Twinr49", "1869 Coins", "49.99"),
        ("Twinr99", "3799 Coins", "99.99")
    ]
    
    var body: some View {
        VStack {
            // Wallet Balance Header
            VStack(spacing: 5) {
                Image(systemName: "bitcoinsign.circle.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.yellow)
                
                Text("\(storeManager.coins)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                
                Text("My Coin Balance")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 5)
            
            List {
                Section(header: Text("Get More Coins")) {
                    ForEach(coinPacks, id: \.0) { pack in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(pack.1)
                                    .fontWeight(.bold)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                if let product = storeManager.products.first(where: { $0.productIdentifier == pack.0 }) {
                                    storeManager.buyProduct(product)
                                } else {
                                    showLoadingAlert = true
                                    storeManager.fetchProducts()
                                }
                            }) {
                                Text("$\(pack.2)")
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 4)
                                    .background(Color.pink)
                                    .foregroundColor(.white)
                                    .cornerRadius(20)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("Coin Store")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showLoadingAlert) {
            Alert(
                title: Text("Connecting to App Store"),
                message: Text("We are still fetching product information from the App Store. Please wait a moment and try again."),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            if storeManager.products.isEmpty {
                storeManager.fetchProducts()
            }
        }
    }
}

extension StoreManager {
    // Helper for simulation if products can't be fetched in simulator
    func addCoinsFromPack(_ productId: String) -> Int {
        let coinMap: [String: Int] = [
            "Twinr": 32, "Twinr1": 60, "Twinr2": 96, "Twinr4": 155,
            "Twinr5": 189, "Twinr9": 359, "Twinr19": 729, "Twinr49": 1869, "Twinr99": 3799
        ]
        if let amount = coinMap[productId] {
            addCoins(amount)
            return amount
        }
        return 0
    }
}
