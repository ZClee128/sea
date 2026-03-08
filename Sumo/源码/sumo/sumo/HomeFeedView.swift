import SwiftUI

@available(iOS 15.0, *)
struct HomeFeedView: View {
    @EnvironmentObject var appState: AppStateManager
    @State private var selectedCategory: LookCategory? = nil
    
    var filteredLooks: [Look] {
        let baseLooks = ContentLibrary.looks.filter { !appState.isBlocked($0.author) }
        if let category = selectedCategory {
            return baseLooks.filter { $0.category == category }
        }
        return baseLooks
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Category Filter Bar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterPill(title: "All", isSelected: selectedCategory == nil) {
                            withAnimation { selectedCategory = nil }
                        }
                        
                        ForEach(LookCategory.allCases, id: \.self) { category in
                            FilterPill(title: category.rawValue, isSelected: selectedCategory == category) {
                                withAnimation { selectedCategory = category }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
                .background(Color(.systemBackground))
                
                // Main Feed
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredLooks) { look in
                            NavigationLink(destination: LookDetailView(look: look)) {
                                FeedItemCell(look: look)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Discover")
        }
    }
}

struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .bold : .medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.primary : Color.secondary.opacity(0.2))
                .foregroundColor(isSelected ? Color(.systemBackground) : .primary)
                .clipShape(Capsule())
        }
    }
}
