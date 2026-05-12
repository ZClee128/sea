//
//  HomeViewController.swift
//  Scenery
//
//  Created on 2026/1/14.
//

import UIKit

class HomeViewController: UIViewController {
    
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.identifier)
        tv.separatorStyle = .none
        tv.allowsSelection = false
        tv.backgroundColor = .systemGroupedBackground
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private var posts: [Post] = []
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Home"
        
        setupUI()
        setupNavigationBar()
        loadData()
        
        // Listen for auth state changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAuthChange),
            name: NSNotification.Name("AuthStateChanged"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePostsUpdated),
            name: NSNotification.Name("PostsUpdated"),
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleAuthChange() {
        tableView.reloadData()
    }
    
    @objc private func handlePostsUpdated() {
        posts = MockDataService.shared.mockPosts
        tableView.reloadData()
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Pull to refresh
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupNavigationBar() {
        // Profile button on right
        let profileButton = UIBarButtonItem(
            image: UIImage(systemName: "person.circle"),
            style: .plain,
            target: self,
            action: #selector(handleProfileTap)
        )
        profileButton.tintColor = .appGreen
        navigationItem.rightBarButtonItem = profileButton
    }
    
    @objc private func handleProfileTap() {
        let authService = AuthService.shared
        if authService.authState.isAuthenticated {
            // Show own profile
            if let user = authService.authState.currentUser {
                let profileVC = ProfileViewController()
                navigationController?.pushViewController(profileVC, animated: true)
            }
        } else {
            // Show login
            let emailVC = EmailInputViewController()
            let navController = UINavigationController(rootViewController: emailVC)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true)
        }
    }
    
    @objc private func handleRefresh() {
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.loadData()
            self?.refreshControl.endRefreshing()
        }
    }
    
    private func loadData() {
        posts = MockDataService.shared.mockPosts
        tableView.reloadData()
    }
}

// MARK: - UITableView Delegate & DataSource

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: PostTableViewCell.identifier,
            for: indexPath
        ) as? PostTableViewCell else {
            return UITableViewCell()
        }
        
        let post = posts[indexPath.row]
        cell.configure(with: post)
        
        // Handle like
        cell.onLike = { [weak self] in
            guard let self = self else { return }
            
            // Check auth
            if !AuthService.shared.authState.isAuthenticated {
                self.showLoginAlert()
                return
            }
            
            // Toggle like
            var updatedPost = self.posts[indexPath.row]
            updatedPost.isLiked.toggle()
            updatedPost.likeCount += updatedPost.isLiked ? 1 : -1
            self.posts[indexPath.row] = updatedPost
            
            // Update cell
            cell.configure(with: updatedPost)
        }
        
        // Handle comment
        cell.onComment = { [weak self] in
            guard let self = self else { return }
            
            if !AuthService.shared.authState.isAuthenticated {
                self.showLoginAlert()
                return
            }
            
            // TODO: Navigate to comments
            let alert = UIAlertController(
                title: "Comments",
                message: "Comment feature coming soon!",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
        
        // Handle share
        cell.onShare = { [weak self] in
            // TODO: Share functionality
        }
        
        // Handle gift
        cell.onGift = { [weak self] in
            guard let self = self else { return }
            let post = self.posts[indexPath.row]
            self.handleGift(for: post)
        }
        
        // Handle report
        cell.onReport = { [weak self] in
            guard let self = self else { return }
            self.showReportAlert(for: post)
        }
        
        // Handle user tap
        cell.onUserTap = { [weak self] in
            guard let self = self else { return }
            let post = self.posts[indexPath.row]
            let otherProfileVC = ProfileViewController(user: post.user)
            otherProfileVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(otherProfileVC, animated: true)
        }
        
        // Handle post image tap
        cell.onPostTap = { [weak self] in
            guard let self = self else { return }
            let post = self.posts[indexPath.row]
            self.handlePostTap(for: post)
        }
        
        return cell
    }
    
    private func showLoginAlert() {
        let alert = UIAlertController(
            title: "Login Required",
            message: "Please login to interact with posts",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Login", style: .default) { [weak self] _ in
            let emailVC = EmailInputViewController()
            let navController = UINavigationController(rootViewController: emailVC)
            navController.modalPresentationStyle = .fullScreen
            self?.present(navController, animated: true)
        })
        
        present(alert, animated: true)
    }
    
    private func showReportAlert(for post: Post) {
        let alert = UIAlertController(
            title: "Report Post",
            message: "Why are you reporting this post?",
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: "Spam", style: .default) { [weak self] _ in
            self?.submitReport(reason: "Spam")
        })
        
        alert.addAction(UIAlertAction(title: "Inappropriate", style: .default) { [weak self] _ in
            self?.submitReport(reason: "Inappropriate")
        })
        
        alert.addAction(UIAlertAction(title: "Harassment", style: .default) { [weak self] _ in
            self?.submitReport(reason: "Harassment")
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // iPad support
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
    
    private func submitReport(reason: String) {
        let alert = UIAlertController(
            title: "Thank You",
            message: "Your report has been submitted",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func handleGift(for post: Post) {
        // Check if user is logged in
        guard AuthService.shared.authState.isAuthenticated else {
            let alert = UIAlertController(
                title: "Login Required",
                message: "Please login to send gifts",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Login", style: .default) { [weak self] _ in
                let emailVC = EmailInputViewController()
                let navController = UINavigationController(rootViewController: emailVC)
                navController.modalPresentationStyle = .fullScreen
                self?.present(navController, animated: true)
            })
            present(alert, animated: true)
            return
        }
        
        let giftVC = GiftSelectionViewController()
        giftVC.modalPresentationStyle = .overFullScreen
        giftVC.modalTransitionStyle = .crossDissolve
        
        giftVC.onGiftSelected = { [weak self] gift in
            self?.sendGift(gift, to: post)
        }
        
        present(giftVC, animated: true)
    }
    
    private func sendGift(_ gift: Gift, to post: Post) {
        // Deduct coins from user
        guard var user = AuthService.shared.authState.currentUser else { return }
        guard user.coinBalance >= gift.coinCost else { return }
        
        user.coinBalance -= gift.coinCost
        AuthService.shared.authState.currentUser = user
        
        // Save coin balance persistently
        AuthService.shared.saveCoinBalance(user.coinBalance, for: user.id)
        
        // Update post gift count
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            posts[index].giftCount += 1
            
            // Save gift count persistently
            MockDataService.shared.saveGiftCount(posts[index].giftCount, for: post.id)
            
            // Reload the specific row
            let indexPath = IndexPath(row: index, section: 0)
            tableView.reloadRows(at: [indexPath], with: .none)
        }
        
        // Post notification for profile to update balance
        NotificationCenter.default.post(name: NSNotification.Name("UserDataUpdated"), object: nil)
        
        // Show success feedback
        let alert = UIAlertController(
            title: "Gift Sent!",
            message: "\(gift.icon) \(gift.name) sent successfully!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func handlePostTap(for post: Post) {
        let detailVC = PostDetailViewController(post: post)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
