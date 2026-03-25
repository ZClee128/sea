import SwiftUI
import StoreKit

@available(iOS 15.0, *)
struct CoinStoreView: View {
    @StateObject var storeManager = StoreManager.shared
    @ObservedObject var coinManager = CoinManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    private let productIdToCoins: [String: Int] = [
        "Sunny": 32,
        "Sunny1": 60,
        "Sunny2": 96,
        "Sunny4": 155,
        "Sunny5": 189,
        "Sunny9": 359,
        "Sunny19": 729,
        "Sunny49": 1869,
        "Sunny99": 3799
    ]
    
    var body: some View {
        ZStack {
            // 背景
            Color(red: 0.99, green: 0.98, blue: 0.96).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // 自定义导航栏
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    Spacer()
                    Text("Coin Store")
                        .font(.system(size: 20, weight: .bold))
                    Spacer()
                    // 占位以对齐
                    Rectangle().fill(Color.clear).frame(width: 20, height: 20)
                }
                .padding()
                
                ScrollView {
                    VStack(spacing: 10) {
                        // 余额卡片
                        VStack(spacing: 12) {
                            Text("Current Balance")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                            
                            HStack(spacing: 8) {
                                Image(systemName: "bitcoinsign.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.2))
                                
                                Text("\(coinManager.balance)")
                                    .font(.system(size: 40, weight: .bold))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                        )
                        .padding(.horizontal)
                        
                        // 产品列表
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                            ForEach(storeManager.products, id: \.id) { product in
                                CoinPackageCard(product: product, coins: productIdToCoins[product.id] ?? 0) {
                                    Task {
                                        do {
                                            try await storeManager.purchase(product)
                                        } catch {
                                            print("Purchase failed")
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        Text("All purchases are final and managed via Apple App Store.")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.top, 20)
                            .padding(.horizontal, 40)
                    }
                    .padding(.vertical)
                }
            }
        }
    }
}

@available(iOS 15.0, *)
struct CoinPackageCard: View {
    let product: Product
    let coins: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                // 图标
                ZStack {
                    Circle()
                        .fill(Color(red: 1.0, green: 0.6, blue: 0.2).opacity(0.1))
                        .frame(width: 20, height: 20)
                    
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.2))
                }
                
                VStack(spacing: 4) {
                    Text("\(coins) Coins")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(product.displayPrice)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Text("Buy Now")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color(red: 1.0, green: 0.6, blue: 0.2))
                    )
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 2)
        }
    }
}
