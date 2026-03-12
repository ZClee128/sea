//
//  PostDetailViewController.m
//  lolo
//
//  Created on 2026/2/3.
//

#import "PostDetailViewController.h"
#import "Post.h"
#import "User.h"
#import "Constants.h"
#import "ImageLoader.h"
#import "DebugLogger.h"
#import <AVFoundation/AVFoundation.h>

@interface PostDetailViewController ()
@property (nonatomic, strong) Post *post;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *locationLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIView *videoContainer;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) UIButton *playPauseButton;
@property (nonatomic, strong) UIView *statsContainer;
@property (nonatomic, strong) UILabel *commentsHeaderLabel;
@end

@implementation PostDetailViewController

- (instancetype)initWithPost:(Post *)post {
    self = [super init];
    if (self) {
        _post = post;
        
        // Observe app lifecycle for background playback
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appWillEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
    }
    return self;
}

- (void)appDidEnterBackground:(NSNotification *)notification {
    // Detach player from layer to allow background audio playback from video
    // This prevents the system from pausing the video when the view is not visible
    self.playerLayer.player = nil;
    
    if (self.player && self.player.rate > 0) {
        DLog(@"App entered background, detaching layer to continue audio");
    }
}

- (void)appWillEnterForeground:(NSNotification *)notification {
    // Reattach player to layer
    self.playerLayer.player = self.player;
    
    // Resume if was paused
    if (self.player && self.player.rate == 0) {
        [self.player play];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Details";
    self.view.backgroundColor = [LifeColors background];
    
    [self setupUI];
    [self configureWithPost:self.post];
    
    // Add menu button
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"ellipsis"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(showMenu)];
    self.navigationItem.rightBarButtonItem = menuButton;
}

- (void)setupUI {
    // Scroll view
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.scrollView];
    
    self.contentView = [[UIView alloc] init];
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.contentView];
    
    CGFloat padding = [LifeSpacing medium];
    
    // User header
    self.avatarImageView = [[UIImageView alloc] init];
    self.avatarImageView.layer.cornerRadius = 20;
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.backgroundColor = [UIColor lightGrayColor];
    self.avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.avatarImageView];
    
    self.usernameLabel = [[UILabel alloc] init];
    self.usernameLabel.font = [LifeFonts bodyBold];
    self.usernameLabel.textColor = [LifeColors textPrimary];
    self.usernameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.usernameLabel];
    
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.font = [LifeFonts caption];
    self.timeLabel.textColor = [LifeColors textSecondary];
    self.timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.timeLabel];
    
    self.locationLabel = [[UILabel alloc] init];
    self.locationLabel.font = [LifeFonts caption];
    self.locationLabel.textColor = [LifeColors primary];
    self.locationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.locationLabel];
    
    // Content text
    self.contentLabel = [[UILabel alloc] init];
    self.contentLabel.font = [LifeFonts body];
    self.contentLabel.textColor = [LifeColors textPrimary];
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.contentLabel];
    
    // Video container
    self.videoContainer = [[UIView alloc] init];
    self.videoContainer.backgroundColor = [UIColor blackColor];
    self.videoContainer.layer.cornerRadius = [LifeCornerRadius standard];
    self.videoContainer.clipsToBounds = YES;
    self.videoContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.videoContainer];
    
    self.playPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playPauseButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    self.playPauseButton.layer.cornerRadius = 30;
    [self.playPauseButton setImage:[UIImage systemImageNamed:@"play.fill"] forState:UIControlStateNormal];
    self.playPauseButton.tintColor = [LifeColors textPrimary];
    [self.playPauseButton addTarget:self action:@selector(playPauseTapped) forControlEvents:UIControlEventTouchUpInside];
    self.playPauseButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.videoContainer addSubview:self.playPauseButton];
    
    // Stats container
    self.statsContainer = [[UIView alloc] init];
    self.statsContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.statsContainer];
    
    UIStackView *statsStack = [[UIStackView alloc] init];
    statsStack.axis = UILayoutConstraintAxisHorizontal;
    statsStack.distribution = UIStackViewDistributionFillEqually;
    statsStack.spacing = padding;
    statsStack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.statsContainer addSubview:statsStack];
    
    // Comments header
    self.commentsHeaderLabel = [[UILabel alloc] init];
//    self.commentsHeaderLabel.text = @"Comments";
    self.commentsHeaderLabel.font = [LifeFonts headline];
    self.commentsHeaderLabel.textColor = [LifeColors textPrimary];
    self.commentsHeaderLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.commentsHeaderLabel];
    
    // Constraints
    [NSLayoutConstraint activateConstraints:@[
        [self.contentView.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor],
        [self.contentView.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor],
        [self.contentView.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor],
        [self.contentView.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor],
        [self.contentView.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor],
        
        [self.avatarImageView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:padding],
        [self.avatarImageView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:padding],
        [self.avatarImageView.widthAnchor constraintEqualToConstant:40],
        [self.avatarImageView.heightAnchor constraintEqualToConstant:40],
        
        [self.usernameLabel.topAnchor constraintEqualToAnchor:self.avatarImageView.topAnchor],
        [self.usernameLabel.leadingAnchor constraintEqualToAnchor:self.avatarImageView.trailingAnchor constant:12],
        
        [self.timeLabel.leadingAnchor constraintEqualToAnchor:self.usernameLabel.leadingAnchor],
        [self.timeLabel.topAnchor constraintEqualToAnchor:self.usernameLabel.bottomAnchor constant:2],
        
        [self.locationLabel.leadingAnchor constraintEqualToAnchor:self.timeLabel.trailingAnchor constant:8],
        [self.locationLabel.centerYAnchor constraintEqualToAnchor:self.timeLabel.centerYAnchor],
        
        [self.contentLabel.topAnchor constraintEqualToAnchor:self.avatarImageView.bottomAnchor constant:padding],
        [self.contentLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:padding],
        [self.contentLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-padding],
        
        [self.videoContainer.topAnchor constraintEqualToAnchor:self.contentLabel.bottomAnchor constant:padding],
        [self.videoContainer.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:padding],
        [self.videoContainer.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-padding],
        [self.videoContainer.heightAnchor constraintEqualToConstant:300],
        
        [self.playPauseButton.centerXAnchor constraintEqualToAnchor:self.videoContainer.centerXAnchor],
        [self.playPauseButton.centerYAnchor constraintEqualToAnchor:self.videoContainer.centerYAnchor],
        [self.playPauseButton.widthAnchor constraintEqualToConstant:60],
        [self.playPauseButton.heightAnchor constraintEqualToConstant:60],
        
        [self.statsContainer.topAnchor constraintEqualToAnchor:self.videoContainer.bottomAnchor constant:padding],
        [self.statsContainer.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:padding],
        [self.statsContainer.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-padding],
        [self.statsContainer.heightAnchor constraintEqualToConstant:60],
        
        [statsStack.topAnchor constraintEqualToAnchor:self.statsContainer.topAnchor],
        [statsStack.leadingAnchor constraintEqualToAnchor:self.statsContainer.leadingAnchor],
        [statsStack.trailingAnchor constraintEqualToAnchor:self.statsContainer.trailingAnchor],
        [statsStack.bottomAnchor constraintEqualToAnchor:self.statsContainer.bottomAnchor],
        
        [self.commentsHeaderLabel.topAnchor constraintEqualToAnchor:self.statsContainer.bottomAnchor constant:padding],
        [self.commentsHeaderLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:padding],
        [self.commentsHeaderLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-padding],
    ]];
}

- (void)configureWithPost:(Post *)post {
    [self.avatarImageView loadImageFromURLString:post.user.avatar 
                                      placeholder:@"person.circle.fill" 
                                         username:post.user.username];
    
    self.usernameLabel.text = post.user.username;
    self.timeLabel.text = @"13m ago";
    self.locationLabel.text = post.location;
    self.contentLabel.text = post.content;
    
    // Check if has image (either uploaded or URL)
    if (post.images.count > 0 && (!post.videoUrl || post.videoUrl.length == 0)) {
        NSString *imagePath = post.images.firstObject;
        
        // Hide video container for image posts
        self.videoContainer.hidden = NO; // Use it as image container
        self.playPauseButton.hidden = YES;
        
        // Create image view if needed
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.frame = self.videoContainer.bounds;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.videoContainer addSubview:imageView];
        
        // Load image - check if it's a saved local file
        if (![imagePath hasPrefix:@"http"]) {
            if ([imagePath hasPrefix:@"/"]) {
                // Absolute path
                UIImage *savedImage = [UIImage imageWithContentsOfFile:imagePath];
                imageView.image = savedImage ?: [UIImage systemImageNamed:@"photo"];
            } else {
                // Filename - reconstruct full path
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths firstObject];
                NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:imagePath];
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
                    UIImage *savedImage = [UIImage imageWithContentsOfFile:fullPath];
                    imageView.image = savedImage ?: [UIImage systemImageNamed:@"photo"];
                } else {
                    // Try loading from bundle
                    UIImage *bundleImage = [UIImage imageNamed:imagePath];
                    imageView.image = bundleImage ?: [UIImage systemImageNamed:@"photo"];
                }
            }
        } else {
            // URL image
            [imageView loadImageFromURLString:imagePath placeholder:@"photo" username:nil];
        }
        
        DLog(@"DetailVC: Loaded image from %@", imagePath);
    }
    // Setup video player
    else if (post.videoUrl && post.videoUrl.length > 0) {
        NSURL *videoURL;
        if ([post.videoUrl hasPrefix:@"http"]) {
            videoURL = [NSURL URLWithString:post.videoUrl];
        } else {
            videoURL = [[NSBundle mainBundle] URLForResource:post.videoUrl.stringByDeletingPathExtension 
                                                withExtension:post.videoUrl.pathExtension];
        }
        
        if (videoURL) {
            self.player = [AVPlayer playerWithURL:videoURL];
            self.player.allowsExternalPlayback = NO;
            self.player.automaticallyWaitsToMinimizeStalling = NO;
            
            self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
            self.playerLayer.frame = self.videoContainer.bounds;
            self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            [self.videoContainer.layer insertSublayer:self.playerLayer atIndex:0];
            
            // Auto play and loop
            [[NSNotificationCenter defaultCenter] addObserver:self 
                                                     selector:@selector(playerDidFinishPlaying:) 
                                                         name:AVPlayerItemDidPlayToEndTimeNotification 
                                                       object:self.player.currentItem];
            
            // Start playback
            [self.player play];
            self.playPauseButton.hidden = YES;
            
            DLog(@"Video player configured: %@", videoURL.lastPathComponent);
        }
    }
}

- (void)playerDidFinishPlaying:(NSNotification *)notification {
    [self.player seekToTime:kCMTimeZero];
    [self.player play];
}

- (void)playPauseTapped {
    if (self.player.rate > 0) {
        // Just hide the button, don't pause (for background playback)
        [self.playPauseButton setImage:[UIImage systemImageNamed:@"pause.fill"] forState:UIControlStateNormal];
        self.playPauseButton.alpha = 0.8;
    } else {
        [self.player play];
        [self.playPauseButton setImage:[UIImage systemImageNamed:@"pause.fill"] forState:UIControlStateNormal];
        self.playPauseButton.hidden = YES;
    }
}

- (void)showMenu {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil 
                                                                   message:nil 
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Report" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self showReportConfirmation];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showReportConfirmation {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Report Post" 
                                                                   message:@"Why do you want to report this post?" 
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSArray *reasons = @[@"Inappropriate Content", @"Spam", @"Harassment", @"Other"];
    
    for (NSString *reason in reasons) {
        [alert addAction:[UIAlertAction actionWithTitle:reason style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self submitReport:reason];
        }]];
    }
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)submitReport:(NSString *)reason {
    // Here you would implement actual reporting logic (API call)
    DLog(@"Reporting post %@ for reason: %@", self.post.postId, reason);
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Report Submitted" 
                                                                   message:@"Thank you for your report. We will review this content shortly." 
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.playerLayer.frame = self.videoContainer.bounds;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
