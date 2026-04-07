import SwiftUI
import StoreKit

@available(iOS 15.0, *)
struct PoplaStoreView: View {
    @ObservedObject var storeManager = StoreManager.shared
    @ObservedObject var collectionManager = CollectionManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    headerSection
                    
                    // Coin Balance Info
                    balanceCard
                    
                    // Product List
                    Text("COIN PACKAGES").font(.system(size: 10, weight: .black)).foregroundColor(.gray.opacity(0.4))
                        .padding(.horizontal, 30)
                    
                    if storeManager.isLoading && storeManager.products.isEmpty {
                        VStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .black))
                            Text("Fetching from App Store...")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                                .padding(.top, 10)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 50)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(storeManager.products) { product in
                                RealProductRow(product: product) {
                                    Task {
                                        await storeManager.purchase(product)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 30)
                    }
                    
                    legalSection
                    
                    Spacer().frame(height: 50)
                }
                .padding(.top, 20)
            }
        }
        .navigationBarHidden(true)
        .overlay(
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                    .padding(25)
            },
            alignment: .topLeading
        )
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("THE STORE")
                .font(.system(size: 10, weight: .black))
                .tracking(5)
                .foregroundColor(.gray.opacity(0.4))
            Text("Popla Coins")
                .font(.system(size: 34, weight: .black))
        }
        .padding(.horizontal, 30).padding(.top, 40)
    }
    
    private var balanceCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("YOUR BALANCE").font(.system(size: 10, weight: .black)).foregroundColor(.white.opacity(0.6))
                Text("\(collectionManager.coinBalance) COINS").font(.system(size: 24, weight: .black)).foregroundColor(.white)
            }
            Spacer()
            Image(systemName: "sparkles")
                .font(.system(size: 30))
                .foregroundColor(.yellow)
        }
        .padding(30)
        .background(Color.black)
        .cornerRadius(30)
        .padding(.horizontal, 30)
    }
    
    private var legalSection: some View {
        VStack(spacing: 8) {
            Text("Purchases are linked to your Apple ID. Consumable items like coins are spent instantly upon use and are not transferable.")
                .font(.system(size: 10))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 50)
            
            Button(action: { /* Restore logic if needed */ }) {
                Text("Restore Purchases")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.black.opacity(0.4))
            }
        }
        .padding(.top, 20)
    }
}

@available(iOS 15.0, *)
struct RealProductRow: View {
    let product: Product
    let action: () -> Void
    @State private var isProcessing = false
    
    var body: some View {
        Button(action: {
            isProcessing = true
            action()
            // Reset processing after a delay (simulated or real)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { isProcessing = false }
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(product.displayName).font(.system(size: 16, weight: .bold)).foregroundColor(.black)
                    Text(product.description).font(.system(size: 10)).foregroundColor(.gray)
                }
                Spacer()
                
                if isProcessing {
                    ProgressView()
                        .padding(.horizontal, 20)
                } else {
                    Text(product.displayPrice)
                        .font(.system(size: 14, weight: .black))
                        .padding(.horizontal, 15).padding(.vertical, 8)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(10)
                        .foregroundColor(.black)
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isProcessing)
    }
}
