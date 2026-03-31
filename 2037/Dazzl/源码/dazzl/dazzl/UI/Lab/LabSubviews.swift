import SwiftUI

// MARK: - Palette Library
@available(iOS 14.0, *)
struct PaletteLibraryView: View {
    @State private var showCopiedAlert = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Palette Library")
                        .font(.largeTitle).bold()
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    ForEach(LabDataStore.palettes) { item in
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(item.name)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                                Text(item.vibe)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            HStack(spacing: 0) {
                                ForEach(item.colors, id: \.self) { hex in
                                    Rectangle()
                                        .fill(Color(hex: hex))
                                        .frame(height: 60)
                                        .overlay(
                                            Text(hex)
                                                .font(.system(size: 10, design: .monospaced))
                                                .foregroundColor(.white)
                                                .shadow(radius: 2)
                                        )
                                }
                            }
                            .cornerRadius(12)
                            .onTapGesture {
                                UIPasteboard.general.string = item.colors.joined(separator: ", ")
                                showCopiedAlert = true
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }
        }
        .navigationTitle("Palettes")
        .alert(isPresented: $showCopiedAlert) {
            Alert(title: Text("Copied Palette"), message: Text("The full palette has been copied to your clipboard."), dismissButton: .default(Text("OK")))
        }
    }
}

// MARK: - Lighting Blueprints
@available(iOS 14.0, *)
struct LightingBlueprintView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Lighting Blueprints")
                        .font(.largeTitle).bold()
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    ForEach(LabDataStore.lightings) { blueprint in
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.yellow)
                                Text(blueprint.title)
                                    .font(.title2).bold()
                                    .foregroundColor(.white)
                            }
                            
                            Text(blueprint.setup)
                                .font(.headline)
                                .foregroundColor(.blue)
                            
                            Text(blueprint.tip)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .lineSpacing(4)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }
        }
    }
}

// MARK: - Pose Geometry
@available(iOS 15.0, *)
struct PoseGeometryView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Pose Geometry")
                        .font(.largeTitle).bold()
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    ForEach(LabDataStore.poses) { pose in
                        VStack(alignment: .leading, spacing: 15) {
                            AsyncImage(url: URL(string: pose.imageUrl)) { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Color.white.opacity(0.1)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 250)
                            .cornerRadius(12)
                            .overlay(
                                // Simulated line art overlay
                                Color.blue.opacity(0.1)
                            )
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text(pose.title)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text(pose.description)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }
        }
    }
}
