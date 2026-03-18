import SwiftUI
import StoreKit

struct GRCreditStoreView: View {
    @ObservedObject var storeManager = GRStoreRegistry.shared
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Spacer()
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        if #available(iOS 14.0, *) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.black.opacity(0.3))
                        } else {
                            // Fallback on earlier versions
                        }
                    }
                }
                .padding(10)
                .background(Color.white)
                .foregroundColor(.black)
                
                // Credit Balance Card
                VStack(spacing: 10) {
                    HStack {
                        Image(systemName: "bitcoinsign.circle.fill")
                            .font(.title)
                            .foregroundColor(.gold)
                        Text("\(storeManager.coins)")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                    }
                    Text("CURRENT BALANCE")
                        .font(.caption)
                        .tracking(3)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.05))
                        .padding(.horizontal)
                )
                
                ScrollView {
                    VStack(spacing: 15) {
                        if storeManager.myProducts.isEmpty {
                            VStack(spacing: 20) {
                                if #available(iOS 14.0, *) {
                                    ProgressView()
                                        .accentColor(.black)
                                } else {
                                    // Fallback on earlier versions
                                }
                                Text("Connecting to Secure Terminal...")
                                    .foregroundColor(.gray)
                            }
                            .padding(.top, 100)
                        } else {
                            ForEach(storeManager.myProducts, id: \.productIdentifier) { product in
                                GRCreditTierRow(product: product) {
                                    storeManager.purchaseProduct(product: product)
                                }
                            }
                        }
                    }
                    .padding(20)
                }
                
                // Footer
                VStack(spacing: 15) {
                    Button(action: {
                        SKPaymentQueue.default().restoreCompletedTransactions()
                    }) {
                        Text("Restore Purchases")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    
                    if #available(iOS 14.0, *) {
                        Text("Secure transaction via Apple App Store.")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    } else {
                        // Fallback on earlier versions
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .navigationBarHidden(true)
    }
}

struct GRCreditTierRow: View {
    let product: SKProduct
    let action: () -> Void
    
    // Hardcoded credit amounts mapping for display if product titles aren't clear
    let coinMap: [String: String] = [
        "Glowr": "32", "Glowr1": "60", "Glowr2": "96", 
        "Glowr4": "155", "Glowr5": "189", "Glowr9": "359", 
        "Glowr19": "729", "Glowr49": "1869", "Glowr99": "3799"
    ]
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(coinMap[product.productIdentifier] ?? "0") Credits")
                        .font(.headline)
                        .foregroundColor(.black)
                    if #available(iOS 14.0, *) {
                        Text("Standard Allocation")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    } else {
                        // Fallback on earlier versions
                    }
                }
                
                Spacer()
                
                Text(priceString(for: product))
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.black)
                    .cornerRadius(20)
            }
            .padding(4)
            .background(Color.black.opacity(0.05))
            .cornerRadius(15)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    func priceString(for product: SKProduct) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        return formatter.string(from: product.price) ?? ""
    }
}

