import UIKit

class StudioViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var savedItems: [FeedItem] = []
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Studio"
        label.font = .systemFont(ofSize: 28, weight: .black)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let importButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "plus"), for: .normal)
        btn.tintColor = .label
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        
        let icon = UIImageView(image: UIImage(systemName: "camera.aperture"))
        icon.tintColor = .tertiaryLabel
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(icon)
        
        let label = UILabel()
        label.text = "Your darkroom is empty.\nCollect inspiration to build your aesthetic."
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),
            icon.widthAnchor.constraint(equalToConstant: 60),
            icon.heightAnchor.constraint(equalToConstant: 60),
            
            label.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 16),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        // Hide standard nav bar for custom premium title
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    private func setupViews() {
        view.addSubview(titleLabel)
        view.addSubview(importButton)
        importButton.addTarget(self, action: #selector(importTapped), for: .touchUpInside)
        
        let layout = UICollectionViewFlowLayout()
        let padding: CGFloat = 2
        let itemsPerRow: CGFloat = 3
        let availableWidth = view.bounds.width - padding * (itemsPerRow + 1)
        let itemWidth = availableWidth / itemsPerRow
        
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth) // Square grid for studio look
        layout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        layout.minimumInteritemSpacing = padding
        layout.minimumLineSpacing = padding
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(StudioCell.self, forCellWithReuseIdentifier: StudioCell.reuseIdentifier)
        
        view.addSubview(collectionView)
        view.addSubview(emptyStateView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            importButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            importButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            importButton.widthAnchor.constraint(equalToConstant: 44),
            importButton.heightAnchor.constraint(equalToConstant: 44),
            
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.widthAnchor.constraint(equalTo: view.widthAnchor),
            emptyStateView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func loadData() {
        savedItems = MoodboardManager.shared.getSavedItems()
        collectionView.reloadData()
        emptyStateView.isHidden = !savedItems.isEmpty
        collectionView.isHidden = savedItems.isEmpty
    }
    
    @objc private func importTapped() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
}

extension StudioViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.originalImage] as? UIImage else { return }
        
        let imageName = UUID().uuidString + ".jpg"
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let filename = paths[0].appendingPathComponent(imageName)
        
        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: filename)
            
            let newItem = FeedItem(
                id: UUID().uuidString,
                imageURL: imageName,
                videoName: nil,
                hexColor: "#000000",
                aspectRatio: image.size.width / image.size.height,
                title: "Imported from Library",
                authorName: "My Studio",
                authorAvatarHex: "#000000",
                isLiked: true,
                cameraModel: "Imported Photo",
                filmType: "Digital",
                lens: "Unknown",
                aperture: "N/A",
                shutterSpeed: "N/A",
                iso: "N/A",
                tags: ["#imported"]
            )
            
            MoodboardManager.shared.saveItem(newItem)
            loadData()
        }
    }
}

extension StudioViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return savedItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StudioCell.reuseIdentifier, for: indexPath) as! StudioCell
        cell.configure(with: savedItems[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = PhotoDetailViewController()
        detailVC.feedItem = savedItems[indexPath.row]
        detailVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}

class StudioCell: UICollectionViewCell {
    static let reuseIdentifier = "StudioCell"
    private var currentItemId: String?
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with item: FeedItem) {
        currentItemId = item.id
        
        // Fast path: Check cache first
        if let name = item.imageURL, let cached = LocalImageCache.shared.object(forKey: name as NSString) {
            imageView.image = cached
            imageView.backgroundColor = .clear
            return
        }
        
        // Loading state
        imageView.image = nil
        imageView.backgroundColor = item.placeholderColor
        
        // Background thread loading
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let img = item.resolveImage()
            DispatchQueue.main.async {
                guard self?.currentItemId == item.id else { return } // Prevent reuse mismatch
                if let finalImg = img {
                    self?.imageView.image = finalImg
                    self?.imageView.backgroundColor = .clear
                }
            }
        }
    }
}
