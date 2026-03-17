import SwiftUI

struct EditorialFeedView: View {
    let photos: [PhotoModel] = PhotoModel.mockData
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Header / Masthead
                    VStack(spacing: 8) {
                        Text("MEXO")
                            .font(.system(size: 44, weight: .black, design: .serif))
                            .tracking(4)
                        
                        Text("PORTRAIT ESTHETICS MAGAZINE")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .tracking(2)
                        
                        Divider()
                            .padding(.horizontal, 40)
                    }
                    .padding(.top, 20)
                    
                    // Top Spotlight (Large Feature)
                    if let first = photos.first {
                        FeaturedMagazineCard(photo: first)
                    }
                    
                    // Regular Feed with staggered look
                    VStack(spacing: 40) {
                        ForEach(photos.dropFirst()) { photo in
                            EditorialMagazineCard(photo: photo)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct FeaturedMagazineCard: View {
    let photo: PhotoModel
    
    var body: some View {
        NavigationLink(destination: PhotoDetailView(photo: photo)) {
            VStack(alignment: .leading, spacing: 12) {
                ZStack(alignment: .bottomLeading) {
                    if #available(iOS 15.0, *) {
                        AsyncImage(url: URL(string: photo.imageUrl)) { image in
                            image.resizable().aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Color.gray.opacity(0.2)
                        }
                        .frame(height: 450)
                        .clipped()
                    } else {
                        Rectangle().fill(Color.gray.opacity(0.2)).frame(height: 450)
                    }
                    
                    // Issue Tag
                    if #available(iOS 14.0, *) {
                        Text(photo.issueNumber.uppercased())
                            .font(.caption2)
                            .fontWeight(.black)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue)
                            .padding(20)
                    } else {
                        // Fallback on earlier versions
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        ForEach(photo.stylingTags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Text(photo.title.uppercased())
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundColor(.primary)
                    
                    Text(photo.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                .padding(.horizontal)
            }
        }
    }
}

struct EditorialMagazineCard: View {
    let photo: PhotoModel
    
    var body: some View {
        NavigationLink(destination: PhotoDetailView(photo: photo)) {
            HStack(spacing: 20) {
                if #available(iOS 15.0, *) {
                    AsyncImage(url: URL(string: photo.imageUrl)) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray.opacity(0.2)
                    }
                    .frame(width: 150, height: 200)
                    .cornerRadius(4)
                    .clipped()
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    if #available(iOS 14.0, *) {
                        Text(photo.category.uppercased())
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    } else {
                        // Fallback on earlier versions
                    }
                    
                    Text(photo.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(photo.subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                    
                    Spacer()
                    
                    HStack {
                        Image(systemName: "camera.viewfinder")
                        Text("Pose Analysis")
                    }
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(4)
                }
                .padding(.vertical, 4)
                
                Spacer()
            }
            .padding(.horizontal)
        }
    }
}

struct EditorialFeedView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EditorialFeedView()
        }
    }
}
