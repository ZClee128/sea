import SwiftUI

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
                    
                    VStack(spacing: 12) {
                        ForEach(storeManager.products) { product in
                            ProductRow(product: product) {
                                Task {
                                    await storeManager.purchase(product)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                    
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
                Text("YOUR BALACE").font(.system(size: 10, weight: .black)).foregroundColor(.white.opacity(0.6))
                Text("\(collectionManager.coinBalance) COINS").font(.system(size: 24, weight: .black)).foregroundColor(.white)
            }
            Spacer()
            Image(systemName: "circle.circle.fill")
                .font(.system(size: 30))
                .foregroundColor(.yellow)
        }
        .padding(30)
        .background(Color.black)
        .cornerRadius(30)
        .padding(.horizontal, 30)
    }
}

struct ProductRow: View {
    let product: ProductItem
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(product.name).font(.system(size: 16, weight: .bold)).foregroundColor(.black)
                    Text("Product ID: \(product.id)").font(.system(size: 10)).foregroundColor(.gray)
                }
                Spacer()
                Text(product.price)
                    .font(.system(size: 14, weight: .black))
                    .padding(.horizontal, 15).padding(.vertical, 8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
