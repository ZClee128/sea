import SwiftUI

@available(iOS 14.0, *)
struct CoinStoreView: View {
    @StateObject var storeManager = StoreManager()
    @ObservedObject var auraStore: AuraStore
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        ZStack {
                            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                .frame(height: 120)
                                .cornerRadius(20)
                            
                            VStack {
                                Text("Crystal Shards")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.white)
                                Text("Current Balance: \(auraStore.userCoins)")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                        .padding(.horizontal)
                        
                        // Package Grid (3 Columns)
                        VStack(spacing: 12) {
                            ForEach(0..<((storeManager.packages.count + 2) / 3), id: \.self) { rowIndex in
                                HStack(spacing: 10) {
                                    ForEach(0..<3) { colIndex in
                                        let itemIndex = rowIndex * 3 + colIndex
                                        if itemIndex < storeManager.packages.count {
                                            StorePackageItem(package: storeManager.packages[itemIndex], auraStore: auraStore, storeManager: storeManager)
                                        } else {
                                            Spacer().frame(maxWidth: .infinity)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        if let error = storeManager.transactionError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding()
                        }
                    }
                    .padding(.vertical)
                }
                
                // Loading Overlay
                if storeManager.isPurchasing {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                    VStack(spacing: 15) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Processing Transaction...")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding(30)
                    .background(BlurView(style: .systemMaterialDark))
                    .cornerRadius(20)
                }
            }
            .navigationBarTitle("Store", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct StorePackageItem: View {
    let package: CoinPackage
    @ObservedObject var auraStore: AuraStore
    @ObservedObject var storeManager: StoreManager
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.system(size: 24))
                .foregroundColor(.yellow)
            
            Text(package.name)
                .font(.system(size: 13, weight: .bold))
                .lineLimit(1)
            
            Text(package.coins)
                .font(.system(size: 10))
                .foregroundColor(.gray)
            
            Button(action: {
                storeManager.purchase(package: package) { success, amount in
                    if success {
                        auraStore.userCoins += amount
                    }
                }
            }) {
                Text(package.price)
                    .font(.system(size: 13, weight: .black))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .frame(maxWidth: .infinity)
    }
}
