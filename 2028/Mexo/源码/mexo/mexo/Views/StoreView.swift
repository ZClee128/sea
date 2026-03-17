import SwiftUI

@available(iOS 14.0, *)
struct StoreView: View {
    @StateObject private var storeManager = StoreManager.shared
    @State private var showingTerms = false
    @Environment(\.presentationMode) var presentationMode
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header Section
                        BalanceHeaderView(coins: storeManager.coins)
                            .padding(.top, 10)
                        
                        Text("Top up Coins")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        // Products Grid
                        LazyVGrid(columns: columns, spacing: 5) {
                            ForEach(storeManager.products) { product in
                                ProductCardView(product: product) {
                                    storeManager.purchase(productID: product.id)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Support Text
                        VStack(alignment: .center, spacing: 8) {
                            Text("Purchases will be charged to your iTunes account.")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            HStack {
                                Button("Restore Purchases") {
                                    storeManager.restorePurchases()
                                }
                                .font(.caption2)
                                
                                Text("|")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                
                                Button("Terms of Service") {
                                    showingTerms = true
                                }
                                .font(.caption2)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 30)
                    }
                }
            }
            .navigationTitle("Premium Store")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .sheet(isPresented: $showingTerms) {
                DocumentView(title: "Terms of Service", content: StoreManager.termsOfService)
            }
        }
    }
}

@available(iOS 14.0, *)
struct BalanceHeaderView: View {
    let coins: Int
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Your Balance")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                HStack(spacing: 8) {
                    Image(systemName: "bitcoinsign.circle.fill")
                        .foregroundColor(.orange)
                        .font(.title2)
                    Text("\(coins)")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                }
            }
            Spacer()
            
            // Premium Badge
            if #available(iOS 15.0, *) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 40))
                    .symbolRenderingMode(.multicolor)
                    .foregroundStyle(.yellow, .orange)
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .clipShape(Circle())
                    .shadow(radius: 5)
            } else {
                // Fallback on earlier versions
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal)
    }
}

@available(iOS 14.0, *)
struct ProductCardView: View {
    let product: CoinProduct
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.1))
                        .frame(width: 20, height: 20)
                    
                    Image(systemName: "bitcoinsign.circle.fill")
                        .foregroundColor(.orange)
                        .font(.title3)
                }
                
                Text(product.displayName)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(product.price)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 16)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(20)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

@available(iOS 14.0, *)
struct StoreView_Previews: PreviewProvider {
    static var previews: some View {
        StoreView()
    }
}
