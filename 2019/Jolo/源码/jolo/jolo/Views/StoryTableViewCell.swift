import UIKit

protocol StoryTableViewCellDelegate: AnyObject {
    func storyCell(_ cell: StoryTableViewCell, didRequestReportForItem item: FeedItem)
    func storyCell(_ cell: StoryTableViewCell, didRequestBlockUser item: FeedItem)
}

class StoryTableViewCell: UITableViewCell {
    static let reuseIdentifier = "StoryTableViewCell"
    weak var delegate: StoryTableViewCellDelegate?
    private var currentItem: FeedItem?
    
    // UI Elements
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 20
        iv.backgroundColor = .systemGray5
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let metaDataLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Nested Collection View for horizontal gallery
    private var collectionView: UICollectionView!
    private var galleryImages: [UIImage] = []
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tagsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var moreButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        btn.setImage(UIImage(systemName: "ellipsis", withConfiguration: config), for: .normal)
        btn.tintColor = .secondaryLabel
        btn.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 14.0, *) {
            btn.showsMenuAsPrimaryAction = true
        } else {
            // Fallback on earlier versions
        }
        return btn
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupCollectionView()
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(StoryGalleryCell.self, forCellWithReuseIdentifier: StoryGalleryCell.reuseIdentifier)
    }
    
    private func setupViews() {
        contentView.addSubview(avatarImageView)
        contentView.addSubview(authorLabel)
        contentView.addSubview(metaDataLabel)
        contentView.addSubview(moreButton)
        contentView.addSubview(collectionView)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(tagsLabel)
        contentView.addSubview(dividerView)
        
        NSLayoutConstraint.activate([
            // Header
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarImageView.widthAnchor.constraint(equalToConstant: 40),
            avatarImageView.heightAnchor.constraint(equalToConstant: 40),
            
            authorLabel.topAnchor.constraint(equalTo: avatarImageView.topAnchor),
            authorLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            authorLabel.trailingAnchor.constraint(equalTo: moreButton.leadingAnchor, constant: -8),

            moreButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            moreButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            moreButton.widthAnchor.constraint(equalToConstant: 32),
            moreButton.heightAnchor.constraint(equalToConstant: 32),

            metaDataLabel.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor),
            metaDataLabel.leadingAnchor.constraint(equalTo: authorLabel.leadingAnchor),
            metaDataLabel.trailingAnchor.constraint(equalTo: authorLabel.trailingAnchor),
            
            // Gallery
            collectionView.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 280),
            
            // Text
            descriptionLabel.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Tags
            tagsLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            tagsLabel.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor),
            tagsLabel.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor),
            
            // Divider
            dividerView.topAnchor.constraint(equalTo: tagsLabel.bottomAnchor, constant: 20),
            dividerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            dividerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            dividerView.heightAnchor.constraint(equalToConstant: 1),
            dividerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(with item: FeedItem) {
        currentItem = item
        authorLabel.text = item.authorName
        avatarImageView.backgroundColor = item.avatarColor
        metaDataLabel.text = "Shot on \(item.cameraModel) • \(item.filmType)"
        descriptionLabel.text = item.title
        tagsLabel.text = item.tags.joined(separator: " ")

        // Build the overflow menu
        if #available(iOS 14.0, *) {
            moreButton.menu = makeContextMenu(for: item)
        } else {
            // Fallback on earlier versions
        }

        galleryImages.removeAll()
        if let mainImg = item.resolveImage() {
            galleryImages.append(mainImg)
            if let rnd1 = UIImage(named: "photo_\(Int.random(in: 1...15))") { galleryImages.append(rnd1) }
            if let rnd2 = UIImage(named: "photo_\(Int.random(in: 1...15))") { galleryImages.append(rnd2) }
        }

        collectionView.reloadData()
    }

    private func makeContextMenu(for item: FeedItem) -> UIMenu {
        let reportAction = UIAction(
            title: "Report Content",
            image: UIImage(systemName: "flag"),
            attributes: .destructive
        ) { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.storyCell(self, didRequestReportForItem: item)
        }

        let blockAction = UIAction(
            title: "Block User",
            image: UIImage(systemName: "person.slash"),
            attributes: .destructive
        ) { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.storyCell(self, didRequestBlockUser: item)
        }

        return UIMenu(title: "", children: [reportAction, blockAction])
    }
}

extension StoryTableViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return galleryImages.isEmpty ? 1 : galleryImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoryGalleryCell.reuseIdentifier, for: indexPath) as! StoryGalleryCell
        if !galleryImages.isEmpty {
            cell.imageView.image = galleryImages[indexPath.row]
            cell.backgroundColor = .clear
        } else {
            cell.imageView.image = nil
            cell.backgroundColor = .darkGray
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Almost full width cell
        return CGSize(width: collectionView.bounds.width - 40, height: collectionView.bounds.height)
    }
}

// Internal cell for the gallery
class StoryGalleryCell: UICollectionViewCell {
    static let reuseIdentifier = "StoryGalleryCell"
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
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
}
