import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Tab setup
        let exploreVC = ExploreViewController()
        exploreVC.tabBarItem = UITabBarItem(title: "Explore", image: UIImage(systemName: "safari"), selectedImage: UIImage(systemName: "safari.fill"))
        let exploreNav = UINavigationController(rootViewController: exploreVC)
        
        let designVC = DesignViewController()
        designVC.tabBarItem = UITabBarItem(title: "Design", image: UIImage(systemName: "paintbrush"), selectedImage: UIImage(systemName: "paintbrush.fill"))
        let designNav = UINavigationController(rootViewController: designVC)
        
        let myInkVC = MyInkViewController()
        myInkVC.tabBarItem = UITabBarItem(title: "My Ink", image: UIImage(systemName: "photo.on.rectangle"), selectedImage: UIImage(systemName: "photo.fill.on.rectangle.fill"))
        let myInkNav = UINavigationController(rootViewController: myInkVC)
        
        let settingsVC = SettingsViewController()
        settingsVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape"), selectedImage: UIImage(systemName: "gearshape.fill"))
        let settingsNav = UINavigationController(rootViewController: settingsVC)
        
        viewControllers = [exploreNav, designNav, myInkNav, settingsNav]
        
        // Appearance for proper Light Mode and Tab Bar Rendering
        tabBar.backgroundColor = .white
        tabBar.tintColor = .black
        tabBar.unselectedItemTintColor = .gray
        
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            
            // Set the explicitly desired colors for the item states
            let itemAppearance = UITabBarItemAppearance()
            itemAppearance.normal.iconColor = .gray
            itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]
            itemAppearance.selected.iconColor = .black
            itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.black]
            
            appearance.stackedLayoutAppearance = itemAppearance
            appearance.inlineLayoutAppearance = itemAppearance
            appearance.compactInlineLayoutAppearance = itemAppearance
            
            // Remove the default selection indicator image
            appearance.selectionIndicatorImage = UIImage()
            appearance.selectionIndicatorTintColor = .clear
            
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
        
        // Force classic tab bar mode on iOS 18 if available
        #if compiler(>=6.0)
        if #available(iOS 18.0, *) {
            self.mode = .tabBar
        }
        #endif
    }
}
