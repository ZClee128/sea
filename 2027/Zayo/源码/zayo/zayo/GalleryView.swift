import SwiftUI

struct GalleryView: View {
    @State private var selectedCategory: PortraitCategory? = nil
    
    var filteredPortraits: [Portrait] {
        if let category = selectedCategory {
            return ZayoData.portraits.filter { $0.category == category }
        }
        return ZayoData.portraits
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Category Selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        CategoryCapsule(title: "All", isSelected: selectedCategory == nil) {
                            selectedCategory = nil
                        }
                        
                        ForEach(PortraitCategory.allCases, id: \.self) { category in
                            CategoryCapsule(title: category.rawValue, isSelected: selectedCategory == category) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 16)
                }
                
                ScrollView {
                    if #available(iOS 14.0, *) {
                        LazyVStack(spacing: 24) {
                            ForEach(filteredPortraits) { portrait in
                                NavigationLink(destination: PortraitDetailView(portrait: portrait)) {
                                    PortraitCard(portrait: portrait)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 24)
                    } else {
                        // Fallback on earlier versions
                    }
                }
            }
            .navigationBarTitle("Zayo Landscapes", displayMode: .inline)
        }
    }
}

struct CategoryCapsule: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(isSelected ? Color.black : Color.gray.opacity(0.1))
                .foregroundColor(isSelected ? .white : .black)
                .cornerRadius(20)
        }
    }
}

struct PortraitCard: View {
    let portrait: Portrait
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image Placeholder
            Image(portrait.imageName)
                .resizable()
                .scaledToFit() // Display at natural aspect ratio
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(portrait.title)
                    .font(.system(size: 18, weight: .bold, design: .serif))
                
                Text(portrait.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct GalleryView_Previews: PreviewProvider {
    static var previews: some View {
        GalleryView()
    }
}
