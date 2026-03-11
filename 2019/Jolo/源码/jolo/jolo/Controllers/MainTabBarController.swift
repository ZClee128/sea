import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Tabs
        let homeVC = HomeViewController()
        let homeNav = UINavigationController(rootViewController: homeVC)
        homeNav.tabBarItem = UITabBarItem(title: "Discover", image: UIImage(systemName: "safari"), selectedImage: UIImage(systemName: "safari.fill"))
        
        let storiesVC = StoriesViewController()
        let storiesNav = UINavigationController(rootViewController: storiesVC)
        storiesNav.tabBarItem = UITabBarItem(title: "Stories", image: UIImage(systemName: "rectangle.stack"), selectedImage: UIImage(systemName: "rectangle.stack.fill"))
        
        // Re-use Favorites VC but stylized as a Studio/Collection
        let studioVC = StudioViewController()
        let studioNav = UINavigationController(rootViewController: studioVC)
        studioNav.tabBarItem = UITabBarItem(title: "Studio", image: UIImage(systemName: "photo.on.rectangle.angled"), selectedImage: UIImage(systemName: "photo.fill.on.rectangle.fill"))
        
        let settingsVC = SettingsViewController()
        let settingsNav = UINavigationController(rootViewController: settingsVC)
        settingsNav.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "slider.horizontal.3"), selectedImage: UIImage(systemName: "slider.horizontal.3"))
        
        viewControllers = [homeNav, storiesNav, studioNav, settingsNav]
        
        // Premium Dark/Light Appearance with Blur
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground() // Uses system material blur
        
        // Customize unselected and selected icon colors for a high-end feel (black/dark gray)
        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = .systemGray
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemGray]
        itemAppearance.selected.iconColor = .label // Black in light mode, white in dark
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.label]
        
        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance
        
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
        
        // Ensure nav bars also have premium blur
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithDefaultBackground()
        navAppearance.largeTitleTextAttributes = [.font: UIFont.systemFont(ofSize: 34, weight: .black)]
        navAppearance.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 17, weight: .bold)]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().prefersLargeTitles = true
    }
}
