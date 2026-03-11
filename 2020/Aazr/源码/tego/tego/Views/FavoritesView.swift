//
//  FavoritesView.swift
//  tego
//

import SwiftUI

@available(iOS 15, *)
struct FavoritesView: View {
    @EnvironmentObject var favorites: FavoritesManager
    let allTrends = MockData.trends
    
    var savedTrends: [AppTrend] {
        allTrends.filter { favorites.isFavorite(trend: $0) }
    }
    
    @State private var showingPaywall = false
    
    var body: some View {
        NavigationView {
            Group {
                if savedTrends.isEmpty {
                    VStack(spacing: 24) {
                        Image(systemName: "bookmark.slash")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray)
                        
                        Text("No Saved Trends")
                            .font(.title)
                            .fontWeight(.semibold)
                        
                        Text("You haven't saved any trends yet. Explore the encyclopedia to find your aesthetic!")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 40)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(savedTrends) { trend in
                                if trend.isPro {
                                    Button(action: {
                                        showingPaywall = true
                                    }) {
                                        TrendCardView(trend: trend)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                } else {
                                    NavigationLink(destination: TrendDetailView(trend: trend)) {
                                        TrendCardView(trend: trend)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarTitle(Text("Saved"))
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }
}
