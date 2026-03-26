import SwiftUI
import StoreKit

@available(iOS 15.0, *)
struct CoinStoreView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var storeManager = StoreManager.shared
    @ObservedObject private var coinManager = CoinManager.shared
    @State private var isLoading = false
    
    // Fallback UI data if StoreKit products are not yet fetched
    let fallbackOptions = [
        ("32 coins", "Cookr", 0.99),
        ("60 coins", "Cookr1", 1.99),
        ("96 coins", "Cookr2", 2.99),
        ("155 coins", "Cookr4", 4.99),
        ("189 coins", "Cookr5", 5.99),
        ("359 coins", "Cookr9", 9.99),
        ("729 coins", "Cookr19", 19.99),
        ("1869 coins", "Cookr49", 49.99),
        ("3799 coins", "Cookr99", 99.99)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Current Balance Summary
                        VStack(spacing: 8) {
                            Image(systemName: "bitcoinsign.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.yellow)
                            Text("\(coinManager.balance)")
                                .font(.system(size: 44, weight: .bold, design: .rounded))
                            Text("Your Coin Balance")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 30)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(20)
                        .padding(.horizontal)
                        
                        // Purchase Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(fallbackOptions, id: \.1) { option in
                                let product = storeManager.products.first(where: { $0.id == option.1 })
                                
                                Button(action: {
                                    if let p = product {
                                        Task {
                                            isLoading = true
                                            try? await storeManager.purchase(p)
                                            isLoading = false
                                        }
                                    } else {
                                        // Mock purchase for testing if products not loaded
                                        coinManager.addCoins(Int(option.0.split(separator: " ")[0]) ?? 0)
                                    }
                                }) {
                                    VStack(spacing: 12) {
                                        Text(option.0)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        Text(product?.displayPrice ?? "$\(String(format: "%.2f", option.2))")
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(Color.accentColor)
                                            .cornerRadius(10)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 20)
                                    .background(Color(UIColor.secondarySystemGroupedBackground))
                                    .cornerRadius(15)
                                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        Text("All items are consumables used to unlock premium recipes. Your balance is synced privately to your device.")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.top, 10)
                            .padding(.bottom, 30)
                    }
                }
                
                if isLoading {
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                    ProgressView("Processing...")
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                }
            }
            .navigationBarTitle("Tokens Store", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                Task {
                    await storeManager.fetchProducts()
                }
            }
        }
    }
}

struct CoinStoreView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 15.0, *) {
            CoinStoreView()
        } else {
            // Fallback on earlier versions
        }
    }
}
