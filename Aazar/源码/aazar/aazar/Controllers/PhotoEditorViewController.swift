import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

class PhotoEditorViewController: UIViewController {
    
    private let originalImage: UIImage
    private let modeImage: MoodImage
    
    private let imageView = UIImageView()
    private let originalPreviewView = UIImageView()
    private let filterScrollView = UIScrollView()
    private let filterStackView = UIStackView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    private let context = CIContext()
    
    private let filters: [(name: String, filter: CIFilter?)] = [
        ("Original", nil),
        ("Noir", CIFilter.photoEffectNoir()),
        ("Fade", CIFilter.photoEffectFade()),
        ("Chrome", CIFilter.photoEffectChrome()),
        ("Process", CIFilter.photoEffectProcess()),
        ("Tonal", CIFilter.photoEffectTonal())
    ]
    
    init(image: UIImage, model: MoodImage) {
        self.originalImage = image
        self.modeImage = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Edit & Filter"
        
        setupNavigationBar()
        setupUI()
        setupFilterButtons()
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelEdit))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveImage))
    }
    
    @objc private func cancelEdit() {
        dismiss(animated: true)
    }
    
    private func setupUI() {
        imageView.image = originalImage
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        filterScrollView.showsHorizontalScrollIndicator = false
        filterScrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filterScrollView)
        
        filterStackView.axis = .horizontal
        filterStackView.spacing = 16
        filterStackView.alignment = .center
        filterStackView.translatesAutoresizingMaskIntoConstraints = false
        filterScrollView.addSubview(filterStackView)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            imageView.bottomAnchor.constraint(equalTo: filterScrollView.topAnchor, constant: -24),
            
            filterScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filterScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            filterScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterScrollView.heightAnchor.constraint(equalToConstant: 100),
            
            filterStackView.topAnchor.constraint(equalTo: filterScrollView.contentLayoutGuide.topAnchor),
            filterStackView.bottomAnchor.constraint(equalTo: filterScrollView.contentLayoutGuide.bottomAnchor),
            filterStackView.leadingAnchor.constraint(equalTo: filterScrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            filterStackView.trailingAnchor.constraint(equalTo: filterScrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            filterStackView.heightAnchor.constraint(equalTo: filterScrollView.frameLayoutGuide.heightAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
    }
    
    private func setupFilterButtons() {
        let thumbnailSize = CGSize(width: 60, height: 60)
        let thumbnailRect = CGRect(origin: .zero, size: thumbnailSize)
        
        // Create an ultra-low res thumbnail for fast filter preview generation
        UIGraphicsBeginImageContextWithOptions(thumbnailSize, false, 1.0)
        originalImage.draw(in: thumbnailRect)
        let rawThumbnail = UIGraphicsGetImageFromCurrentImageContext() ?? originalImage
        UIGraphicsEndImageContext()
        
        for (index, filterData) in filters.enumerated() {
            let container = UIStackView()
            container.axis = .vertical
            container.spacing = 8
            container.alignment = .center
            
            let btn = UIButton(type: .custom)
            btn.layer.cornerRadius = 8
            btn.clipsToBounds = true
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.tag = index
            btn.addTarget(self, action: #selector(filterSelected(_:)), for: .touchUpInside)
            
            // Generate preview
            if let ciFilter = filterData.filter,
               let ciImage = CIImage(image: rawThumbnail) {
                ciFilter.setValue(ciImage, forKey: kCIInputImageKey)
                if let output = ciFilter.outputImage,
                   let cgimg = context.createCGImage(output, from: output.extent) {
                    btn.setImage(UIImage(cgImage: cgimg), for: .normal)
                } else {
                    btn.setImage(rawThumbnail, for: .normal)
                }
            } else {
                btn.setImage(rawThumbnail, for: .normal)
            }
            
            let lbl = UILabel()
            lbl.text = filterData.name
            lbl.font = .systemFont(ofSize: 12, weight: .medium)
            lbl.textColor = .label
            
            container.addArrangedSubview(btn)
            container.addArrangedSubview(lbl)
            
            NSLayoutConstraint.activate([
                btn.widthAnchor.constraint(equalToConstant: 60),
                btn.heightAnchor.constraint(equalToConstant: 60)
            ])
            
            filterStackView.addArrangedSubview(container)
        }
    }
    
    @objc private func filterSelected(_ sender: UIButton) {
        let filterData = filters[sender.tag]
        
        // Reset to original
        guard let customFilter = filterData.filter else {
            imageView.image = originalImage
            return
        }
        
        activityIndicator.startAnimating()
        
        // Process full resolution image in background
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let ciOriginal = CIImage(image: self.originalImage)!
            customFilter.setValue(ciOriginal, forKey: kCIInputImageKey)
            
            if let output = customFilter.outputImage,
               let cgimg = self.context.createCGImage(output, from: output.extent) {
                let processedImage = UIImage(cgImage: cgimg)
                
                DispatchQueue.main.async {
                    self.imageView.image = processedImage
                    self.activityIndicator.stopAnimating()
                }
            } else {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    @objc private func saveImage() {
        guard let imageToSave = imageView.image else { return }
        UIImageWriteToSavedPhotosAlbum(imageToSave, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let alert = UIAlertController(title: "Save Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        } else {
            let alert = UIAlertController(title: "Saved!", message: "Your edited image has been saved to your Camera Roll.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}
