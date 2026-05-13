import SwiftUI

@available(iOS 14.0, *)
struct ExploreView: View {
    @ObservedObject var store: AuraStore
    @State private var selectedItem: AuraItem?
    @State private var selectedCategory: AuraCategory = .emerald
    @State private var searchText = ""
    @State private var sortOption: SortOption = .none
    
    enum SortOption {
        case none, rarityHighToLow, costLowToHigh
    }
    
    let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all)
                    .onTapGesture { hideKeyboard() }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 25) {
                        HStack {
                            Image(systemName: "magnifyingglass").foregroundColor(.gray)
                            TextField("Search Mussa or Crystals...", text: $searchText)
                        }
                        .padding(12).background(Color.white).cornerRadius(12).padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Featured Mussa").font(.system(size: 20, weight: .bold)).padding(.horizontal)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 20) {
                                    ForEach(store.items.filter { $0.rarity == "Legendary" }) { item in
                                        FeaturedCarouselItem(item: item).onTapGesture { selectedItem = item }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        CollectionProgressCard(store: store).padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Text("Mussa Collection").font(.system(size: 20, weight: .bold))
                                Spacer()
                                Menu {
                                    Button(action: { sortOption = .rarityHighToLow }) { Label("Rarity: High to Low", systemImage: "star.fill") }
                                    Button(action: { sortOption = .costLowToHigh }) { Label("Cost: Low to High", systemImage: "dollarsign.circle") }
                                    Button(action: { sortOption = .none }) { Label("Reset Sort", systemImage: "arrow.counterclockwise") }
                                } label: {
                                    Image(systemName: "line.3.horizontal.decrease.circle").font(.title3).foregroundColor(sortOption == .none ? .primary : .blue)
                                }
                            }
                            .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(AuraCategory.allCases) { category in
                                        CategoryTag(title: category.rawValue, isSelected: selectedCategory == category)
                                            .onTapGesture {
                                                withAnimation(.spring()) { selectedCategory = category }
                                            }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            LazyVGrid(columns: columns, spacing: 15) {
                                ForEach(sortedAndFilteredItems) { item in
                                    ExploreCard(item: item).onTapGesture { selectedItem = item }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Discovery").font(.system(size: 20, weight: .bold)).padding(.horizontal)
                            HStack {
                                Image(systemName: "dice.fill").font(.largeTitle).foregroundColor(.white)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Surprise Me").font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                                    Text("Pick a random Mussa to inspire you.").font(.system(size: 12)).foregroundColor(.white.opacity(0.8))
                                }
                                Spacer()
                                Image(systemName: "chevron.right").foregroundColor(.white)
                            }
                            .padding(20).background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing)).cornerRadius(20).padding(.horizontal)
                            .onTapGesture { selectedItem = store.items.randomElement() }
                        }
                        Spacer(minLength: 50)
                    }
                    .padding(.top, 10)
                }
                .onTapGesture { hideKeyboard() }
            }
            .navigationBarTitle("Explore", displayMode: .inline)
            .sheet(item: $selectedItem) { item in
                AuraDetailView(item: item, store: store)
            }
        }
    }
    
    private var sortedAndFilteredItems: [AuraItem] {
        var filtered = store.items.filter { 
            (selectedCategory == .amethyst || $0.category == selectedCategory) &&
            (searchText.isEmpty || $0.museName.localizedCaseInsensitiveContains(searchText) || $0.title.localizedCaseInsensitiveContains(searchText))
        }
        switch sortOption {
        case .rarityHighToLow: filtered.sort { $0.rarityValue > $1.rarityValue }
        case .costLowToHigh: filtered.sort { $0.unlockCost < $1.unlockCost }
        case .none: break
        }
        return filtered
    }
}

// Extension to hide keyboard
#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

@available(iOS 14.0, *)
struct FeaturedCarouselItem: View {
    let item: AuraItem
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(item.imageName).resizable().aspectRatio(contentMode: .fill).frame(width: 280, height: 160).clipped().cornerRadius(20)
                .overlay(LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.6)]), startPoint: .top, endPoint: .bottom).cornerRadius(20))
            VStack(alignment: .leading, spacing: 4) {
                Text(item.rarity).font(.system(size: 10, weight: .heavy)).padding(.horizontal, 8).padding(.vertical, 4).background(Color.yellow).foregroundColor(.black).cornerRadius(6)
                Text(item.title).font(.system(size: 18, weight: .bold)).foregroundColor(.white)
            }
            .padding(15)
        }
    }
}

@available(iOS 14.0, *)
struct CollectionProgressCard: View {
    @ObservedObject var store: AuraStore
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Collection Status").font(.system(size: 16, weight: .bold))
                Text("\(store.unlockedIds.count) of \(store.items.count) Mussa Unlocked").font(.system(size: 12)).foregroundColor(.secondary)
                ZStack(alignment: .leading) {
                    Rectangle().fill(Color.blue.opacity(0.1)).frame(height: 8)
                    Rectangle().fill(Color.blue).frame(width: CGFloat(store.unlockedIds.count) / CGFloat(store.items.count) * 200, height: 8)
                }
                .cornerRadius(4).frame(width: 200)
            }
            Spacer()
            Image(systemName: "crown.fill").font(.system(size: 30)).foregroundColor(.yellow)
        }
        .padding(20).background(Color.white).cornerRadius(20).shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

@available(iOS 14.0, *)
struct ExploreCard: View {
    let item: AuraItem
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .topTrailing) {
                GeometryReader { geo in
                    Image(item.imageName).resizable().aspectRatio(contentMode: .fill).frame(width: geo.size.width, height: geo.size.height).clipped()
                }
                .aspectRatio(0.8, contentMode: .fit).cornerRadius(15)
                Text(item.rarity).font(.system(size: 8, weight: .heavy)).padding(.horizontal, 6).padding(.vertical, 3).background(BlurView(style: .systemUltraThinMaterialLight)).cornerRadius(5).padding(8)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(item.museName).font(.system(size: 14, weight: .bold))
                Text(item.crystalType).font(.system(size: 12)).foregroundColor(.secondary)
            }
            .padding(.horizontal, 5)
        }
        .padding(8).background(Color.white).cornerRadius(20).shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct CategoryTag: View {
    let title: String
    let isSelected: Bool
    var body: some View {
        Text(title).font(.system(size: 14, weight: isSelected ? .bold : .medium)).padding(.horizontal, 18).padding(.vertical, 10).background(isSelected ? Color.blue : Color.gray.opacity(0.08)).foregroundColor(isSelected ? .white : .primary).cornerRadius(25)
    }
}
