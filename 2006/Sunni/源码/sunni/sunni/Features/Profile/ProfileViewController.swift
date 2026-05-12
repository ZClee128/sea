//
//  ProfileViewController.swift
//  Scenery
//
//  Created on 2026/1/14.
//

import UIKit

// MARK: - Profile Grid Cell
class ProfileGridCell: UICollectionViewCell {
    static let identifier = "ProfileGridCell"
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .systemGray6
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with post: Post) {
        let urlString = post.thumbnailURL ?? post.mediaURL
        imageView.loadImage(from: URL(string: urlString))
    }
}

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var posts: [Post] = []
    private var targetUser: User?
    
    init(user: User? = nil) {
        self.targetUser = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.register(ProfileGridCell.self, forCellWithReuseIdentifier: ProfileGridCell.identifier)
        cv.register(ProfileHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileHeaderView.identifier)
        cv.alwaysBounceVertical = true
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupUI()
        setupNavigationBar()
        loadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: NSNotification.Name("UserDataUpdated"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: NSNotification.Name("PostsUpdated"), object: nil)
    }
    
    private func setupNavigationBar() {
        let isOwnProfile = (targetUser == nil) || (targetUser?.id == AuthService.shared.authState.currentUser?.id)
        
        if isOwnProfile {
            title = "Profile"
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .plain, target: self, action: #selector(handleSettings))
        } else {
            if let user = targetUser {
                title = user.displayName
            }
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), style: .plain, target: self, action: #selector(handleMore)) // Reuse handleMore logic if possible or create new
        }
    }
    
    @objc private func handleSettings() {
        let settingsVC = SettingsViewController()
        settingsVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    @objc private func handleMore() {
        guard let user = targetUser else { return }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Report
        alert.addAction(UIAlertAction(title: "Report User", style: .default) { _ in
            let reportAlert = UIAlertController(title: "Reported", message: "User has been reported.", preferredStyle: .alert)
            reportAlert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(reportAlert, animated: true)
        })
        
        // Block
        let blockService = BlockService.shared
        let isBlocked = blockService.isUserBlocked(user.id)
        let blockTitle = isBlocked ? "Unblock User" : "Block User"
        alert.addAction(UIAlertAction(title: blockTitle, style: .destructive) { _ in
             if isBlocked {
                 blockService.unblockUser(user.id)
             } else {
                 blockService.blockUser(user.id)
                 self.navigationController?.popViewController(animated: true)
             }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
             popover.barButtonItem = navigationItem.rightBarButtonItem
        }
        present(alert, animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    @objc private func loadData() {
        let displayUser = targetUser ?? AuthService.shared.authState.currentUser
        
        // Load Posts
        if let user = displayUser {
             // Filter posts for this user
             let allPosts = MockDataService.shared.mockPosts
             self.posts = allPosts.filter { $0.userId == user.id || $0.user.id == user.id }
        } else {
             self.posts = []
        }
        collectionView.reloadData()
    }
    

    private func handleMessage() {
        guard let user = targetUser else { return }
        let chatVC = ChatViewController(otherUser: user)
        chatVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    // MARK: - CollectionView DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileGridCell.identifier, for: indexPath) as? ProfileGridCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: posts[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ProfileHeaderView.identifier, for: indexPath) as? ProfileHeaderView else {
                return UICollectionReusableView()
            }
            
            let isOwnProfile = (targetUser == nil) || (targetUser?.id == AuthService.shared.authState.currentUser?.id)
            
            // IMPORTANT: If targetUser is set, use it. But we also need latest state (like isFollowing)
            // So we should try to fetch latest user object from MockDataService if possible, or trust targetUser
            // For safety, let's refresh targetUser from MockDataService if available
            if let tUser = targetUser, let updatedUser = MockDataService.shared.mockUsers.first(where: { $0.id == tUser.id }) {
                self.targetUser = updatedUser
            }
            
            header.configure(user: targetUser, postCount: self.posts.count, isOwnProfile: isOwnProfile)
            
            if isOwnProfile {
                header.onBuyCoins = { [weak self] in
                    let iapVC = InAppPurchaseViewController()
                    iapVC.hidesBottomBarWhenPushed = true
                    self?.navigationController?.pushViewController(iapVC, animated: true)
                }
                
                header.onLogin = { [weak self] in
                    // Present Login (wrapped in Nav)
                    let loginVC = EmailInputViewController()
                    let nav = UINavigationController(rootViewController: loginVC)
                    nav.modalPresentationStyle = .fullScreen
                    self?.present(nav, animated: true, completion: nil)
                }
            } else {
                header.onMessage = { [weak self] in self?.handleMessage() }
            }
            
            return header
        }
        return UICollectionReusableView()
    }
    
    // MARK: - Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 480) 
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post = posts[indexPath.item]
        let detailVC = PostDetailViewController(post: post)
        detailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - Profile Header View
// Moving all existing profile UI code into this header view
class ProfileHeaderView: UICollectionReusableView {
    static let identifier = "ProfileHeaderView"
    
    var onBuyCoins: (() -> Void)?
    var onLogin: (() -> Void)?
    
    // ... (UI Components adapted from original ProfileViewController) ...
    private let avatarView: UIView = {
        let view = UIView()
        view.backgroundColor = .appGreen
        view.layer.cornerRadius = 50
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let avatarLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 40, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let displayNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 24
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let coinBalanceView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 255/255, green: 215/255, blue: 0/255, alpha: 0.15)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let coinIcon: UILabel = {
        let label = UILabel()
        label.text = "🪙"
        label.font = .systemFont(ofSize: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let coinBalanceLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = UIColor(red: 255/255, green: 193/255, blue: 7/255, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let coinTextLabel: UILabel = {
        let label = UILabel()
        label.text = "Coins"
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Buttons need user interaction enabled and targets added
    private lazy var buyCoinsButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Buy Coins", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        btn.backgroundColor = .appGreen
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 12
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(handleBuyCoins), for: .touchUpInside)
        return btn
    }()
    
//    private lazy var loginButton: UIButton = {
//        let btn = UIButton(type: .system)
//        btn.setTitle("Login / Register", for: .normal)
//        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
//        btn.backgroundColor = .appGreen
//        btn.setTitleColor(.white, for: .normal)
//        btn.layer.cornerRadius = 12
//        btn.translatesAutoresizingMaskIntoConstraints = false
//        btn.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
//        return btn
//    }()
    

    
    private var postCountLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(user: User? = nil, postCount: Int? = nil, isOwnProfile: Bool = true) {
        // Load Data
        let currentUser = AuthService.shared.authState.currentUser
        let displayUser = user ?? currentUser
        
        if let u = displayUser {
            avatarView.isHidden = false
            avatarLabel.isHidden = false
            displayNameLabel.isHidden = false
            usernameLabel.isHidden = false
            statsStackView.isHidden = false
            
            displayNameLabel.text = u.displayName
            usernameLabel.text = "@\(u.username)"
            let firstLetter = String(u.displayName.prefix(1).uppercased())
            avatarLabel.text = firstLetter
            
            // Bio
            if let bio = u.bio, !bio.isEmpty {
                bioLabel.text = bio
                bioLabel.isHidden = false
            } else {
                bioLabel.isHidden = true
            }
            
            // Post Count
            if let count = postCount {
                postCountLabel?.text = "\(count)"
            } else {
                postCountLabel?.text = "\(u.postCount)"
            }
            
            // Layout changes based on isOwnProfile
            // Layout changes based on isOwnProfile
            if isOwnProfile {
                coinBalanceView.isHidden = false
                buyCoinsButton.isHidden = false
                messageButton.isHidden = true
                
                coinBalanceLabel.text = "\(u.coinBalance)"
            } else {
                coinBalanceView.isHidden = true
                buyCoinsButton.isHidden = true
                messageButton.isHidden = false
            }
        } else {
             // Guest Mode: Hide User Info
             avatarView.isHidden = true
             avatarLabel.isHidden = true
             displayNameLabel.text = "Guest"
             displayNameLabel.isHidden = true // Hide name too? User said "Don't have avatar and post0".
             // Let's show a "Welcome" or just empty?
             // "Login directly" -> Maybe just Login Button in center.
             usernameLabel.isHidden = true
             bioLabel.isHidden = true
             statsStackView.isHidden = true
             
             coinBalanceView.isHidden = true
             buyCoinsButton.isHidden = true
             messageButton.isHidden = true
             
//             loginButton.isHidden = false
        }
    }
    
    // UI Properties for Other Profile
    private let bioLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let messageButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Message", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16)
        btn.setTitleColor(.label, for: .normal)
        btn.layer.cornerRadius = 12
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.systemGray4.cgColor
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    var onFollow: (() -> Void)? // Kept to avoid breaking interface if any, but unused
    var onMessage: (() -> Void)?
    
    private func setupUIActions() {
        buyCoinsButton.addTarget(self, action: #selector(handleBuyCoins), for: .touchUpInside)
        messageButton.addTarget(self, action: #selector(handleMessage), for: .touchUpInside)
    }
    

    @objc private func handleMessage() { onMessage?() }
    
    // ... setupUI (updated) ...
    // Note: I will update setupUI inside the replace block or assume it needs partial update
    // Since setupUI is large, I'll update constraints here.
    
    private func setupUIConstants() {
        addSubview(avatarView)
        avatarView.addSubview(avatarLabel)
        addSubview(displayNameLabel)
        addSubview(usernameLabel)
        addSubview(bioLabel) // Added
        addSubview(statsStackView)
        addSubview(coinBalanceView)
        coinBalanceView.addSubview(coinIcon)
        coinBalanceView.addSubview(coinBalanceLabel)
        coinBalanceView.addSubview(coinTextLabel)
        addSubview(buyCoinsButton)
        addSubview(messageButton) // Added
//        addSubview(loginButton) // Added
        
        // Stats logic remains same
        let postsView = createStatView(label: "Posts")
        postCountLabel = postsView.subviews.compactMap { $0 as? UILabel }.first { $0.font.pointSize == 20 }
        statsStackView.addArrangedSubview(postsView)
        
        setupUIActions()
        
        NSLayoutConstraint.activate([
            avatarView.topAnchor.constraint(equalTo: topAnchor, constant: 32),
            avatarView.centerXAnchor.constraint(equalTo: centerXAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 100),
            avatarView.heightAnchor.constraint(equalToConstant: 100),
            
            avatarLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            
            displayNameLabel.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 16),
            displayNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            displayNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            
            usernameLabel.topAnchor.constraint(equalTo: displayNameLabel.bottomAnchor, constant: 4),
            usernameLabel.leadingAnchor.constraint(equalTo: displayNameLabel.leadingAnchor),
            usernameLabel.trailingAnchor.constraint(equalTo: displayNameLabel.trailingAnchor),
            
            // Bio Constraints
            bioLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 12),
            bioLabel.leadingAnchor.constraint(equalTo: displayNameLabel.leadingAnchor),
            bioLabel.trailingAnchor.constraint(equalTo: displayNameLabel.trailingAnchor),
            
            statsStackView.topAnchor.constraint(equalTo: bioLabel.bottomAnchor, constant: 24),
            statsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 48),
            statsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -48),
            
            // Coin View (Own Profile)
            coinBalanceView.topAnchor.constraint(equalTo: statsStackView.bottomAnchor, constant: 20),
            coinBalanceView.centerXAnchor.constraint(equalTo: centerXAnchor),
            coinBalanceView.widthAnchor.constraint(equalToConstant: 200),
            coinBalanceView.heightAnchor.constraint(equalToConstant: 64),
            
            coinIcon.leadingAnchor.constraint(equalTo: coinBalanceView.leadingAnchor, constant: 16),
            coinIcon.centerYAnchor.constraint(equalTo: coinBalanceView.centerYAnchor),
            
            coinBalanceLabel.leadingAnchor.constraint(equalTo: coinIcon.trailingAnchor, constant: 8),
            coinBalanceLabel.topAnchor.constraint(equalTo: coinBalanceView.topAnchor, constant: 12),
            
            coinTextLabel.leadingAnchor.constraint(equalTo: coinBalanceLabel.leadingAnchor),
            coinTextLabel.topAnchor.constraint(equalTo: coinBalanceLabel.bottomAnchor, constant: 2),
            
            buyCoinsButton.topAnchor.constraint(equalTo: coinBalanceView.bottomAnchor, constant: 24),
            buyCoinsButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            buyCoinsButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
            buyCoinsButton.heightAnchor.constraint(equalToConstant: 48),
            
            // Other Profile Constraints (Overlapping with Coin/Buy layout but controlled via isHidden)
            // Message Button (Re-anchored)
            messageButton.topAnchor.constraint(equalTo: statsStackView.bottomAnchor, constant: 32),
            messageButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            messageButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            messageButton.heightAnchor.constraint(equalToConstant: 50),
            
//            loginButton.centerXAnchor.constraint(equalTo: centerXAnchor),
//            loginButton.centerYAnchor.constraint(equalTo: statsStackView.centerYAnchor, constant: 50),
//            loginButton.widthAnchor.constraint(equalToConstant: 200),
//            loginButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func createStatView(label: String) -> UIView {
        let container = UIView()
        
        let countLabel = UILabel()
        countLabel.text = "0"
        countLabel.font = .systemFont(ofSize: 20, weight: .bold)
        countLabel.textAlignment = .center
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let textLabel = UILabel()
        textLabel.text = label
        textLabel.font = .systemFont(ofSize: 14)
        textLabel.textColor = .secondaryLabel
        textLabel.textAlignment = .center
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(countLabel)
        container.addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            countLabel.topAnchor.constraint(equalTo: container.topAnchor),
            countLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            
            textLabel.topAnchor.constraint(equalTo: countLabel.bottomAnchor, constant: 4),
            textLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            textLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }

    // Override setupUI to use new constraints
    private func setupUI() {
        setupUIConstants()
    }

    @objc private func handleBuyCoins() {
        onBuyCoins?()
    }
    
    @objc private func handleLogin() {
        onLogin?()
    }
}
