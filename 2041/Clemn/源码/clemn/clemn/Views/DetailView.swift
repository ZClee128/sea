import SwiftUI

@available(iOS 14.0, *)
struct DetailView: View {
    let reference: PortraitReference
    @State private var showGrid = false
    @State private var showLighting = false
    @State private var isUnlocked = false
    @ObservedObject var iapManager = IAPManager.shared
    @State private var showingAlert = false
    @State private var showingBlueprint = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ZStack {
                    Image(reference.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(16)
                        .overlay(
                            Group {
                                if showGrid {
                                    CompositionOverlay()
                                }
                            }
                        )
                    
                    if showLighting {
                        LightingMapOverlay(type: reference.lighting)
                            .transition(.opacity)
                    }
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text(reference.title)
                        .font(.title)
                        .bold()
                    
                    Text(reference.lighting)
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    Divider()
                    
                    // Technical Specs Section
                    Text("Technical Specs")
                        .font(.headline)
                    
                    VStack(spacing: 10) {
                        SpecRow(label: "Camera", value: reference.camera)
                        SpecRow(label: "Lens", value: reference.lens)
                        HStack(spacing: 20) {
                            SpecRow(label: "Aperture", value: reference.aperture)
                            SpecRow(label: "Shutter", value: reference.shutter)
                            SpecRow(label: "ISO", value: reference.iso)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Color Palette Section
                    Text("Color Palette")
                        .font(.headline)
                    
                    HStack(spacing: 10) {
                        ForEach(reference.palette, id: \.self) { colorHex in
                            VStack(spacing: 5) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(hex: colorHex))
                                    .frame(height: 40)
                                
                                Text(colorHex)
                                    .font(.system(size: 8, design: .monospaced))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Divider()
                        .padding(.vertical, 10)
                    
                    // Studio Blueprint (Locked Feature)
                    Text("Studio Blueprint")
                        .font(.headline)
                    
                    if iapManager.unlockedIDs.contains(reference.imageName) {
                        VStack(spacing: 15) {
                            Image(systemName: "square.and.pencil")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                                .padding(.top)
                            
                            Text("Technical Blueprint Unlocked")
                                .font(.caption)
                                .bold()
                            
                            Button(action: { showingBlueprint = true }) {
                                Text("View Full Blueprint Diagram")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 20)
                        .background(Color.blue.opacity(0.05))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                        )
                        .sheet(isPresented: $showingBlueprint) {
                            LightingBlueprintView(lightingType: reference.lighting)
                        }
                    } else {
                        Button(action: {
                            if iapManager.coins >= 10 {
                                if iapManager.consume(amount: 10) {
                                    iapManager.unlockID(reference.imageName)
                                }
                            } else {
                                showingAlert = true
                            }
                        }) {
                            VStack(spacing: 12) {
                                Image(systemName: "lock.fill")
                                    .font(.title)
                                    .foregroundColor(.gray)
                                
                                Text("Unlock Technical Blueprint")
                                    .font(.headline)
                                
                                HStack(spacing: 4) {
                                    Image(systemName: "m.circle.fill")
                                        .foregroundColor(.orange)
                                    Text("10 Coins")
                                        .font(.caption)
                                        .bold()
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 30)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                    
                    Divider()
                        .padding(.vertical, 10)
                    
                    Text("Case Analysis")
                        .font(.headline)
                    
                    Text("This reference case demonstrates the technical application of \(reference.lighting.lowercased()). The \(reference.lens) allows for precise focus control, while the \(reference.aperture) aperture ensures the correct depth of field for professional portraiture.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                HStack(spacing: 20) {
                    ControlButton(icon: "grid", text: "Grid", isActive: showGrid) {
                        withAnimation { showGrid.toggle() }
                    }
                    
                    ControlButton(icon: "lightbulb", text: "Lights", isActive: showLighting) {
                        withAnimation { showLighting.toggle() }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

@available(iOS 14.0, *)
struct ControlButton: View {
    let icon: String
    let text: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.title2)
                Text(text)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isActive ? Color.blue : Color.gray.opacity(0.1))
            .foregroundColor(isActive ? .white : .primary)
            .cornerRadius(12)
        }
    }
}

struct SpecRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.caption)
                .bold()
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

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct CompositionOverlay: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Rule of Thirds
                Path { path in
                    let w = geo.size.width
                    let h = geo.size.height
                    
                    path.move(to: CGPoint(x: w / 3, y: 0))
                    path.addLine(to: CGPoint(x: w / 3, y: h))
                    
                    path.move(to: CGPoint(x: 2 * w / 3, y: 0))
                    path.addLine(to: CGPoint(x: 2 * w / 3, y: h))
                    
                    path.move(to: CGPoint(x: 0, y: h / 3))
                    path.addLine(to: CGPoint(x: w, y: h / 3))
                    
                    path.move(to: CGPoint(x: 0, y: 2 * h / 3))
                    path.addLine(to: CGPoint(x: w, y: 2 * h / 3))
                }
                .stroke(Color.white.opacity(0.6), lineWidth: 1)
            }
        }
    }
}

struct LightingMapOverlay: View {
    let type: String
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack(alignment: .center, spacing: 10) {
                    Text("Lighting Setup")
                        .font(.caption)
                        .bold()
                    
                    // Simple schematic representation
                    ZStack {
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                            .frame(width: 40, height: 40)
                            .overlay(Text("MOD").font(.system(size: 8)))
                        
                        // Main Light (Key)
                        Image(systemName: "sun.max.fill")
                            .foregroundColor(.yellow)
                            .offset(x: 40, y: -40)
                        
                        // Fill Light (if applicable)
                        Image(systemName: "sun.max")
                            .foregroundColor(.white)
                            .offset(x: -40, y: 0)
                            .opacity(0.5)
                    }
                    .frame(width: 120, height: 120)
                    
                    Text(type)
                        .font(.system(size: 10))
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color.black.opacity(0.7))
                .foregroundColor(.white)
                .cornerRadius(16)
                .padding()
            }
        }
    }
}
