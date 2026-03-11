import SwiftUI
import StoreKit

// MARK: - Static product info for display (always shown immediately, no backend needed)

struct CoinPackageInfo {
    let productID: String
    let baseCoins: Int
    let bonusCoins: Int
    let price: String          // hardcoded display price matching App Store Connect
    var totalCoins: Int { baseCoins + bonusCoins }
    var hasBonus: Bool { bonusCoins > 0 }

    static let all: [CoinPackageInfo] = [
        CoinPackageInfo(productID: "Sumo",   baseCoins: 32,   bonusCoins: 0,   price: "$0.99"),
        CoinPackageInfo(productID: "Sumo1",  baseCoins: 60,   bonusCoins: 0,   price: "$1.99"),
        CoinPackageInfo(productID: "Sumo2",  baseCoins: 96,   bonusCoins: 0,   price: "$2.99"),
        CoinPackageInfo(productID: "Sumo4",  baseCoins: 155,  bonusCoins: 0,   price: "$4.99"),
        CoinPackageInfo(productID: "Sumo5",  baseCoins: 189,  bonusCoins: 0,   price: "$5.99"),
        CoinPackageInfo(productID: "Sumo9",  baseCoins: 299,  bonusCoins: 60,  price: "$9.99"),
        CoinPackageInfo(productID: "Sumo19", baseCoins: 599,  bonusCoins: 130, price: "$19.99"),
        CoinPackageInfo(productID: "Sumo49", baseCoins: 1599, bonusCoins: 270, price: "$49.99"),
        CoinPackageInfo(productID: "Sumo99", baseCoins: 3199, bonusCoins: 600, price: "$99.99"),
    ]
}

// MARK: - Coin Store View

@available(iOS 15.0, *)
struct CoinStoreView: View {
    @EnvironmentObject var appState: AppStateManager
    @StateObject private var store = StoreManager.shared
    @State private var showRestoreAlert = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {

                // Balance banner
                HStack(spacing: 8) {
                    Image(systemName: "bitcoinsign.circle.fill")
                        .foregroundColor(.yellow)
                    Text("Current Balance")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(appState.coinBalance) coins")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(Color.secondary.opacity(0.08))

                Divider()

                if let error = store.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                        .padding(.top, 6)
                }

                // Always show all 9 packages immediately using local data
                VStack(spacing: 0) {
                    ForEach(CoinPackageInfo.all, id: \.productID) { info in
                        CoinPackageRow(info: info, isPurchasing: store.isPurchasing) {
                            // Try real StoreKit purchase if product loaded, else no-op
                            if let skProduct = store.products.first(where: { $0.id == info.productID }) {
                                Task { await store.purchase(skProduct, appState: appState) }
                            }
                        }
                        if info.productID != CoinPackageInfo.all.last?.productID {
                            Divider().padding(.leading, 16)
                        }
                    }
                }
                .background(Color(.secondarySystemBackground))
                .cornerRadius(14)
                .padding(.horizontal)
                .padding(.top, 12)

                Spacer()

                // Restore Purchases
                Button("Restore Purchases") {
                    Task {
                        await store.restorePurchases(appState: appState)
                        showRestoreAlert = true
                    }
                }
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding(.bottom, 16)
            }
            .navigationTitle("Get Coins")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .alert("Restore Complete", isPresented: $showRestoreAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Any previous purchases have been restored.")
        }
    }
}

// MARK: - Compact row

@available(iOS 15.0, *)
struct CoinPackageRow: View {
    let info: CoinPackageInfo
    let isPurchasing: Bool
    let onBuy: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Icon + bonus badge
            ZStack(alignment: .topTrailing) {
                Image(systemName: "bitcoinsign.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.yellow)

                if info.hasBonus {
                    Text("+\(info.bonusCoins)")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(Color.red)
                        .clipShape(Capsule())
                        .offset(x: 10, y: -4)
                }
            }
            .frame(width: 40)

            // Coin amount
            VStack(alignment: .leading, spacing: 1) {
                Text("\(info.totalCoins) coins")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                if info.hasBonus {
                    Text("\(info.baseCoins) + \(info.bonusCoins) bonus")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            }

            Spacer()

            // Buy button — always visible
            Button(action: onBuy) {
                Text(info.price)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 7)
                    .background(isPurchasing ? Color.gray : Color.blue)
                    .cornerRadius(20)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(isPurchasing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}
