import SwiftUI

@available(iOS 14.0, *)
struct AestheticScannerView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedImage: UIImage?
    @State private var isScanning = false
    @State private var showResult = false
    @State private var scanProgress: CGFloat = 0
    @State private var isImagePickerPresented = false
    
    @State private var scores: [ScanScore] = []
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Text("AESTHETIC LAB")
                        .font(.system(size: 14, weight: .black))
                        .tracking(4)
                    Spacer()
                    Color.clear.frame(width: 32)
                }
                .padding(.top, 40)
                .padding(.horizontal)
                
                // Image Box
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.blue.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [8]))
                        .frame(height: 350)
                    
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 350)
                            .cornerRadius(24)
                            .clipped()
                        
                        if isScanning {
                            // Scanning Line
                            Rectangle()
                                .fill(LinearGradient(gradient: Gradient(colors: [.clear, .blue, .clear]), startPoint: .top, endPoint: .bottom))
                                .frame(height: 4)
                                .offset(y: -175 + (350 * scanProgress))
                                .shadow(color: .blue, radius: 10)
                        }
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                            Text("Drop Dance Asset for Analysis")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal)
                
                if !showResult {
                    // Controls
                    VStack(spacing: 16) {
                        Button(action: {
                            isImagePickerPresented = true
                        }) {
                            HStack {
                                Image(systemName: "photo.on.rectangle")
                                Text("Import from Gallery")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(16)
                        }
                        
                        if selectedImage != nil && !isScanning {
                            Button(action: startScan) {
                                Text("START PRO SCAN")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(16)
                            }
                        }
                    }
                    .padding()
                } else {
                    // Result Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("ANALYSIS COMPLETED")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        ForEach(scores) { score in
                            VStack(alignment: .leading, spacing: 5) {
                                HStack {
                                    Text(score.label)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(Int(score.value * 100))%")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                }
                                
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        Rectangle()
                                            .fill(Color(UIColor.secondarySystemBackground))
                                            .frame(height: 6)
                                        
                                        Rectangle()
                                            .fill(Color.blue)
                                            .frame(width: geo.size.width * score.value, height: 6)
                                    }
                                    .cornerRadius(3)
                                }
                                .frame(height: 6)
                            }
                        }
                        
                        Button(action: {
                            showResult = false
                            selectedImage = nil
                        }) {
                            Text("NEW ANALYSIS")
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 10)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground).opacity(0.5))
                    .cornerRadius(20)
                    .padding(.horizontal)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                Spacer()
            }
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(image: $selectedImage)
        }
    }
    
    func startScan() {
        withAnimation {
            isScanning = true
            scanProgress = 0
            showResult = false
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { timer in
            scanProgress += 0.01
            if scanProgress >= 1.0 {
                timer.invalidate()
                generateResults()
            }
        }
    }
    
    func generateResults() {
        scores = [
            ScanScore(label: "Composition & Flow", value: CGFloat.random(in: 0.75...0.98)),
            ScanScore(label: "Energy Distribution", value: CGFloat.random(in: 0.65...0.95)),
            ScanScore(label: "Movement Impact", value: CGFloat.random(in: 0.8...1.0))
        ]
        
        withAnimation {
            isScanning = false
            showResult = true
        }
    }
}

// Result data model
struct ScanScore: Identifiable {
    let id = UUID()
    let label: String
    let value: CGFloat
}

// Simple Image Picker Integration
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
