import UIKit
import CoreImage
import Photos
import AVFoundation
import AVKit

class PhotoDetailViewController: UIViewController, UIScrollViewDelegate {
    
    var feedItem: FeedItem?
    private var originalImage: UIImage?
    private var filteredImage: UIImage?
    
    private let context = CIContext(options: nil)
    
    private var player: AVPlayer?
    private var playerVC: AVPlayerViewController?
    private var playerItemObserver: NSKeyValueObservation?
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.minimumZoomScale = 1.0
        sv.maximumZoomScale = 4.0
        sv.showsHorizontalScrollIndicator = false
        sv.showsVerticalScrollIndicator = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.isUserInteractionEnabled = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let heartButton: UIButton = {
        let btn = UIButton(type: .custom)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        btn.setImage(UIImage(systemName: "heart", withConfiguration: config), for: .normal)
        btn.setImage(UIImage(systemName: "heart.fill", withConfiguration: config), for: .selected)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        btn.layer.cornerRadius = 25
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        btn.clipsToBounds = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let trashButton: UIButton = {
        let btn = UIButton(type: .custom)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        btn.setImage(UIImage(systemName: "trash", withConfiguration: config), for: .normal)
        
        btn.tintColor = .systemRed
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        btn.layer.cornerRadius = 25
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.isHidden = true
        return btn
    }()
    
    private let saveButton: UIButton = {
        let btn = UIButton(type: .custom)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        btn.setImage(UIImage(systemName: "square.and.arrow.down", withConfiguration: config), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        btn.layer.cornerRadius = 25
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let shareButton: UIButton = {
        let btn = UIButton(type: .custom)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        btn.setImage(UIImage(systemName: "square.and.arrow.up", withConfiguration: config), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        btn.layer.cornerRadius = 25
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // Filter Bar
    private let filterSegmentedControl: UISegmentedControl = {
        let items = ["Original", "Mono", "Chrome", "Fade"]
        let sc = UISegmentedControl(items: items)
        sc.selectedSegmentIndex = 0
        sc.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        sc.selectedSegmentTintColor = .white
        sc.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        sc.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()
    
    // EXIF Data Panel
    private let exifContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let exifLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .semibold)
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let closeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "xmark"), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        btn.layer.cornerRadius = 20
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        title = "Inspiration"
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        setupViews()
        populateData()
        setupGestures()
        checkSavedState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        player?.play()
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.delegate = self
        
        view.addSubview(heartButton)
        heartButton.addTarget(self, action: #selector(heartTapped), for: .touchUpInside)
        
        view.addSubview(trashButton)
        trashButton.addTarget(self, action: #selector(trashTapped), for: .touchUpInside)
        
        view.addSubview(saveButton)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        
        view.addSubview(shareButton)
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        
        view.addSubview(filterSegmentedControl)
        filterSegmentedControl.addTarget(self, action: #selector(filterChanged(_:)), for: .valueChanged)
        
        view.addSubview(exifContainer)
        exifContainer.addSubview(exifLabel)
        
        view.addSubview(closeButton)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40),
            
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            
            imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            
            filterSegmentedControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            filterSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            filterSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            filterSegmentedControl.heightAnchor.constraint(equalToConstant: 40),
            
            exifContainer.bottomAnchor.constraint(equalTo: filterSegmentedControl.topAnchor, constant: -20),
            exifContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            exifContainer.trailingAnchor.constraint(equalTo: heartButton.leadingAnchor, constant: -20),
            
            exifLabel.topAnchor.constraint(equalTo: exifContainer.topAnchor, constant: 12),
            exifLabel.leadingAnchor.constraint(equalTo: exifContainer.leadingAnchor, constant: 12),
            exifLabel.trailingAnchor.constraint(equalTo: exifContainer.trailingAnchor, constant: -12),
            exifLabel.bottomAnchor.constraint(equalTo: exifContainer.bottomAnchor, constant: -12),
            
            heartButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            heartButton.bottomAnchor.constraint(equalTo: exifContainer.bottomAnchor),
            heartButton.widthAnchor.constraint(equalToConstant: 50),
            heartButton.heightAnchor.constraint(equalToConstant: 50),
            
            trashButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            trashButton.bottomAnchor.constraint(equalTo: exifContainer.bottomAnchor),
            trashButton.widthAnchor.constraint(equalToConstant: 50),
            trashButton.heightAnchor.constraint(equalToConstant: 50),
            
            saveButton.trailingAnchor.constraint(equalTo: heartButton.trailingAnchor),
            saveButton.bottomAnchor.constraint(equalTo: heartButton.topAnchor, constant: -16),
            saveButton.widthAnchor.constraint(equalToConstant: 50),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            
            shareButton.trailingAnchor.constraint(equalTo: saveButton.trailingAnchor),
            shareButton.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -16),
            shareButton.widthAnchor.constraint(equalToConstant: 50),
            shareButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func generateSolidImage(color: UIColor) -> UIImage {
        let size = CGSize(width: 800, height: 1000)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
    
    private func populateData() {
        guard let item = feedItem else { return }
        
        let img = item.resolveImage() ?? generateSolidImage(color: item.placeholderColor)
        
        originalImage = img
        filteredImage = img
        imageView.image = img
        
        if let videoName = item.videoName {
            var finalPlayURL: URL? = nil
            
            if let bundleURL = Bundle.main.url(forResource: videoName, withExtension: "mp4") ?? Bundle.main.url(forResource: "video", withExtension: "mp4") {
                finalPlayURL = bundleURL
            }
            
            if let safeURL = finalPlayURL {
                imageView.image = nil
                imageView.backgroundColor = .clear
                
                player = AVPlayer(url: safeURL)
//                player?.isMuted = true // Keep muted to avoid HALC_ProxyObjectMap crashes
                
                let pvc = AVPlayerViewController()
                pvc.player = player
                pvc.showsPlaybackControls = false
                pvc.videoGravity = .resizeAspect
                pvc.view.backgroundColor = .clear
                
                self.addChild(pvc)
                imageView.addSubview(pvc.view)
                pvc.view.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    pvc.view.topAnchor.constraint(equalTo: imageView.topAnchor),
                    pvc.view.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
                    pvc.view.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
                    pvc.view.trailingAnchor.constraint(equalTo: imageView.trailingAnchor)
                ])
                pvc.didMove(toParent: self)
                self.playerVC = pvc
                
                playerItemObserver = player?.currentItem?.observe(\.status, options: [.new, .old]) { [weak self] item, _ in
                    if item.status == .failed {
                        DispatchQueue.main.async {
                            let msg = item.error?.localizedDescription ?? "Unknown AVPlayerItem.failed error."
                            let domain = (item.error as NSError?)?.domain ?? "No Domain"
                            let code = (item.error as NSError?)?.code ?? -1
                            let alert = UIAlertController(title: "Video Engine Error", message: "iOS CoreMedia blocked video:\n\(msg)\nCode: \(domain) \(code)", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default))
                            self?.present(alert, animated: true)
                        }
                    }
                }
                
                player?.play()
                
                NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
                
                filterSegmentedControl.isHidden = true
                imageView.isUserInteractionEnabled = false
            } else {
                let alert = UIAlertController(title: "Video File Missing", message: "Cannot play video. The file 'videoData.dataset' or 'video.mp4' is not bundled into the App correctly in Xcode.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Got it", style: .default))
                self.present(alert, animated: true)
                
                filterSegmentedControl.isHidden = false
                imageView.isUserInteractionEnabled = true
            }
        } else {
            filterSegmentedControl.isHidden = false
            imageView.isUserInteractionEnabled = true
        }
        
        exifLabel.text = """
        CAM: \(item.cameraModel)
        LENS: \(item.lens)
        FILM: \(item.filmType)
        EXP: \(item.aperture)  \(item.shutterSpeed)  \(item.iso)
        """
    }
    
    @objc private func playerItemDidReachEnd(notification: Notification) {
        player?.seek(to: .zero)
        player?.play()
    }
    
    @objc private func appDidBecomeActive() {
        playerVC?.player = player
        player?.play()
    }
    
    @objc private func appDidEnterBackground() {
        playerVC?.player = nil
        player?.play()
    }
    
    private func checkSavedState() {
        guard let item = feedItem else { return }
        
        if item.tags.contains("#imported") {
            heartButton.isHidden = true
            trashButton.isHidden = false
        } else {
            heartButton.isHidden = false
            trashButton.isHidden = true
            let isSaved = MoodboardManager.shared.isSaved(id: item.id)
            heartButton.isSelected = isSaved
            heartButton.tintColor = isSaved ? .systemPink : .white
        }
    }
    
    @objc private func closeTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func heartTapped() {
        guard let item = feedItem else { return }
        if heartButton.isSelected {
            MoodboardManager.shared.removeItem(withId: item.id)
            heartButton.tintColor = .white
        } else {
            MoodboardManager.shared.saveItem(item)
            heartButton.tintColor = .systemPink
        }
        heartButton.isSelected.toggle()
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    @objc private func trashTapped() {
        guard let item = feedItem else { return }
        
        let alert = UIAlertController(title: "Delete from Studio", message: "Are you sure you want to remove this imported photo?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            MoodboardManager.shared.removeItem(withId: item.id)
            self.navigationController?.popViewController(animated: true)
        }))
        present(alert, animated: true)
    }
    
    @objc private func saveTapped() {
        let cost = 10
        if StoreManager.shared.coinBalance >= cost {
            StoreManager.shared.coinBalance -= cost
            
            guard let imageToSave = filteredImage else { return }
            UIImageWriteToSavedPhotosAlbum(imageToSave, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        } else {
            let alert = UIAlertController(title: "Not Enough Coins", message: "Downloading this curated aesthetic costs \(cost) coins. You currently have \(StoreManager.shared.coinBalance) coins. Would you like to get more?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Get Coins", style: .default, handler: { _ in
                let storeVC = StoreViewController()
                storeVC.modalPresentationStyle = .pageSheet
                self.present(storeVC, animated: true)
            }))
            present(alert, animated: true)
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        let alert = UIAlertController(title: error == nil ? "Saved!" : "Error",
                                      message: error == nil ? "Image saved to your camera roll." : error?.localizedDescription,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func shareTapped() {
        guard let imageToShare = filteredImage else { return }
        let activityVC = UIActivityViewController(activityItems: [imageToShare], applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    @objc private func filterChanged(_ sender: UISegmentedControl) {
        guard let original = originalImage else { return }
        
        var filterName = ""
        switch sender.selectedSegmentIndex {
        case 1: filterName = "CIPhotoEffectMono"
        case 2: filterName = "CIPhotoEffectChrome"
        case 3: filterName = "CIPhotoEffectFade"
        default:
            imageView.image = original
            filteredImage = original
            return
        }
        
        guard let currentCGImage = original.cgImage else { return }
        let currentCIImage = CIImage(cgImage: currentCGImage)
        
        if let filter = CIFilter(name: filterName) {
            filter.setValue(currentCIImage, forKey: kCIInputImageKey)
            if let output = filter.outputImage,
               let cgimg = context.createCGImage(output, from: output.extent) {
                let processedImage = UIImage(cgImage: cgimg)
                imageView.image = processedImage
                filteredImage = processedImage
            }
        }
    }
    
    private func setupGestures() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(doubleTap)
    }
    
    @objc private func handleDoubleTap(_ recognizer: UITapGestureRecognizer) {
        if scrollView.zoomScale > 1.0 {
            scrollView.setZoomScale(1.0, animated: true)
        } else {
            let point = recognizer.location(in: imageView)
            let scrollSize = scrollView.frame.size
            let size = CGSize(width: scrollSize.width / scrollView.maximumZoomScale,
                              height: scrollSize.height / scrollView.maximumZoomScale)
            let origin = CGPoint(x: point.x - size.width / 2, y: point.y - size.height / 2)
            scrollView.zoom(to: CGRect(origin: origin, size: size), animated: true)
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
