import SwiftUI

@available(iOS 14.0, *)
struct FavoritesView: View {
    @StateObject private var favManager = FavoritesManager.shared

    var body: some View {
        NavigationView {
            ZStack {
                Color.zBackground.ignoresSafeArea()

                if favManager.favoriteItems.isEmpty {
                    emptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("\(favManager.favoriteItems.count) saved workouts")
                                .font(.zCaption(13))
                                .foregroundColor(Color.zTextSub)
                                .padding(.horizontal, 16)
                                .padding(.top, 4)

                            LazyVGrid(
                                columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                                spacing: 14
                            ) {
                                ForEach(favManager.favoriteItems) { item in
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
                            .padding(.horizontal, 16)
                            .padding(.bottom, 100)
                        }
                    }
                }
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.large)
        }
        .navigationViewStyle(.stack)
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.slash")
                .font(.system(size: 60, weight: .light))
                .foregroundColor(Color.zPrimary.opacity(0.4))

            Text("No Favorites Yet")
                .font(.zHeadline(20))
                .foregroundColor(Color.zText)

            Text("Tap the ♥ on any workout to save it here for quick access.")
                .font(.zBody(15))
                .foregroundColor(Color.zTextSub)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}
