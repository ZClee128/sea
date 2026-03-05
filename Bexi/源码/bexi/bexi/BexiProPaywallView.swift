import SwiftUI
import StoreKit

@available(iOS 14.0, *)
struct BexiProPaywallView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var storageManager: StorageManager
    @StateObject private var iapManager = IAPManager.shared
    
    // Internal struct for IAP items based on user's table
    struct CoinPackage: Identifiable {
        let id: String // Product ID
        let priceString: String
        let coins: Int
        let bonus: Int
        let name: String
        
        var totalCoins: Int { coins + bonus }
    }
    
    let packages: [CoinPackage] = [
        CoinPackage(id: "Bexi", priceString: "$0.99", coins: 32, bonus: 0, name: "32 coins"),
        CoinPackage(id: "Bexi1", priceString: "$1.99", coins: 60, bonus: 0, name: "60 coins"),
        CoinPackage(id: "Bexi2", priceString: "$2.99", coins: 96, bonus: 0, name: "96 coins"),
        CoinPackage(id: "Bexi4", priceString: "$4.99", coins: 155, bonus: 0, name: "155 coins"),
        CoinPackage(id: "Bexi5", priceString: "$5.99", coins: 189, bonus: 0, name: "189 coins"),
        CoinPackage(id: "Bexi9", priceString: "$9.99", coins: 299, bonus: 60, name: "359 coins"),
        CoinPackage(id: "Bexi19", priceString: "$19.99", coins: 599, bonus: 130, name: "729 coins"),
        CoinPackage(id: "Bexi49", priceString: "$49.99", coins: 1599, bonus: 270, name: "1869 coins"),
        CoinPackage(id: "Bexi99", priceString: "$99.99", coins: 3199, bonus: 600, name: "3799 coins")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Header
            ZStack(alignment: .topTrailing) {
                LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.8)]), 
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.top)
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                        .padding([.top, .trailing], 16)
                }
                
                VStack(spacing: 4) {
                    Image(systemName: "bitcoinsign.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.yellow)
                        .padding(.top, 10)
                    
                    Text("Coin Shop")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Get coins to unlock premium features and generate moodboards.")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 15)
            }
            .frame(height: 140)
            
            // Coin Balance Display
            HStack {
                Text("Your Balance:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(storageManager.coins)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.yellow)
                Image(systemName: "bitcoinsign.circle.fill")
                    .foregroundColor(.yellow)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(8)
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            // Packages List
            VStack(spacing: 8) {
                ForEach(packages) { pkg in
                    Button(action: {
                        if let product = iapManager.products.first(where: { $0.productIdentifier == pkg.id }) {
                            iapManager.purchase(product: product) { success in
                                if success {
                                    print("Successfully purchased \(pkg.id)")
                                }
                            }
                        } else {
                            // Mock Behavior Sandbox
                            print("Sandbox mode: Added \(pkg.totalCoins) Mock Coins")
                            // storageManager.coins += pkg.totalCoins
                        }
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(pkg.name)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                if pkg.bonus > 0 {
                                    Text("Includes \(pkg.bonus) bonus!")
                                        .font(.caption2)
                                        .foregroundColor(.green)
                                }
                            }
                            
                            Spacer()
                            
                            if let realProduct = iapManager.products.first(where: { $0.productIdentifier == pkg.id }) {
                                Text(priceString(for: realProduct))
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 12)
                                    .background(Color.blue)
                                    .cornerRadius(6)
                            } else {
                                Text(pkg.priceString)
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 12)
                                    .background(Color.blue)
                                    .cornerRadius(6)
                                    .opacity(0.6)
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
                    }
                    .disabled(iapManager.isPurchasing)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            
            Spacer(minLength: 0)
        }
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .onAppear {
            if iapManager.products.isEmpty {
                iapManager.fetchProducts()
            }
        }
    }
    
    // Helper to format SKProduct price locally
    func priceString(for product: SKProduct) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        return formatter.string(from: product.price) ?? "\(product.price)"
    }
}

#Preview {
    if #available(iOS 14.0, *) {
        BexiProPaywallView()
            .environmentObject(StorageManager())
    } else {
        // Fallback on earlier versions
    }
}
