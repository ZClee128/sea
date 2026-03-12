import SwiftUI
import StoreKit

struct PremiumStoreView: View {
    @ObservedObject var storeManager = StoreManager.shared
    
    // The exact IAP packages based on the user's provided screenshot
    let packageOffers = [
        (id: "Aazrr", price: "$0.99", coins: "32", bonus: "0"),
        (id: "Aazrr1", price: "$1.99", coins: "60", bonus: "0"),
        (id: "Aazrr2", price: "$2.99", coins: "96", bonus: "0"),
        (id: "Aazrr4", price: "$4.99", coins: "155", bonus: "0"),
        (id: "Aazrr5", price: "$5.99", coins: "189", bonus: "0"),
        (id: "Aazrr9", price: "$9.99", coins: "299", bonus: "60"),
        (id: "Aazrr19", price: "$19.99", coins: "599", bonus: "130"),
        (id: "Aazrr49", price: "$49.99", coins: "1599", bonus: "270"),
        (id: "Aazrr99", price: "$99.99", coins: "3199", bonus: "600")
    ]
    
    @State private var showUnavailableAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Balance Header
                VStack(spacing: 8) {
                    Image(systemName: "dollarsign.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.yellow)
                    
                    Text("\(storeManager.coinBalance) Coins")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Your Current Balance")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 5)
                .padding(.horizontal)
                
                Text("Select a Top-Up Package")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 10)
                
                // Store Items
                VStack(spacing: 12) {
                    ForEach(packageOffers, id: \.id) { offer in
                        Button(action: {
                            // Trigger native StoreKit purchase logic
                            if let product = storeManager.availableProducts.first(where: { $0.productIdentifier == offer.id }) {
                                storeManager.purchase(product)
                            } else {
                                // Product not loaded via StoreKit
                                self.showUnavailableAlert = true
                            }
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    let totalCoins = Int(offer.coins)! + Int(offer.bonus)!
                                    Text("\(totalCoins) coins")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    if offer.bonus != "0" {
                                        Text("Includes \(offer.bonus) Bonus")
                                            .font(.caption)
                                            .foregroundColor(.green)
                                    }
                                }
                                
                                Spacer()
                                
                                // Get real localized price if fetched, else use fallback
                                let fallbackPrice = offer.price
                                let realProduct = storeManager.availableProducts.first(where: { $0.productIdentifier == offer.id })
                                let priceString = realProduct.map { "\($0.priceLocale.currencySymbol ?? "$")\($0.price)" } ?? fallbackPrice
                                
                                Text(priceString)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.blue)
                                    .cornerRadius(20)
                            }
                            .padding(5)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationBarTitle("Premium Store", displayMode: .inline)
        .onAppear {
            storeManager.fetchProducts()
        }
        .alert(isPresented: $showUnavailableAlert) {
            Alert(
                title: Text("Store Unavailable"),
                message: Text("Products are currently unavailable. Make sure your StoreKit Configuration is active in your Xcode Scheme or test with an App Store Sandbox account."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
