//
//  TrackerView.swift
//  melonShare
//
//  Created by zclee on 2026/5/19.
//

import SwiftUI

struct TrackerView: View {
    @ObservedObject private var watchManager = WatchlistManager.shared
    @State private var selectedSegment = "Watching"
    
    let segments = ["Watching", "Plan to Watch", "Completed"]
    
    // Watch items filtered by current segment selection
    var filteredItems: [WatchItem] {
        watchManager.items.filter { $0.status == selectedSegment }
    }
    
    // MARK: - Computed statistics
    var totalTracked: Int {
        watchManager.items.count
    }
    
    var completedCount: Int {
        watchManager.items.filter { $0.status == "Completed" }.count
    }
    
    var totalEpisodesWatched: Int {
        watchManager.items.reduce(0) { $0 + $1.currentEpisode }
    }
    
    var completionRate: Double {
        guard totalTracked > 0 else { return 0.0 }
        return Double(completedCount) / Double(totalTracked)
    }
    
    // Category counts for bar graph representation
    var categoryDistribution: [(name: String, count: Int)] {
        let categories = ["CEO Romance", "Action & Revenge", "Time Travel & Retro", "Urban Fantasy & Power"]
        return categories.map { category in
            let count = watchManager.items.filter { $0.category == category }.count
            return (category.replacingOccurrences(of: " Romance", with: "").replacingOccurrences(of: " & ", with: "/"), count)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.backgroundGray.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        
                        // Header
                        ViewHeader(
                            title: "My Tracker",
                            subtitle: "Drama Progress"
                        )
                        
                        // Statistics Dashboard
                        if totalTracked > 0 {
                            GlassCard(padding: 16) {
                                HStack(spacing: 20) {
                                    // Left: Ring Graph
                                    VStack(spacing: 6) {
                                        ZStack {
                                            Circle()
                                                .stroke(Theme.borderGray, lineWidth: 8)
                                                .frame(width: 80, height: 80)
                                            
                                            Circle()
                                                .trim(from: 0.0, to: CGFloat(completionRate))
                                                .stroke(Theme.accentGradient, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                                .frame(width: 80, height: 80)
                                                .rotationEffect(Angle(degrees: -90))
                                                .animation(.easeOut(duration: 0.8), value: completionRate)
                                            
                                            Text(String(format: "%.0f%%", completionRate * 100))
                                                .font(.headline)
                                                .bold()
                                                .foregroundColor(Theme.textDark)
                                        }
                                        
                                        Text("Completion")
                                            .font(.caption2)
                                            .bold()
                                            .foregroundColor(Theme.textMedium)
                                    }
                                    
                                    // Right: Stats Values
                                    VStack(alignment: .leading, spacing: 10) {
                                        StatsRow(icon: "tv.fill", title: "Tracked", value: "\(totalTracked) Dramas")
                                        StatsRow(icon: "play.circle.fill", title: "Episodes", value: "\(totalEpisodesWatched) Eps")
                                        StatsRow(icon: "checkmark.seal.fill", title: "Completed", value: "\(completedCount) Dramas")
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            // Category Bar Graph Section
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Tracking Distribution")
                                    .font(.headline)
                                    .foregroundColor(Theme.textDark)
                                    .padding(.horizontal, 20)
                                
                                GlassCard(padding: 16) {
                                    HStack(alignment: .bottom, spacing: 16) {
                                        ForEach(categoryDistribution, id: \.name) { stat in
                                            VStack(spacing: 8) {
                                                // Dynamic Bar height based on ratio of total tracked
                                                ZStack(alignment: .bottom) {
                                                    RoundedRectangle(cornerRadius: 6)
                                                        .fill(Theme.borderGray)
                                                        .frame(width: 32, height: 80)
                                                    
                                                    if totalTracked > 0 && stat.count > 0 {
                                                        RoundedRectangle(cornerRadius: 6)
                                                            .fill(Theme.primaryGradient)
                                                            .frame(width: 32, height: CGFloat(stat.count) / CGFloat(totalTracked) * 80)
                                                            .transition(.move(edge: .bottom))
                                                            .animation(.spring(), value: totalTracked)
                                                    }
                                                }
                                                
                                                Text("\(stat.count)")
                                                    .font(.caption2)
                                                    .bold()
                                                    .foregroundColor(Theme.textDark)
                                                
                                                Text(stat.name)
                                                    .font(.system(size: 8))
                                                    .bold()
                                                    .foregroundColor(Theme.textMedium)
                                                    .lineLimit(1)
                                                    .frame(width: 46)
                                            }
                                            .frame(maxWidth: .infinity)
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        } else {
                            // Blank state prompt
                            GlassCard(padding: 24) {
                                VStack(spacing: 12) {
                                    Image(systemName: "checklist")
                                        .font(.system(size: 40))
                                        .foregroundColor(Theme.primaryPeach.opacity(0.6))
                                    Text("Your watchlist is empty")
                                        .font(.headline)
                                        .foregroundColor(Theme.textDark)
                                    Text("Explore curated recommendations and start tracking progress of your favorite short dramas.")
                                        .font(.caption)
                                        .foregroundColor(Theme.textMedium)
                                        .multilineTextAlignment(.center)
                                        .lineSpacing(3)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Segmented Control
                        Picker("Status Filter", selection: $selectedSegment) {
                            ForEach(segments, id: \.self) { seg in
                                Text(seg).tag(seg)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        
                        // Tracker items list
                        if filteredItems.isEmpty {
                            VStack(spacing: 8) {
                                Text("No items in this section")
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundColor(Theme.textLight)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 30)
                        } else {
                            VStack(spacing: 14) {
                                ForEach(filteredItems) { item in
                                    // Locate the corresponding full Drama to navigate to details
                                    if let originalDrama = DramaDatabase.list.first(where: { $0.id == item.id }) {
                                        NavigationLink(destination: DramaDetailView(drama: originalDrama)) {
                                            TrackedDramaRow(item: item)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    } else {
                                        TrackedDramaRow(item: item)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        Spacer(minLength: 80)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .preferredColorScheme(.light)
    }
}

// Stats detail helper row
struct StatsRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(Theme.primaryPeach)
                .frame(width: 20)
            
            Text(title + ":")
                .font(.caption)
                .foregroundColor(Theme.textMedium)
            
            Text(value)
                .font(.subheadline)
                .bold()
                .foregroundColor(Theme.textDark)
        }
    }
}

// Tracked item row component inside watchlist
struct TrackedDramaRow: View {
    let item: WatchItem
    @ObservedObject private var watchManager = WatchlistManager.shared
    
    var body: some View {
        GlassCard(padding: 12) {
            HStack(spacing: 14) {
                // Gradient Icon Cover
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color(hexString: item.startColorHex), Color(hexString: item.endColorHex)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: item.iconName)
                            .font(.headline)
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.title)
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(Theme.textDark)
                        .lineLimit(1)
                    
                    Text("Episode \(item.currentEpisode) / \(item.totalEpisodes)")
                        .font(.caption)
                        .bold()
                        .foregroundColor(Theme.primaryPeach)
                    
                    // Mini progress indicator
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Theme.borderGray)
                                .frame(height: 6)
                            
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Theme.accentGradient)
                                .frame(width: max(0, CGFloat(item.currentEpisode) / CGFloat(item.totalEpisodes) * geo.size.width), height: 6)
                        }
                    }
                    .frame(height: 6)
                }
                
                Spacer()
                
                // Stepper Buttons (+ / -) for rapid modification
                HStack(spacing: 4) {
                    Button(action: {
                        watchManager.updateEpisode(for: item.id, to: item.currentEpisode - 1)
                    }) {
                        Image(systemName: "minus.square.fill")
                            .font(.title3)
                            .foregroundColor(Theme.textLight)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        watchManager.updateEpisode(for: item.id, to: item.currentEpisode + 1)
                    }) {
                        Image(systemName: "plus.square.fill")
                            .font(.title3)
                            .foregroundColor(Theme.primaryPeach)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

struct TrackerView_Previews: PreviewProvider {
    static var previews: some View {
        TrackerView()
    }
}
