import UIKit

class HomeFeedCell: UICollectionViewCell {
    static let reuseIdentifier = "HomeFeedCell"
    private var currentItemId: String?
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        iv.layer.cornerRadius = 8
        iv.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        iv.setContentHuggingPriority(.defaultLow, for: .vertical)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let videoIconView: UIImageView = {
        let iv = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        iv.image = UIImage(systemName: "play.circle.fill", withConfiguration: config)
        iv.tintColor = .white
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.shadowColor = UIColor.black.cgColor
        iv.layer.shadowOffset = CGSize(width: 0, height: 2)
        iv.layer.shadowOpacity = 0.5
        iv.layer.shadowRadius = 4
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(imageView)
        contentView.addSubview(videoIconView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(authorLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            // Leave bottom space for labels
            
            videoIconView.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 8),
            videoIconView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -8),
            videoIconView.widthAnchor.constraint(equalToConstant: 24),
            videoIconView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            
            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            authorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            authorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            authorLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2)
        ])
        
        // Add subtle shadow to the image view for premium depth
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOffset = CGSize(width: 0, height: 4)
        imageView.layer.shadowOpacity = 0.1
        imageView.layer.shadowRadius = 8
        imageView.layer.masksToBounds = true // MUST BE TRUE to prevent image bleeding!
        contentView.clipsToBounds = true
    }
    
    func configure(with item: FeedItem) {
        currentItemId = item.id
        
        // Fast path: Check cache first
        if let name = item.imageURL, let cached = LocalImageCache.shared.object(forKey: name as NSString) {
            imageView.image = cached
            imageView.backgroundColor = .clear
        } else {
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
        
        videoIconView.isHidden = (item.videoName == nil)
        titleLabel.text = item.title
        authorLabel.text = item.authorName
    }
}
