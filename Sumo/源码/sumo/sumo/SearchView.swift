import SwiftUI

struct SearchView: View {
    @EnvironmentObject var appState: AppStateManager
    @State private var searchText = ""
    
    // Masonry-like grid layout
    let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]
    
    var searchResults: [Look] {
        let activeLooks = MockData.looks.filter { !appState.isBlocked($0.author) }
        
        if searchText.isEmpty {
            return activeLooks
        } else {
            return activeLooks.filter { look in
                look.description.localizedCaseInsensitiveContains(searchText) ||
                look.author.localizedCaseInsensitiveContains(searchText) ||
                look.category.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                // Popular Tags
                if searchText.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Trending Styles")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(LookCategory.allCases, id: \.self) { category in
                                    Button(action: {
                                        searchText = category.rawValue
                                    }) {
                                        Text(category.rawValue)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(Color.secondary.opacity(0.15))
                                            .foregroundColor(.primary)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                }
                
                // Results Grid
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(searchResults) { look in
                        NavigationLink(destination: LookDetailView(look: look)) {
                            WardrobeGridItem(look: look)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("Search")
            .searchable(text: $searchText, prompt: "Search styles, creators, tags...")
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
            .environmentObject(AppStateManager())
    }
}
