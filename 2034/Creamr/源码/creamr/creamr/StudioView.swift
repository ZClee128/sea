import SwiftUI
import PhotosUI
import CoreImage
import CoreImage.CIFilterBuiltins

// MARK: - Filter Preset
struct ArtFilter: Identifiable {
    let id = UUID()
    let name: String
    let subtitle: String
    let icon: String
    let gradient: [Color]
    let premiumPackId: String? // If nil, the filter is free
    let apply: (CIImage) -> CIImage?
}

// MARK: - Filter Definitions (CoreImage)
let artFilters: [ArtFilter] = [
    ArtFilter(name: "Original",  subtitle: "No filter",      icon: "photo",
              gradient: [.gray.opacity(0.4), .gray.opacity(0.2)], premiumPackId: nil) { img in img },

    ArtFilter(name: "Noir",      subtitle: "Dramatic B&W",   icon: "moon.fill",
              gradient: [Color(red:0.1,green:0.1,blue:0.1), Color(red:0.4,green:0.4,blue:0.4)], premiumPackId: nil) { img in
        let f = CIFilter.photoEffectNoir(); f.inputImage = img; return f.outputImage },

    ArtFilter(name: "Vintage",   subtitle: "Film photo",     icon: "camera.aperture",
              gradient: [Color(red:0.6,green:0.4,blue:0.1), Color(red:0.9,green:0.7,blue:0.3)], premiumPackId: nil) { img in
        let f = CIFilter.photoEffectProcess(); f.inputImage = img; return f.outputImage },

    ArtFilter(name: "Fade",      subtitle: "Matte look",     icon: "sun.haze.fill",
              gradient: [Color(red:0.8,green:0.6,blue:0.5), Color(red:0.9,green:0.8,blue:0.7)], premiumPackId: nil) { img in
        let f = CIFilter.photoEffectFade(); f.inputImage = img; return f.outputImage },

    ArtFilter(name: "Transfer",  subtitle: "Warm tones",     icon: "flame.fill",
              gradient: [Color(red:0.8,green:0.3,blue:0.0), Color(red:0.9,green:0.6,blue:0.2)], premiumPackId: nil) { img in
        let f = CIFilter.photoEffectTransfer(); f.inputImage = img; return f.outputImage },

    ArtFilter(name: "Chrome",    subtitle: "High contrast",  icon: "sparkles",
              gradient: [Color(red:0.1,green:0.3,blue:0.6), Color(red:0.4,green:0.7,blue:0.9)], premiumPackId: nil) { img in
        let f = CIFilter.photoEffectChrome(); f.inputImage = img; return f.outputImage },

    ArtFilter(name: "Vivid",     subtitle: "Punchy colors",  icon: "paintpalette.fill",
              gradient: [Color(red:0.8,green:0.1,blue:0.5), Color(red:0.9,green:0.5,blue:0.1)], premiumPackId: "pack_ethereal") { img in
        let f = CIFilter.vibrance(); f.inputImage = img; f.amount = 2.0; return f.outputImage },

    ArtFilter(name: "Bloom",     subtitle: "Dream glow",     icon: "staroflife.fill",
              gradient: [Color(red:0.6,green:0.2,blue:0.8), Color(red:0.9,green:0.4,blue:0.7)], premiumPackId: "pack_ethereal") { img in
        let f = CIFilter.bloom(); f.inputImage = img; f.intensity = 1.0; f.radius = 10; return f.outputImage },

    ArtFilter(name: "Pixellate", subtitle: "Mosaic art",     icon: "squareshape.split.2x2",
              gradient: [Color(red:0.1,green:0.5,blue:0.3), Color(red:0.3,green:0.8,blue:0.5)], premiumPackId: "pack_neon") { img in
        let f = CIFilter.pixellate(); f.inputImage = img; f.scale = 12; return f.outputImage },

    ArtFilter(name: "Crystallize", subtitle: "Crystal shards", icon: "diamond.fill",
              gradient: [Color(red:0.0,green:0.4,blue:0.8), Color(red:0.3,green:0.7,blue:1.0)], premiumPackId: "pack_classic") { img in
        let f = CIFilter.crystallize(); f.inputImage = img; f.radius = 18; return f.outputImage },

    ArtFilter(name: "Edges",     subtitle: "Sketch lines",   icon: "pencil.line",
              gradient: [Color(red:0.2,green:0.2,blue:0.2), Color(red:0.6,green:0.6,blue:0.6)], premiumPackId: "pack_neon") { img in
        let f = CIFilter.edges(); f.inputImage = img; f.intensity = 5; return f.outputImage },

    ArtFilter(name: "Thermal",   subtitle: "Heat vision",    icon: "thermometer.sun.fill",
              gradient: [Color(red:0.8,green:0.0,blue:0.0), Color(red:0.0,green:0.8,blue:0.8)], premiumPackId: "pack_neon") { img in
        let f = CIFilter.thermal(); f.inputImage = img; return f.outputImage }
]

// MARK: - PHPicker Wrapper
@available(iOS 14, *)
struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        let vc = PHPickerViewController(configuration: config)
        vc.delegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker
        init(_ p: PhotoPicker) { parent = p }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
            provider.loadObject(ofClass: UIImage.self) { object, _ in
                DispatchQueue.main.async {
                    self.parent.selectedImage = object as? UIImage
                }
            }
        }
    }
}

// MARK: - CoreImage Processing
let ciContext = CIContext()

func applyFilter(_ filter: ArtFilter, to image: UIImage) -> UIImage {
    guard let cgInput = image.cgImage else { return image }
    let ciInput = CIImage(cgImage: cgInput)
    guard let ciOutput = filter.apply(ciInput),
          let cgOutput = ciContext.createCGImage(ciOutput, from: ciOutput.extent) else { return image }
    return UIImage(cgImage: cgOutput, scale: image.scale, orientation: image.imageOrientation)
}

// MARK: - Studio View
@available(iOS 15.0, *)
struct StudioView: View {
    @State private var selectedImage: UIImage? = nil
    @State private var showPicker = false
    @State private var selectedFilter: ArtFilter = artFilters[0]
    @State private var processedImage: UIImage? = nil
    @State private var isProcessing = false
    @State private var saveStatus: String? = nil
    @State private var showSaveAlert = false
    @State private var showCoinShop = false
    @ObservedObject private var coinStore = CoinStore.shared

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {

                    // ── Canvas ─────────────────────────────────────
                    ZStack {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color(.systemGray6))
                            .frame(height: 300)

                        if let img = processedImage ?? selectedImage {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 300)
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                .transition(.opacity)
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.system(size: 52))
                                    .foregroundColor(.secondary)
                                Text("Tap below to select a photo")
                                    .font(.subheadline).foregroundColor(.secondary)
                            }
                        }

                        if isProcessing {
                            ZStack {
                                Color.black.opacity(0.35)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                ProgressView().tint(.white)
                            }
                        }
                    }
                    .frame(height: 300)
                    .animation(.easeInOut(duration: 0.25), value: processedImage)

                    // ── Action Buttons ─────────────────────────────
                    HStack(spacing: 12) {
                        Button(action: { showPicker = true }) {
                            if #available(iOS 16.0, *) {
                                Label("Choose Photo", systemImage: "photo.badge.plus")
                                    .font(.subheadline).fontWeight(.semibold)
                                    .frame(maxWidth: .infinity).padding(.vertical, 12)
                                    .background(Color.purple)
                                    .foregroundColor(.white)
                                    .cornerRadius(14)
                            } else {
                                // Fallback on earlier versions
                            }
                        }

                        if selectedImage != nil {
                            Button(action: saveToAlbum) {
                                if #available(iOS 16.0, *) {
                                    Label("Save", systemImage: "arrow.down.circle.fill")
                                        .font(.subheadline).fontWeight(.semibold)
                                        .frame(maxWidth: .infinity).padding(.vertical, 12)
                                        .background(Color(.systemGray5))
                                        .foregroundColor(.primary)
                                        .cornerRadius(14)
                                } else {
                                    // Fallback on earlier versions
                                }
                            }
                        }
                    }

                    // ── Filter Grid ────────────────────────────────
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Art Style Filters")
                            .font(.headline).fontWeight(.bold)

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 12) {
                            ForEach(artFilters) { filter in
                                FilterChip(
                                    filter: filter,
                                    isSelected: selectedFilter.id == filter.id,
                                    isUnlocked: filter.premiumPackId == nil || coinStore.isPackUnlocked(filter.premiumPackId!)
                                ) {
                                    handleFilterTap(filter)
                                }
                            }
                        }
                    }

                    // ── Premium Packs ──────────────────────────────
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("✨ Premium Packs")
                                .font(.headline).fontWeight(.bold)
                            Spacer()
                            Button("Get Coins 🪙") { showCoinShop = true }
                                .font(.caption).foregroundColor(.purple)
                        }

                        ForEach(premiumFilterPacks) { pack in
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(LinearGradient(colors: pack.gradient,
                                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(width: 42, height: 42)
                                    Image(systemName: pack.icon).font(.headline).foregroundColor(.white)
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(pack.name).font(.subheadline).fontWeight(.semibold)
                                    Text(pack.filterNames.joined(separator: " · "))
                                        .font(.caption2).foregroundColor(.secondary)
                                }
                                Spacer()
                                if coinStore.isPackUnlocked(pack.id) {
                                    Image(systemName: "checkmark.seal.fill")
                                        .font(.caption).foregroundColor(.green)
                                } else {
                                    Button(action: { showCoinShop = true }) {
                                        HStack(spacing: 3) {
                                            Image(systemName: "dollarsign.circle.fill").font(.caption2)
                                            Text("\(pack.cost)").font(.caption).fontWeight(.bold)
                                        }
                                        .padding(.horizontal, 10).padding(.vertical, 6)
                                        .background(Color(.systemGray5))
                                        .cornerRadius(16)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(12)
                            .background(Color(.systemBackground))
                            .cornerRadius(14)
                            .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
                        }
                    }

                    Spacer(minLength: 30)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
            .navigationTitle("Art Studio")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showPicker) {
                PhotoPicker(selectedImage: $selectedImage)
                    .onDisappear { applySelectedFilter() }
            }
            .sheet(isPresented: $showCoinShop) {
                NavigationView {
                    CoinShopView()
                }
            }
            .alert("Saved!", isPresented: $showSaveAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(saveStatus ?? "Image saved to your photo library.")
            }
        }
    }

    private func handleFilterTap(_ filter: ArtFilter) {
        if let packId = filter.premiumPackId, !coinStore.isPackUnlocked(packId) {
            showCoinShop = true
        } else {
            selectedFilter = filter
            applySelectedFilter()
        }
    }
    private func applySelectedFilter() {
        guard let image = selectedImage else { return }
        guard selectedFilter.name != "Original" else {
            processedImage = image; return
        }
        isProcessing = true
        DispatchQueue.global(qos: .userInitiated).async {
            let result = applyFilter(selectedFilter, to: image)
            DispatchQueue.main.async {
                withAnimation { processedImage = result }
                isProcessing = false
            }
        }
    }

    private func saveToAlbum() {
        let imageToSave = processedImage ?? selectedImage
        guard let img = imageToSave else { return }
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            DispatchQueue.main.async {
                if status == .authorized || status == .limited {
                    UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
                    saveStatus = "Your styled artwork has been saved to Photos."
                } else {
                    saveStatus = "Please allow photo library access in Settings."
                }
                showSaveAlert = true
            }
        }
    }
}

// MARK: - Filter Chip
@available(iOS 15.0, *)
struct FilterChip: View {
    let filter: ArtFilter
    let isSelected: Bool
    let isUnlocked: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(LinearGradient(colors: filter.gradient,
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 52, height: 52)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(Color.white, lineWidth: isSelected ? 2.5 : 0)
                        )
                        .shadow(color: isSelected ? filter.gradient[0].opacity(0.5) : .clear,
                                radius: 8, x: 0, y: 3)

                    Image(systemName: filter.icon)
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                    
                    if !isUnlocked {
                        ZStack {
                            Color.black.opacity(0.4)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            Image(systemName: "lock.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                        }
                    }
                }

                Text(filter.name)
                    .font(.caption2).fontWeight(isSelected ? .bold : .regular)
                    .foregroundColor(isSelected ? .primary : (isUnlocked ? .secondary : .secondary.opacity(0.5)))
                    .lineLimit(1)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.06 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}
