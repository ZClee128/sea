//
//  InAppPurchaseView.swift
//  Scenery
//
//  Created on 2026/1/14.
//

import SwiftUI

@available(iOS 16.0, *)
struct InAppPurchaseView: View {
    @State private var selectedPackage: CoinPackage?
    @State private var isPurchasing = false
    @Environment(\.dismiss) var dismiss
    
    struct CoinPackage: Identifiable, Equatable {
        let id = UUID()
        let name: String
        let price: String
        let priceValue: Double
        let coins: Int
        let bonus: String?
        
        var displayName: String {
            return name
        }
        
        var coinDescription: String {
            if let bonus = bonus {
                return "\(coins)金币\n\(bonus)"
            }
            return "\(coins)金币"
        }
    }
    
    let coinPackages: [CoinPackage] = [
        CoinPackage(name: "Sunni", price: "$0.99", priceValue: 0.99, coins: 32, bonus: "32金币≈1购币"),
        CoinPackage(name: "Sunni1", price: "$1.99", priceValue: 1.99, coins: 60, bonus: "60金币≈1购币"),
        CoinPackage(name: "Sunni2", price: "$2.99", priceValue: 2.99, coins: 96, bonus: "96金币≈1购币"),
        CoinPackage(name: "Sunni4", price: "$4.99", priceValue: 4.99, coins: 155, bonus: "155金币≈1购币"),
        CoinPackage(name: "Sunni5", price: "$5.99", priceValue: 5.99, coins: 189, bonus: "189金币≈1购币"),
        CoinPackage(name: "Sunni9", price: "$9.99", priceValue: 9.99, coins: 359, bonus: "299金币+60"),
        CoinPackage(name: "Sunni19", price: "$19.99", priceValue: 19.99, coins: 729, bonus: "599金币+130"),
        CoinPackage(name: "Sunni49", price: "$49.99", priceValue: 49.99, coins: 1869, bonus: "1599金币+270"),
        CoinPackage(name: "Sunni99", price: "$99.99", priceValue: 99.99, coins: 3799, bonus: "3199金币+600")
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "circle.grid.cross.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color(hex: "2ECC71"))
                        
                        Text("购买金币")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("金币可用于解锁更多功能")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    
                    // Coin packages grid
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ], spacing: 12) {
                        ForEach(coinPackages) { package in
                            CoinPackageCard(
                                package: package,
                                isSelected: selectedPackage == package,
                                action: { selectedPackage = package }
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Purchase button
                    if selectedPackage != nil {
                        Button(action: handlePurchase) {
                            if isPurchasing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("购买 \(selectedPackage?.price ?? "")")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "2ECC71"))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .disabled(isPurchasing)
                    }
                    
                    Text("购买即视为同意相关条款")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func handlePurchase() {
        isPurchasing = true
        
        // Simulate purchase
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isPurchasing = false
            dismiss()
        }
    }
}

// Helper view valid for iOS 13? CoinPackageCard uses standard views, but LazyVGrid is iOS 14.
// So parent handles LazyVGrid availability, but this child view is likely safe.
// However InAppPurchaseView.CoinPackage is defined inside InAppPurchaseView.
// If InAppPurchaseView is @available limited, CoinPackage access might be issue.
// Let's wrap helper too or just leave it if it uses base types.
// Wait, CoinPackageCard takes InAppPurchaseView.CoinPackage as param.
// If InAppPurchaseView is restricted, using its nested type in a non-restricted view is valid?
// It might be better to move struct out or wrap both.

@available(iOS 16.0, *)
struct CoinPackageCard: View {
    // If InAppPurchaseView is available 15.0+, we can't use its nested type here without restriction?
    // Actually Swift might complain.
    // Let's check if we can just wrap the whole file content.
    // simpler to wrap the whole file content if possible, but replace_file_content targets ranges.
    // I will wrap CoinPackageCard as well.
    let package: InAppPurchaseView.CoinPackage
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(package.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text("\(package.coins)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "2ECC71"))
                
                Text("coins")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                if let bonus = package.bonus {
                    Text(bonus)
                        .font(.caption2)
                        .foregroundColor(.orange)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Text(package.price)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .padding(.top, 4)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color(hex: "2ECC71").opacity(0.1) : Color(.systemGray6))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color(hex: "2ECC71") : Color.clear, lineWidth: 2)
            )
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

@available(iOS 16.0, *)
struct InAppPurchaseView_Previews: PreviewProvider {
    static var previews: some View {
        InAppPurchaseView()
    }
}
