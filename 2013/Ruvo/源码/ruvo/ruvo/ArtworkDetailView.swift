import SwiftUI

struct ArtworkDetailView: View {
    let artwork: Artwork
    @State private var showGrid = false
    @State private var gridRows = 3
    @State private var gridCols = 3
    @State private var gridOpacity = 0.5
    @State private var showVideoPlayer = false
    @ObservedObject var unlockedManager = UnlockedManager.shared
    @State private var showUnlockAlert = false
    @State private var unlockMessage = ""
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Image Section with Lock/Unlock Logic
                    VStack {
                        Group {
                            if unlockedManager.isUnlocked(artwork) {
                                if let uiImage = UIImage(named: artwork.title) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFit()
                                } else {
                                    ZStack {
                                        Color.gray.opacity(0.2)
                                        VStack(spacing: 12) {
                                            Image(systemName: artwork.imageName)
                                                .font(.system(size: 50))
                                            Text("Image Missing")
                                                .font(.caption)
                                        }
                                        .foregroundColor(.gray.opacity(0.8))
                                    }
                                    .frame(height: 300)
                                }
                            } else {
                                // Locked Blur Preview
                                ZStack {
                                    if let uiImage = UIImage(named: artwork.title) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFit()
                                            .blur(radius: 20)
                                    } else {
                                        Color.gray.opacity(0.3)
                                    }
                                    
                                    VStack(spacing: 15) {
                                        Image(systemName: "lock.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.white)
                                        Text("Premium Content")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        
                                        Button(action: {
                                            if unlockedManager.unlock(artwork) {
                                                unlockMessage = "Successfully unlocked!"
                                            } else {
                                                unlockMessage = "Insufficient coins. Please visit the Store."
                                            }
                                            showUnlockAlert = true
                                        }) {
                                            HStack {
                                                Image(systemName: "bitcoinsign.circle.fill")
                                                Text("Unlock for \(artwork.coinCost) Coins")
                                            }
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 10)
                                            .background(Color.orange)
                                            .foregroundColor(.white)
                                            .cornerRadius(20)
                                        }
                                    }
                                }
                                .frame(height: 300)
                                .clipped()
                                .background(Color.black.opacity(0.1))
                            }
                        }
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                        .overlay(
                            Group {
                                if showGrid && unlockedManager.isUnlocked(artwork) {
                                    GridOverlayView(rows: gridRows, columns: gridCols, opacity: gridOpacity)
                                        .cornerRadius(16)
                                }
                            }
                        )
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // Titles and Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text(artwork.category.uppercased())
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                        
                        Text(artwork.title)
                            .font(.system(size: 28, weight: .heavy, design: .rounded))
                        
                        Text("Masterpiece by \(artwork.artist)")
                            .font(.title) 
                            .foregroundColor(.primary.opacity(0.8))
                        
                        Text(artwork.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal)
                    
                    // Grid Tool
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "square.grid.3x3.fill")
                                .foregroundColor(.blue)
                            Text("Grid Drawing Assistant")
                                .font(.headline)
                            Spacer()
                            Toggle("", isOn: $showGrid)
                                .labelsHidden()
                                .disabled(!unlockedManager.isUnlocked(artwork))
                        }
                        
                        if showGrid && unlockedManager.isUnlocked(artwork) {
                            Divider()
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Rows: \(gridRows)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Stepper("", value: $gridRows, in: 2...10)
                                        .labelsHidden()
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("Columns: \(gridCols)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Stepper("", value: $gridCols, in: 2...10)
                                        .labelsHidden()
                                }
                            }
                            
                            Divider()
                            HStack {
                                Text("Opacity")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Slider(value: $gridOpacity, in: 0.1...1.0)
                                    .frame(width: 150)
                            }
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    // Color Palette
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "paintpalette.fill")
                                .foregroundColor(.orange)
                            Text("Color Palette Analyzer")
                                .font(.headline)
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(artwork.colors, id: \.self) { hex in
                                    VStack {
                                        Circle()
                                            .fill(Color(hex: hex))
                                            .frame(width: 50, height: 50)
                                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                        Text(hex)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Video Button
                    if let videoURLStr = artwork.videoURL, let _ = resolveVideoURL(str: videoURLStr) {
                        Button(action: {
                            if unlockedManager.isUnlocked(artwork) {
                                showVideoPlayer = true
                            } else {
                                unlockMessage = "Please unlock this reference to watch the process video."
                                showUnlockAlert = true
                            }
                        }) {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                    .font(.title)
                                Text("Watch Painting Process")
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(16)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .navigationBarTitle(Text(""), displayMode: .inline)
        .alert(isPresented: $showUnlockAlert) {
            Alert(title: Text("Reference Shop"), message: Text(unlockMessage), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $showVideoPlayer) {
            if let videoURLStr = artwork.videoURL, let url = resolveVideoURL(str: videoURLStr) {
                VideoPlayerView(videoURL: url)
            }
        }
    }
    
    private func resolveVideoURL(str: String) -> URL? {
        if str.hasPrefix("http") {
            return URL(string: str)
        } else {
            let parts = str.components(separatedBy: ".")
            if parts.count > 1 {
                let ext = parts.last!
                let name = str.replacingOccurrences(of: "." + ext, with: "")
                return Bundle.main.url(forResource: name, withExtension: ext)
            }
            return nil
        }
    }
}

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
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue:  Double(b) / 255, opacity: Double(a) / 255)
    }
}
