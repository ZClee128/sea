//
//  ProfileHeaderView.m
//  lolo
//
//  Created on 2026/2/3.
//

#import "ProfileHeaderView.h"
#import "User.h"
#import "Constants.h"
#import "ImageLoader.h"
#import "DataService.h"
#import "PremiumSubscriptionView.h"


@interface ProfileHeaderView ()
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *bioLabel;
@property (nonatomic, strong) UILabel *followersLabel;
@property (nonatomic, strong) UILabel *followingLabel;
@property (nonatomic, strong) UIView *statsCard;
@property (nonatomic, strong) UILabel *distanceLabel;
@property (nonatomic, strong) UILabel *distanceValueLabel;
@property (nonatomic, strong) UILabel *caloriesLabel;
@property (nonatomic, strong) UILabel *caloriesValueLabel;
@property (nonatomic, strong) UILabel *workoutsLabel;
@property (nonatomic, strong) UILabel *workoutsValueLabel;
@property (nonatomic, strong) UILabel *starsLabel;
@property (nonatomic, strong) UIButton *buyStarsButton;
@property (nonatomic, weak) UIViewController *parentViewController;
@end

@implementation ProfileHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [LifeColors background];
        [self setupUI];
        
        // Listen for stars balance changes
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateStarsBalance)
                                                     name:@"StarsBalanceChanged"
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupUI {
    CGFloat padding = [LifeSpacing medium];
    
    // Avatar
    self.avatarImageView = [[UIImageView alloc] init];
    self.avatarImageView.layer.cornerRadius = 60;
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.backgroundColor = [UIColor lightGrayColor];
    self.avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.avatarImageView];
    
    // Name
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.font = [LifeFonts title];
    self.nameLabel.textColor = [LifeColors textPrimary];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.numberOfLines = 2; // Allow wrapping for long names
    self.nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.nameLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.nameLabel];
    
    // Bio
    self.bioLabel = [[UILabel alloc] init];
    self.bioLabel.font = [LifeFonts body];
    self.bioLabel.textColor = [LifeColors textSecondary];
    self.bioLabel.textAlignment = NSTextAlignmentCenter;
    self.bioLabel.numberOfLines = 2;
    self.bioLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.bioLabel];
    
    // Followers/Following
    UIStackView *followStack = [[UIStackView alloc] init];
    followStack.axis = UILayoutConstraintAxisHorizontal;
    followStack.distribution = UIStackViewDistributionFillEqually;
    followStack.spacing = 40;
    followStack.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:followStack];
    
    UIView *followersView = [self createStatView:@"" label:@"Followers"];
    UIView *followingView = [self createStatView:@"" label:@"Following"];
    [followStack addArrangedSubview:followersView];
    [followStack addArrangedSubview:followingView];
    
    // Get the value labels (first subview in each stat view)
    for (UIView *subview in followersView.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)subview;
            if (label.font.pointSize == 20) { // The value label has size 20
                self.followersLabel = label;
                break;
            }
        }
    }
    
    for (UIView *subview in followingView.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)subview;
            if (label.font.pointSize == 20) { // The value label has size 20
                self.followingLabel = label;
                break;
            }
        }
    }
    
    // Stars display and buy button
    UIView *starsContainer = [[UIView alloc] init];
    starsContainer.backgroundColor = [UIColor whiteColor];
    starsContainer.layer.cornerRadius = [LifeCornerRadius standard];
    starsContainer.layer.borderColor = [LifeColors primary].CGColor;
    starsContainer.layer.borderWidth = 2;
    starsContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:starsContainer];
    
    self.starsLabel = [[UILabel alloc] init];
    self.starsLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    self.starsLabel.textColor = [LifeColors textPrimary];
    self.starsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [starsContainer addSubview:self.starsLabel];
    
    self.buyStarsButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.buyStarsButton setTitle:@"Buy Stars" forState:UIControlStateNormal];
    self.buyStarsButton.titleLabel.font = [LifeFonts bodyBold];
    self.buyStarsButton.backgroundColor = [LifeColors primary];
    [self.buyStarsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.buyStarsButton.layer.cornerRadius = [LifeCornerRadius standard];
    self.buyStarsButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.buyStarsButton addTarget:self action:@selector(buyStarsButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [starsContainer addSubview:self.buyStarsButton];
    
    [self updateStarsBalance];
    
    // Stats card
    self.statsCard = [[UIView alloc] init];
    self.statsCard.backgroundColor = [UIColor whiteColor];
    self.statsCard.layer.cornerRadius = [LifeCornerRadius standard];
    self.statsCard.layer.shadowColor = [UIColor blackColor].CGColor;
    self.statsCard.layer.shadowOffset = CGSizeMake(0, 2);
    self.statsCard.layer.shadowOpacity = 0.1;
    self.statsCard.layer.shadowRadius = 8;
    self.statsCard.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.statsCard];
    
    // Sport Statistics label
    UILabel *statsTitle = [[UILabel alloc] init];
    statsTitle.text = @"";
    statsTitle.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    statsTitle.textColor = [LifeColors textPrimary];
    statsTitle.translatesAutoresizingMaskIntoConstraints = NO;
    [self.statsCard addSubview:statsTitle];
    
    // Stats  icons and values
    UIStackView *statsStack = [[UIStackView alloc] init];
    statsStack.axis = UILayoutConstraintAxisHorizontal;
    statsStack.distribution = UIStackViewDistributionFillEqually;
    statsStack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.statsCard addSubview:statsStack];
    
    UIView *distanceView = [self createStatsItemView:@"🏃" value:@"2847.5 km" label:@"ViewsCount"];
    UIView *caloriesView = [self createStatsItemView:@"🔥" value:@"145230 cal" label:@"SharesCount"];
    UIView *workoutsView = [self createStatsItemView:@"💪" value:@"386" label:@"Workouts"];
    [statsStack addArrangedSubview:distanceView];
    [statsStack addArrangedSubview:caloriesView];
    [statsStack addArrangedSubview:workoutsView];
    
    self.distanceValueLabel = distanceView.subviews[1];
    self.caloriesValueLabel = caloriesView.subviews[1];
    self.workoutsValueLabel = workoutsView.subviews[1];
    
    // Constraints
    [NSLayoutConstraint activateConstraints:@[
        [self.avatarImageView.topAnchor constraintEqualToAnchor:self.topAnchor constant:padding],
        [self.avatarImageView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [self.avatarImageView.widthAnchor constraintEqualToConstant:120],
        [self.avatarImageView.heightAnchor constraintEqualToConstant:120],
        
        [self.nameLabel.topAnchor constraintEqualToAnchor:self.avatarImageView.bottomAnchor constant:padding],
        [self.nameLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:padding*2],
        [self.nameLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-padding*2],
        [self.nameLabel.heightAnchor constraintGreaterThanOrEqualToConstant:50], // Fixed height to prevent compression
        
        [self.bioLabel.topAnchor constraintEqualToAnchor:self.nameLabel.bottomAnchor constant:4],
        [self.bioLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:padding*2],
        [self.bioLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-padding*2],
        
        [followStack.topAnchor constraintEqualToAnchor:self.bioLabel.bottomAnchor constant:padding],
        [followStack.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [followStack.widthAnchor constraintEqualToConstant:240],
        
        [starsContainer.topAnchor constraintEqualToAnchor:followStack.bottomAnchor constant:padding],
        [starsContainer.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:padding*2],
        [starsContainer.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-padding*2],
        [starsContainer.heightAnchor constraintEqualToConstant:50],
        
        [self.starsLabel.leadingAnchor constraintEqualToAnchor:starsContainer.leadingAnchor constant:padding],
        [self.starsLabel.centerYAnchor constraintEqualToAnchor:starsContainer.centerYAnchor],
        
        [self.buyStarsButton.trailingAnchor constraintEqualToAnchor:starsContainer.trailingAnchor constant:-padding],
        [self.buyStarsButton.centerYAnchor constraintEqualToAnchor:starsContainer.centerYAnchor],
        [self.buyStarsButton.widthAnchor constraintEqualToConstant:100],
        [self.buyStarsButton.heightAnchor constraintEqualToConstant:36],
        
        [self.statsCard.topAnchor constraintEqualToAnchor:starsContainer.bottomAnchor constant:padding],
        [self.statsCard.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:padding],
        [self.statsCard.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-padding],
        [self.statsCard.heightAnchor constraintEqualToConstant:120],
        [self.statsCard.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-padding],
        
        [statsTitle.topAnchor constraintEqualToAnchor:self.statsCard.topAnchor constant:padding],
        [statsTitle.leadingAnchor constraintEqualToAnchor:self.statsCard.leadingAnchor constant:padding],
        [statsTitle.trailingAnchor constraintLessThanOrEqualToAnchor:self.statsCard.trailingAnchor constant:-padding],
        
        [statsStack.topAnchor constraintEqualToAnchor:statsTitle.bottomAnchor constant:padding],
        [statsStack.leadingAnchor constraintEqualToAnchor:self.statsCard.leadingAnchor constant:padding],
        [statsStack.trailingAnchor constraintEqualToAnchor:self.statsCard.trailingAnchor constant:-padding],
        [statsStack.bottomAnchor constraintEqualToAnchor:self.statsCard.bottomAnchor constant:-padding],
        [statsStack.heightAnchor constraintEqualToConstant:80],
    ]];
}

- (UIView *)createStatView:(NSString *)value label:(NSString *)label {
    UIView *view = [[UIView alloc] init];
    
    UILabel *valueLabel = [[UILabel alloc] init];
    valueLabel.text = value;
    valueLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
    valueLabel.textColor = [LifeColors textPrimary];
    valueLabel.textAlignment = NSTextAlignmentCenter;
    valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:valueLabel];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = label;
    titleLabel.font = [LifeFonts body];
    titleLabel.textColor = [LifeColors textSecondary];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:titleLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [valueLabel.topAnchor constraintEqualToAnchor:view.topAnchor],
        [valueLabel.leadingAnchor constraintEqualToAnchor:view.leadingAnchor],
        [valueLabel.trailingAnchor constraintEqualToAnchor:view.trailingAnchor],
        
        [titleLabel.topAnchor constraintEqualToAnchor:valueLabel.bottomAnchor constant:2],
        [titleLabel.leadingAnchor constraintEqualToAnchor:view.leadingAnchor],
        [titleLabel.trailingAnchor constraintEqualToAnchor:view.trailingAnchor],
        [titleLabel.bottomAnchor constraintEqualToAnchor:view.bottomAnchor],
    ]];
    
    return view;
}

- (UIView *)createStatsItemView:(NSString *)icon value:(NSString *)value label:(NSString *)label {
    UIView *view = [[UIView alloc] init];
    
    UILabel *iconLabel = [[UILabel alloc] init];
    iconLabel.text = icon;
    iconLabel.font = [UIFont systemFontOfSize:32];
    iconLabel.textAlignment = NSTextAlignmentCenter;
    iconLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:iconLabel];
    
    UILabel *valueLabel = [[UILabel alloc] init];
    valueLabel.text = value;
    valueLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    valueLabel.textColor = [LifeColors primary];
    valueLabel.textAlignment = NSTextAlignmentCenter;
    valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:valueLabel];
    
   UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = label;
    titleLabel.font = [LifeFonts caption];
    titleLabel.textColor = [LifeColors textSecondary];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:titleLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [iconLabel.topAnchor constraintEqualToAnchor:view.topAnchor],
        [iconLabel.centerXAnchor constraintEqualToAnchor:view.centerXAnchor],
        [valueLabel.topAnchor constraintEqualToAnchor:iconLabel.bottomAnchor constant:4],
        [valueLabel.centerXAnchor constraintEqualToAnchor:view.centerXAnchor],
        [titleLabel.topAnchor constraintEqualToAnchor:valueLabel.bottomAnchor constant:2],
        [titleLabel.centerXAnchor constraintEqualToAnchor:view.centerXAnchor],
    ]];
    
    return view;
}

- (void)configureWithUser:(User *)user {
    self.nameLabel.text = user.username;
    self.bioLabel.text = user.bio;
    self.followersLabel.text = [NSString stringWithFormat:@"%ld", (long)user.followersCount];
    self.followingLabel.text = [NSString stringWithFormat:@"%ld", (long)user.followingCount];
    
    self.distanceValueLabel.text = [NSString stringWithFormat:@"%.1f km", user.totalViews];
    self.caloriesValueLabel.text = [NSString stringWithFormat:@"%ld cal", (long)user.totalShares];
    self.workoutsValueLabel.text = [NSString stringWithFormat:@"%ld", (long)user.totalTips];
    
    [self.avatarImageView loadImageFromURLString:user.avatar 
                                      placeholder:@"person.circle.fill" 
                                         username:user.username];
                                         
    // Store parent view controller for presenting star store
    UIResponder *responder = self.nextResponder;
    while (responder) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            self.parentViewController = (UIViewController *)responder;
            break;
        }
        responder = responder.nextResponder;
    }
}

- (void)updateStarsBalance {
    NSInteger stars = [[DataService shared] getCurrentUserStars];
    self.starsLabel.text = [NSString stringWithFormat:@"⭐️ %ld stars", (long)stars];
}

- (void)buyStarsButtonTapped {
    if (self.parentViewController) {
        PremiumSubscriptionView *storeVC = [[PremiumSubscriptionView alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:storeVC];
        [self.parentViewController presentViewController:nav animated:YES completion:nil];
    }
}

@end
