//
//  PostTableViewCell.swift
//  Scenery
//
//  Created on 2026/1/14.
//

import UIKit
import AVFoundation

class PostTableViewCell: UITableViewCell {
    static let identifier = "PostTableViewCell"
    
    // MARK: - Video Properties
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var currentPost: Post?
    
    // MARK: - Callbacks
    var onLike: (() -> Void)?
    var onComment: (() -> Void)?
    var onShare: (() -> Void)?
    var onGift: (() -> Void)?
    var onReport: (() -> Void)?
    var onUserTap: (() -> Void)?
    var onPostTap: (() -> Void)?
    
    // MARK: - UI Components
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 24
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.12
        view.layer.shadowOffset = CGSize(width: 0, height: 6)
        view.layer.shadowRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Avatar overlaps image and footer
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 22
        iv.layer.borderWidth = 3
        iv.layer.borderColor = UIColor.systemBackground.cgColor // Match card bg
        iv.backgroundColor = .appGreen
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let avatarLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let displayNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let moreButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        btn.tintColor = .tertiaryLabel
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let mediaImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        // Top corners rounded only
        iv.layer.cornerRadius = 24
        iv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        iv.backgroundColor = .systemGray6
        iv.isUserInteractionEnabled = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let playButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 56, weight: .light)
        btn.setImage(UIImage(systemName: "play.circle.fill", withConfiguration: config), for: .normal)
        btn.tintColor = .white.withAlphaComponent(0.9)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.isHidden = true
        return btn
    }()
    
    private let likeButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        btn.setImage(UIImage(systemName: "heart", withConfiguration: config), for: .normal)
        btn.tintColor = .label
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let giftButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        btn.setImage(UIImage(systemName: "gift.fill", withConfiguration: config), for: .normal)
        btn.tintColor = UIColor(red: 255/255, green: 200/255, blue: 0/255, alpha: 1.0)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let giftCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = UIColor(red: 255/255, green: 200/255, blue: 0/255, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    private let likeCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let captionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .label
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timestampLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11)
        label.textColor = .tertiaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        mediaImageView.image = nil
        avatarImageView.image = nil
        
        resetPlayer()
    }
    
    private func resetPlayer() {
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        player = nil
        playerLayer = nil
        playButton.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = mediaImageView.bounds
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(containerView)
        
        // Media in top part
        containerView.addSubview(mediaImageView)
        containerView.addSubview(playButton)
        
        // Footer Elements
        containerView.addSubview(avatarImageView)
        containerView.addSubview(avatarLabel)
        containerView.addSubview(displayNameLabel)
        containerView.addSubview(locationLabel)
        containerView.addSubview(moreButton)
        
        containerView.addSubview(likeButton)
        containerView.addSubview(likeCountLabel)
        containerView.addSubview(giftButton)
        containerView.addSubview(giftCountLabel)
        
        containerView.addSubview(captionLabel)
        containerView.addSubview(timestampLabel)
        
        NSLayoutConstraint.activate([
            // Card Container
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            // Dynamic Height from Constraints
            
            // Image Section (Fixed Ratio/Height)
            mediaImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            mediaImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            mediaImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            mediaImageView.heightAnchor.constraint(equalToConstant: 400),
            
            // Overlapping Avatar (Half on image, half on footer)
            avatarImageView.centerYAnchor.constraint(equalTo: mediaImageView.bottomAnchor),
            avatarImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            avatarImageView.widthAnchor.constraint(equalToConstant: 44),
            avatarImageView.heightAnchor.constraint(equalToConstant: 44),
            
            avatarLabel.centerXAnchor.constraint(equalTo: avatarImageView.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            
            // Name Info (Right of Avatar, in footer space)
            displayNameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            displayNameLabel.topAnchor.constraint(equalTo: mediaImageView.bottomAnchor, constant: 8),
            
            locationLabel.leadingAnchor.constraint(equalTo: displayNameLabel.leadingAnchor),
            locationLabel.topAnchor.constraint(equalTo: displayNameLabel.bottomAnchor, constant: 2),
            
            // More Button
            moreButton.centerYAnchor.constraint(equalTo: displayNameLabel.centerYAnchor),
            moreButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // Actions Row (Below Loc)
            likeButton.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 12),
            likeButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            likeCountLabel.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            likeCountLabel.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor, constant: 6),
            
            giftButton.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            giftButton.leadingAnchor.constraint(equalTo: likeCountLabel.trailingAnchor, constant: 20),
            
            giftCountLabel.centerYAnchor.constraint(equalTo: giftButton.centerYAnchor),
            giftCountLabel.leadingAnchor.constraint(equalTo: giftButton.trailingAnchor, constant: 6),
            
            // Caption
            captionLabel.topAnchor.constraint(equalTo: likeButton.bottomAnchor, constant: 16),
            captionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            captionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // Timestamp
            timestampLabel.topAnchor.constraint(equalTo: captionLabel.bottomAnchor, constant: 8),
            timestampLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            timestampLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20), // Bottom padding
            
            // Play Button
            playButton.centerXAnchor.constraint(equalTo: mediaImageView.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: mediaImageView.centerYAnchor)
        ])
    }
    
    private func setupActions() {
        moreButton.addTarget(self, action: #selector(handleMore), for: .touchUpInside)
        likeButton.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        giftButton.addTarget(self, action: #selector(handleGift), for: .touchUpInside)
        
        let avatarTap = UITapGestureRecognizer(target: self, action: #selector(handleUserTap))
        avatarImageView.addGestureRecognizer(avatarTap)
        avatarImageView.isUserInteractionEnabled = true
        
        let nameTap = UITapGestureRecognizer(target: self, action: #selector(handleUserTap))
        displayNameLabel.addGestureRecognizer(nameTap)
        displayNameLabel.isUserInteractionEnabled = true
        
        // Post image tap
        let postTap = UITapGestureRecognizer(target: self, action: #selector(handlePostTap))
        mediaImageView.addGestureRecognizer(postTap)
        mediaImageView.isUserInteractionEnabled = true
        
        playButton.addTarget(self, action: #selector(handlePlayVideo), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func handleMore() {
        onReport?()
    }
    
    @objc private func handleLike() {
        onLike?()
    }
    
    @objc private func handleComment() {
        onComment?()
    }
    
    @objc private func handleShare() {
        onShare?()
    }
    
    @objc private func handleGift() {
        onGift?()
    }
    
    @objc private func handleUserTap() {
        onUserTap?()
    }
    
    @objc private func handlePostTap() {
        onPostTap?()
    }
    
    @objc private func handlePlayVideo() {
        guard let post = currentPost, post.type == .video else { return }
        // Implement video playback logic here if needed, or open detail
        onPostTap?()
    }
    
    // MARK: - Configure
    
    func configure(with post: Post) {
        self.currentPost = post
        
        // User info
        displayNameLabel.text = post.user.displayName
        
        if let location = post.location {
            locationLabel.text = location
            locationLabel.isHidden = false
        } else {
            locationLabel.isHidden = true
        }
        
        // Avatar - show first letter
        let firstLetter = String(post.user.displayName.prefix(1).uppercased())
        avatarLabel.text = firstLetter
        avatarImageView.image = nil // Clear any previous image
        
        // Media
        if post.type == .video {
            let urlStr = post.thumbnailURL ?? post.mediaURL
            mediaImageView.loadImage(from: URL(string: urlStr))
            playButton.isHidden = false
        } else {
            mediaImageView.loadImage(from: URL(string: post.mediaURL))
            playButton.isHidden = true
        }
        
        // Like state
        let heartImage = post.isLiked ? UIImage(systemName: "heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 22)) : UIImage(systemName: "heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 22))
        likeButton.setImage(heartImage, for: .normal)
        likeButton.tintColor = post.isLiked ? .systemRed : .label
        
        // Like count
        likeCountLabel.text = "\(post.likeCount)"
        
        // Gift count
        giftCountLabel.text = "\(post.giftCount)"
        giftCountLabel.isHidden = post.giftCount == 0
        
        // Caption
        // Use an attributed string to bold the username in caption if desired, but here just plain text
        // Format: "Username Caption" or just Caption. Let's do Just Caption as username is above.
        captionLabel.text = post.caption
        
        // Timestamp
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        timestampLabel.text = formatter.localizedString(for: post.createdAt, relativeTo: Date())
    }
}
