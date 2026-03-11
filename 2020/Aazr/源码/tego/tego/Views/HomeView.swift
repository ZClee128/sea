//
//  HomeView.swift
//  tego
//

import SwiftUI

struct HomeView: View {
    let trends = MockData.trends
    
    @State private var showingStore = false
    @State private var showingUnlockAlert = false
    @State private var pendingTrend: AppTrend? = nil
    
    let unlockCost = 50

    // Helper: is this trend currently locked (requires coin unlock)?
    func isLocked(_ trend: AppTrend) -> Bool {
        guard trend.isPro else { return false }
        if #available(iOS 15, *) {
            return !StoreManager.shared.isUnlocked(trend.id)
        }
        return true // On iOS 14-, treat all pro items as locked
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(trends) { trend in
                        if !isLocked(trend) {
                            NavigationLink(destination: TrendDetailView(trend: trend)) {
                                TrendCardView(trend: trend, isLocked: false)
                            }
                            .buttonStyle(PlainButtonStyle())
                        } else {
                            Button(action: {
                                pendingTrend = trend
                                showingUnlockAlert = true
                            }) {
                                TrendCardView(trend: trend, isLocked: true)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitle(Text("Trends"))
            .sheet(isPresented: $showingStore) {
                CoinStoreView()
            }
            .alert(isPresented: $showingUnlockAlert) {
                if #available(iOS 15, *) {
                    return Alert(
                        title: Text("Unlock \(pendingTrend?.title ?? "")"),
                        message: Text("Spend \(unlockCost) coins to unlock? (Balance: \(StoreManager.shared.coins) coins)"),
                        primaryButton: .default(Text("Unlock for \(unlockCost) coins")) {
                            if let trend = pendingTrend {
                                if !StoreManager.shared.unlockItem(trend.id, cost: unlockCost) {
                                    showingStore = true
                                }
                            }
                        },
                        secondaryButton: .cancel(Text("Get Coins")) {
                            showingStore = true
                        }
                    )
                } else {
                    return Alert(
                        title: Text("Upgrade Required"),
                        message: Text("In-app purchases require iOS 15 or later."),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
        }
    }
}

struct TrendCardView: View {
    let trend: AppTrend
    var isLocked: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                Image(trend.title)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 250)
                    .clipped()
                
                if isLocked {
                    HStack(spacing: 4) {
                        Image(systemName: "bitcoinsign.circle.fill")
                            .foregroundColor(.yellow)
                        Text("50")
                            .bold()
                    }
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.6))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(12)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(trend.title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: isLocked ? "lock.fill" : "chevron.right")
                        .foregroundColor(isLocked ? .yellow : .gray)
                }
                
                Text(trend.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(16)
        }
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .opacity(isLocked ? 0.85 : 1.0)
    }
}

