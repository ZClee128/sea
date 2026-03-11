import UIKit
import AVFoundation

class ExploreViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var collectionView: UICollectionView!
    
    // Updated mock data to use the title as the image name, falling back to color if nil
    let styles: [(title: String, desc: String, color: UIColor)] = [
        ("Old School", "Classic Americana with bold black outlines and a limited color palette of primary colors.", .systemRed),
        ("Geometric", "Precise lines and shapes forming intricate, symmetrical patterns that follow the body's natural curves.", .systemBlue),
        ("Watercolor", "Vibrant, fluid designs that mimic the look of watercolor paintings, often without heavy outlines.", .systemPink),
        ("Fine Line", "Delicate, detailed artwork using a single needle to create minimalist and highly intricate designs.", .systemGray),
        ("Tribal", "Rooted in Indigenous traditions, featuring large areas of solid black and sweeping, masculine curves.", .darkGray),
        ("Realism", "Photorealistic tattoos that capture incredible detail, often used for portraits and wildlife.", .systemBrown),
        ("Neo-Traditional", "Combines the bold lines of Old School with a broader color palette and more complex illustrations.", .systemPurple)
    ]
    
    // Helper to get the visible video header view
    private var videoHeaderView: VideoHeaderView? {
        return collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: 0)) as? VideoHeaderView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Explore Styles"
        view.backgroundColor = .systemBackground
        setupCollectionView()
    }
    
    // MARK: - View Lifecycle for Playback Control
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Resume video when coming back to this tab
        videoHeaderView?.playVideo()
        // Resume video when app comes back from background
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause only when navigating away from this tab (not when going to background)
        // We do NOT pause on willResignActive to allow background audio.
        // Determine if we are being removed from hierarchy (tab switch) vs covered by another VC
        if isMovingFromParent || tabBarController?.selectedViewController != navigationController {
            videoHeaderView?.pauseVideo()
        }
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc private func appDidBecomeActive() {
        // Resume playing when app returns to foreground on this tab
        videoHeaderView?.playVideo()
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(StyleGalleryCell.self, forCellWithReuseIdentifier: "StyleGalleryCell")
        collectionView.register(VideoHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "VideoHeader")
        view.addSubview(collectionView)
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return styles.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StyleGalleryCell", for: indexPath) as! StyleGalleryCell
        let style = styles[indexPath.item]
        cell.titleLabel.text = style.title
        
        // Load image by title, fallback to color
        if let image = UIImage(named: style.title) {
            cell.imageView.image = image
            cell.imageView.backgroundColor = .clear
        } else {
            cell.imageView.image = nil
            cell.imageView.backgroundColor = style.color
        }
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate Action
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedStyle = styles[indexPath.item]
        let detailVC = ExploreDetailViewController(styleTitle: selectedStyle.title, styleDescription: selectedStyle.desc, headerColor: selectedStyle.color)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    // MARK: - Header
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "VideoHeader", for: indexPath) as! VideoHeaderView
            header.playVideo()
            return header
        }
        return UICollectionReusableView()
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 2-column grid
        let padding: CGFloat = 16
        let availableWidth = collectionView.bounds.width - (padding * 3) // left, right, middle
        let width = availableWidth / 2
        return CGSize(width: width, height: width * 1.3) // Tall image ratio
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 280) // Header height for the video
    }
}

class VideoHeaderView: UICollectionReusableView {
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    let titleLabel = UILabel()
    let coverImageView = UIImageView()
    
    private var isPlaying = false
    private var timeObserver: Any?
    
    // Play/Pause button overlay
    private let playPauseButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 36, weight: .bold)
        btn.setImage(UIImage(systemName: "play.circle.fill", withConfiguration: config), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        btn.layer.cornerRadius = 32
        btn.clipsToBounds = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("🎬 VideoHeaderView Init - Frame: \(frame)")
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupUI() {
        backgroundColor = .black
        clipsToBounds = true
        
        // 1. Cover Image
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Try to load from assets or loose file
        if let img = UIImage(named: "maxres2") ?? UIImage(named: "maxres2.jpg") {
            coverImageView.image = img
        } else if let path = Bundle.main.path(forResource: "maxres2", ofType: "jpg") {
            coverImageView.image = UIImage(contentsOfFile: path)
        }
        addSubview(coverImageView)
        
        NSLayoutConstraint.activate([
            coverImageView.topAnchor.constraint(equalTo: topAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            coverImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // 2. Video Player
        if let videoURL = Bundle.main.url(forResource: "videoplayback", withExtension: "mp4") {
            print("🎬 Video file found: \(videoURL)")
            player = AVPlayer(url: videoURL)
            // WORKAROUND: Force mute to bypass simulator audio hardware crashes (Error -66680 / 560947818)
//            player?.isMuted = true
            
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.videoGravity = .resizeAspectFill
            if let layer = playerLayer {
                self.layer.insertSublayer(layer, below: coverImageView.layer)
                print("🎬 Added player layer below cover image")
            }
            
            // Loop video continuously
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem, queue: .main) { [weak self] _ in
                self?.player?.seek(to: .zero)
                self?.player?.play()
            }
            
            // Background detach
            NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { [weak self] _ in
                guard let self = self, self.isPlaying else { return }
                self.playerLayer?.player = nil
            }
            NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { [weak self] _ in
                guard let self = self, self.isPlaying else { return }
                self.playerLayer?.player = self.player
                self.player?.play()
            }
        } else {
            print("❌ Video file videoplayback.mp4 not found in bundle!")
        }
        
        // 3. Title Overlay
        titleLabel.text = "Masterclass Artists"
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
        titleLabel.textColor = .white
        titleLabel.layer.shadowColor = UIColor.black.cgColor
        titleLabel.layer.shadowRadius = 3.0
        titleLabel.layer.shadowOpacity = 1.0
        titleLabel.layer.shadowOffset = CGSize(width: 2, height: 2)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        // 4. Play/Pause Button
        addSubview(playPauseButton)
        playPauseButton.addTarget(self, action: #selector(togglePlayPause), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            
            playPauseButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            playPauseButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            playPauseButton.widthAnchor.constraint(equalToConstant: 64),
            playPauseButton.heightAnchor.constraint(equalToConstant: 64)
        ])
    }
    
    @objc private func togglePlayPause() {
        guard let player = player else { return }
        
        if isPlaying {
            isPlaying = false
            player.pause()
            updateButtonIcon()
            UIView.animate(withDuration: 0.3) { self.coverImageView.alpha = 1 }
        } else {
            isPlaying = true
            
            // Fix: ensure we are at the start and active before playing
            if player.currentTime() == player.currentItem?.duration {
                player.seek(to: .zero)
            }
            player.play()
            
            updateButtonIcon()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                UIView.animate(withDuration: 0.5) { self.coverImageView.alpha = 0 }
            }
        }
    }
    
    private func updateButtonIcon() {
        let name = isPlaying ? "pause.circle.fill" : "play.circle.fill"
        let config = UIImage.SymbolConfiguration(pointSize: 36, weight: .bold)
        playPauseButton.setImage(UIImage(systemName: name, withConfiguration: config), for: .normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Ensure layer matches bounds absolutely
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        playerLayer?.frame = bounds
        CATransaction.commit()
    }
    
    /// Resume only if it was already playing
    func playVideo() {
        guard isPlaying else { return }
        player?.play()
    }
    
    func pauseVideo() {
        // We pause the player unconditionally, but preserve `isPlaying`
        // so it resumes automatically when coming back to the tab.
        player?.pause()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


class StyleGalleryCell: UICollectionViewCell {
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.2
        contentView.layer.shadowOffset = CGSize(width: 0, height: 4)
        contentView.layer.shadowRadius = 6

        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)

        // Add a bottom dark gradient so white text is always readable over images
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.8).cgColor]
        gradientLayer.locations = [0.5, 1.0]
        imageView.layer.addSublayer(gradientLayer)

        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}
