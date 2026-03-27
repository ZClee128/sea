import SwiftUI
import StoreKit

// MARK: - Premium Filter Pack Definition
struct PremiumFilterPack: Identifiable {
    let id: String
    let name: String
    let subtitle: String
    let icon: String
    let cost: Int
    let gradient: [Color]
    let filterNames: [String]
}

let premiumFilterPacks: [PremiumFilterPack] = [
    PremiumFilterPack(
        id: "pack_neon",
        name: "Neon Dreams",
        subtitle: "Glowing cyberpunk effects",
        icon: "bolt.fill",
        cost: 50,
        gradient: [Color(red: 0.0, green: 0.8, blue: 0.9), Color(red: 0.5, green: 0.0, blue: 1.0)],
        filterNames: ["Pixellate", "Thermal", "Edges"]
    ),
    PremiumFilterPack(
        id: "pack_ethereal",
        name: "Ethereal Glow",
        subtitle: "Dreamy luminous radiance",
        icon: "sparkles",
        cost: 80,
        gradient: [Color(red: 0.7, green: 0.2, blue: 0.9), Color(red: 1.0, green: 0.5, blue: 0.7)],
        filterNames: ["Bloom", "Fade", "Vivid"]
    ),
    PremiumFilterPack(
        id: "pack_classic",
        name: "Classic Film",
        subtitle: "Timeless analog aesthetics",
        icon: "camera.aperture",
        cost: 60,
        gradient: [Color(red: 0.6, green: 0.4, blue: 0.1), Color(red: 0.9, green: 0.75, blue: 0.4)],
        filterNames: ["Noir", "Vintage", "Chrome"]
    )
]

// MARK: - Coin Shop View
@available(iOS 15.0, *)
struct CoinShopView: View {
    @ObservedObject private var coinStore = CoinStore.shared
    @StateObject private var storeManager = StoreManager.shared
    @State private var showUnlockAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    @State private var selectedPack: PremiumFilterPack? = nil
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            // Background
            Color(.systemGroupedBackground).ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {

                    // ── Glassmorphic Coin Balance Banner ────────────────
                    BalanceBanner(balance: coinStore.coinBalance)
                        .padding(.top, 10)

                    // ── Spend Coins: Premium Filter Packs ─────────────
                    VStack(alignment: .leading, spacing: 16) {
                        SectionTitle("🎨 Premium Studio Packs", 
                                     subtitle: "Use coins to unlock exclusive artistic filters")

                        ForEach(premiumFilterPacks) { pack in
                            PremiumPackCard(pack: pack, coinStore: coinStore) {
                                handleUnlock(pack)
                            }
                        }
                    }

                    // ── Buy Coins ──────────────────────────────────────
                    VStack(alignment: .leading, spacing: 16) {
                        SectionTitle("💰 Get Coins", 
                                     subtitle: "Quick top-up for instant creativity")

                        if storeManager.products.isEmpty {
                            LoadingProductsView()
                        } else {
                            ForEach(coinPackages) { pkg in
                                if let product = storeManager.product(for: pkg.id) {
                                    CoinPackageRow(package: pkg, product: product, storeManager: storeManager)
                                }
                            }
                        }

                        if let err = storeManager.lastError {
                            Text(err).font(.caption).foregroundColor(.red).padding(.top, 4)
                        }
                        
                        RestoreButton(storeManager: storeManager)
                    }

                    // ── Footer Info ────────────────────────────────────
                    VStack(spacing: 8) {
                        Text("Unlock benefits with your coins")
                            .font(.footnote).fontWeight(.semibold).foregroundColor(.secondary)
                        Text("All filter unlocks are permanent. Purchased coins never expire.")
                            .font(.caption2).foregroundColor(.secondary.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .padding(.vertical, 20)

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 16)
            }
        }
        .navigationTitle("Coin Shop")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .alert(alertTitle, isPresented: $showUnlockAlert) {
            Button("Got it", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }

    private func handleUnlock(_ pack: PremiumFilterPack) {
        selectedPack = pack
        let unlocked = coinStore.unlockPack(pack.id, cost: pack.cost)
        if unlocked {
            alertTitle = "Pack Unlocked! ✨"
            alertMessage = "\"\(pack.name)\" is now active in your Art Studio."
        } else {
            alertTitle = "Low Balance"
            alertMessage = "You need \(pack.cost) coins to unlock this pack. Please purchase more coins below."
        }
        showUnlockAlert = true
    }
}

// MARK: - Components

@available(iOS 15.0, *)
private struct BalanceBanner: View {
    let balance: Int
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(LinearGradient(
                    colors: [Color.purple, Color.pink.opacity(0.8)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))
            
            HStack(spacing: 20) {
                ZStack {
                    Circle().fill(.white.opacity(0.2))
                        .frame(width: 70, height: 70)
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(balance)")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("Digital Coin Balance")
                        .font(.subheadline).foregroundColor(.white.opacity(0.9))
                }
                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .frame(height: 130)
        .shadow(color: .purple.opacity(0.3), radius: 15, x: 0, y: 8)
    }
}

@available(iOS 15.0, *)
private struct SectionTitle: View {
    let title: String
    let subtitle: String
    init(_ title: String, subtitle: String) {
        self.title = title; self.subtitle = subtitle
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.title3).fontWeight(.bold)
            Text(subtitle).font(.footnote).foregroundColor(.secondary)
        }
        .padding(.leading, 4)
    }
}

@available(iOS 15.0, *)
private struct PremiumPackCard: View {
    let pack: PremiumFilterPack
    @ObservedObject var coinStore: CoinStore
    let onUnlock: () -> Void
    var isUnlocked: Bool { coinStore.isPackUnlocked(pack.id) }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(LinearGradient(colors: pack.gradient,
                                        startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 64, height: 64)
                Image(systemName: pack.icon)
                    .font(.title2)
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(pack.name).font(.headline)
                Text(pack.subtitle).font(.caption).foregroundColor(.secondary)
                HStack(spacing: 6) {
                    ForEach(pack.filterNames.prefix(3), id: \.self) { name in
                        Text(name)
                            .font(.system(size: 9, weight: .bold))
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(Color(.systemGray6))
                            .cornerRadius(4)
                    }
                }
            }

            Spacer()

            if isUnlocked {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.green)
                    .font(.title2)
            } else {
                Button(action: onUnlock) {
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.caption2)
                        Text("\(pack.cost)").font(.subheadline).fontWeight(.bold)
                    }
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(LinearGradient(colors: pack.gradient, startPoint: .leading, endPoint: .trailing))
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
    }
}

@available(iOS 15.0, *)
private struct CoinPackageRow: View {
    let package: CoinPackage
    let product: Product
    @ObservedObject var storeManager: StoreManager

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [Color.orange, Color.yellow],
                        startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 20, height: 20)
                Image(systemName: "dollarsign.circle.fill")
                    .font(.title3)
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text("\(package.totalCoins) Coins")
                        .font(.headline)
                    if let badge = package.badge {
                        Text(badge)
                            .font(.system(size: 8, weight: .black))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(Capsule().fill(Color.orange))
                    }
                }
//                if package.bonusCoins > 0 {
//                    Text("Includes \(package.bonusCoins) bonus coins")
//                        .font(.caption).foregroundColor(.orange)
//                } else {
//                    Text("Basic pack").font(.caption).foregroundColor(.secondary)
//                }
            }

            Spacer()

            Button(action: {
                Task { await storeManager.purchase(product) }
            }) {
                if storeManager.purchaseInProgress {
                    ProgressView().tint(.white)
                        .frame(width: 80, height: 36)
                        .background(Color.purple)
                        .clipShape(Capsule())
                } else {
                    Text(product.displayPrice)
                        .font(.subheadline).fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 85, height: 38)
                        .background(Color.purple)
                        .clipShape(Capsule())
                }
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(storeManager.purchaseInProgress)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
    }
}

@available(iOS 15.0, *)
private struct LoadingProductsView: View {
    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 12) {
                ProgressView()
                Text("Connecting to App Store…")
                    .font(.caption).foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 30)
    }
}

@available(iOS 15.0, *)
private struct RestoreButton: View {
    @ObservedObject var storeManager: StoreManager
    var body: some View {
        Button(action: {
            Task { await storeManager.restorePurchases() }
        }) {
            Text("Restore Purchases")
                .font(.footnote).foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
        }
    }
}
