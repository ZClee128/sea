import SwiftUI

@available(iOS 15.0, *)
struct ExploreView: View {
    @StateObject var assetManager = AssetManager()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Featured Section (Editorial Layout)
                    Text("Featured Muses")
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(assetManager.muses.filter { $0.isEditorialFeatured }) { muse in
                                FeaturedMuseCard(muse: muse)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Main Grid
                    Text("Collections")
                        .font(.system(size: 20, weight: .semibold, design: .serif))
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
                    VStack(spacing: 20) {
                        ForEach(assetManager.muses.filter { !$0.isEditorialFeatured }) { muse in
                            NavigationLink(destination: MuseDetailView(muse: muse)) {
                                MuseEditorialCard(muse: muse)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Fickr Insights")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

@available(iOS 15.0, *)
struct FeaturedMuseCard: View {
    let muse: MuseItem
    
    var body: some View {
        NavigationLink(destination: MuseDetailView(muse: muse)) {
            ZStack(alignment: .bottomLeading) {
                Image(muse.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 280, height: 350)
                    .clipped()
                    .cornerRadius(20)
                
                LinearGradient(colors: [.black.opacity(0.6), .clear], startPoint: .bottom, endPoint: .top)
                    .cornerRadius(20)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(muse.category.uppercased())
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(muse.title)
                        .font(.system(size: 22, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                }
                .padding(20)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MuseEditorialCard: View {
    let muse: MuseItem
    
    var body: some View {
        HStack(spacing: 16) {
                Image(muse.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 130)
                    .clipped()
                    .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(muse.category.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.gray)
                
                Text(muse.title)
                    .font(.system(size: 18, weight: .semibold, design: .serif))
                    .foregroundColor(.black)
                
                Text(muse.description)
                    .font(.system(size: 14, design: .serif))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(16)
    }
}

@available(iOS 15.0, *)
struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
    }
}
