import SwiftUI

@available(iOS 15.0, *)
struct SavedMusesView: View {
    @EnvironmentObject var dataStore: MuseDataStore
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                let savedItems = dataStore.muses.filter { $0.isFavorite }
                
                if savedItems.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No Favorites Yet")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        Text("Explore the Discover feed to find your favorite aesthetic muses.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(savedItems) { muse in
                                NavigationLink(destination: MuseDetailView(muse: muse)) {
                                    MuseCard(muse: muse)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationTitle("My Collection")
        .navigationBarTitleDisplayMode(.inline)
    }
}
