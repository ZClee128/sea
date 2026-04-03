import SwiftUI
import PhotosUI
import Combine

@available(iOS 16.0, *)
struct AestheticScannerView: View {
    @ObservedObject var scannerManager = ScannerManager.shared
    @ObservedObject var personaManager = PersonaManager.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var showResults = false
    @State private var showingInfo = false
    @State private var gridOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 24) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Circle().fill(Color.white.opacity(0.1)))
                    }
                    .contentShape(Circle())
                    Spacer()
                    Text("Optical Analysis Lab")
                        .font(.system(size: 18, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                    Spacer()
                    // Help Icon
                    Button(action: { showingInfo = true }) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                .padding(.horizontal)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        if let image = selectedImage {
                            scanningArea(image: image)
                        } else {
                            uploadArea
                        }
                        
                        if showResults {
                            resultsSection
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .padding(.bottom, 20)
                }
                
                if selectedImage != nil && !scannerManager.isScanning {
                    Button(action: reset) {
                        Text("Reset Scanner")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white.opacity(0.5))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .contentShape(Rectangle())
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationBarHidden(true)
        .alert(isPresented: $showingInfo) {
            Alert(
                title: Text("Optical Scan Logic"),
                message: Text("Our algorithm deconstructs the pixel-level data of your photo to extract its underlying 'Color DNA'. It then calculates the structural resonance between these data points and your current Aesthetic Persona using deterministic optical distance metrics."),
                dismissButton: .default(Text("Understood"))
            )
        }
        .onChange(of: selectedItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    selectedImage = uiImage
                    startScan(image: uiImage)
                }
            }
        }
    }
    
    var uploadArea: some View {
        VStack(spacing: 20) {
            PhotosPicker(selection: $selectedItem, matching: .images) {
                VStack(spacing: 16) {
                    Image(systemName: "photo.stack")
                        .font(.system(size: 60))
                        .foregroundColor(.white.opacity(0.2))
                    
                    Text("Import Photo for Deconstruction")
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                    
                    Text("Analyze your personal captures through the lens of your \(personaManager.currentPersona.rawValue) persona.")
                        .font(.system(size: 14, design: .serif))
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Text("SELECT FROM LIBRARY")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 14)
                        .background(Color.white)
                        .cornerRadius(12)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 80)
                .background(RoundedRectangle(cornerRadius: 30).stroke(Color.white.opacity(0.1), style: StrokeStyle(lineWidth: 2, dash: [8])))
            }
            .padding(.horizontal)
        }
    }
    
    func scanningArea(image: UIImage) -> some View {
        ZStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 400)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            
            if scannerManager.isScanning {
                // Optical Scan Grid
                VStack {
                    Spacer().frame(height: 400 * CGFloat(scannerManager.scanProgress))
                    Rectangle()
                        .fill(LinearGradient(colors: [.clear, .blue.opacity(0.5), .clear], startPoint: .top, endPoint: .bottom))
                        .frame(height: 100)
                    Spacer()
                }
                .frame(height: 400)
                .clipped()
                
                // Optical Data Points
                ZStack {
                    Circle().stroke(Color.blue, lineWidth: 1).frame(width: 40, height: 40)
                        .position(x: 100, y: 100)
                    Circle().stroke(Color.blue, lineWidth: 1).frame(width: 40, height: 40)
                        .position(x: 250, y: 300)
                }
                .opacity(gridOpacity)
                .onAppear {
                    withAnimation(Animation.easeInOut(duration: 0.5).repeatForever()) {
                        gridOpacity = 1.0
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    var resultsSection: some View {
        VStack(spacing: 24) {
            Divider().background(Color.white.opacity(0.1))
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Aesthetic Alignment")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    Text("\(scannerManager.alignmentScore)% Match")
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                }
                Spacer()
                // Persona Tag
                Text(personaManager.currentPersona.rawValue.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(personaManager.currentPersona.themeColor.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            
            // Color DNA extracted
            VStack(alignment: .leading, spacing: 12) {
                Text("Color DNA Extracted")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.horizontal)
                
                HStack(spacing: 12) {
                    ForEach(scannerManager.extractedColors, id: \.self) { color in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(color)
                            .frame(width: 60, height: 60)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
                    }
                }
                .padding(.horizontal)
            }
            
            Text("Data indicates a strong resonance with your \(personaManager.currentPersona.rawValue) profile. The balance of tone and hue reflects a curated aesthetic intent.")
                .font(.system(size: 14, design: .serif))
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal)
        }
    }
    
    private func startScan(image: UIImage) {
        showResults = false
        scannerManager.analyzeImage(image, persona: personaManager.currentPersona)
        
        // Timer to show results after scan
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
            withAnimation {
                showResults = true
            }
        }
    }
    
    private func reset() {
        selectedItem = nil
        selectedImage = nil
        showResults = false
    }
}
