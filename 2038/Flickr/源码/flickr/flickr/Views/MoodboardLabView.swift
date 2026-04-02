import SwiftUI

@available(iOS 15.0, *)
struct MoodboardLabView: View {
    @StateObject var assetManager = AssetManager()
    @State private var selectedMuses: [MuseItem] = []
    @State private var keywords: String = ""
    @State private var isExported: Bool = false
    @Environment(\.presentationMode) var presentationMode
    @FocusState private var isInputActive: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                        .padding(12)
                        .background(Circle().fill(Color(.systemGray6)))
                }
                Spacer()
                Text("Moodboard Laboratory")
                    .font(.system(size: 18, weight: .bold, design: .serif))
                Spacer()
                // Invisible spacer for balance
                Circle().fill(Color.clear).frame(width: 44)
            }
            .padding()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    // VISION HEADER
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Define your aesthetic story. Layer your muses, capture your intent, and archive your creative evolution.")
                            .font(.system(size: 16, design: .serif))
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal)
                    
                    if !selectedMuses.isEmpty {
                        // Collage Display
                        VStack(alignment: .leading, spacing: 20) {
                            // The Moodboard Area
                            VStack(spacing: 4) {
                                HStack(spacing: 4) {
                                    if selectedMuses.indices.contains(0) {
                                        Image(selectedMuses[0].imageName)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 200)
                                            .clipped()
                                    }
                                    if selectedMuses.indices.contains(1) {
                                        Image(selectedMuses[1].imageName)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 200)
                                            .clipped()
                                    }
                                }
                                HStack(spacing: 4) {
                                    if selectedMuses.indices.contains(2) {
                                        Image(selectedMuses[2].imageName)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 150)
                                            .clipped()
                                    }
                                    if selectedMuses.indices.contains(3) {
                                        Image(selectedMuses[3].imageName)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 150)
                                            .clipped()
                                    }
                                }
                            }
                            .cornerRadius(20)
                            .shadow(radius: 10)
                            
                            // Keywords Input
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Aesthetic Intent")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.secondary)
                                
                                TextField("Enter vibes (e.g. Dreamy, Minimal, Noir)", text: $keywords)
                                    .padding()
                                    .background(Color(.systemGray6).opacity(0.4))
                                    .cornerRadius(12)
                                    .focused($isInputActive)
                            }
                            
                            Button(action: saveMoodboard) {
                                Text("EXPORT MOODBOARD")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.black)
                                    .cornerRadius(12)
                            }
                            
                            if isExported {
                                Text("Aesthetic Archive Created")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                    .padding(.top, 4)
                                    .frame(maxWidth: .infinity)
                            }
                            
                            Button(action: { selectedMuses = [] }) {
                                Text("RE-START ARCHIVE")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal)
                        
                    } else {
                        // Selection Section
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Select up to 4 muses to begin deconstructing your current aesthetic mood.")
                                .font(.system(size: 16, design: .serif))
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                                ForEach(assetManager.muses) { muse in
                                    Button(action: {
                                        if selectedMuses.count < 4 && !selectedMuses.contains(where: { $0.id == muse.id }) {
                                            selectedMuses.append(muse)
                                        }
                                    }) {
                                        ZStack(alignment: .bottomLeading) {
                                            Image(muse.imageName)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: (UIScreen.main.bounds.width - 60) / 2, height: 160)
                                                .clipped()
                                                .cornerRadius(16)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .stroke(selectedMuses.contains(where: { $0.id == muse.id }) ? Color.black : Color.clear, lineWidth: 3)
                                                )
                                            
                                            if selectedMuses.contains(where: { $0.id == muse.id }) {
                                                Circle()
                                                    .fill(Color.black)
                                                    .frame(width: 24, height: 24)
                                                    .overlay(
                                                        Text("\(selectedMuses.firstIndex(where: { $0.id == muse.id })! + 1)")
                                                            .font(.caption)
                                                            .foregroundColor(.white)
                                                    )
                                                    .padding(8)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.vertical)
            }
            .onTapGesture {
                isInputActive = false
            }
        }
        .navigationBarHidden(true)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isInputActive = false
                }
            }
        }
    }
    
    private func saveMoodboard() {
        // Render Collage Image
        let renderer = CollageRendererView(muses: selectedMuses, keywords: keywords)
        let image = renderer.snapshot()
        
        // Save to Photo Library
        let saver = PhotoSaver()
        saver.writeToPhotoAlbum(image: image)
        
        // Save to Local Archive Manager
        ArchiveManager.shared.saveArchive(muses: selectedMuses, keywords: keywords)
        
        withAnimation {
            isExported = true
        }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            presentationMode.wrappedValue.dismiss()
        }
    }
}

// HIGH-RES COLLAGE RENDERER
struct CollageRendererView: View {
    let muses: [MuseItem]
    let keywords: String
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    if muses.indices.contains(0) {
                        Image(muses[0].imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 400, height: 400)
                            .clipped()
                    }
                    if muses.indices.contains(1) {
                        Image(muses[1].imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 400, height: 400)
                            .clipped()
                    }
                }
                HStack(spacing: 4) {
                    if muses.indices.contains(2) {
                        Image(muses[2].imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 400, height: 300)
                            .clipped()
                    }
                    if muses.indices.contains(3) {
                        Image(muses[3].imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 400, height: 300)
                            .clipped()
                    }
                }
            }
            .frame(width: 800)
            
            if !keywords.isEmpty {
                Text(keywords.uppercased())
                    .font(.system(size: 24, weight: .black, design: .serif))
                    .tracking(8)
                    .foregroundColor(.black)
                    .padding(.vertical, 40)
                    .frame(width: 800)
                    .background(Color.white)
            }
        }
        .frame(width: 800)
        .background(Color.white)
    }
    
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        let targetSize = CGSize(width: 800, height: keywords.isEmpty ? 704 : 800)
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .white

        let renderer = UIGraphicsImageRenderer(size: targetSize)

        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

@available(iOS 15.0, *)
struct MoodboardLabView_Previews: PreviewProvider {
    static var previews: some View {
        MoodboardLabView()
    }
}
