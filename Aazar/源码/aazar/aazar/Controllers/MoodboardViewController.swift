import UIKit

class MoodboardViewController: UIViewController {
    
    private var images = [MoodImage]()
    private var collectionView: UICollectionView!
    private let generateButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Moodboard Maker"
        
        setupUI()
        loadImages()
    }
    
    private func loadImages() {
        // Load all mock data to give users a wide selection for moodboarding
        images = InspirationDataService.shared.fetchImages()
        collectionView.reloadData()
    }
    
    private func setupUI() {
        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 8
        let availableWidth = view.bounds.width - spacing * 4
        let itemWidth = availableWidth / 3
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = true
        collectionView.register(GalleryCell.self, forCellWithReuseIdentifier: "GalleryCell")
        
        generateButton.setTitle("Generate & Save", for: .normal)
        generateButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        generateButton.backgroundColor = .systemBlue
        generateButton.setTitleColor(.white, for: .normal)
        generateButton.layer.cornerRadius = 12
        generateButton.translatesAutoresizingMaskIntoConstraints = false
        generateButton.addTarget(self, action: #selector(generateMoodboard), for: .touchUpInside)
        
        view.addSubview(collectionView)
        view.addSubview(generateButton)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: generateButton.topAnchor, constant: -16),
            
            generateButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            generateButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            generateButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            generateButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func generateMoodboard() {
        guard let indexPaths = collectionView.indexPathsForSelectedItems, !indexPaths.isEmpty else {
            let alert = UIAlertController(title: "Select Images", message: "Please select at least 1 image to generate a moodboard.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // We need URL -> UIImage. For simplicity in this demo, we can just snapshot the selected cells directly
        // since they have already fetched the images.
        let selectedCells = indexPaths.compactMap { collectionView.cellForItem(at: $0) as? GalleryCell }
        let uiImages = selectedCells.compactMap { $0.imageView.image }
        
        guard !uiImages.isEmpty else { return }
        
        let boardImage = createMoodboardImage(from: uiImages)
        UIImageWriteToSavedPhotosAlbum(boardImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        } else {
            let alert = UIAlertController(title: "Saved!", message: "Your Moodboard has been saved to your Camera Roll.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Awesome", style: .default))
            present(alert, animated: true)
            
            // Clear selection
            collectionView.indexPathsForSelectedItems?.forEach {
                collectionView.deselectItem(at: $0, animated: true)
            }
        }
    }
    
    private func createMoodboardImage(from images: [UIImage]) -> UIImage {
        // A simple layout: just stack them vertically with a white background padding
        let padding: CGFloat = 20
        var totalHeight: CGFloat = padding
        var maxWidth: CGFloat = 0
        
        for image in images {
            let ratio = image.size.height / image.size.width
            let targetWidth: CGFloat = 800
            let targetHeight = targetWidth * ratio
            totalHeight += targetHeight + padding
            maxWidth = max(maxWidth, targetWidth + padding * 2)
        }
        
        let size = CGSize(width: maxWidth, height: totalHeight)
        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
        
        UIColor.white.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        
        var currentY: CGFloat = padding
        for image in images {
            let ratio = image.size.height / image.size.width
            let targetWidth: CGFloat = 800
            let targetHeight = targetWidth * ratio
            
            let x = (maxWidth - targetWidth) / 2
            image.draw(in: CGRect(x: x, y: currentY, width: targetWidth, height: targetHeight))
            
            currentY += targetHeight + padding
        }
        
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return finalImage
    }
}

extension MoodboardViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCell", for: indexPath) as! GalleryCell
        let image = images[indexPath.row]
        cell.configure(with: image)
        return cell
    }
    
    // Visually show selection
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderWidth = 4
        cell?.layer.borderColor = UIColor.systemBlue.cgColor
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderWidth = 0
    }
}
