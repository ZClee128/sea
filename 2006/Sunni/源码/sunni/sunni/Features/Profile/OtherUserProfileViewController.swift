//
//  OtherUserProfileViewController.swift
//  Scenery
//
//  Created on 2026/1/14.
//

import UIKit

class OtherUserProfileViewController: UIViewController {
    
    private var user: User
    
    // UI Label references
    private var postCountLabel: UILabel!
    private var followerCountLabel: UILabel!
    private var followingCountLabel: UILabel!
    
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
    
    private let bioLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
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
    
    private let followButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Follow", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        btn.backgroundColor = .appGreen
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 12
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
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
    // ... (rest of properties)
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = user.displayName
        
        setupUI()
        loadData()
        setupActions()
        setupNavigationBar()
        
        // Listen for updates
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserDataUpdate), name: NSNotification.Name("UserDataUpdated"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserDataUpdate), name: NSNotification.Name("PostsUpdated"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupNavigationBar() {
        let moreButton = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis.circle"),
            style: .plain,
            target: self,
            action: #selector(handleMore)
        )
        navigationItem.rightBarButtonItem = moreButton
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(avatarView)
        avatarView.addSubview(avatarLabel)
        contentView.addSubview(displayNameLabel)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(bioLabel)
        contentView.addSubview(statsStackView)
        contentView.addSubview(followButton)
        contentView.addSubview(messageButton)
        
        // Stats
        // Stats
        let postsView = createStatView(label: "Posts")
        postCountLabel = postsView.subviews.compactMap { $0 as? UILabel }.first { $0.font.pointSize == 20 }
        
        let followersView = createStatView(label: "Followers")
        followerCountLabel = followersView.subviews.compactMap { $0 as? UILabel }.first { $0.font.pointSize == 20 }
        
        let followingView = createStatView(label: "Following")
        followingCountLabel = followingView.subviews.compactMap { $0 as? UILabel }.first { $0.font.pointSize == 20 }
        
        
        statsStackView.addArrangedSubview(postsView)
        statsStackView.addArrangedSubview(followersView)
        statsStackView.addArrangedSubview(followingView)
        
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
            
            avatarView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
            avatarView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 100),
            avatarView.heightAnchor.constraint(equalToConstant: 100),
            
            avatarLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            
            displayNameLabel.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 16),
            displayNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            displayNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            
            usernameLabel.topAnchor.constraint(equalTo: displayNameLabel.bottomAnchor, constant: 4),
            usernameLabel.leadingAnchor.constraint(equalTo: displayNameLabel.leadingAnchor),
            usernameLabel.trailingAnchor.constraint(equalTo: displayNameLabel.trailingAnchor),
            
            bioLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 12),
            bioLabel.leadingAnchor.constraint(equalTo: displayNameLabel.leadingAnchor),
            bioLabel.trailingAnchor.constraint(equalTo: displayNameLabel.trailingAnchor),
            
            statsStackView.topAnchor.constraint(equalTo: bioLabel.bottomAnchor, constant: 24),
            statsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 48),
            statsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -48),
            
            followButton.topAnchor.constraint(equalTo: statsStackView.bottomAnchor, constant: 32),
            followButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            followButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            followButton.heightAnchor.constraint(equalToConstant: 50),
            
            messageButton.topAnchor.constraint(equalTo: followButton.bottomAnchor, constant: 12),
            messageButton.leadingAnchor.constraint(equalTo: followButton.leadingAnchor),
            messageButton.trailingAnchor.constraint(equalTo: followButton.trailingAnchor),
            messageButton.heightAnchor.constraint(equalToConstant: 50),
            messageButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
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
    
    private func setupActions() {
        followButton.addTarget(self, action: #selector(handleFollow), for: .touchUpInside)
        messageButton.addTarget(self, action: #selector(handleMessage), for: .touchUpInside)
    }
    
    private func loadData() {
        displayNameLabel.text = user.displayName
        usernameLabel.text = "@\(user.username)"
        
        // Avatar - show first letter
        let firstLetter = String(user.displayName.prefix(1).uppercased())
        avatarLabel.text = firstLetter
        
        // Stats
        postCountLabel?.text = "\(user.postCount)"
        followerCountLabel?.text = "\(user.followerCount)"
        followingCountLabel?.text = "\(user.followingCount)"
        
        // Bio
        if let bio = user.bio, !bio.isEmpty {
            bioLabel.text = bio
            bioLabel.isHidden = false
        } else {
            bioLabel.isHidden = true
        }
    }
    
    @objc private func handleUserDataUpdate() {
        // Fetch latest user data
        if let updatedUser = MockDataService.shared.mockUsers.first(where: { $0.id == user.id }) {
            self.user = updatedUser
            loadData()
        }
    }
    
    @objc private func handleFollow() {
        guard let currentUser = AuthService.shared.authState.currentUser else { return }
        let currentTitle = followButton.title(for: .normal)
        
        if currentTitle == "Follow" {
            // Follow
            MockDataService.shared.followUser(targetUserId: user.id, currentUserId: currentUser.id)
            
            followButton.setTitle("Following", for: .normal)
            followButton.backgroundColor = .systemGray5
            followButton.setTitleColor(.label, for: .normal)
            
            // Update local user object to reflect change immediately in UI if needed (though we rely on service)
            // Ideally we'd re-fetch user data, but for now button state is enough.
        } else {
            // Unfollow
            MockDataService.shared.unfollowUser(targetUserId: user.id, currentUserId: currentUser.id)
            
            followButton.setTitle("Follow", for: .normal)
            followButton.backgroundColor = .appGreen
            followButton.setTitleColor(.white, for: .normal)
        }
    }
    
    @objc private func handleMessage() {
        let chatVC = ChatViewController(otherUser: user)
        chatVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    @objc private func handleMore() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Block/Unblock
        let blockService = BlockService.shared
        let isBlocked = blockService.isUserBlocked(user.id)
        
        let blockTitle = isBlocked ? "Unblock User" : "Block User"
        alert.addAction(UIAlertAction(title: blockTitle, style: .destructive) { [weak self] _ in
            self?.handleBlock(isBlocked: isBlocked)
        })
        
        // Report
        alert.addAction(UIAlertAction(title: "Report User", style: .default) { [weak self] _ in
            self?.handleReport()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // iPad support
        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(alert, animated: true)
    }
    
    private func handleBlock(isBlocked: Bool) {
        let blockService = BlockService.shared
        
        if isBlocked {
            // Unblock
            blockService.unblockUser(user.id)
            
            let alert = UIAlertController(title: "User Unblocked", message: "\(user.displayName) has been unblocked", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        } else {
            // Block
            let confirmAlert = UIAlertController(
                title: "Block \(user.displayName)?",
                message: "They won't be able to see your posts or contact you.",
                preferredStyle: .alert
            )
            
            confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            confirmAlert.addAction(UIAlertAction(title: "Block", style: .destructive) { [weak self] _ in
                guard let self = self else { return }
                blockService.blockUser(self.user.id)
                
                // Go back
                self.navigationController?.popViewController(animated: true)
            })
            
            present(confirmAlert, animated: true)
        }
    }
    
    private func handleReport() {
        let alert = UIAlertController(title: "Report User", message: "Why are you reporting this user?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Spam", style: .default) { [weak self] _ in
            self?.submitReport(reason: "Spam")
        })
        
        alert.addAction(UIAlertAction(title: "Harassment", style: .default) { [weak self] _ in
            self?.submitReport(reason: "Harassment")
        })
        
        alert.addAction(UIAlertAction(title: "Inappropriate Content", style: .default) { [weak self] _ in
            self?.submitReport(reason: "Inappropriate Content")
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // iPad support
        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(alert, animated: true)
    }
    
    private func submitReport(reason: String) {
        let blockService = BlockService.shared
        blockService.reportUser(user.id)
        
        let alert = UIAlertController(
            title: "Thank You",
            message: "Your report has been submitted. We'll review it shortly.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
