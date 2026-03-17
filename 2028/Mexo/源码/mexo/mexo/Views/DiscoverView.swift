import SwiftUI

@available(iOS 14.0, *)
struct DiscoverView: View {
    let photos: [PhotoModel] = PhotoModel.mockData
    
    let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(photos) { photo in
                        NavigationLink(destination: PhotoDetailView(photo: photo)) {
                            PhotoCardView(photo: photo)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Discover")
        }
    }
}

struct PhotoCardView: View {
    let photo: PhotoModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Image(photo.imageUrl)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 200)
                .cornerRadius(12)
                .clipped()
            
            Text(photo.category)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .padding(.top, 4)
                .padding(.horizontal, 4)
        }
    }
}

struct DiscoverView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 14.0, *) {
            DiscoverView()
        } else {
            // Fallback on earlier versions
        }
    }
}
