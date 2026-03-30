import SwiftUI

@available(iOS 14.0, *)
struct ExploreView: View {
    @StateObject private var favManager = FavoritesManager.shared
    @State private var selectedCategory: FitnessCategory = .all
    @State private var searchText = ""

    private var filteredItems: [ContentItem] {
        var items = SampleData.items
        if selectedCategory != .all {
            items = items.filter { $0.category == selectedCategory.rawValue }
        }
        if !searchText.isEmpty {
            items = items.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.subtitle.localizedCaseInsensitiveContains(searchText) ||
                $0.tags.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
            }
        }
        return items
    }

    private var featuredItems: [ContentItem] {
        SampleData.items.filter { $0.isFeatured }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.zBackground.ignoresSafeArea()
                    .onTapGesture {
                        hideKeyboard()
                    }

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        // Search bar
                        searchBar
                            .padding(.horizontal, 16)
                            .padding(.top, 4)
                            .padding(.bottom, 16)

                        // Featured carousel (only when no search/filter active)
                        if searchText.isEmpty && selectedCategory == .all {
                            featuredSection
                        }

                        // Category picker
                        categoryPicker
                            .padding(.top, 20)
                            .padding(.bottom, 12)

                        // Grid
                        contentGrid
                            .padding(.horizontal, 16)
                            .padding(.bottom, 100) // tab bar clearance
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle()) // 确保空白区域也能响应点击
                    .onTapGesture {
                        hideKeyboard()
                    }
                }
                .simultaneousGesture(
                    DragGesture().onChanged { _ in
                        hideKeyboard() // 滑动时也同时收下键盘，极大提升体验
                    }
                )
            }
            .navigationTitle("Explore")
            .navigationBarTitleDisplayMode(.large)
        }
        .navigationViewStyle(.stack)
    }

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color.zTextSub)
            TextField("Search workouts…", text: $searchText)
                .font(.zBody(15))
                .foregroundColor(Color.zText)
            if !searchText.isEmpty {
                Button { searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color.zTextSub)
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.zPrimary.opacity(0.07), radius: 8, x: 0, y: 2)
    }

    // MARK: - Featured Carousel
    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Featured")
                .font(.zHeadline(18))
                .foregroundColor(Color.zText)
                .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(featuredItems) { item in
                        NavigationLink(destination: ContentDetailView(item: item)) {
                            if #available(iOS 15.0, *) {
                                FeaturedCard(item: item)
                            } else {
                                // Fallback on earlier versions
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
            }
        }
    }

    // MARK: - Category Picker
    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(FitnessCategory.allCases) { cat in
                    Button {
                        withAnimation(.spring()) { selectedCategory = cat }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: cat.icon)
                                .font(.system(size: 12, weight: .semibold))
                            Text(cat.rawValue)
                                .font(.zCaption(13))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            selectedCategory == cat
                            ? LinearGradient(colors: [Color.zPrimary, Color.zAccent],
                                             startPoint: .leading, endPoint: .trailing)
                            : LinearGradient(colors: [Color.white, Color.white],
                                             startPoint: .leading, endPoint: .trailing)
                        )
                        .foregroundColor(selectedCategory == cat ? .white : Color.zTextSub)
                        .cornerRadius(20)
                        .shadow(color: selectedCategory == cat ? Color.zPrimary.opacity(0.3) : Color.clear,
                                radius: 6, x: 0, y: 3)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Content Grid
    private var contentGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
            spacing: 14
        ) {
            ForEach(filteredItems) { item in
                NavigationLink(destination: ContentDetailView(item: item)) {
                    if #available(iOS 15.0, *) {
                        ContentCard(item: item)
                    } else {
                        // Fallback on earlier versions
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

// MARK: - Featured Card
@available(iOS 15.0, *)
struct FeaturedCard: View {
    let item: ContentItem
    @StateObject private var favManager = FavoritesManager.shared

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // ── overlay pattern: Color establishes the immovable frame ──
            Color(hex: "#F5CDD6")
                .overlay(
                    Image(item.title)
                        .resizable()
                        .scaledToFill()
                        .clipped()
                )
                .clipped()
                .cornerRadius(18)

            // Gradient overlay
            LinearGradient(
                colors: [.clear, Color.black.opacity(0.7)],
                startPoint: .center, endPoint: .bottom
            )
            .cornerRadius(18)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    DifficultyBadge(level: item.difficulty)
                    Spacer()
                    Image(systemName: "clock")
                        .font(.system(size: 11))
                    Text(item.duration)
                        .font(.zCaption(11))
                }
                .foregroundColor(.white.opacity(0.9))

                Text(item.title)
                    .font(.zHeadline(16))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text("\(item.calories) cal")
                    .font(.zCaption(11))
                    .foregroundColor(.white.opacity(0.75))
            }
            .padding(12)
        }
        // Fixed size on the outer ZStack — nothing inside can change this
        .frame(width: 260, height: 160)
        .clipped()
    }

    private var shimmerPlaceholder: some View {
        LinearGradient(colors: [Color(hex: "#F5CDD6"), Color(hex: "#FADDE1")],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

// MARK: - Content Card
@available(iOS 15.0, *)
struct ContentCard: View {
    let item: ContentItem
    @StateObject private var favManager = FavoritesManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // ── overlay pattern: Color sets the immovable frame ──
            Color(hex: "#F5CDD6")
                .overlay(
                    Image(item.title)
                        .resizable()
                        .scaledToFill()
                        .clipped()
                )
                .overlay(
                    // Fav button on top-right
                    Button {
                        withAnimation(.spring()) {
                            favManager.toggle(item.id)
                        }
                    } label: {
                        Image(systemName: favManager.isFavorite(item.id) ? "heart.fill" : "heart")
                            .foregroundColor(favManager.isFavorite(item.id) ? Color.zPrimary : .white)
                            .padding(8)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    .padding(8),
                    alignment: .topTrailing
                )
                .frame(height: 130)           // ← only this line controls height
                .clipped()
                .cornerRadius(14, corners: [.topLeft, .topRight])

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.zCaption(13))
                    .fontWeight(.semibold)
                    .foregroundColor(Color.zText)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 10))
                    Text(item.duration)
                    Text("·")
                    Text("\(item.calories) cal")
                }
                .font(.system(size: 11))
                .foregroundColor(Color.zTextSub)

                DifficultyBadge(level: item.difficulty)
                    .padding(.top, 2)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
        }
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.zPrimary.opacity(0.06), radius: 8, x: 0, y: 3)
    }
}

// MARK: - Difficulty Badge
struct DifficultyBadge: View {
    let level: ContentItem.Difficulty
    var body: some View {
        Text(level.rawValue)
            .font(.system(size: 10, weight: .semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Color(hex: level.color).opacity(0.15))
            .foregroundColor(Color(hex: level.color))
            .cornerRadius(6)
    }
}

// MARK: - Corner radius helper
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// MARK: - Keyboard Helper
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
