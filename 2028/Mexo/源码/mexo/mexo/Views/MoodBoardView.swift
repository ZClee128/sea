import SwiftUI

@available(iOS 14.0, *)
struct MoodBoardView: View {
    @State private var savedPhotos: [PhotoModel] = []
    
    let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]
    
    var body: some View {
        NavigationView {
            Group {
                if savedPhotos.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "photo.stack")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Your Inspiration Board is Empty")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Save photos from Discover to start building your own portrait reference collection.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 15) {
                            ForEach(savedPhotos) { photo in
                                NavigationLink(destination: PhotoDetailView(photo: photo)) {
                                    PhotoCardView(photo: photo)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Mood Board")
            .onAppear {
                loadSavedPhotos()
            }
        }
    }
    
    // Simplistic load logic
    private func loadSavedPhotos() {
        let savedIds = UserDefaults.standard.stringArray(forKey: "savedPhotoIds") ?? []
        // In a real app we would fetch from CoreData or Backend, here we filter mock
        savedPhotos = PhotoModel.mockData.filter { savedIds.contains($0.id) }
    }
}

struct MoodBoardView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 14.0, *) {
            MoodBoardView()
        } else {
            // Fallback on earlier versions
        }
    }
}
