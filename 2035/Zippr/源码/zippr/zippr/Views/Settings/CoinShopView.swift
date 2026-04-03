import SwiftUI
import StoreKit

@available(iOS 15.0, *)
struct CoinShopView: View {
    @StateObject private var storeManager = StoreManager.shared
    @StateObject private var coinManager = CoinManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    // UI Format for grid
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ZStack {
            Color(hex: "#F7F8FA").ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // 1. Balance Header
                    VStack(spacing: 12) {
                        Image(systemName: "bitcoinsign.circle.fill")
                            .font(.system(size: 56))
                            .foregroundColor(Color(hex: "#FFC107"))
                            .shadow(color: Color(hex: "#FFC107").opacity(0.5), radius: 10, x: 0, y: 5)
                            .padding(.top, 24)
                        
                        Text("My Balance")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color.gray)
                        
                        Text("\(coinManager.balance)")
                            .font(.system(size: 48, weight: .heavy, design: .rounded))
                            .foregroundColor(Color(hex: "#1D1D2B"))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 24)
                    .background(Color.white)
                    .cornerRadius(24)
                    .shadow(color: Color.black.opacity(0.03), radius: 15, x: 0, y: 8)
                    .padding(.horizontal, 16)
                    
                    // 2. Shop Grid
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Top up Coins")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(hex: "#1D1D2B"))
                            .padding(.horizontal, 16)
                        
                        if storeManager.products.isEmpty {
                            ProgressView("Loading Products...")
                                .padding(.top, 40)
                                .frame(maxWidth: .infinity)
                        } else {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(storeManager.products, id: \.id) { product in
                                    CoinProductRow(product: product)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    
                    Spacer(minLength: 60)
                }
                .padding(.top, 16)
            }
        }
        .navigationTitle("Coin Shop")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task {
                        await storeManager.requestProducts()
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(Color.zPrimary)
                }
            }
        }
    }
}

@available(iOS 15.0, *)
struct CoinProductRow: View {
    let product: Product
    @StateObject private var storeManager = StoreManager.shared
    @State private var isPurchasing = false
    
    var body: some View {
        Button {
            Task {
                isPurchasing = true
                do {
                    try await storeManager.purchase(product)
                } catch {
                    print("Purchase failed: \(error)")
                }
                isPurchasing = false
            }
        } label: {
            VStack(spacing: 12) {
                // If this is the highest tier, show Best Value
                if storeManager.productIDs[product.id] ?? 0 > 3000 {
                    Text("BEST VALUE")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red)
                        .cornerRadius(6)
                        .offset(y: -10)
                        .padding(.bottom, -14) // Offset space
                } else if storeManager.productIDs[product.id] ?? 0 > 700 {
                    Text("POPULAR")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue)
                        .cornerRadius(6)
                        .offset(y: -10)
                        .padding(.bottom, -14)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "bitcoinsign.circle.fill")
                        .foregroundColor(Color(hex: "#FFC107"))
                        .font(.system(size: 24))
                        
                    // Show corresponding coins
                    if let coins = storeManager.productIDs[product.id] {
                        Text("\(coins)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(hex: "#1D1D2B"))
                    }
                }
                
                if isPurchasing {
                    ProgressView()
                        .frame(height: 36)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                } else {
                    Text(product.displayPrice)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.zPrimary)
                        .frame(height: 36)
                        .frame(maxWidth: .infinity)
                        .background(Color.zPrimary.opacity(0.1))
                        .cornerRadius(12)
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.black.opacity(0.04), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
