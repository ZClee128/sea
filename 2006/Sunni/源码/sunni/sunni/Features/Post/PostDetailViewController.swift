//
//  PostDetailViewController.swift
//  Scenery
//
//  Created on 2026/1/14.
//

import UIKit
import AVFoundation

class PostDetailViewController: UIViewController {
    
    private var post: Post
    
    // MARK: - Video Properties
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let postImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .systemGray6
        iv.isUserInteractionEnabled = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let playButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 80, weight: .regular)
        btn.setImage(UIImage(systemName: "play.circle.fill", withConfiguration: config), for: .normal)
        btn.tintColor = .white
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.isHidden = true
        return btn
    }()
    
    private let userAvatarLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        label.textColor = .white
        label.backgroundColor = .systemGray
        label.layer.cornerRadius = 20
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let captionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 16
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let likeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "heart"), for: .normal)
        btn.tintColor = .label
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let commentButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "bubble.right"), for: .normal)
        btn.tintColor = .label
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let giftButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "gift"), for: .normal)
        btn.tintColor = UIColor(red: 255/255, green: 193/255, blue: 7/255, alpha: 1.0)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let shareButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        btn.tintColor = .label
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // MARK: - Initialization
    init(post: Post) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupUI()
        configureWithPost()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: self, action: #selector(handleMoreOptions))
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(postImageView)
        contentView.addSubview(playButton)
        contentView.addSubview(userAvatarLabel)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(locationLabel)
        contentView.addSubview(captionLabel)
        // Stats (Removed as per user request to avoid duplication)
        
        // Action buttons
        // User requested to remove comment and share buttons
        let buttonStack = UIStackView(arrangedSubviews: [likeButton, giftButton])
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillProportionally // Changed to fillProportionally for buttons with text
        buttonStack.spacing = 32
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(buttonStack)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            postImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            postImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            postImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            postImageView.heightAnchor.constraint(equalTo: postImageView.widthAnchor),
            
            playButton.centerXAnchor.constraint(equalTo: postImageView.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: postImageView.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 80),
            playButton.heightAnchor.constraint(equalToConstant: 80),
            
        // User info constraints remain same
            userAvatarLabel.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: 16),
            userAvatarLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            userAvatarLabel.widthAnchor.constraint(equalToConstant: 40),
            userAvatarLabel.heightAnchor.constraint(equalToConstant: 40),
            
            usernameLabel.centerYAnchor.constraint(equalTo: userAvatarLabel.centerYAnchor, constant: -8),
            usernameLabel.leadingAnchor.constraint(equalTo: userAvatarLabel.trailingAnchor, constant: 12),
            usernameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            locationLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 2),
            locationLabel.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor),
            locationLabel.trailingAnchor.constraint(equalTo: usernameLabel.trailingAnchor),
            
            captionLabel.topAnchor.constraint(equalTo: userAvatarLabel.bottomAnchor, constant: 16),
            captionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            captionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Replaced statsStackView with buttonStack directly
            buttonStack.topAnchor.constraint(equalTo: captionLabel.bottomAnchor, constant: 24),
            buttonStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            // buttonStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40), // Remove trailing constraint to allow leading alignment
            buttonStack.heightAnchor.constraint(equalToConstant: 44),
            buttonStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
        
        
        likeButton.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        giftButton.addTarget(self, action: #selector(handleGift), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(handlePlayVideo), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleImageTap))
        postImageView.addGestureRecognizer(tap)
    }
    
    private func configureWithPost() {
        // Load image
        if post.type == .video {
            let urlStr = post.thumbnailURL ?? post.mediaURL
            postImageView.loadImage(from: URL(string: urlStr))
            playButton.isHidden = false
        } else {
            postImageView.loadImage(from: URL(string: post.mediaURL))
            playButton.isHidden = true
        }
        
        // User info
        let firstLetter = String(post.user.displayName.prefix(1).uppercased())
        userAvatarLabel.text = firstLetter
        usernameLabel.text = post.user.displayName
        
        // Location
        if let location = post.location {
            locationLabel.text = "📍 \(location)"
        }
        
        // Caption
        captionLabel.text = post.caption
        
        // Update Buttons with Counts
        updateButton(likeButton, count: post.likeCount)
        updateButton(giftButton, count: post.giftCount)
        
        title = "Post Detail"
    }
    
    private func updateButton(_ button: UIButton, count: Int) {
        button.setTitle(" \(count)", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
    }
    
    // Removed createStatView
    
    // MARK: - Actions
    @objc private func handleLike() {
        print("Like tapped")
        // Logic to update like count could go here
    }
    
    @objc private func handlePlayVideo() {
        guard let url = URL(string: post.mediaURL) else { return }
        
        // If already playing, toggle (Pause)
        if let player = player {
            if player.timeControlStatus == .playing || player.timeControlStatus == .waitingToPlayAtSpecifiedRate {
                player.pause()
                playButton.isHidden = false
            } else {
                player.play()
                playButton.isHidden = true
            }
            return
        }
        
        let playerItem = AVPlayerItem(url: url)
        self.player = AVPlayer(playerItem: playerItem)
        
        // Allow background playback
        if #available(iOS 15.0, *) {
            self.player?.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
        }
        
        let layer = AVPlayerLayer(player: player)
        layer.frame = postImageView.bounds
        layer.videoGravity = .resizeAspectFill
        postImageView.layer.addSublayer(layer)
        self.playerLayer = layer
        
        player?.play()
        playButton.isHidden = true
        
        // Loop video
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: .main) { [weak self] _ in
            self?.player?.seek(to: .zero)
            self?.player?.play()
        }
    }
    
    @objc private func handleImageTap() {
        if post.type == .video {
            handlePlayVideo()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = postImageView.bounds
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleGift() {
        let giftVC = GiftSelectionViewController()
        giftVC.onGiftSelected = { [weak self] gift in
            guard let self = self else { return }
            
            // Deduct coins (logic handled in GiftSelectionVC or Service, but we assume success here or GiftSelectionVC handles error)
            
            // Update local post model
            self.post.giftCount += 1 // For simplicity, adding 1 to count, or could be gift value
            
            // Update UI
            self.updateButton(self.giftButton, count: self.post.giftCount)
            
            // Save to Mock Service
            // Save to Mock Service
            MockDataService.shared.updatePost(self.post)
            
            // Show Success Animation or Toast
            // The GiftSelectionVC usually dismisses itself or we dismiss it
            // Assuming GiftSelectionVC dismisses on selection or we need to dismiss if it doesn't
            self.dismiss(animated: true, completion: nil)
            
            let alert = UIAlertController(title: "Gift Sent!", message: "You sent a \(gift.name)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
        
        if #available(iOS 15.0, *) {
            if let sheet = giftVC.sheetPresentationController {
                sheet.detents = [.medium()]
            }
        }
        present(giftVC, animated: true)
    }
    
    // Removed handleComment and handleShare
    
    @objc private func handleMoreOptions() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let reportAction = UIAlertAction(title: "Report", style: .destructive) { [weak self] _ in
            self?.handleReport()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(reportAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func handleReport() {
        let alert = UIAlertController(title: "Report Submitted", message: "Thank you for reporting this post. We will review it shortly.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
