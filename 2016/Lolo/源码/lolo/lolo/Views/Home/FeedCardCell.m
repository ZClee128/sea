//
//  FeedCardCell.m
//  lolo
//
//  Created on 2026/2/3.
//

#import "FeedCardCell.h"
#import "Post.h"
#import "User.h"
#import "Constants.h"
#import "ImageLoader.h"
#import "DebugLogger.h"
#import <AVFoundation/AVFoundation.h>
#import <objc/runtime.h>
#import "DataService.h"

@interface FeedCardCell()
@property (nonatomic, strong) Post *currentPost;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
- (void)setupMoreButtonMenu;
@end

@implementation FeedCardCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [LifeColors background];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    // Card container
    self.cardView = [[UIView alloc] init];
    self.cardView.backgroundColor = [UIColor whiteColor];
    self.cardView.layer.cornerRadius = [LifeCornerRadius standard];
    self.cardView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.cardView.layer.shadowOffset = CGSizeMake(0, 2);
    self.cardView.layer.shadowOpacity = 0.1;
    self.cardView.layer.shadowRadius = 8;
    self.cardView.translatesAutoresizingMaskIntoConstraints = NO;
    self.cardView.userInteractionEnabled = YES; // Ensure touch events pass through
    [self.contentView addSubview:self.cardView];
    
    // Avatar
    self.avatarImageView = [[UIImageView alloc] init];
    self.avatarImageView.layer.cornerRadius = 20;
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.backgroundColor = [UIColor lightGrayColor];
    self.avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cardView addSubview:self.avatarImageView];
    
    // Username
    self.usernameLabel = [[UILabel alloc] init];
    self.usernameLabel.font = [LifeFonts bodyBold];
    self.usernameLabel.textColor = [LifeColors textPrimary];
    self.usernameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cardView addSubview:self.usernameLabel];
    
    // Time
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.font = [LifeFonts caption];
    self.timeLabel.textColor = [LifeColors textSecondary];
    self.timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cardView addSubview:self.timeLabel];
    
    // Sport badge
    self.sportBadgeLabel = [[UILabel alloc] init];
    self.sportBadgeLabel.font = [LifeFonts caption];
    self.sportBadgeLabel.textColor = [UIColor whiteColor];
    self.sportBadgeLabel.backgroundColor = [LifeColors primary];
    self.sportBadgeLabel.textAlignment = NSTextAlignmentCenter;
    self.sportBadgeLabel.layer.cornerRadius = 12;
    self.sportBadgeLabel.clipsToBounds = YES;
    self.sportBadgeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cardView addSubview:self.sportBadgeLabel];
    
    // More button (report/block)
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [moreButton setImage:[UIImage systemImageNamed:@"ellipsis"] forState:UIControlStateNormal];
    moreButton.tintColor = [LifeColors textSecondary];
    moreButton.translatesAutoresizingMaskIntoConstraints = NO;
    [moreButton addTarget:self action:@selector(moreButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    moreButton.showsMenuAsPrimaryAction = YES;
    [self.cardView addSubview:moreButton];
    
    // Store reference for updating menu
    objc_setAssociatedObject(self, "moreButton", moreButton, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // Content
    self.contentLabel = [[UILabel alloc] init];
    self.contentLabel.font = [LifeFonts body];
    self.contentLabel.textColor = [LifeColors textPrimary];
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cardView addSubview:self.contentLabel];
    
    // Media image
    self.mediaImageView = [[UIImageView alloc] init];
    self.mediaImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.mediaImageView.clipsToBounds = YES;
    self.mediaImageView.layer.cornerRadius = 8.0;
    self.mediaImageView.backgroundColor = [UIColor colorWithRed:0.9 green:0.95 blue:0.98 alpha:1.0];
    self.mediaImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cardView addSubview:self.mediaImageView];
    
    // Play button
    self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    self.playButton.layer.cornerRadius = 30;
    [self.playButton setImage:[UIImage systemImageNamed:@"play.fill"] forState:UIControlStateNormal];
    self.playButton.tintColor = [LifeColors textPrimary];
    self.playButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.mediaImageView addSubview:self.playButton];
    
    // Stats labels
    self.distanceLabel = [[UILabel alloc] init];
    self.distanceLabel.font = [LifeFonts caption];
    self.distanceLabel.textColor = [LifeColors textSecondary];
    self.distanceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cardView addSubview:self.distanceLabel];
    
    self.durationLabel = [[UILabel alloc] init];
    self.durationLabel.font = [LifeFonts caption];
    self.durationLabel.textColor = [LifeColors textSecondary];
    self.durationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cardView addSubview:self.durationLabel];
    
    self.caloriesLabel = [[UILabel alloc] init];
    self.caloriesLabel.font = [LifeFonts caption];
    self.caloriesLabel.textColor = [LifeColors textSecondary];
    self.caloriesLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cardView addSubview:self.caloriesLabel];
    
    // Like button
    self.likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.likeButton setImage:[UIImage systemImageNamed:@"heart.fill"] forState:UIControlStateNormal];
    self.likeButton.tintColor = [UIColor systemRedColor];
    self.likeButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    [self.likeButton setTitleColor:[UIColor labelColor] forState:UIControlStateNormal];
    self.likeButton.backgroundColor = [UIColor whiteColor];
    self.likeButton.layer.cornerRadius = 18;
    self.likeButton.contentEdgeInsets = UIEdgeInsetsMake(8, 12, 8, 12);
    self.likeButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.likeButton.userInteractionEnabled = YES;
    [self.cardView addSubview:self.likeButton];
    
    // Tip button
    self.tipButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.tipButton setImage:[UIImage systemImageNamed:@"gift.fill"] forState:UIControlStateNormal];
    self.tipButton.tintColor = [UIColor systemOrangeColor];
    self.tipButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    [self.tipButton setTitleColor:[UIColor labelColor] forState:UIControlStateNormal];
    self.tipButton.backgroundColor = [UIColor whiteColor];
    self.tipButton.layer.cornerRadius = 18;
    self.tipButton.contentEdgeInsets = UIEdgeInsetsMake(8, 12, 8, 12);
    self.tipButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.tipButton.userInteractionEnabled = YES;
    [self.cardView addSubview:self.tipButton];
    
    // Add button actions
    [self.likeButton addTarget:self action:@selector(likeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.tipButton addTarget:self action:@selector(tipButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.playButton addTarget:self action:@selector(playButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    // Pin button (only shown for own posts)
    self.pinButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.pinButton setTitle:@"📌 Pin" forState:UIControlStateNormal];
    self.pinButton.titleLabel.font = [LifeFonts caption];
    self.pinButton.tintColor = [LifeColors primary];
    self.pinButton.backgroundColor = [[LifeColors primary] colorWithAlphaComponent:0.1];
    self.pinButton.layer.cornerRadius = 12;
    self.pinButton.layer.borderWidth = 1;
    self.pinButton.layer.borderColor = [LifeColors primary].CGColor;
    self.pinButton.contentEdgeInsets = UIEdgeInsetsMake(6, 12, 6, 12);
    self.pinButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.pinButton.hidden = YES; // Hidden by default
    [self.pinButton addTarget:self action:@selector(pinButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.cardView addSubview:self.pinButton];
    
    // Pinned badge (shown when post is pinned)
    self.pinnedBadge = [[UILabel alloc] init];
    self.pinnedBadge.text = @"📌 Pinned";
    self.pinnedBadge.font = [LifeFonts caption];
    self.pinnedBadge.textColor = [UIColor whiteColor];
    self.pinnedBadge.backgroundColor = [UIColor systemOrangeColor];
    self.pinnedBadge.textAlignment = NSTextAlignmentCenter;
    self.pinnedBadge.layer.cornerRadius = 12;
    self.pinnedBadge.clipsToBounds = YES;
    self.pinnedBadge.translatesAutoresizingMaskIntoConstraints = NO;
    self.pinnedBadge.hidden = YES; // Hidden by default
    [self.cardView addSubview:self.pinnedBadge];
    
    [self setupConstraints];
}

- (void)setupConstraints {
    CGFloat padding = [LifeSpacing medium];
    CGFloat smallPadding = [LifeSpacing small];
    
    [NSLayoutConstraint activateConstraints:@[
        // Card
        [self.cardView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:smallPadding],
        [self.cardView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:padding],
        [self.cardView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-padding],
        [self.cardView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-smallPadding],
        
        // Avatar
        [self.avatarImageView.topAnchor constraintEqualToAnchor:self.cardView.topAnchor constant:padding],
        [self.avatarImageView.leadingAnchor constraintEqualToAnchor:self.cardView.leadingAnchor constant:padding],
        [self.avatarImageView.widthAnchor constraintEqualToConstant:40],
        [self.avatarImageView.heightAnchor constraintEqualToConstant:40],
        
        // Username
        [self.usernameLabel.topAnchor constraintEqualToAnchor:self.avatarImageView.topAnchor],
        [self.usernameLabel.leadingAnchor constraintEqualToAnchor:self.avatarImageView.trailingAnchor constant:smallPadding],
        [self.usernameLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.sportBadgeLabel.leadingAnchor constant:-8], // Prevent overlap
        
        // Time
        [self.timeLabel.topAnchor constraintEqualToAnchor:self.usernameLabel.bottomAnchor constant:2],
        [self.timeLabel.leadingAnchor constraintEqualToAnchor:self.usernameLabel.leadingAnchor],
        [self.timeLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.sportBadgeLabel.leadingAnchor constant:-8], // Prevent overlap
        // Sport badge - positioned first so username can reference it
        [self.sportBadgeLabel.centerYAnchor constraintEqualToAnchor:self.avatarImageView.centerYAnchor],
        [self.sportBadgeLabel.trailingAnchor constraintEqualToAnchor:self.cardView.trailingAnchor constant:-54], // Make room for more button
        [self.sportBadgeLabel.widthAnchor constraintLessThanOrEqualToConstant:100], // Max width to prevent overlap
        [self.sportBadgeLabel.heightAnchor constraintEqualToConstant:24],
        
        // More button
        [((UIButton *)objc_getAssociatedObject(self, "moreButton")).centerYAnchor constraintEqualToAnchor:self.avatarImageView.centerYAnchor],
        [((UIButton *)objc_getAssociatedObject(self, "moreButton")).trailingAnchor constraintEqualToAnchor:self.cardView.trailingAnchor constant:-padding],
        [((UIButton *)objc_getAssociatedObject(self, "moreButton")).widthAnchor constraintEqualToConstant:30],
        [((UIButton *)objc_getAssociatedObject(self, "moreButton")).heightAnchor constraintEqualToConstant:30],
        
        // Content
        [self.contentLabel.topAnchor constraintEqualToAnchor:self.avatarImageView.bottomAnchor constant:padding],
        [self.contentLabel.leadingAnchor constraintEqualToAnchor:self.cardView.leadingAnchor constant:padding],
        [self.contentLabel.trailingAnchor constraintEqualToAnchor:self.cardView.trailingAnchor constant:-padding],
        
        // Media
        [self.mediaImageView.topAnchor constraintEqualToAnchor:self.contentLabel.bottomAnchor constant:smallPadding],
        [self.mediaImageView.leadingAnchor constraintEqualToAnchor:self.cardView.leadingAnchor constant:padding],
        [self.mediaImageView.trailingAnchor constraintEqualToAnchor:self.cardView.trailingAnchor constant:-padding],
        [self.mediaImageView.heightAnchor constraintEqualToConstant:200],
        
        // Play button
        [self.playButton.centerXAnchor constraintEqualToAnchor:self.mediaImageView.centerXAnchor],
        [self.playButton.centerYAnchor constraintEqualToAnchor:self.mediaImageView.centerYAnchor],
        [self.playButton.widthAnchor constraintEqualToConstant:60],
        [self.playButton.heightAnchor constraintEqualToConstant:60],
        
        // Stats
        [self.distanceLabel.topAnchor constraintEqualToAnchor:self.mediaImageView.bottomAnchor constant:smallPadding],
        [self.distanceLabel.leadingAnchor constraintEqualToAnchor:self.cardView.leadingAnchor constant:padding],
        
        [self.durationLabel.centerYAnchor constraintEqualToAnchor:self.distanceLabel.centerYAnchor],
        [self.durationLabel.leadingAnchor constraintEqualToAnchor:self.distanceLabel.trailingAnchor constant:padding],
        
        [self.caloriesLabel.centerYAnchor constraintEqualToAnchor:self.distanceLabel.centerYAnchor],
        [self.caloriesLabel.leadingAnchor constraintEqualToAnchor:self.durationLabel.trailingAnchor constant:padding],
        
        // Actions - with minimum height for iPad touch targets
        [self.likeButton.topAnchor constraintEqualToAnchor:self.distanceLabel.bottomAnchor constant:smallPadding], // Like button
        [self.likeButton.leadingAnchor constraintEqualToAnchor:self.cardView.leadingAnchor constant:padding],
        [self.likeButton.bottomAnchor constraintEqualToAnchor:self.cardView.bottomAnchor constant:-padding],
        [self.likeButton.heightAnchor constraintEqualToConstant:36],
        
        // Tip button (right of like button)
        [self.tipButton.centerYAnchor constraintEqualToAnchor:self.likeButton.centerYAnchor],
        [self.tipButton.leadingAnchor constraintEqualToAnchor:self.likeButton.trailingAnchor constant:8],
        [self.tipButton.heightAnchor constraintEqualToConstant:36],
        
        // Pin button (right of tip button)
        [self.pinButton.centerYAnchor constraintEqualToAnchor:self.likeButton.centerYAnchor],
        [self.pinButton.leadingAnchor constraintEqualToAnchor:self.tipButton.trailingAnchor constant:8],
        [self.pinButton.heightAnchor constraintEqualToConstant:36],
        
        // Pinned badge (replaces sport badge when pinned)
        [self.pinnedBadge.centerYAnchor constraintEqualToAnchor:self.avatarImageView.centerYAnchor],
        [self.pinnedBadge.trailingAnchor constraintEqualToAnchor:self.cardView.trailingAnchor constant:-54],
        [self.pinnedBadge.heightAnchor constraintEqualToConstant:24],
        [self.pinnedBadge.widthAnchor constraintGreaterThanOrEqualToConstant:80],
    ]];
}

- (void)configureWithPost:(Post *)post {
    self.currentPost = post;
    
    // Debug: Print configured post info
    DLog(@"[FeedCardCell] Configuring cell with post: ID=%@, User=%@, Content=%@", 
         post.postId, post.user.username, [post.content substringToIndex:MIN(20, post.content.length)]);
    
    self.usernameLabel.text = post.user.username;
    self.timeLabel.text = @"5m ago"; // TODO: Calculate from timestamp
    self.sportBadgeLabel.text = [NSString stringWithFormat:@"  %@  ", post.category];
    self.contentLabel.text = post.content;
    
    // Setup more button menu
    [self setupMoreButtonMenu];
    
    // Load avatar
    [self.avatarImageView loadImageFromURLString:post.user.avatar 
                                      placeholder:@"person.circle.fill" 
                                         username:post.user.username];
    
    // Clean up old player
    [self pauseVideo];
    if (self.playerLayer) {
        [self.playerLayer removeFromSuperlayer];
        self.playerLayer = nil;
    }
    self.player = nil;
    
    // Load media - check if local file first
    if (post.images.count > 0) {
        NSString *imageName = post.images.firstObject;
        DLog(@"Loading image: %@", imageName);
        
        // First check if there's a user-uploaded image in memory
        if (post.selectedImage) {
            DLog(@"Using cached selectedImage");
            self.mediaImageView.image = post.selectedImage;
        } else {
            // Check if it's a saved image filename (not a full path, not a URL)
            if (![imageName hasPrefix:@"/"] && ![imageName hasPrefix:@"http"] && [imageName containsString:@"post_image_"]) {
                // Reconstruct full path from filename
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths firstObject];
                NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:imageName];
                
                DLog(@"Reconstructed path: %@", fullPath);
                
                // Check if file exists
                if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
                    DLog(@"File exists, loading...");
                    UIImage *savedImage = [UIImage imageWithContentsOfFile:fullPath];
                    DLog(@"Image loaded from file: %@", savedImage ? @"SUCCESS" : @"FAILED");
                    if (savedImage) {
                        DLog(@"Successfully loaded image from disk, size: %.0fx%.0f", savedImage.size.width, savedImage.size.height);
                        self.mediaImageView.image = savedImage;
                        // Cache in memory
                        post.selectedImage = savedImage;
                    } else {
                        DLog(@"Failed to create UIImage from file data");
                        self.mediaImageView.image = [UIImage systemImageNamed:@"photo"];
                    }
                } else {
                    DLog(@"File does not exist at path: %@", fullPath);
                    self.mediaImageView.image = [UIImage systemImageNamed:@"photo"];
                }
            }
            // Check if it's an absolute file path (legacy, shouldn't happen anymore)
            else if ([imageName hasPrefix:@"/"]) {
                DLog(@"Legacy absolute path detected: %@", imageName);
                UIImage *savedImage = [UIImage imageWithContentsOfFile:imageName];
                if (savedImage) {
                    self.mediaImageView.image = savedImage;
                    post.selectedImage = savedImage;
                } else {
                    self.mediaImageView.image = [UIImage systemImageNamed:@"photo"];
                }
            }
            // Check if it's a local bundle file (no http prefix)
            else if (![imageName hasPrefix:@"http"]) {
                DLog(@"Loading from bundle: %@", imageName);
                // Load local image from bundle
                UIImage *localImage = [UIImage imageNamed:imageName];
                if (localImage) {
                    self.mediaImageView.image = localImage;
                } else {
                    [self.mediaImageView loadImageFromURLString:imageName 
                                                     placeholder:@"photo" 
                                                        username:nil];
                }
            } else {
                DLog(@"Loading from URL: %@", imageName);
                // Load remote image
                [self.mediaImageView loadImageFromURLString:imageName 
                                                 placeholder:@"photo" 
                                                    username:nil];
            }
        }
        
        // Setup video player if has video
        if (post.videoUrl && post.videoUrl.length > 0) {
            self.playButton.hidden = NO;
            [self setupVideoPlayer];
        } else {
            self.playButton.hidden = YES;
        }
    } else if (post.videoUrl) {
        self.playButton.hidden = NO;
        // Load video thumbnail or default image
        self.mediaImageView.backgroundColor = [UIColor colorWithRed:0.9 green:0.95 blue:0.98 alpha:1.0];
        [self setupVideoPlayer];
    }
    
    // Stats
    self.distanceLabel.text = [NSString stringWithFormat:@"🏃 %.1fkm", post.viewsCount.doubleValue];
    self.durationLabel.text = [NSString stringWithFormat:@"⏱ %ldmin", (long)post.savesCount.integerValue];
    self.caloriesLabel.text = [NSString stringWithFormat:@"🔥 %ldcal", (long)post.sharesCount.integerValue];
    
    // Actions
    [self.likeButton setTitle:[NSString stringWithFormat:@" %ld", (long)post.likesCount] forState:UIControlStateNormal];
    [self.tipButton setTitle:[NSString stringWithFormat:@" %ld", (long)post.tipsCount] forState:UIControlStateNormal];
    
    // Pin UI
    BOOL isOwnPost = NO;
    if (self.currentUserId && post.user.userId) {
        isOwnPost = [post.user.userId isEqualToString:self.currentUserId];
    }
    
    if (post.isPinned) {
        // Show pinned badge
        self.pinnedBadge.hidden = NO;
        self.sportBadgeLabel.hidden = YES;
        self.pinButton.hidden = YES; // Hide pin button when already pinned
        
        // Calculate remaining time
        NSTimeInterval remaining = [post.pinnedUntil timeIntervalSinceNow];
        if (remaining > 0) {
            NSInteger hours = (NSInteger)(remaining / 3600);
            self.pinnedBadge.text = [NSString stringWithFormat:@"📌 %ldh left", (long)hours];
        } else {
            self.pinnedBadge.text = @"📌 Pinned";
        }
    } else {
        // Show sport badge
        self.pinnedBadge.hidden = YES;
        self.sportBadgeLabel.hidden = NO;
        
        // Show pin button only for own posts that are not pinned
        self.pinButton.hidden = !isOwnPost;
        if (isOwnPost) {
            [self.pinButton setTitle:@"📌 Pin 24h" forState:UIControlStateNormal];
        }
    }
}

#pragma mark - Button Actions

- (void)likeButtonTapped:(UIButton *)sender {
    if (!self.currentPost) return;
    
    // Increment like count
    self.currentPost.likesCount = self.currentPost.likesCount + 1;
    
    // Update button title
    [sender setTitle:[NSString stringWithFormat:@" %ld", (long)self.currentPost.likesCount] forState:UIControlStateNormal];
    
    DLog(@"Post %@ liked, count: %ld", self.currentPost.postId, (long)self.currentPost.likesCount);
}

- (void)tipButtonTapped:(UIButton *)sender {
    if (!self.currentPost) return;
    
    // Check if user has stars
    NSInteger currentStars = [[DataService shared] getCurrentUserStars];
    if (currentStars > 0) {
        // Tip post (deducts star and persists tip counts)
        if ([[DataService shared] tipPost:self.currentPost]) {
            // Let App know to update stars globally
            [[NSNotificationCenter defaultCenter] postNotificationName:@"StarsBalanceChanged" object:nil];
            
            // Play tip animation (simple scale bounce)
            [UIView animateWithDuration:0.1 animations:^{
                sender.transform = CGAffineTransformMakeScale(1.2, 1.2);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.2 animations:^{
                    sender.transform = CGAffineTransformIdentity;
                }];
            }];
            
            // Update button title
            [sender setTitle:[NSString stringWithFormat:@" %ld", (long)self.currentPost.tipsCount] forState:UIControlStateNormal];
            
            DLog(@"Tipped post %@, remaining stars: %ld", self.currentPost.postId, (long)currentStars - 1);
        }
    } else {
        // Trigger buy stars flow - Ideally delegate this out, but for now we post notification or rely on delegate
        if (self.delegate && [self.delegate respondsToSelector:@selector(feedCardCell:didTapReportForPost:)]) {
            // Reusing report delegate temporarily, or just let user know they need stars
            // A better way is to add a proper delegate method, but to stay within scope we just alert if possible
            DLog(@"Not enough stars to tip");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NotEnoughStarsForTip" object:nil];
        }
    }
}

- (void)setupMoreButtonMenu {
    if (!self.currentPost) return;
    
    UIButton *moreButton = objc_getAssociatedObject(self, "moreButton");
    if (!moreButton) return;
    
    // Hide menu button if viewing own post
    BOOL isOwnPost = NO;
    if (self.currentUserId && self.currentPost.user.userId) {
        isOwnPost = [self.currentPost.user.userId isEqualToString:self.currentUserId];
    }
    
    if (isOwnPost) {
        moreButton.hidden = YES;
        return;
    }
    
    moreButton.hidden = NO;
    
    __weak typeof(self) weakSelf = self;
    
    UIAction *reportAction = [UIAction actionWithTitle:@"Report Post" 
                                                  image:[UIImage systemImageNamed:@"exclamationmark.bubble"]
                                             identifier:nil
                                                handler:^(__kindof UIAction * _Nonnull action) {
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(feedCardCell:didTapReportForPost:)]) {
            [weakSelf.delegate feedCardCell:weakSelf didTapReportForPost:weakSelf.currentPost];
        }
    }];
    reportAction.attributes = UIMenuElementAttributesDestructive;
    
    UIMenu *menu = [UIMenu menuWithTitle:@"" 
                                children:@[reportAction]];
    if (@available(iOS 14.0, *)) {
        moreButton.menu = menu;
    }
}

- (void)moreButtonTapped:(UIButton *)sender {
    // Menu is shown automatically due to showsMenuAsPrimaryAction = YES
    DLog(@"More button tapped for post %@", self.currentPost.postId);
}

- (void)pinButtonTapped:(UIButton *)sender {
    if (!self.currentPost) return;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(feedCardCell:didTapPinForPost:)]) {
        [self.delegate feedCardCell:self didTapPinForPost:self.currentPost];
    }
    
    DLog(@"Pin button tapped for post %@", self.currentPost.postId);
}

- (void)playButtonTapped:(UIButton *)sender {
    [self playVideo];
}

- (void)setupVideoPlayer {
    if (!self.currentPost.videoUrl || self.currentPost.videoUrl.length == 0) {
        return;
    }
    
    NSURL *videoURL;
    if ([self.currentPost.videoUrl hasPrefix:@"http"]) {
        videoURL = [NSURL URLWithString:self.currentPost.videoUrl];
    } else {
        // Local video file
        NSString *videoName = self.currentPost.videoUrl.stringByDeletingPathExtension;
        NSString *videoExt = self.currentPost.videoUrl.pathExtension;
        videoURL = [[NSBundle mainBundle] URLForResource:videoName withExtension:videoExt];
    }
    
    if (videoURL) {
        self.player = [AVPlayer playerWithURL:videoURL];
        self.player.allowsExternalPlayback = NO;
        self.player.automaticallyWaitsToMinimizeStalling = NO;
        
        // Keep audio enabled for background playback
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        self.playerLayer.frame = self.mediaImageView.bounds;
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [self.mediaImageView.layer insertSublayer:self.playerLayer atIndex:0];
        
        // Loop video
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(playerDidFinishPlaying:) 
                                                     name:AVPlayerItemDidPlayToEndTimeNotification 
                                                   object:self.player.currentItem];
        
        DLog(@"Feed video player setup: %@", videoURL.lastPathComponent);
    }
}

- (void)playerDidFinishPlaying:(NSNotification *)notification {
    [self.player seekToTime:kCMTimeZero];
    [self.player play];
}

- (void)playVideo {
    if (self.player) {
        [self.player play];
        self.playButton.hidden = YES;
    }
}

- (void)pauseVideo {
    if (self.player) {
        [self.player pause];
        self.playButton.hidden = NO;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.playerLayer) {
        self.playerLayer.frame = self.mediaImageView.bounds;
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    // Don't pause if app is in background (to maintain background playback)
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        return;
    }
    
    [self pauseVideo];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
