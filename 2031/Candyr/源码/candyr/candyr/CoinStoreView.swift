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
    
    @State private var showingError = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 16) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray.opacity(0.5))
                    }
                    
                    Button(action: { storeManager.getProducts() }) {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .font(.title2)
                            .foregroundColor(storeManager.isLoading ? NeonCouture.primary : .gray.opacity(0.5))
                    }
                    .disabled(storeManager.isLoading)
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
                    
                    if storeManager.isLoading {
                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .accentColor(NeonCouture.primary)
                            Text("Curating Your Collection...")
                                .font(.system(size: 14, weight: .medium, design: .serif))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 100)
                    } else if storeManager.myProducts.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "cart.badge.minus")
                                .font(.system(size: 50))
                                .foregroundColor(.gray.opacity(0.3))
                            
                            Text("Boutique Temporarily Closed")
                                .font(.headline)
                            
                            Text("We couldn't reach the styling vault. Please check your connection and try again.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                            
                            Button(action: { storeManager.getProducts() }) {
                                Text("RETRY ACCESS")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 12)
                                    .background(NeonCouture.primary)
                                    .cornerRadius(25)
                                    .neonGlow()
                            }
                        }
                        .padding(.vertical, 60)
                    } else {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(storeManager.myProducts) { product in
                                Button(action: { storeManager.purchaseProduct(product: product) }) {
                                    CoinPackCard(id: product.id, 
                                                 coins: storeManager.coinMap[product.id] ?? 0, 
                                                 price: product.displayPrice)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .onAppear {
            storeManager.getProducts()
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
