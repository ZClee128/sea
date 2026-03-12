//
//  DailyLifeTabBarController.m
//  lolo
//
//  Created on 2026/1/30.
//

#import "DailyLifeTabBarController.h"

#import "Constants.h"
#import "ViewControllers.h"

@implementation DailyLifeTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupTabs];
    [self customizeAppearance];
}

- (void)setupTabs {
    // Home Tab
    LifeHacksFeedViewController *homeVC = [[LifeHacksFeedViewController alloc] init];
    UINavigationController *homeNav = [[UINavigationController alloc] initWithRootViewController:homeVC];
    homeNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Home"
                                                       image:[UIImage systemImageNamed:@"house"]
                                                selectedImage:[UIImage systemImageNamed:@"house.fill"]];
    
    // IM Tab
    CommunityMessageViewController *imVC = [[CommunityMessageViewController alloc] init];
    UINavigationController *imNav = [[UINavigationController alloc] initWithRootViewController:imVC];
    imNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Messages"
                                                     image:[UIImage systemImageNamed:@"message"]
                                              selectedImage:[UIImage systemImageNamed:@"message.fill"]];
    
    // Profile Tab
    LifeProfileViewController *profileVC = [[LifeProfileViewController alloc] init];
    UINavigationController *profileNav = [[UINavigationController alloc] initWithRootViewController:profileVC];
    profileNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Profile"
                                                          image:[UIImage systemImageNamed:@"person"]
                                                   selectedImage:[UIImage systemImageNamed:@"person.fill"]];
    
    self.viewControllers = @[homeNav, imNav, profileNav];
}

- (void)customizeAppearance {
    UITabBarAppearance *appearance = [[UITabBarAppearance alloc] init];
    [appearance configureWithOpaqueBackground];
    appearance.backgroundColor = [UIColor whiteColor];
    
    // Customize selected item color
    appearance.stackedLayoutAppearance.selected.iconColor = [LifeColors primary];
    appearance.stackedLayoutAppearance.selected.titleTextAttributes = @{
        NSForegroundColorAttributeName: [LifeColors primary]
    };
    
    // Customize normal item color
    appearance.stackedLayoutAppearance.normal.iconColor = [LifeColors textSecondary];
    appearance.stackedLayoutAppearance.normal.titleTextAttributes = @{
        NSForegroundColorAttributeName: [LifeColors textSecondary]
    };
    
    self.tabBar.standardAppearance = appearance;
    
    // scrollEdgeAppearance is only available in iOS 15+
    if (@available(iOS 15.0, *)) {
        self.tabBar.scrollEdgeAppearance = appearance;
    }
    
    // Add subtle shadow
    self.tabBar.layer.shadowColor = [UIColor blackColor].CGColor;
    self.tabBar.layer.shadowOpacity = 0.1;
    self.tabBar.layer.shadowOffset = CGSizeMake(0, -2);
    self.tabBar.layer.shadowRadius = 8;
}

@end
