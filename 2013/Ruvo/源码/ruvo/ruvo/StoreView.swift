import SwiftUI
import StoreKit

struct StoreView: View {
    @ObservedObject var storeManager = StoreManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    private let coinIcons = ["Ruvo": "circle.grid.hex", "Ruvo1": "circle.grid.hex.fill", "Ruvo2": "suit.diamond.fill", "Ruvo4": "star.fill", "Ruvo5": "crown.fill", "Ruvo9": "bitcoinsign.circle.fill", "Ruvo19": "dollarsign.circle.fill", "Ruvo49": "gift.fill", "Ruvo99": "briefcase.fill"]
    
    var body: some View {
        NavigationView {
            VStack {
                // Balance Header
                VStack(spacing: 5) {
                    Text("\(storeManager.userCoins)")
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundColor(.orange)
                    Text("TOTAL COINS")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fontWeight(.bold)
                }
                .padding(.vertical, 30)
                
                ScrollView {
                    VStack(spacing: 12) {
                        let chunkedProducts = storeManager.products.chunked(into: 3)
                        ForEach(0..<chunkedProducts.count, id: \.self) { rowIndex in
                            HStack(spacing: 12) {
                                ForEach(chunkedProducts[rowIndex], id: \.productIdentifier) { product in
                                    Button(action: {
                                        storeManager.purchase(product: product)
                                    }) {
                                        VStack(spacing: 8) {
                                            Image(systemName: coinIcons[product.productIdentifier] ?? "circle.hex")
                                                .font(.headline)
                                                .foregroundColor(.orange)
                                            
                                            VStack(spacing: 2) {
                                                Text(product.localizedTitle.replacingOccurrences(of: " coins", with: ""))
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundColor(.primary)
                                                Text("Coins")
                                                    .font(.system(size: 10))
                                                    .foregroundColor(.secondary)
                                                Text(product.localizedPrice)
                                                    .font(.system(size: 11))
                                                    .foregroundColor(.blue)
                                            }
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 15)
                                        .background(Color(UIColor.secondarySystemBackground))
                                        .cornerRadius(12)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                
                                if chunkedProducts[rowIndex].count < 3 {
                                    ForEach(0..<(3 - chunkedProducts[rowIndex].count), id: \.self) { _ in
                                        Spacer().frame(maxWidth: .infinity)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarTitle("Coin Store", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                storeManager.fetchProducts()
            }) {
                Image(systemName: "arrow.clockwise")
            }, trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

extension SKProduct {
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price) ?? ""
    }
}
