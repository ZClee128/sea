import SwiftUI
import StoreKit

@available(iOS 14.0, *)
struct StoreView: View {
    @ObservedObject var iapManager = IAPManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    let coinData = [
        ("Clemn", 32), ("Clemn1", 60), ("Clemn2", 96),
        ("Clemn4", 155), ("Clemn5", 189), ("Clemn9", 359),
        ("Clemn19", 729), ("Clemn49", 1869), ("Clemn99", 3799)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6).edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        VStack(spacing: 10) {
                            Image(systemName: "bitcoinsign.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.orange)
                            
                            Text("\(iapManager.coins)")
                                .font(.system(size: 44, weight: .bold))
                            
                            Text("Current Clemn Coins")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 30)
                        
                        // Grid of products
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            ForEach(coinData, id: \.0) { item in
                                CoinProductRow(id: item.0, count: item.1)
                            }
                        }
                        .padding(.horizontal)
                        
                        Text("Coins can be used to unlock premium studio blueprints and high-res lighting analysis templates.")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.top, 20)
                    }
                }
            }
            .navigationTitle("Clemn Store")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

@available(iOS 14.0, *)
struct CoinProductRow: View {
    let id: String
    let count: Int
    @ObservedObject var iapManager = IAPManager.shared
    
    var body: some View {
        Button(action: {
            if let product = iapManager.products.first(where: { $0.productIdentifier == id }) {
                iapManager.purchase(product: product)
            } else {
                // Demo mode for when App Store is not available
                iapManager.coins += count
            }
        }) {
            VStack(spacing: 12) {
                HStack(spacing: 4) {
                    Image(systemName: "m.circle.fill")
                        .foregroundColor(.orange)
                    Text("\(count)")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                
                Text(priceString())
                    .font(.caption)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(15)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.white)
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
    
    func priceString() -> String {
        if let product = iapManager.products.first(where: { $0.productIdentifier == id }) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = product.priceLocale
            return formatter.string(from: product.price) ?? "$--"
        }
        // Fallback demo prices
        let prices = ["Clemn": "$0.99", "Clemn1": "$1.99", "Clemn2": "$2.99", "Clemn4": "$4.99", "Clemn5": "$5.99", "Clemn9": "$9.99", "Clemn19": "$19.99", "Clemn49": "$49.99", "Clemn99": "$99.99"]
        return prices[id] ?? "$--"
    }
}
