import SwiftUI
import StoreKit

@available(iOS 14.0, *)
struct CoinStoreView: View {
    @StateObject private var storeManager = StoreManager.shared
    @StateObject private var coinManager = CoinManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Header Balance
                    VStack(spacing: 8) {
                        Image(systemName: "bitcoinsign.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(AppTheme.primary)
                        
                        Text("\(coinManager.balance)")
                            .font(.system(size: 20, weight: .black))
                            .foregroundColor(AppTheme.secondary)
                        
                        Text("Current Balance")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .textCase(.uppercase)
                    }
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    
                    if storeManager.myProducts.isEmpty {
                        Spacer()
                        ProgressView("Fetching Store Packages...")
                            .padding()
                        Spacer()
                        
                        // Fallback UI for testing if ASC is not fully configured
                        Button("Simulate Purchase (Test Mode)") {
                            coinManager.addCoins(32)
                        }
                        .padding()
                        .foregroundColor(.blue)
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(storeManager.myProducts, id: \.productIdentifier) { product in
                                    CoinPackageRow(product: product) {
                                        storeManager.purchaseProduct(product: product)
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
                
                if storeManager.isPurchasing {
                    Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                    ProgressView("Processing...")
                        .padding(30)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(radius: 10)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
            .navigationTitle("Buy Coins")
        }
    }
}

@available(iOS 14.0, *)
struct CoinPackageRow: View {
    let product: SKProduct
    let action: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "bitcoinsign.circle.fill")
                        .foregroundColor(AppTheme.primary)
                    Text(getCoinsAmount(for: product.productIdentifier))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppTheme.secondary)
                }
                
                Text(product.localizedTitle)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: action) {
                Text(getPriceString(product: product))
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(AppTheme.primary)
                    .cornerRadius(8)
            }
        }
        .padding(4)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private func getCoinsAmount(for identifier: String) -> String {
        let dict: [String: String] = [
            "Junip": "32 Coins",
            "Junip1": "60 Coins",
            "Junip2": "96 Coins",
            "Junip4": "155 Coins",
            "Junip5": "189 Coins",
            "Junip9": "359 Coins",
            "Junip19": "729 Coins",
            "Junip49": "1869 Coins",
            "Junip99": "3799 Coins"
        ]
        return dict[identifier] ?? "Coins"
    }
    
    private func getPriceString(product: SKProduct) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        return formatter.string(from: product.price) ?? "Buy"
    }
}
