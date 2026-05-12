//
//  MainTabBarController.swift
//  Scenery
//
//  Created on 2026/1/14.
//

import UIKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        setupTabs()
        customizeAppearance()
    }
    
    // MARK: - Tab Bar Delegate
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // Check if the tab requires authentication
        let restrictedTags = [2, 3, 4] // Post (tag 2) and Messages (tag 3)
        
        if restrictedTags.contains(viewController.tabBarItem.tag) {
            let authService = AuthService.shared
            if !authService.authState.isAuthenticated {
                // Not logged in, show login screen
                showLoginPrompt()
                return false
            }
        }
        
        return true
    }
    
    // MARK: - Setup
    
    private func setupTabs() {
        let homeVC = HomeViewController()
        let homeNav = UINavigationController(rootViewController: homeVC)
        homeNav.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        homeNav.tabBarItem.tag = 0
        
        let discoverVC = DiscoveryViewController()
        let discoverNav = UINavigationController(rootViewController: discoverVC)
        discoverNav.tabBarItem = UITabBarItem(
            title: "Discover",
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage: UIImage(systemName: "magnifyingglass")
        )
        discoverNav.tabBarItem.tag = 1
        
        let postVC = PostCreationViewController()
        let postNav = UINavigationController(rootViewController: postVC)
        postNav.tabBarItem = UITabBarItem(
            title: "Post",
            image: UIImage(systemName: "plus.circle"),
            selectedImage: UIImage(systemName: "plus.circle.fill")
        )
        postNav.tabBarItem.tag = 2
        
        let messagesVC = MessagesViewController()
        let messagesNav = UINavigationController(rootViewController: messagesVC)
        messagesNav.tabBarItem = UITabBarItem(
            title: "Messages",
            image: UIImage(systemName: "message"),
            selectedImage: UIImage(systemName: "message.fill")
        )
        messagesNav.tabBarItem.tag = 3
        
        let profileVC = ProfileViewController()
        let profileNav = UINavigationController(rootViewController: profileVC)
        profileNav.tabBarItem = UITabBarItem(
            title: "Me",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )
        profileNav.tabBarItem.tag = 4
        
        viewControllers = [homeNav, discoverNav, postNav, messagesNav, profileNav]
    }
    
    private func customizeAppearance() {
        // Tab bar tint color (green theme)
        tabBar.tintColor = UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1.0) // #2ECC71
        tabBar.unselectedItemTintColor = .gray
        
        // Tab Bar background
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .systemBackground
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        } else {
            tabBar.barTintColor = .systemBackground
            tabBar.isTranslucent = false
        }
    }
    
    private func showLoginPrompt() {
        let alert = UIAlertController(
            title: "Login Required",
            message: "Please login to access this feature",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Login", style: .default) { [weak self] _ in
            self?.showLoginFlow()
        })
        
        present(alert, animated: true)
    }
    
    private func showLoginFlow() {
        let emailVC = EmailInputViewController()
        let navController = UINavigationController(rootViewController: emailVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
}
