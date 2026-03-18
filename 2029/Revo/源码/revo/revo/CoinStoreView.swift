import SwiftUI
import StoreKit

struct CoinStoreView: View {
    @ObservedObject var storeManager = StoreManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    let coinPacks = [
        ("Revo", "32 Coins", "$0.99"),
        ("Revo1", "60 Coins", "$1.99"),
        ("Revo2", "96 Coins", "$2.99"),
        ("Revo4", "155 Coins", "$4.99"),
        ("Revo5", "189 Coins", "$5.99"),
        ("Revo9", "359 Coins", "$9.99"),
        ("Revo19", "729 Coins", "$19.99"),
        ("Revo49", "1869 Coins", "$49.99"),
        ("Revo99", "3799 Coins", "$99.99")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Header with balance
                PremiumCard {
                    VStack(spacing: 8) {
                        Image(systemName: "circle.grid.hex.fill")
                            .font(.system(size: 20))
                            .foregroundColor(RevoDesign.primary)
                        
                        Text("Your Coin Balance")
                            .font(.subheadline)
                            .foregroundColor(RevoDesign.textSecondary)
                        
                        Text("\(storeManager.coinBalance)")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(RevoDesign.text)
                        
                        Text("Coins can be used for professional AI analysis and private studio guides.")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .foregroundColor(RevoDesign.textSecondary)
                            .padding(.horizontal)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Store Grid
                VStack(spacing: 10) {
                    Text("Top-Up Packs")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    ForEach(coinPacks, id: \.0) { packID, name, price in
                        Button(action: {
                            if let product = storeManager.products.first(where: { $0.productIdentifier == packID }) {
                                storeManager.purchase(product: product)
                            } else {
                                // For testing purposes in environment where StoreKit isn't fully set up
                                // (Remove in final production build or handle appropriately)
                                #if targetEnvironment(simulator)
                                let coins = Int(name.components(separatedBy: " ").first ?? "0") ?? 0
                                storeManager.addCoins(coins)
                                #endif
                            }
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(name)
                                        .font(.headline)
                                        .foregroundColor(RevoDesign.text)
                                    Text("Premium Token Pack")
                                        .font(.caption)
                                        .foregroundColor(RevoDesign.textSecondary)
                                }
                                
                                Spacer()
                                
                                Text(price)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(RevoDesign.primary)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                    .font(.subheadline.bold())
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 8)
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 3)
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Footer
                VStack(spacing: 15) {
                    Button(action: {
                        storeManager.restorePurchases()
                    }) {
                        Text("Restore Purchases")
                            .font(.caption)
                            .foregroundColor(RevoDesign.primary)
                    }
                    
                    Text("Purchases are governed by the Standard Apple EULA and our Privacy Policy. All coin purchases are final.")
                        .font(.system(size: 10))
                        .foregroundColor(RevoDesign.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .padding(.bottom, 30)
            }
        }
        .navigationBarTitle(Text("Coin Store"), displayMode: .inline)
        .background(RevoDesign.background.edgesIgnoringSafeArea(.all))
        .forceLightMode()
    }
}
