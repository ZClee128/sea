import SwiftUI

struct GRDiscoverGalleryView: View {
    let models = GRModelRegistry.samples
    @State private var selectedModel: GRModelProfile?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 25) {
                        headerSection
                        
                        featuredSection
                        
                        Text("New Faces")
                            .font(.system(size: 26, weight: .bold, design: .serif))
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                        
                        let newFaces = GRModelRegistry.samples.filter { !$0.isFeatured }
                        VStack(spacing: 20) {
                            ForEach(0..<(newFaces.count + 1) / 2, id: \.self) { rowIndex in
                                HStack(spacing: 20) {
                                    NavigationLink(destination: GRProfileDetailView(model: newFaces[rowIndex * 2])) {
                                        GRProfileGridCell(model: newFaces[rowIndex * 2])
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    if rowIndex * 2 + 1 < newFaces.count {
                                        NavigationLink(destination: GRProfileDetailView(model: newFaces[rowIndex * 2 + 1])) {
                                            GRProfileGridCell(model: newFaces[rowIndex * 2 + 1])
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    } else {
                                        Spacer()
                                    }
                                }.padding(.trailing, 20)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 80)
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    var headerSection: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("GLOWR")
                    .font(.system(size: 38, weight: .black, design: .serif))
                    .tracking(5)
                Text("PORTFOLIO HUB")
                    .font(.caption)
                    .tracking(2)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .foregroundColor(.black)
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    var featuredSection: some View {
        VStack(alignment: .leading) {
            Text("Editor's Pick")
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundColor(.black)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    let featuredModels = GRModelRegistry.samples.filter { $0.isFeatured }
                    ForEach(featuredModels) { model in
                        NavigationLink(destination: GRProfileDetailView(model: model)) {
                            GRFeaturedProfileCard(model: model)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct GRFeaturedProfileCard: View {
    let model: GRModelProfile
    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .bottomLeading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 250, height: 350)
                    .cornerRadius(15)
                
                // Real Model Image
                Image(model.imageNames.first ?? "")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 250, height: 350)
                    .clipped()
                    .overlay(Color.black.opacity(0.05))
                
                VStack(alignment: .leading) {
                    if #available(iOS 14.0, *) {
                        Text(model.name)
                            .font(.title2)
                            .fontWeight(.bold)
                    } else {
                        // Fallback on earlier versions
                    }
                    Text(model.agency)
                        .font(.caption)
                }
                .foregroundColor(.white) // Keep white text for image overlay
                .padding()
                .shadow(radius: 5)
            }
        }
    }
}

struct GRProfileGridCell: View {
    let model: GRModelProfile
    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .topTrailing) {
                Rectangle()
                    .fill(Color.gray.opacity(0.05))
                    .aspectRatio(0.7, contentMode: .fill)
                    .cornerRadius(10)
                
                Image(model.imageNames.first ?? "")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                
                Image(systemName: "plus.circle.fill")
                    .padding(8)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Text(model.name)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black)
            
            Text(model.agency)
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
    }
}
