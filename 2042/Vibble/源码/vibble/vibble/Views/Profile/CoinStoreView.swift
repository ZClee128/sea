//
//  CoinStoreView.swift
//  vibble
//

import SwiftUI
import StoreKit

@available(iOS 15.0, *)
struct CoinStoreView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var storeManager = StoreManager.shared
    @StateObject private var authManager = AuthManager.shared
    
    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 1. 顶部导航
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text("Top Up").font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "circle.fill").foregroundColor(.yellow).font(.system(size: 8))
                        Text("\(authManager.coinsCount)").font(.system(size: 12, weight: .bold)).foregroundColor(.white)
                    }
                    .padding(.horizontal, 10).padding(.vertical, 4).background(Color.white.opacity(0.1)).cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 15) {
                        // 2. Banner
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Theme.Gradients.primaryGradient)
                                .frame(height: 80)
                                .opacity(0.8)
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Vibble Gold")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("Enhance your experience")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                .padding(.leading, 20)
                                Spacer()
                                Image(systemName: "bitcoinsign.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white.opacity(0.3))
                                    .padding(.trailing, 20)
                            }
                        }
                        .padding(.horizontal)
                        
                        // 3. 真实产品列表
                        if storeManager.storeProducts.isEmpty {
                            VStack {
                                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Text("Loading products...").foregroundColor(.gray).font(.caption).padding(.top, 10)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 300)
                        } else {
                            LazyVGrid(columns: columns, spacing: 10) {
                                ForEach(storeManager.storeProducts) { product in
                                    RealCoinCard(product: product) {
                                        Task {
                                            await storeManager.purchase(product)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // 底部协议与法律声明
                        VStack(spacing: 8) {
                            Button(action: {
                                Task { await storeManager.restorePurchases() }
                            }) {
                                Text("Restore Purchase")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Theme.primary)
                                    .padding(.bottom, 5)
                            }
                            
                            Text("1. Users must be at least 18 years old to top up.")
                                .font(.system(size: 10))
                                .foregroundColor(.gray.opacity(0.6))
                            
                            Text("2. Virtual goods are non-refundable after successful purchase.")
                                .font(.system(size: 10))
                                .foregroundColor(.gray.opacity(0.6))
                            
                            Text("3. Purchase indicates agreement with User Agreement and Privacy Policy")
                                .font(.system(size: 10))
                                .foregroundColor(.gray.opacity(0.8))
                        }
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 15)
                        .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 15)
                }
            }
            
            // 购买加载遮罩
            if storeManager.isPurchasing {
                ZStack {
                    Color.black.opacity(0.6).ignoresSafeArea()
                    VStack(spacing: 15) {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white)).scaleEffect(1.2)
                        Text("Connecting to App Store...").foregroundColor(.white).font(.system(size: 14))
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}

@available(iOS 15.0, *)
struct RealCoinCard: View {
    let product: Product
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: "circle.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 20))
                
                // 自动提取金币数量 (假设名称格式为 "XX coins")
                Text(product.displayName.replacingOccurrences(of: " coins", with: ""))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Coins")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
                
                // 显示本地化价格 (如 $0.99, ¥6.00)
                Text(product.displayPrice)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Theme.primary)
                    .cornerRadius(8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(Theme.cardBackground)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.05), lineWidth: 1))
        }
    }
}
