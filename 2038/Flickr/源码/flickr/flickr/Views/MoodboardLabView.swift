import SwiftUI
import PhotosUI

@available(iOS 16.0, *)
struct MoodboardLabView: View {
    @StateObject var assetManager = AssetManager()
    @State private var selectedItems: [MoodboardItem] = []
    @State private var keywords: String = ""
    @State private var isSaving: Bool = false
    @State private var showStatusAlert: Bool = false
    @State private var statusMessage: String = ""
    @State private var isSuccess: Bool = false
    
    @State private var selectedPhotosPickerItems: [PhotosPickerItem] = []
    @Environment(\.dismiss) var dismiss
    @FocusState private var isInputActive: Bool
    
    struct MoodboardItem: Identifiable, Hashable {
        let id: UUID = UUID()
        var muse: MuseItem?
        var image: UIImage?
        
        static func == (lhs: MoodboardItem, rhs: MoodboardItem) -> Bool {
            lhs.id == rhs.id
        }
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { dismiss() }) {
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
            .overlay(
                Group {
                    if isSaving {
                        ProgressView()
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                }
            )
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) { // Tightened spacing
                    // VISION HEADER
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Define your aesthetic story. Layer your muses, capture your intent, and archive your creative evolution.")
                            .font(.system(size: 16, design: .serif))
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true) // Force wrapping
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal)
                    
                    if !selectedItems.isEmpty {
                        // Collage Display
                        VStack(alignment: .leading, spacing: 20) {
                            // The Moodboard Area (Strictly Capped Height)
                            VStack(spacing: 4) {
                                HStack(spacing: 4) {
                                    if selectedItems.indices.contains(0) {
                                        MoodboardElementView(item: selectedItems[0], height: 140)
                                    }
                                    if selectedItems.indices.contains(1) {
                                        MoodboardElementView(item: selectedItems[1], height: 140)
                                    }
                                }
                                HStack(spacing: 4) {
                                    if selectedItems.indices.contains(2) {
                                        MoodboardElementView(item: selectedItems[2], height: 100)
                                    }
                                    if selectedItems.indices.contains(3) {
                                        MoodboardElementView(item: selectedItems[3], height: 100)
                                    }
                                }
                            }
                            .frame(maxWidth: UIScreen.main.bounds.width - 32) // Prevent horizontal overflow
                            .frame(maxHeight: 280)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                            
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
                                if isSaving {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("EXPORT MOODBOARD")
                                        .font(.system(size: 14, weight: .bold))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .disabled(isSaving)
                            
                            Button(action: { selectedItems = [] }) {
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
                            Text("Select from archives or upload your own to begin deconstructing your current aesthetic mood.")
                                .font(.system(size: 15, design: .serif))
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            
                            // NEW: Custom Upload Button
                            PhotosPicker(selection: $selectedPhotosPickerItems, maxSelectionCount: 4 - selectedItems.count, matching: .images) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("IMPORT PERSONAL CAPTURES")
                                        .font(.system(size: 14, weight: .bold))
                                }
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 16).stroke(Color.black.opacity(0.1), style: StrokeStyle(lineWidth: 1, dash: [4])))
                            }
                            .padding(.horizontal)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                                ForEach(assetManager.muses) { muse in
                                    Button(action: {
                                        if selectedItems.count < 4 && !selectedItems.contains(where: { $0.muse?.id == muse.id }) {
                                            selectedItems.append(MoodboardItem(muse: muse))
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
                                                        .stroke(selectedItems.contains(where: { $0.muse?.id == muse.id }) ? Color.black : Color.clear, lineWidth: 3)
                                                )
                                            
                                            if selectedItems.contains(where: { $0.muse?.id == muse.id }) {
                                                Circle()
                                                    .fill(Color.black)
                                                    .frame(width: 24, height: 24)
                                                    .overlay(
                                                        Text("\(selectedItems.firstIndex(where: { $0.muse?.id == muse.id })! + 1)")
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
        .alert(statusMessage, isPresented: $showStatusAlert) {
            Button(isSuccess ? "Fabulous" : "Retry") {
                if isSuccess { dismiss() }
            }
        }
        .onChange(of: selectedPhotosPickerItems) { newItems in
            Task {
                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        if selectedItems.count < 4 {
                            selectedItems.append(MoodboardItem(image: uiImage))
                        }
                    }
                }
                selectedPhotosPickerItems = [] // Reset the picker selection
            }
        }
    }
    
    private func saveMoodboard() {
        isSaving = true
        
        // Render Collage Image
        let renderer = CollageRendererView(items: selectedItems, keywords: keywords)
        
        Task {
            let uiImage = await snapshotFor(renderer: renderer)
            
            // Save to Photo Library
            let saver = PhotoSaver()
            saver.writeToPhotoAlbum(image: uiImage) { error in
                DispatchQueue.main.async {
                    self.isSaving = false
                    if let error = error {
                        self.statusMessage = "Unable to process archive: \(error.localizedDescription)"
                        self.isSuccess = false
                    } else {
                        self.statusMessage = "Aesthetic Archive Success. Check your photo library."
                        self.isSuccess = true
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        
                        // Also local archive
                        let museSubset = selectedItems.compactMap { $0.muse }
                        let customSubset = selectedItems.compactMap { $0.image }
                        ArchiveManager.shared.saveArchive(muses: museSubset, keywords: keywords, customImages: customSubset)
                    }
                    self.showStatusAlert = true
                }
            }
        }
    }
    
    @MainActor
    private func snapshotFor(renderer: CollageRendererView) async -> UIImage {
        let renderer = ImageRenderer(content: renderer)
        renderer.scale = 2.0 // High res
        return renderer.uiImage ?? UIImage()
    }
}

// Subview to handle both Muse and Custom Images
@available(iOS 16.0, *)
struct MoodboardElementView: View {
    let item: MoodboardLabView.MoodboardItem
    let height: CGFloat
    
    var body: some View {
        Group {
            if let muse = item.muse {
                Image(muse.imageName)
                    .resizable()
                    .scaledToFill()
            } else if let custom = item.image {
                Image(uiImage: custom)
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height > 0 ? height : nil) // Prioritize fixed height if provided
        .aspectRatio(height > 0 ? nil : 1.0, contentMode: .fit) // Only use aspect ratio if height is fluid
        .clipped()
    }
}

// HIGH-RES COLLAGE RENDERER
@available(iOS 16.0, *)
struct CollageRendererView: View {
    let items: [MoodboardLabView.MoodboardItem]
    let keywords: String
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    if items.indices.contains(0) {
                        rendererElement(item: items[0], size: CGSize(width: 400, height: 400))
                    }
                    if items.indices.contains(1) {
                        rendererElement(item: items[1], size: CGSize(width: 400, height: 400))
                    }
                }
                HStack(spacing: 4) {
                    if items.indices.contains(2) {
                        rendererElement(item: items[2], size: CGSize(width: 400, height: 300))
                    }
                    if items.indices.contains(3) {
                        rendererElement(item: items[3], size: CGSize(width: 400, height: 300))
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
    
    @ViewBuilder
    func rendererElement(item: MoodboardLabView.MoodboardItem, size: CGSize) -> some View {
        if let muse = item.muse {
            Image(muse.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: size.width, height: size.height)
                .clipped()
        } else if let custom = item.image {
            Image(uiImage: custom)
                .resizable()
                .scaledToFill()
                .frame(width: size.width, height: size.height)
                .clipped()
        }
    }
}

@available(iOS 16.0, *)
struct MoodboardLabView_Previews: PreviewProvider {
    static var previews: some View {
        MoodboardLabView()
    }
}
