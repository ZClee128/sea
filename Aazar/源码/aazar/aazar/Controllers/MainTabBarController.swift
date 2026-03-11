import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        } else {
            tabBar.isTranslucent = false
            tabBar.backgroundColor = .white
            tabBar.barTintColor = .white
        }
        
        tabBar.tintColor = .systemBlue
    }
    
    private func setupTabs() {
        let galleryVC = GalleryViewController()
        let galleryNav = UINavigationController(rootViewController: galleryVC)
        galleryNav.tabBarItem = UITabBarItem(title: "Discover", image: UIImage(systemName: "photo.on.rectangle.angled"), tag: 0)
        
        let moodboardVC = MoodboardViewController()
        let moodboardNav = UINavigationController(rootViewController: moodboardVC)
        moodboardNav.tabBarItem = UITabBarItem(title: "Moodboard", image: UIImage(systemName: "square.grid.2x2"), tag: 1)
        
        let collectionsVC = CollectionListViewController()
        let collectionsNav = UINavigationController(rootViewController: collectionsVC)
        collectionsNav.tabBarItem = UITabBarItem(title: "Boards", image: UIImage(systemName: "folder"), tag: 2)
        
        let masterclassVC = MasterclassViewController()
        let masterclassNav = UINavigationController(rootViewController: masterclassVC)
        masterclassNav.tabBarItem = UITabBarItem(title: "Classes", image: UIImage(systemName: "play.tv"), tag: 3)
        
        let settingsVC = SettingsViewController()
        let settingsNav = UINavigationController(rootViewController: settingsVC)
        settingsNav.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape"), tag: 4)
        
        viewControllers = [galleryNav, moodboardNav, collectionsNav, masterclassNav, settingsNav]
    }
}
