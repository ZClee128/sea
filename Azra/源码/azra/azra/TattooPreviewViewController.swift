import UIKit
import AVFoundation
import Photos

class TattooPreviewViewController: UIViewController {

    let tattooImage: UIImage
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var photoOutput: AVCapturePhotoOutput!

    let tattooImageView = UIImageView()
    let snapButton = UIButton(type: .system)
    let closeButton = UIButton(type: .system)

    init(tattooImage: UIImage) {
        self.tattooImage = tattooImage
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        checkCameraPermissions()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let previewLayer = previewLayer {
            previewLayer.frame = view.bounds
        }
    }

    private func checkCameraPermissions() {
        #if targetEnvironment(simulator)
        setupSimulatorFallback()
        #else
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.setupCamera()
                    }
                } else {
                    self?.showPermissionAlert()
                }
            }
        default:
            showPermissionAlert()
        }
        #endif
    }

    private func showPermissionAlert() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Camera Access Required", message: "Azra needs camera access to preview the tattoo on your body.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak self] _ in
                self?.dismiss(animated: true)
            }))
            self.present(alert, animated: true)
        }
    }
    
    private func setupSimulatorFallback() {
        let fallbackImageView = UIImageView(frame: view.bounds)
        // Draw a simulated "skin" or just a colorful gradient background so user can see it works
        fallbackImageView.backgroundColor = UIColor(red: 0.94, green: 0.81, blue: 0.73, alpha: 1.0)
        fallbackImageView.contentMode = .scaleAspectFill
        view.addSubview(fallbackImageView)
        
        let label = UILabel()
        label.text = "Simulator Mode: Mock Skin View"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        fallbackImageView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: fallbackImageView.centerXAnchor),
            label.topAnchor.constraint(equalTo: fallbackImageView.topAnchor, constant: 100)
        ])
        
        setupOverlayUI()
    }

    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo

        guard let backCamera = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: backCamera) else {
            print("Unable to access back camera!")
            return
        }

        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }

        photoOutput = AVCapturePhotoOutput()
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        setupOverlayUI()

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }

    private func setupOverlayUI() {
        // Tattoo Image
        tattooImageView.image = tattooImage
        tattooImageView.contentMode = .scaleAspectFit
        tattooImageView.isUserInteractionEnabled = true
        // Set initial size
        let initialSize: CGFloat = 200
        tattooImageView.frame = CGRect(x: (view.bounds.width - initialSize) / 2,
                                       y: (view.bounds.height - initialSize) / 2,
                                       width: initialSize,
                                       height: initialSize)
        
        // Add blend mode to make the white background of our mock image transparent
        // In reality, actual models will output images with transparent backgrounds or we can use CI filters.
        tattooImageView.layer.compositingFilter = "multiplyBlendMode"
        
        view.addSubview(tattooImageView)

        // Close Button
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = .white
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        view.addSubview(closeButton)

        // Snap Button
        snapButton.setImage(UIImage(systemName: "camera.circle.fill"), for: .normal)
        snapButton.tintColor = .white
        snapButton.contentVerticalAlignment = .fill
        snapButton.contentHorizontalAlignment = .fill
        snapButton.translatesAutoresizingMaskIntoConstraints = false
        snapButton.addTarget(self, action: #selector(snapTapped), for: .touchUpInside)
        view.addSubview(snapButton)

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),

            snapButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            snapButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            snapButton.widthAnchor.constraint(equalToConstant: 70),
            snapButton.heightAnchor.constraint(equalToConstant: 70)
        ])

        setupGestures()
    }

    private func setupGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotate(_:)))

        panGesture.delegate = self
        pinchGesture.delegate = self
        rotateGesture.delegate = self

        tattooImageView.addGestureRecognizer(panGesture)
        tattooImageView.addGestureRecognizer(pinchGesture)
        tattooImageView.addGestureRecognizer(rotateGesture)
    }

    @objc private func closeTapped() {
        captureSession?.stopRunning()
        dismiss(animated: true)
    }

    @objc private func snapTapped() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    // MARK: - Gesture Handlers
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        if let viewToMove = gesture.view {
            viewToMove.center = CGPoint(x: viewToMove.center.x + translation.x, y: viewToMove.center.y + translation.y)
        }
        gesture.setTranslation(.zero, in: view)
    }

    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        if let viewToScale = gesture.view {
            viewToScale.transform = viewToScale.transform.scaledBy(x: gesture.scale, y: gesture.scale)
            gesture.scale = 1.0
        }
    }

    @objc private func handleRotate(_ gesture: UIRotationGestureRecognizer) {
        if let viewToRotate = gesture.view {
            viewToRotate.transform = viewToRotate.transform.rotated(by: gesture.rotation)
            gesture.rotation = 0
        }
    }
}

extension TattooPreviewViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension TattooPreviewViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(), let capturedImage = UIImage(data: imageData) else { return }

        // Take a snapshot of the screen to merge camera layout and tattoo overlay
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        let compositeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        if let finalImage = compositeImage {
            UIImageWriteToSavedPhotosAlbum(finalImage, self, #selector(imageSaved(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }

    @objc func imageSaved(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        DispatchQueue.main.async {
            if let error = error {
                print("Error saving image: \(error.localizedDescription)")
            } else {
                let alert = UIAlertController(title: "Saved!", message: "Your tattoo try-on photo has been saved to your photo album.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Awesome", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
}
