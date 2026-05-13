import SwiftUI

// MARK: - Color Extension for App Theme
extension Color {
    static let ios13Teal  = Color(red: 48/255,  green: 176/255, blue: 199/255)
    static let ios13Indigo = Color(red: 88/255,  green: 86/255,  blue: 214/255)
    static let ios13Cyan  = Color(red: 50/255,  green: 173/255, blue: 230/255)
    static let aiPink     = Color(red: 255/255, green: 100/255, blue: 180/255)
    static let aiPurple   = Color(red: 148/255, green: 87/255,  blue: 235/255)
    static let aiDeep     = Color(red: 30/255,  green: 20/255,  blue: 60/255)
}

// MARK: - Home View (AI Art Generator)

@available(iOS 14.0, *)
struct HomeView: View {
    @ObservedObject var store: AuraStore
    @State private var selectedItem: AuraItem?
    @State private var selectedCategory: AuraCategory = .emerald

    private let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {

                // ── Header Banner（固定，不在 ScrollView 内）──────────────
                ZStack(alignment: .bottomLeading) {
                    LinearGradient(
                        colors: [Color.aiDeep, Color.aiPurple.opacity(0.85), Color.aiPink.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 175)

                    Circle()
                        .fill(Color.white.opacity(0.05))
                        .frame(width: 160, height: 160)
                        .offset(x: 220, y: -20)
                    Circle()
                        .fill(Color.white.opacity(0.07))
                        .frame(width: 100, height: 100)
                        .offset(x: 260, y: 50)

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Image(systemName: "wand.and.stars")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.aiPink)
                            Text("AI ART STUDIO")
                                .font(.system(size: 12, weight: .black))
                                .foregroundColor(.white.opacity(0.7))
                                .tracking(3)
                        }
                        Text("Create Stunning AI Portraits")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)

                        HStack(spacing: 6) {
                            Image(systemName: "pentagon.fill")
                                .font(.system(size: 11))
                                .foregroundColor(.yellow)
                            Text("\(store.userCoins) Credits")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(20)
                        .padding(.top, 2)
                    }
                    .padding(.horizontal, 22)
                    .padding(.bottom, 20)
                }
                .clipped()

                // ── Category Filter（固定，不在 ScrollView 内）────────────
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(AuraCategory.allCases) { cat in
                            Button(action: {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedCategory = cat
                                }
                            }) {
                                StyleCategoryChip(
                                    title: cat.rawValue,
                                    isSelected: selectedCategory == cat
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                }
                .background(Color(.systemBackground))

                // ── 可滚动内容区域 ─────────────────────────────────────────
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {

                        // Featured Style
                        if let featured = filteredItems.first {
                            FeaturedStyleBanner(item: featured) {
                                selectedItem = featured
                            }
                            .padding(.horizontal, 18)
                            .padding(.top, 8)
                        }

                        // Style Grid
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("All Styles")
                                    .font(.system(size: 18, weight: .bold))
                                Spacer()
                                Text("\(filteredItems.count) styles")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 18)
                            .padding(.top, 18)

                            LazyVGrid(columns: columns, spacing: 14) {
                                ForEach(filteredItems.dropFirst()) { item in
                                    StyleGridCard(item: item, isUnlocked: store.isUnlocked(item))
                                        .onTapGesture { selectedItem = item }
                                }
                            }
                            .padding(.horizontal, 18)
                        }

                        Spacer(minLength: 100)
                    }
                }
                .background(Color(.systemGroupedBackground))
            }
            .ignoresSafeArea(edges: .top)
            .navigationBarHidden(true)
            .sheet(item: $selectedItem) { item in
                if #available(iOS 14.0, *) {
                    AuraDetailView(item: item, store: store)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private var filteredItems: [AuraItem] {
        store.items.filter { $0.category == selectedCategory }
            .isEmpty ? store.items : store.items.filter { $0.category == selectedCategory }
    }
}

// MARK: - Category Chip

struct StyleCategoryChip: View {
    let title: String
    let isSelected: Bool

    var body: some View {
        Text(title)
            .font(.system(size: 13, weight: isSelected ? .bold : .medium))
            .foregroundColor(isSelected ? .white : .secondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                isSelected
                    ? LinearGradient(colors: [Color.aiPurple, Color.aiPink], startPoint: .leading, endPoint: .trailing)
                    : LinearGradient(colors: [Color(.systemGray5), Color(.systemGray5)], startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(20)
    }
}

// MARK: - Featured Style Banner

struct FeaturedStyleBanner: View {
    let item: AuraItem
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottomLeading) {
                Image(item.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(20)
                    .overlay(
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.75)],
                            startPoint: .top, endPoint: .bottom
                        )
                        .cornerRadius(20)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text("FEATURED STYLE")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(.aiPink)
                        .tracking(2)
                    Text(item.title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)

                    HStack(spacing: 6) {
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 11))
                        Text("Tap to Generate")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(.white.opacity(0.8))
                }
                .padding(18)

                // Rarity badge
                HStack {
                    Spacer()
                    Text(item.rarity.uppercased())
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.aiPink.opacity(0.85))
                        .cornerRadius(8)
                        .padding(14)
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Style Grid Card

struct StyleGridCard: View {
    let item: AuraItem
    let isUnlocked: Bool

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(item.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 180)
                .clipped()
                .cornerRadius(16)
                .overlay(
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.65)],
                        startPoint: .center, endPoint: .bottom
                    )
                    .cornerRadius(16)
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                if isUnlocked {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.green)
                        Text("Unlocked")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.green)
                    }
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "pentagon.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.yellow)
                        Text("\(item.unlockCost)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(10)

            // Lock icon overlay
            if !isUnlocked {
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "lock.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(8)
                            .background(Color.black.opacity(0.35))
                            .clipShape(Circle())
                            .padding(8)
                    }
                    Spacer()
                }
            }
        }
        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Aura Card (legacy, kept for compatibility)

struct AuraCard: View {
    let item: AuraItem
    var body: some View {
        StyleGridCard(item: item, isUnlocked: false)
    }
}
