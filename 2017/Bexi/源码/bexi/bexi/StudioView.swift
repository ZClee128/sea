import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

@available(iOS 14.0, *)
struct StudioView: View {
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var showingFilterEditor = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Bexi Studio")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Transform your photos into stunning art pieces with our professional-grade filters.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                Spacer()
                
                Button(action: {
                    showingImagePicker = true
                }) {
                    HStack {
                        Image(systemName: "photo.on.rectangle")
                        Text("Select Photo")
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingImagePicker) {
                PhotoPicker(selectedImage: $inputImage)
            }
            .onChange(of: inputImage) { newImage in
                if newImage != nil {
                    // Give the sheet a moment to dismiss before pushing the new view
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showingFilterEditor = true
                    }
                }
            }
            .background(
                NavigationLink(
                    destination: Group {
                        if let image = inputImage {
                            FilterEditorView(image: image, onDismiss: {
                                inputImage = nil
                            })
                        }
                    },
                    isActive: $showingFilterEditor,
                    label: { EmptyView() }
                )
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

@available(iOS 14.0, *)
struct FilterItem: Identifiable {
    let id = UUID()
    let name: String
    let filter: CIFilter
}

@available(iOS 14.0, *)
struct FilterEditorView: View {
    let image: UIImage
    var onDismiss: () -> Void
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var storageManager: StorageManager
    @State private var outputImage: UIImage?
    @State private var selectedFilterId: UUID?
    @State private var isSaving = false
    @State private var showSaveSuccess = false
    @State private var showingCoinAlert = false
    @State private var isApplyingFilter = false
    
    let cost = 5
    
    let context = CIContext()
    
    let filters: [FilterItem] = [
        FilterItem(name: "Original", filter: CIFilter()), // Dummy
        FilterItem(name: "Sepia", filter: CIFilter.sepiaTone()),
        FilterItem(name: "Noir", filter: CIFilter.photoEffectNoir()),
        FilterItem(name: "Vintage", filter: CIFilter.photoEffectProcess()),
        FilterItem(name: "Chrome", filter: CIFilter.photoEffectChrome()),
        FilterItem(name: "Fade", filter: CIFilter.photoEffectFade()),
        FilterItem(name: "Tonal", filter: CIFilter.photoEffectTonal()),
        FilterItem(name: "Invert", filter: CIFilter.colorInvert()),
        FilterItem(name: "Mono", filter: CIFilter.photoEffectMono())
    ]
    
    var body: some View {
        VStack {
            Spacer()
            
            // Image Preview
            ZStack {
                if let outImage = outputImage {
                    Image(uiImage: outImage)
                        .resizable()
                        .scaledToFit()
                        .padding()
                } else {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .padding()
                }
                
                if isApplyingFilter {
                    ProgressView("Applying Filter...")
                        .padding()
                        .background(Color(.systemBackground).opacity(0.8))
                        .cornerRadius(10)
                }
            }
            
            Spacer()
            
            // Filter Selection
            VStack(alignment: .leading) {
                Text("Filters")
                    .font(.headline)
                    .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(filters) { filterItem in
                            VStack {
                                ZStack {
                                    Circle()
                                        .fill(selectedFilterId == filterItem.id ? Color.blue : Color.gray.opacity(0.3))
                                        .frame(width: 60, height: 60)
                                    
                                    if filterItem.name == "Original" {
                                        Image(systemName: "photo")
                                            .foregroundColor(selectedFilterId == filterItem.id ? .white : .primary)
                                    } else {
                                        Image(systemName: "camera.filters")
                                            .foregroundColor(selectedFilterId == filterItem.id ? .white : .primary)
                                    }
                                }
                                
                                Text(filterItem.name)
                                    .font(.caption)
                                    .foregroundColor(selectedFilterId == filterItem.id ? .blue : .primary)
                            }
                            .onTapGesture {
                                selectedFilterId = filterItem.id
                                applyFilter(filterItem)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .disabled(isApplyingFilter)
            }
            .padding(.bottom, 20)
            
            // Save Button
            Button(action: saveImage) {
                if isSaving {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Save to Photos (\(cost) Coins)")
                        .fontWeight(.bold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.bottom, 20)
            .disabled(isSaving)
        }
        .navigationBarTitle("Studio Editor", displayMode: .inline)
        .alert(isPresented: Binding<Bool>(
            get: { showSaveSuccess || showingCoinAlert },
            set: { _ in
                showSaveSuccess = false
                showingCoinAlert = false
            }
        )) {
            if showSaveSuccess {
                return Alert(
                    title: Text("Saved!"),
                    message: Text("Your magnificent creation has been saved to your photo library."),
                    dismissButton: .default(Text("OK")) {
                        presentationMode.wrappedValue.dismiss()
                        onDismiss()
                    }
                )
            } else {
                return Alert(
                    title: Text("Not Enough Coins"),
                    message: Text("Saving this filter costs \(cost) coins. Please recharge your coins in the Profile tab."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .onAppear {
            selectedFilterId = filters.first?.id
            outputImage = image
        }
    }
    
    func applyFilter(_ filterItem: FilterItem) {
        if filterItem.name == "Original" {
            outputImage = image
            return
        }
        
        isApplyingFilter = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let ciImage = CIImage(image: self.image)
            filterItem.filter.setValue(ciImage, forKey: kCIInputImageKey)
            
            if let outputCIImage = filterItem.filter.outputImage,
               let cgImage = self.context.createCGImage(outputCIImage, from: outputCIImage.extent) {
                
                let processedImage = UIImage(cgImage: cgImage, scale: self.image.scale, orientation: self.image.imageOrientation)
                
                DispatchQueue.main.async {
                    self.outputImage = processedImage
                    self.isApplyingFilter = false
                }
            } else {
                DispatchQueue.main.async {
                    self.isApplyingFilter = false
                }
            }
        }
    }
    
    func saveImage() {
        guard let _ = outputImage else { return }
        
        if storageManager.coins < cost {
            showingCoinAlert = true
            return
        }
        
        guard let imageToSave = outputImage else { return }
        
        isSaving = true
        
        // Save to Photo Library
        UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil)
        
        // Also save to app's mock library to reflect usage & utility
        storageManager.saveUserImage(image: imageToSave) { _ in
            DispatchQueue.main.async {
                self.storageManager.coins -= self.cost
                self.isSaving = false
                self.showSaveSuccess = true
            }
        }
    }
}

#Preview {
    if #available(iOS 14.0, *) {
        StudioView()
            .environmentObject(StorageManager())
    } else {
        // Fallback
    }
}
