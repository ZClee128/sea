import SwiftUI
import AVFoundation
import Combine

@available(iOS 14.0, *)
struct CameraView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var cameraManager = CameraManager()
    @State private var flashOpacity: Double = 0.0
    let overlayImage: String?
    
    var body: some View {
        ZStack {
            CameraPreview(session: cameraManager.session)
                .ignoresSafeArea()
            
            if let overlay = overlayImage {
                Image(overlay)
                    .resizable()
                    .aspectRatio(contentMode: .fill) // Fill for better alignment in full screen
                    .opacity(0.3)
                    .allowsHitTesting(false)
                    .ignoresSafeArea()
            }
            
            // Capture Flash Effect
            Color.white
                .opacity(flashOpacity)
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(BlurView(style: .systemThinMaterialDark).clipShape(Circle()))
                    }.padding(.leading, 70)
                    Spacer()
                    Image("")
                    Spacer()
                }
                .padding(.top, 20) // Moderate padding as fallback
                .padding(.horizontal, 0)
                
                Spacer()
                
                HStack {
                    Spacer()
                    Button(action: { 
                        cameraManager.capturePhoto()
                        triggerFlash()
                    }) {
                        ZStack {
                            Circle()
                                .strokeBorder(Color.white, lineWidth: 4)
                                .frame(width: 80, height: 80)
                            Circle()
                                .fill(Color.white)
                                .frame(width: 68, height: 68)
                        }
                    }
                    Spacer()
                }
                .padding(.bottom, 50)
            }
        }
        .statusBar(hidden: true)
        .onAppear {
            cameraManager.checkPermissions()
        }
        .onDisappear {
            cameraManager.stop()
        }
    }
    
    private func triggerFlash() {
        withAnimation(.easeInOut(duration: 0.1)) {
            flashOpacity = 1.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.3)) {
                flashOpacity = 0.0
            }
        }
    }
}

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

import Photos

class CameraManager: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private let sessionQueue = DispatchQueue(label: "com.mexo.cameraSessionQueue")
    
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setup()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async { self.setup() }
                }
            }
        default:
            break
        }
        
        PHPhotoLibrary.requestAuthorization { _ in }
    }
    
    private func setup() {
        sessionQueue.async {
            do {
                self.session.beginConfiguration()
                guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { 
                    self.session.commitConfiguration()
                    return 
                }
                let input = try AVCaptureDeviceInput(device: device)
                
                if self.session.canAddInput(input) {
                    self.session.addInput(input)
                }
                
                if self.session.canAddOutput(self.output) {
                    self.session.addOutput(self.output)
                }
                
                self.session.commitConfiguration()
                
                if !self.session.isRunning {
                    self.session.startRunning()
                }
            } catch {
                self.session.commitConfiguration()
                print("Camera setup error: \(error)")
            }
        }
    }
    
    func capturePhoto() {
        #if targetEnvironment(simulator)
        // Simulator Mock
        DispatchQueue.main.async {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            print("Simulator: Photo capture simulated")
        }
        #else
        sessionQueue.async {
            guard let connection = self.output.connection(with: .video), connection.isActive, connection.isEnabled else {
                print("Camera Error: No active video connection")
                return
            }
            
            let settings = AVCapturePhotoSettings()
            self.output.capturePhoto(with: settings, delegate: self)
        }
        #endif
    }
    
    func stop() {
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else { return }
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { success, error in
            print("Save status: \(success)")
        }
        
        DispatchQueue.main.async {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
