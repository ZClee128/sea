import SwiftUI
import StoreKit

struct StoreView: View {
    @EnvironmentObject var storeManager: StoreManager
    @EnvironmentObject var coinManager: CoinManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header / Balance
                VStack(spacing: 12) {
                    Image(systemName: "bitcoinsign.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.yellow)
                    
                    Text("\(coinManager.balance)")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                    
                    Text("CURRENT BALANCE")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.05))
                
                ScrollView {
                    VStack(spacing: 8) {
                        if storeManager.products.isEmpty {
                            Text("Loading premium offers...")
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            ForEach(storeManager.products, id: \.productIdentifier) { product in
                                CoinBundleRow(product: product) {
                                    storeManager.purchase(product: product)
                                }
                            }
                        }
                        
                        Button(action: {
                            SKPaymentQueue.default().restoreCompletedTransactions()
                        }) {
                            Text("Restore Purchases")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding()
                        }
                    }
                    .padding(20)
                }
            }
            .navigationBarTitle("Premium Store", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct CoinBundleRow: View {
    let product: SKProduct
    let action: () -> Void
    
    var coins: String {
        switch product.productIdentifier {
        case "Zayo": return "32"
        case "Zayo1": return "60"
        case "Zayo2": return "96"
        case "Zayo4": return "155"
        case "Zayo5": return "189"
        case "Zayo9": return "359"
        case "Zayo19": return "729"
        case "Zayo49": return "1869"
        case "Zayo99": return "3799"
        default: return "0"
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(coins) Coins")
                        .font(.headline)
                    Text(product.localizedTitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(priceString)
                    .font(.system(size: 16, weight: .bold))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(4)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var priceString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        return formatter.string(from: product.price) ?? ""
    }
}
