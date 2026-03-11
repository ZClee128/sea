//
//  PaywallView.swift
//  tego
//

import SwiftUI
import StoreKit

// Wrapper view that shows the Coin Store on iOS 15+, and an upgrade prompt on older versions
struct CoinStoreView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        if #available(iOS 15, *) {
            PaywallView()
        } else {
            UpgradeRequiredView()
        }
    }
}

// Shown on iOS 13 and 14 — they cannot use StoreKit 2
struct UpgradeRequiredView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Spacer()
                Button { presentationMode.wrappedValue.dismiss() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            
            Spacer()
            
            Image(systemName: "arrow.up.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.blue)
            
            Text("iOS 15 Required")
                .font(.largeTitle)
                .bold()
            
            Text("In-app purchases require iOS 15 or later.\n\nPlease upgrade your device in Settings → General → Software Update.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            Spacer()
            
            Button { presentationMode.wrappedValue.dismiss() } label: {
                Text("Got it")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
    }
}

@available(iOS 15, *)
struct PaywallView: View {
    @Environment(\.presentationMode) var presentationMode
    // Proper @ObservedObject so @Published products triggers targeted rerenders
    @ObservedObject private var store: StoreManager = StoreManager.shared
    @State private var isPurchasing = false
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Close button
            HStack {
                Spacer()
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                .padding()
            }
            
            // Compact header
            VStack(spacing: 4) {
                Image(systemName: "bitcoinsign.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.yellow)
                Text("Coin Store")
                    .font(.title2).bold()
                Text("Balance: \(store.coins) Coins")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 12)
            
            if store.products.isEmpty {
                Spacer()
                ProgressView("Loading…")
                Spacer()
            } else {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(store.products, id: \.id) { product in
                        CoinGridCell(product: product) {
                            Task {
                                isPurchasing = true
                                try? await store.purchase(product)
                                isPurchasing = false
                            }
                        }
                    }
                }
                .padding(.horizontal, 12)
            }
            
            Spacer()
        }
        .onAppear {
            guard store.products.isEmpty else { return }
            // Delay fetch until after sheet animation completes (~0.4s)
            // to prevent objectWillChange from firing mid-animation which auto-dismisses the sheet
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                Task { await store.fetchProducts() }
            }
        }
        .overlay(
            Group {
                if isPurchasing {
                    Color.black.opacity(0.35).ignoresSafeArea()
                    ProgressView("Processing…")
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 8)
                }
            }
        )
    }
}


@available(iOS 15.0, *)
struct CoinPackageRow: View {
    let product: Product
    let action: () -> Void
    
    var coinAmount: Int {
        let mapping = [
            "Aazr": 32, "Aazr1": 60, "Aazr2": 96, "Aazr4": 155,
            "Aazr5": 189, "Aazr9": 359, "Aazr19": 729, "Aazr49": 1869, "Aazr99": 3799
        ]
        return mapping[product.id] ?? 0
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(coinAmount) Coins")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(product.displayName.isEmpty ? "Coin Pack" : product.displayName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(product.displayPrice)
                    .bold()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

@available(iOS 15.0, *)
struct CoinGridCell: View {
    let product: Product
    let action: () -> Void
    
    var coinAmount: Int {
        let mapping = [
            "Aazr": 32, "Aazr1": 60, "Aazr2": 96, "Aazr4": 155,
            "Aazr5": 189, "Aazr9": 359, "Aazr19": 729, "Aazr49": 1869, "Aazr99": 3799
        ]
        return mapping[product.id] ?? 0
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: "bitcoinsign.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.yellow)
                
                Text("\(coinAmount)")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("coins")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text(product.displayPrice)
                    .font(.caption)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue)
                    .cornerRadius(6)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

