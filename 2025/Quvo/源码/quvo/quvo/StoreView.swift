import SwiftUI
import StoreKit

struct StoreView: View {
    @ObservedObject var storeManager = StoreManager.shared
    @ObservedObject var appState = AppState.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Coin Balance Header
                ZStack {
                    LinearGradient(gradient: Gradient(colors: [Color.yellow, Color.orange]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        .frame(height: 120)
                        .cornerRadius(16)
                    
                    VStack {
                        Text("Current Balance")
                            .font(.subheadline)
                            .foregroundColor(.white)
                        HStack {
                            Image(systemName: "bitcoinsign.circle.fill")
                                .foregroundColor(.white)
                            Text("\(appState.coinBalance)")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .font(.system(size: 34))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                Text("Get More Coins")
                    .font(.system(size: 22, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                if storeManager.myProducts.isEmpty {
                    VStack(spacing: 15) {
                        Spacer(minLength: 50)
                        Text("Loading Products...")
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            storeManager.getProducts()
                        }) {
                            Text("Reload")
                                .font(.system(size: 16, weight: .semibold))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                } else {
                    VStack(spacing: 15) {
                        ForEach(0..<Int(ceil(Double(storeManager.myProducts.count) / 2.0)), id: \.self) { row in
                            HStack(spacing: 15) {
                                ForEach(0..<2, id: \.self) { column in
                                    let index = row * 2 + column
                                    if index < storeManager.myProducts.count {
                                        ProductCard(product: storeManager.myProducts[index])
                                    } else {
                                        Spacer().frame(maxWidth: .infinity)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.bottom, 30)
        }
        .navigationBarTitle("Premium Store", displayMode: .inline)
        .navigationBarItems(trailing: Button(action: {
            storeManager.getProducts()
        }) {
            Image(systemName: "arrow.clockwise")
                .imageScale(.large)
        })
        .onAppear {
            if storeManager.myProducts.isEmpty {
                storeManager.getProducts()
            }
        }
    }
}

struct ProductCard: View {
    let product: SKProduct
    @ObservedObject var storeManager = StoreManager.shared
    
    var coins: Int {
        storeManager.productDict[product.productIdentifier] ?? 0
    }
    
    var priceFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        return formatter
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "bitcoinsign.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(.yellow)
            
            Text("\(coins) Coins")
                .font(.headline)
            
            Button(action: {
                storeManager.purchaseProduct(product: product)
            }) {
                Text(priceFormatter.string(from: product.price) ?? "")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}
