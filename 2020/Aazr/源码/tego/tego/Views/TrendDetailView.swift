//
//  TrendDetailView.swift
//  tego
//

import SwiftUI

struct TrendDetailView: View {
    let trend: AppTrend
    
    @EnvironmentObject var favorites: FavoritesManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Image/Gradient
                ZStack(alignment: .topTrailing) {
                    Image(trend.title)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 350)
                        .clipped()
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    // Title and Save Button
                    HStack {
                        Text(trend.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button(action: {
                            favorites.toggleFavorite(for: trend)
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                        }) {
                            Image(systemName: favorites.isFavorite(trend: trend) ? "bookmark.fill" : "bookmark")
                                .font(.title)
                                .foregroundColor(favorites.isFavorite(trend: trend) ? .blue : .primary)
                        }
                    }
                    
                    Text(trend.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                    
                    Divider()
                    
                    // Colors
                    Text("Signature Colors")
                        .font(.headline)
                    
                    HStack(spacing: 12) {
                        ForEach(0..<trend.colors.count, id: \.self) { index in
                            Circle()
                                .fill(trend.colors[index])
                                .frame(width: 44, height: 44)
                                .shadow(radius: 2)
                        }
                    }
                    
                    Divider()
                    
                    // Pose Tips
                    Text("Photo Posing Guide")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(trend.poseTips, id: \.self) { tip in
                            HStack(alignment: .top) {
                                Image(systemName: "camera.macro")
                                    .foregroundColor(.blue)
                                Text(tip)
                                    .font(.subheadline)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitle(Text(""), displayMode: .inline)
        .edgesIgnoringSafeArea(.top)
    }
}
