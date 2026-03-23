import SwiftUI
import StoreKit

struct StoreView: View {
    @ObservedObject var iap = IAPManager.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "bitcoinsign.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.yellow)
                        .shadow(color: .yellow.opacity(0.4), radius: 10, y: 5)
                    
                    Text("\(iap.coins)")
                        .font(.system(size: 48, weight: .bold))
                    
                    Text("Total Coins Balance")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top, 40)
                .padding(.bottom, 20)
                
                // Products List
                VStack(spacing: 12) {
                    if iap.products.isEmpty {
                        VStack(spacing: 20) {
                            ActivityIndicator()
                            Text("Loading Store...")
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 40)
                    } else {
                        // Live StoreKit Product Listing
                        ForEach(iap.products, id: \.productIdentifier) { product in
                            StoreRow(
                                coins: coinsFor(product.productIdentifier),
                                title: "\(coinsFor(product.productIdentifier)) Coins",
                                price: format(price: product.price, locale: product.priceLocale)
                            ) {
                                iap.buy(product: product)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 40)
        }
        .navigationBarTitle("Store", displayMode: .inline)
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
    }
    
    func format(price: NSDecimalNumber, locale: Locale) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        return formatter.string(from: price) ?? "$\(price)"
    }
    
    func coinsFor(_ id: String) -> Int {
        return iap.mockPackages.first(where: { $0.id == id })?.coins ?? 0
    }
}

struct StoreRow: View {
    let coins: Int
    let title: String
    let price: String
    let action: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "bitcoinsign.circle.fill")
                .foregroundColor(.yellow)
                .font(.title)
            
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
            
            Spacer()
            
            Button(action: action) {
                Text(price)
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 5)
                    .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(20)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 4)
    }
}

struct ActivityIndicator: UIViewRepresentable {
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let ai = UIActivityIndicatorView(style: .medium)
        ai.startAnimating()
        return ai
    }
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {}
}

