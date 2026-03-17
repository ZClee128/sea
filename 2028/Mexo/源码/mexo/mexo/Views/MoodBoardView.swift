import SwiftUI

@available(iOS 14.0, *)
struct MoodBoardView: View {
    @State private var savedPhotos: [PhotoModel] = []
    
    let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignTokens.Colors.background.ignoresSafeArea()
                
                Group {
                    if savedPhotos.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 80))
                                .foregroundColor(DesignTokens.Colors.accent.opacity(0.2))
                            
                            Text("CURATE YOUR INSPIRATION")
                                .font(DesignTokens.Typography.headline())
                                .foregroundColor(DesignTokens.Colors.primary)
                            
                            Text("Save masterworks from Discover to build your personalized portrait reference collection.")
                                .font(DesignTokens.Typography.body(14))
                                .foregroundColor(DesignTokens.Colors.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 50)
                            
                            NavigationLink(destination: DiscoverView()) {
                                Text("BRIGHTEN YOUR BOARD")
                                    .font(DesignTokens.Typography.caption())
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 25)
                                    .padding(.vertical, 12)
                                    .background(DesignTokens.Colors.accent)
                                    .cornerRadius(25)
                            }
                            .padding(.top, 10)
                        }
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 20) {
                                Text("MY COLLECTION")
                                    .font(DesignTokens.Typography.caption())
                                    .fontWeight(.heavy)
                                    .tracking(2)
                                    .foregroundColor(DesignTokens.Colors.secondary)
                                    .padding(.horizontal, 25)
                                    .padding(.top, 20)
                                    
                                LazyVGrid(columns: columns, spacing: 25) {
                                    ForEach(savedPhotos) { photo in
                                        NavigationLink(destination: PhotoDetailView(photo: photo)) {
                                            PremiumPhotoCard(photo: photo)
                                        }
                                    }
                                }
                                .padding(.horizontal, 25)
                                .padding(.bottom, 120)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Mood Board")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .onAppear {
                loadSavedPhotos()
            }
        }
    }
    
    private func loadSavedPhotos() {
        let savedIds = UserDefaults.standard.stringArray(forKey: "savedPhotoIds") ?? []
        savedPhotos = PhotoModel.mockData.filter { savedIds.contains($0.id) }
    }
}

@available(iOS 14.0, *)
struct MoodBoardView_Previews: PreviewProvider {
    static var previews: some View {
        MoodBoardView()
    }
}
