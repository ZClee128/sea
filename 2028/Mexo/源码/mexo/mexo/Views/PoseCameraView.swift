import SwiftUI
import AVFoundation
import Photos

private let cameraSessionQueue = DispatchQueue(label: "com.mexo.cameraSessionQueue")

struct PoseCameraView: View {
    let photoUrl: String
    @Environment(\.presentationMode) var presentationMode
    
    @State private var overlayOpacity: Double = 0.5
    @State private var session = AVCaptureSession()
    @State private var photoOutput = AVCapturePhotoOutput()
    @State private var isCameraAuthorized = false
    @State private var isFlashActive = false
    @State private var showingSavedAlert = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                // LAYER 1: Full-screen background (Camera & Overlay)
                ZStack {
                    Color.black
                    
                    if isCameraAuthorized {
                        CameraPreview(session: session)
                        
                        Image(photoUrl) // Now local asset name
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .opacity(overlayOpacity)
                            .allowsHitTesting(false)
                    }
                    
                    if isFlashActive {
                        Color.white.transition(.opacity).zIndex(5)
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .edgesIgnoringSafeArea(.all)
                
                // LAYER 2: INTERACTION UI (Absolute Positioning)
                if isCameraAuthorized {
                    // CLOSE BUTTON - Moved further down to clear navigation bar area
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.5).clipShape(Circle()))
                            .shadow(radius: 5)
                    }
                    // Adjusted Y Offset: safeAreaInsets.top + 50 to fully clear the status bar and potential nav bar overlap
                    .position(x: 44, y: geometry.safeAreaInsets.top + 50)
                    .zIndex(100)
                    
                    // BOTTOM CONTROLS
                    VStack {
                        Spacer()
                        VStack(spacing: 25) {
                            VStack(spacing: 8) {
                                Text("Overlay Opacity")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .shadow(radius: 2)
                                
                                Slider(value: $overlayOpacity, in: 0.1...0.9)
                                    .accentColor(.white)
                            }
                            .padding(.horizontal, 40)
                            
                            Button(action: {
                                capturePhoto()
                            }) {
                                ZStack {
                                    Circle()
                                        .stroke(Color.white, lineWidth: 3)
                                        .frame(width: 75, height: 75)
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 65, height: 65)
                                }
                            }
                        }
                        .padding(.bottom, geometry.safeAreaInsets.bottom + 20)
                    }
                    .frame(width: geometry.size.width)
                    .zIndex(1)
                } else {
                    // Permission Screen
                    VStack(spacing: 20) {
                        Text("Camera Access Required").foregroundColor(.white)
                        Button("Grant Access") { requestCameraAccess() }
                            .padding().background(Color.blue).cornerRadius(8).foregroundColor(.white)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarHidden(true) // Ensure nav bar is hidden if inherited
        .alert(isPresented: $showingSavedAlert) {
            Alert(title: Text("Photo Saved"), message: Text("The photo has been saved to your Photo Library."), dismissButton: .default(Text("OK")))
        }
        .onAppear { requestCameraAccess() }
        .onDisappear {
            cameraSessionQueue.async {
                if session.isRunning { session.stopRunning() }
            }
        }
    }
    
    private func requestCameraAccess() {
        #if targetEnvironment(simulator)
        DispatchQueue.main.async { self.isCameraAuthorized = true }
        #else
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                self.isCameraAuthorized = granted
                if granted { self.setupCamera() }
            }
        }
        #endif
        
        // Also request Photo Library permission
        PHPhotoLibrary.requestAuthorization { _ in }
    }
    
    private func setupCamera() {
        cameraSessionQueue.async {
            session.beginConfiguration()
            if let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
               let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) {
                if session.inputs.isEmpty && session.canAddInput(videoDeviceInput) { session.addInput(videoDeviceInput) }
            }
            if session.canAddOutput(photoOutput) { session.addOutput(photoOutput) }
            session.commitConfiguration()
            if !session.isRunning { session.startRunning() }
        }
    }
    
    private func capturePhoto() {
        withAnimation(.easeInOut(duration: 0.1)) { isFlashActive = true }
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeOut(duration: 0.2)) { isFlashActive = false }
        }
        
        #if targetEnvironment(simulator)
        // Simulator - Get the local asset image and save it
        if let localImage = UIImage(named: photoUrl) {
            self.saveImageToLibrary(localImage)
        } else {
            // Fallback to blue if image not found
            let size = CGSize(width: 800, height: 1200)
            UIGraphicsBeginImageContext(size)
            UIColor.systemBlue.setFill()
            UIRectFill(CGRect(origin: .zero, size: size))
            let fallbackImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
            UIGraphicsEndImageContext()
            self.saveImageToLibrary(fallbackImage)
        }
        #else
        let settings = AVCapturePhotoSettings()
        let processor = PhotoCaptureProcessor { image in
            if let image = image {
                self.saveImageToLibrary(image)
            }
        }
        objc_setAssociatedObject(self.photoOutput, &processorKey, processor, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        photoOutput.capturePhoto(with: settings, delegate: processor)
        #endif
    }
    
    private func saveImageToLibrary(_ image: UIImage) {
        // Only use the modern framework method for a single, reliable save
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { success, error in
            print("Photo save status: \(success). Error: \(String(describing: error))")
        }
        
        // Always show the alert on main thread to give feedback
        DispatchQueue.main.async {
            showingSavedAlert = true
        }
    }
}

// Helper to convert Color to UIColor for drawing
extension Color {
    func uiColor() -> UIColor {
        if #available(iOS 14.0, *) {
            return UIColor(self)
        } else {
            // Simplified fallback for iOS 13: return a standard blue
            return UIColor.systemBlue
        }
    }
}

private var processorKey: UInt8 = 0
class PhotoCaptureProcessor: NSObject, AVCapturePhotoCaptureDelegate {
    private let completion: (UIImage?) -> Void
    init(completion: @escaping (UIImage?) -> Void) { self.completion = completion }
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let data = photo.fileDataRepresentation(), let image = UIImage(data: data) { completion(image) } else { completion(nil) }
    }
}

struct CameraPreview: UIViewRepresentable {
    class VideoPreviewView: UIView {
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        var videoPreviewLayer: AVCaptureVideoPreviewLayer { return layer as! AVCaptureVideoPreviewLayer }
    }
    let session: AVCaptureSession
    func makeUIView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
        view.backgroundColor = .black
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }
    func updateUIView(_ uiView: VideoPreviewView, context: Context) {}
}
