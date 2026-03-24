import SwiftUI
import StoreKit

@available(iOS 15.0, *)
struct CoinStoreView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var storeManager = StoreManager.shared
    @StateObject var coinManager = CoinManager.shared
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    // Fallback data if StoreKit is not configured in environment
    let fallbackPacks = [
        (id: "Candyr", coins: 32, price: "0.99"),
        (id: "Candyr1", coins: 60, price: "1.99"),
        (id: "Candyr2", coins: 96, price: "2.99"),
        (id: "Candyr4", coins: 155, price: "4.99"),
        (id: "Candyr5", coins: 189, price: "5.99"),
        (id: "Candyr9", coins: 359, price: "9.99"),
        (id: "Candyr19", coins: 729, price: "19.99"),
        (id: "Candyr49", coins: 1869, price: "49.99"),
        (id: "Candyr99", coins: 3799, price: "99.99")
    ]
    
    @State private var showingConfigAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray.opacity(0.5))
                }
                Spacer()
                Text("COIN BOUTIQUE")
                    .font(.system(size: 18, weight: .black, design: .serif))
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "circle.hexagongrid.fill")
                        .foregroundColor(NeonCouture.primary)
                    Text("\(coinManager.balance)")
                        .fontWeight(.bold)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(NeonCouture.primary.opacity(0.1))
                .cornerRadius(20)
            }
            .padding()
            
            ScrollView {
                VStack(spacing: 12) {
                    // Promotional Banner
                    VStack(spacing: 8) {
                        Text("Elevate Your Influence")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Use coins to gift designers, unlock deep style scans, and prioritize your digital couture consultations.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top)
                    
                    LazyVGrid(columns: columns, spacing: 16) {
                        if storeManager.myProducts.isEmpty {
                            // Show fallback UI for demonstration/sandbox - WITH interactive buttons
                            ForEach(fallbackPacks, id: \.id) { pack in
                                Button(action: { 
                                    // Formal request: Attempt to fetch real products 
                                    storeManager.getProducts() 
                                    showingConfigAlert = true
                                }) {
                                    CoinPackCard(id: pack.id, coins: pack.coins, price: "$\(pack.price) (Sample)")
                                }
                            }
                        } else {
                            ForEach(storeManager.myProducts) { product in
                                Button(action: { storeManager.purchaseProduct(product: product) }) {
                                    CoinPackCard(id: product.id, 
                                                 coins: storeManager.coinMap[product.id] ?? 0, 
                                                 price: product.displayPrice)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            storeManager.getProducts()
        }
        .alert(isPresented: $showingConfigAlert) {
            Alert(
                title: Text("StoreKit Configuration Required"),
                message: Text("To test the formal payment flow in the simulator:\n\n1. Edit Scheme -> Run -> Options\n2. Set 'StoreKit Configuration' to 'Candyr.storekit'"),
                dismissButton: .default(Text("Got it!"))
            )
        }
    }
}

@available(iOS 14.0, *)
struct CoinPackCard: View {
    let id: String
    let coins: Int
    let price: String
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: coins >= 300 ? "bitcoinsign.circle.fill" : "circle.hexagongrid.fill")
                .font(.system(size: 20))
                .foregroundColor(NeonCouture.primary)
                .neonGlow()
            
            VStack(spacing: 4) {
                Text("\(coins) COINS")
                    .font(.system(size: 16, weight: .black))
                Text(price)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text("PURCHASE")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.black)
                .cornerRadius(12)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(NeonCouture.primary.opacity(0.1), lineWidth: 1)
        )
    }
}
