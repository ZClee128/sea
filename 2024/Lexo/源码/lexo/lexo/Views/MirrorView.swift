import SwiftUI
import AVFoundation

struct MirrorView: View {
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    
    // Pro Makeup Adjustments
    @State private var brightness: Double = 0.0
    @State private var contrast: Double = 1.0
    @State private var saturation: Double = 1.0
    @State private var showGrid: Bool = false
    @State private var showControls: Bool = true
    
    var body: some View {
        ZStack {
            // 背景层内容
            Group {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .edgesIgnoringSafeArea(.top)
                        // 若是导入，默认不需要水平反转
                } else {
                    CameraPreview()
                        .edgesIgnoringSafeArea(.top)
                }
            }
            .brightness(brightness)
            .contrast(contrast)
            .saturation(saturation)
            
            // 对称辅助线 (Symmetry Guide)
            if showGrid {
                GeometryReader { geometry in
                    Path { path in
                        let width = geometry.size.width
                        let height = geometry.size.height
                        
                        path.move(to: CGPoint(x: width/2, y: 0))
                        path.addLine(to: CGPoint(x: width/2, y: height))
                        
                        path.move(to: CGPoint(x: 0, y: height/3))
                        path.addLine(to: CGPoint(x: width, y: height/3))
                        
                        path.move(to: CGPoint(x: 0, y: height*2/3))
                        path.addLine(to: CGPoint(x: width, y: height*2/3))
                    }
                    .stroke(Color.white.opacity(0.6), lineWidth: 1)
                }
                .allowsHitTesting(false)
            }
            
            // 底部控制面板 UI
            VStack {
                Spacer()
                
                if showControls {
                    VStack(spacing: 20) {
                        // Import and Grid Toggle
                        HStack {
                            Button(action: {
                                showingImagePicker = true
                            }) {
                                HStack {
                                    Image(systemName: "photo")
                                    Text("Import")
                                }
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(12)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                withAnimation { showGrid.toggle() }
                            }) {
                                HStack {
                                    Image(systemName: showGrid ? "grid.circle.fill" : "grid.circle")
                                    Text("Symmetry")
                                }
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(showGrid ? Color.accentColor : Color.white.opacity(0.2))
                                .cornerRadius(12)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                brightness = 0.0
                                contrast = 1.0
                                saturation = 1.0
                            }) {
                                Text("Reset")
                                    .font(.subheadline)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(12)
                            }
                        }
                        
                        // Lighting & Color Adjustments
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "sun.max")
                                    .frame(width: 20)
                                Slider(value: $brightness, in: -0.5...0.5)
                            }
                            
                            HStack {
                                Image(systemName: "circle.lefthalf.filled")
                                    .frame(width: 20)
                                Slider(value: $contrast, in: 0.5...1.5)
                            }
                            
                            HStack {
                                Image(systemName: "drop")
                                    .frame(width: 20)
                                Slider(value: $saturation, in: 0.0...2.0)
                            }
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.75))
                    .cornerRadius(20)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    .transition(.move(edge: .bottom))
                }
                
                // Toggle Panel Button
                Button(action: {
                    withAnimation { showControls.toggle() }
                }) {
                    if #available(iOS 14.0, *) {
                        Image(systemName: showControls ? "chevron.down.circle.fill" : "chevron.up.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.bottom, 10)
                    } else {
                        // Fallback on earlier versions
                    }
                }
            }
        }
        .navigationBarTitle("Pro Mirror Studio", displayMode: .inline)
        .foregroundColor(.white)
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct CameraPreview: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CameraViewController {
        return CameraViewController()
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}

class CameraViewController: UIViewController {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        // 尝试获取前置摄像头 (如果是模拟器会直接返回并在中间显示黑布)
        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("Front camera not found")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: frontCamera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch {
            print("Error accessing camera: \(error.localizedDescription)")
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        // 关键：水平翻转画面使其像一面真正的镜子
        if previewLayer.connection?.isVideoMirroringSupported == true {
            previewLayer.connection?.automaticallyAdjustsVideoMirroring = false
            previewLayer.connection?.isVideoMirrored = true
        }
        
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        // Started session on a background thread to avoid UI block
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession?.isRunning == true {
            captureSession.stopRunning()
        }
    }
}
