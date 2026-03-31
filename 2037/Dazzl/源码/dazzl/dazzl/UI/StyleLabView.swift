import SwiftUI

@available(iOS 15.0, *)
struct StyleLabView: View {
    @EnvironmentObject var dataStore: MuseDataStore
    @State private var showCopiedToast = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 25) {
                        // Header Section
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Aesthetic Lab")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(.white)
                            Text("Technical references for creators")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        
                        // Categories Summary - Now Functional Navigation
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                NavigationLink(destination: PaletteLibraryView()) {
                                    LabCategoryCard(title: "Palettes", icon: "paintpalette.fill", color: .purple) {}
                                }
                                
                                NavigationLink(destination: LightingBlueprintView()) {
                                    LabCategoryCard(title: "Lighting", icon: "lightbulb.fill", color: .yellow) {}
                                }
                                
                                NavigationLink(destination: PoseGeometryView()) {
                                    LabCategoryCard(title: "Geometry", icon: "skew", color: .blue) {}
                                }
                                
                                NavigationLink(destination: ProTipsView()) {
                                    LabCategoryCard(title: "Pro Tips", icon: "star.fill", color: .orange) {}
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Text("Lab Insights")
                            .font(.title2).bold()
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        // Detailed Analysis Cards
                        VStack(spacing: 20) {
                            ForEach(dataStore.muses.filter { $0.videoUrl != nil }) { muse in
                                NavigationLink(destination: MuseDetailView(muse: muse)) {
                                    LabAnalysisCard(muse: muse) { hex in
                                        UIPasteboard.general.string = hex
                                        withAnimation {
                                            showCopiedToast = true
                                        }
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            withAnimation { showCopiedToast = false }
                                        }
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.top)
                }
                
                // Toast Feedback
                if showCopiedToast {
                    VStack {
                        Spacer()
                        Text("Color Copied to Clipboard!")
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 24)
                            .background(Color.blue)
                            .cornerRadius(25)
                            .standardShadow()
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .padding(.bottom, 100)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct LabCategoryCard: View {
    let title: String
    let icon: String
    let color: Color
    var action: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
        }
        .frame(width: 120, height: 100)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

@available(iOS 15.0, *)
struct LabAnalysisCard: View {
    let muse: Muse
    var onHexTap: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 15) {
                // Thumbnail
                AsyncImage(url: URL(string: muse.imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.white.opacity(0.1)
                }
                .frame(width: 80, height: 80)
                .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(muse.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(muse.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(4)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            
            // Palette section
            VStack(alignment: .leading, spacing: 8) {
                Text("Color Palette (Tap color to copy)")
                    .font(.caption.bold())
                    .foregroundColor(.gray)
                
                HStack(spacing: 10) {
                    ForEach(muse.palette, id: \.self) { hex in
                        // Use a simple view with onTapGesture to avoid Button interference
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color(hex: hex))
                                .frame(width: 12, height: 12)
                            Text(hex)
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.1)) // Slightly brighter for visibility
                        .cornerRadius(6)
                        .onTapGesture {
                            onHexTap(hex)
                        }
                    }
                }
            }
            
            // Lighting Tip
            VStack(alignment: .leading, spacing: 8) {
                Text("Lighting Technique")
                    .font(.caption.bold())
                    .foregroundColor(.gray)
                
                Text(muse.lightingTip)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(2)
            }
        }
        .padding()
        .background(Color.white.opacity(0.03))
        .cornerRadius(20)
    }
}


// Color extension to handle HEX strings
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

