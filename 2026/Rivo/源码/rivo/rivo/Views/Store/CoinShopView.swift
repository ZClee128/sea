import SwiftUI
import StoreKit

struct CoinShopView: View {
    @ObservedObject var storeManager: StoreManager
    @Environment(\.presentationMode) var presentationMode
    
    private let coinMap: [String: String] = [
        "Rivo": "32 Coins", "Rivo1": "60 Coins", "Rivo2": "96 Coins", "Rivo4": "155 Coins", "Rivo5": "189 Coins",
        "Rivo9": "359 Coins", "Rivo19": "729 Coins", "Rivo49": "1869 Coins", "Rivo99": "3799 Coins"
    ]
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Balance Header
                    VStack(spacing: 8) {
                        Text("Your Balance")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("\(storeManager.coinBalance)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.yellow)
                        Text("COINS")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.yellow.opacity(0.8))
                    }
                    .padding(.vertical, 30)
                    
                    if storeManager.products.isEmpty {
                        VStack(spacing: 12) {
                            ActivityIndicator(isAnimating: .constant(true), style: .medium)
                            Text("Loading Products...")
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 40)
                    } else {
                        // 3-Column Grid Layout
                        VStack(spacing: 12) {
                            let totalProducts = storeManager.products.count
                            let columns = 3
                            let rowCount = Int(ceil(Double(totalProducts) / Double(columns)))
                            
                            ForEach(0..<rowCount, id: \.self) { row in
                                HStack(spacing: 12) {
                                    ForEach(0..<columns, id: \.self) { column in
                                        let index = row * columns + column
                                        if index < totalProducts {
                                            self.packageCard(product: storeManager.products[index])
                                        } else {
                                            Color.clear.frame(maxWidth: .infinity)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                    }
                    
                    if #available(iOS 14.0, *) {
                        Text("Purchases will be charged to your App Store account.")
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.top, 20)
                            .padding(.bottom, 100)
                    } else {
                        // Fallback on earlier versions
                    } // Guaranteed visibility for all items
                }
            }
            .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all))
            
            // Purchase Overlay
            if storeManager.transactionState == .purchasing {
                ZStack {
                    Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                    VStack(spacing: 16) {
                        ActivityIndicator(isAnimating: .constant(true), style: .large)
                        Text("Processing Transaction...")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    .padding(30)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(20)
                }
            }
        }
        .navigationBarTitle("Coin Shop", displayMode: .inline)
    }
    
    func packageCard(product: SKProduct) -> some View {
        let title = coinMap[product.productIdentifier] ?? product.localizedTitle
        return Button(action: {
            storeManager.purchase(productID: product.productIdentifier)
        }) {
            VStack(spacing: 6) {
                Image(systemName: "circle.grid.hex.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.yellow)
                
                Text(title.replacingOccurrences(of: " Coins", with: ""))
                    .font(.system(size: 14, weight: .bold))
                
                Text("COINS")
                    .font(.system(size: 8))
                    .foregroundColor(.gray)
                
                Text(getPriceString(product: product))
                    .font(.system(size: 12, weight: .black))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getPriceString(product: SKProduct) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        return formatter.string(from: product.price) ?? ""
    }
}

// Activity Indicator for iOS 13
struct ActivityIndicator: UIViewRepresentable {
    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}
