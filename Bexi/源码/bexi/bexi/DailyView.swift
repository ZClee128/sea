import SwiftUI

@available(iOS 14.0, *)
struct DailyView: View {
    let heroImageURL = "cosplay_1" // Local Hero
    let featuredItems = [
        "cosplay_2",
        "cosplay_3",
        "cosplay_4",
        "cosplay_5"
    ]
    
    @State private var selectedItem: MediaItem?
    @EnvironmentObject var storageManager: StorageManager
    
    var heroItem: MediaItem? {
        ContentProvider.items.first(where: { $0.urlString == heroImageURL })
    }
    
    var filteredFeaturedMediaItems: [MediaItem] {
        ContentProvider.items.filter { item in
            featuredItems.contains(item.urlString) &&
            !storageManager.reportedItems.contains(item.urlString)
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Date Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text(DateFormatter.localizedString(from: Date(), dateStyle: .full, timeStyle: .none).uppercased())
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        Text("Today's Inspiration")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    if !storageManager.reportedItems.contains(heroImageURL), let hero = heroItem {
                        VStack(alignment: .leading, spacing: 8) {
                            RemoteImage(urlString: hero.urlString)
                                .scaledToFill()
                                .frame(height: 280)
                                .frame(maxWidth: .infinity)
                                .contentShape(Rectangle())
                                .clipped()
                                .cornerRadius(16)
                                .shadow(radius: 5)
                                .onTapGesture {
                                    selectedItem = hero
                                }
                            
                            Text("Editor's Pick: Cosplay Showcase")
                                .font(.headline)
                                .padding(.top, 4)
                            
                            Text("Explore our hand-picked collection of this week's most stunning cosplay masterpieces.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        
                        Divider().padding(.vertical, 10)
                    } else {
                        Divider().padding(.vertical, 10) // Keep spacing even if hero is hidden
                    }
                    
                    // Curated Collection
                    if !filteredFeaturedMediaItems.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Curated For You")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            ForEach(filteredFeaturedMediaItems) { item in
                                RemoteImage(urlString: item.urlString)
                                    .scaledToFill()
                                    .frame(height: 200)
                                    .frame(maxWidth: .infinity)
                                    .contentShape(Rectangle())
                                    .clipped()
                                    .cornerRadius(12)
                                    .onTapGesture {
                                        selectedItem = item
                                    }
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.bottom, 30)
            }
            .navigationBarHidden(true)
            .sheet(item: $selectedItem) { item in
                NavigationView {
                    FeedDetailView(item: item)
                }
            }
        }
    }
}



#Preview {
    if #available(iOS 14.0, *) {
        DailyView()
            .environmentObject(StorageManager())
    } else {
        // Fallback on earlier versions
    }
}
