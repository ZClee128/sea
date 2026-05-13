import SwiftUI

struct PortraitReference: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let lighting: String
    let camera: String
    let lens: String
    let aperture: String
    let shutter: String
    let iso: String
    let palette: [String]
}

@available(iOS 14.0, *)
struct GalleryView: View {
    @State private var selectedCategory: String = "All"
    let categories = ["All", "Rembrandt", "Butterfly", "Split", "Loop", "Rim", "Creative"]
    
    let references = [
        PortraitReference(imageName: "p1", title: "Classic Rembrandt", lighting: "Rembrandt", camera: "Sony A7R IV", lens: "85mm f/1.4", aperture: "f/1.8", shutter: "1/200s", iso: "100", palette: ["#2C3E50", "#E67E22", "#BDC3C7", "#7F8C8D", "#34495E"]),
        PortraitReference(imageName: "p2", title: "Golden Butterfly", lighting: "Butterfly", camera: "Canon R5", lens: "50mm f/1.2", aperture: "f/2.0", shutter: "1/160s", iso: "100", palette: ["#FAD7A0", "#D35400", "#E67E22", "#2E4053", "#5D6D7E"]),
        PortraitReference(imageName: "p3", title: "Shadow Split", lighting: "Split", camera: "Nikon Z9", lens: "105mm f/2.8", aperture: "f/2.8", shutter: "1/250s", iso: "200", palette: ["#17202A", "#7FB3D5", "#2980B9", "#1B4F72", "#5499C7"]),
        PortraitReference(imageName: "p4", title: "Mood Loop", lighting: "Loop", camera: "Fujifilm GFX100S", lens: "80mm f/1.7", aperture: "f/1.7", shutter: "1/125s", iso: "400", palette: ["#F5B7B1", "#78281F", "#943126", "#1B2631", "#212F3C"]),
        PortraitReference(imageName: "p5", title: "Glow Rim", lighting: "Rim", camera: "Sony A1", lens: "35mm f/1.4", aperture: "f/4.0", shutter: "1/200s", iso: "100", palette: ["#D4AC0D", "#1C2833", "#2C3E50", "#7D6608", "#F1C40F"]),
        PortraitReference(imageName: "p6", title: "Neon Creative", lighting: "Creative", camera: "Sony A7 IV", lens: "24-70mm f/2.8", aperture: "f/2.8", shutter: "1/100s", iso: "800", palette: ["#8E44AD", "#2E86C1", "#1ABC9C", "#273746", "#D5F5E3"]),
        PortraitReference(imageName: "p7", title: "Heritage Style", lighting: "Rembrandt", camera: "Canon R6", lens: "85mm f/2.0", aperture: "f/2.0", shutter: "1/160s", iso: "100", palette: ["#A04000", "#D35400", "#F5B041", "#1B2631", "#2E4053"]),
        PortraitReference(imageName: "p8", title: "Vogue Light", lighting: "Butterfly", camera: "Sony A7R V", lens: "50mm f/1.4", aperture: "f/1.4", shutter: "1/200s", iso: "100", palette: ["#F9E79F", "#B7950B", "#7D6608", "#17202A", "#1C2833"]),
        PortraitReference(imageName: "p9", title: "Noir Split", lighting: "Split", camera: "Fujifilm X-T5", lens: "56mm f/1.2", aperture: "f/1.2", shutter: "1/250s", iso: "160", palette: ["#0B5345", "#16A085", "#73C6B6", "#17202A", "#1C2833"]),
        PortraitReference(imageName: "p10", title: "Soft Loop", lighting: "Loop", camera: "Nikon Z7 II", lens: "85mm f/1.8", aperture: "f/1.8", shutter: "1/160s", iso: "200", palette: ["#5D6D7E", "#2E4053", "#AEB6BF", "#212F3C", "#1B2631"]),
        PortraitReference(imageName: "p11", title: "Backlit Rim", lighting: "Rim", camera: "Canon R3", lens: "70-200mm f/2.8", aperture: "f/5.6", shutter: "1/200s", iso: "400", palette: ["#1B2631", "#FBFCFC", "#D5DBDB", "#85929E", "#2C3E50"]),
        PortraitReference(imageName: "p12", title: "Artistic Tint", lighting: "Creative", camera: "Leica SL2", lens: "50mm f/2.0", aperture: "f/2.0", shutter: "1/60s", iso: "1600", palette: ["#922B21", "#C0392B", "#F2D7D5", "#1C2833", "#273746"])
    ]
    
    var filteredReferences: [PortraitReference] {
        if selectedCategory == "All" {
            return references
        } else {
            return references.filter { $0.lighting == selectedCategory }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Category Filter Bar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(categories, id: \.self) { category in
                            Button(action: {
                                withAnimation {
                                    selectedCategory = category
                                }
                            }) {
                                Text(category)
                                    .font(.system(size: 14, weight: .medium))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedCategory == category ? Color.blue : Color(.systemGray6))
                                    .foregroundColor(selectedCategory == category ? .white : .primary)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                .background(Color.white)
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        ForEach(filteredReferences) { reference in
                            NavigationLink(destination: DetailView(reference: reference)) {
                                ReferenceCard(reference: reference)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Clemn Library")
        }
    }
}

@available(iOS 14.0, *)
struct ReferenceCard: View {
    let reference: PortraitReference
    
    var body: some View {
        VStack(alignment: .leading) {
            Image(reference.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(minWidth: 0, maxWidth: .infinity)
                .frame(height: 180)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)
                .clipped()
            
            VStack(alignment: .leading, spacing: 2) {
                Text(reference.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(reference.lighting)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 4)
            .padding(.top, 4)
        }
    }
}
