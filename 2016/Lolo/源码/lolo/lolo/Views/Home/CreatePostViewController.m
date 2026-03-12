//
//  CreatePostViewController.m
//  lolo
//
//  Created on 2026/2/3.
//

#import "CreatePostViewController.h"
#import "Constants.h"
#import "DebugLogger.h"
#import "Post.h"
#import "User.h" 
#import "DataService.h"
#import "PremiumSubscriptionView.h"
#import <PhotosUI/PhotosUI.h>


#define STARS_PER_POST 0  // Posting is now FREE - stars used for other features

@interface CreatePostViewController () <UITextViewDelegate, PHPickerViewControllerDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UISegmentedControl *sportTypeControl;
@property (nonatomic, strong) UITextView *experienceTextView;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) UITextField *distanceField;
@property (nonatomic, strong) UITextField *durationField;
@property (nonatomic, strong) UITextField *caloriesField;
@property (nonatomic, strong) NSArray<NSString *> *categories;
@property (nonatomic, strong) UIButton *addMediaButton;
@property (nonatomic, strong) UIImageView *mediaPreviewImageView;
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) UILabel *starsLabel;
@end

@implementation CreatePostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Create Post";
    self.view.backgroundColor = [LifeColors background];
    
    // Sport types for segmented control
    self.categories = @[@"Running", @"Cycling", @"Swimming"];
    
    // Navigation buttons
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" 
                                                                     style:UIBarButtonItemStylePlain 
                                                                    target:self 
                                                                    action:@selector(cancelTapped)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem *postButton = [[UIBarButtonItem alloc] initWithTitle:@"Post" 
                                                                   style:UIBarButtonItemStyleDone 
                                                                  target:self 
                                                                  action:@selector(postTapped)];
    self.navigationItem.rightBarButtonItem = postButton;
    
    // Stars label in navigation bar
    self.starsLabel = [[UILabel alloc] init];
    self.starsLabel.font = [LifeFonts caption];
    self.starsLabel.textColor = [LifeColors textPrimary];
    [self updateStarsLabel];
    self.navigationItem.titleView = self.starsLabel;
    
    [self setupUI];
    
    // Listen for stars balance changes
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateStarsLabel)
                                                 name:@"StarsBalanceChanged"
                                               object:nil];
    
    // Keyboard observation
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillShow:) 
                                                 name:UIKeyboardWillShowNotification 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillHide:) 
                                                 name:UIKeyboardWillHideNotification 
                                               object:nil];
}

- (void)setupUI {
    CGFloat padding = [LifeSpacing medium];
    
    // Scroll view
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    [self.view addSubview:self.scrollView];
    
    self.contentView = [[UIView alloc] init];
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.contentView];
    
    // Sport Type Label
    UILabel *sportTypeLabel = [[UILabel alloc] init];
    sportTypeLabel.text = @"Sport Type";
    sportTypeLabel.font = [LifeFonts bodyBold];
    sportTypeLabel.textColor = [LifeColors textPrimary];
    sportTypeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:sportTypeLabel];
    
    // Segmented Control
    self.sportTypeControl = [[UISegmentedControl alloc] initWithItems:self.categories];
    self.sportTypeControl.selectedSegmentIndex = 0;
    self.sportTypeControl.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.sportTypeControl];
    
    // Experience Label
    UILabel *experienceLabel = [[UILabel alloc] init];
    experienceLabel.text = @"Share your experience";
    experienceLabel.font = [LifeFonts bodyBold];
    experienceLabel.textColor = [LifeColors textPrimary];
    experienceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:experienceLabel];
    
    // Experience TextView
    self.experienceTextView = [[UITextView alloc] init];
    self.experienceTextView.font = [LifeFonts body];
    self.experienceTextView.textColor = [LifeColors textPrimary];
    self.experienceTextView.backgroundColor = [UIColor whiteColor];
    self.experienceTextView.layer.cornerRadius = [LifeCornerRadius standard];
    self.experienceTextView.layer.borderColor = [LifeColors border].CGColor;
    self.experienceTextView.layer.borderWidth = 1;
    self.experienceTextView.textContainerInset = UIEdgeInsetsMake(12, 12, 12, 12);
    self.experienceTextView.delegate = self;
    self.experienceTextView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.experienceTextView];
    
    self.placeholderLabel = [[UILabel alloc] init];
    self.placeholderLabel.text = @"Share your experience...";
    self.placeholderLabel.font = [LifeFonts body];
    self.placeholderLabel.textColor = [LifeColors textSecondary];
    self.placeholderLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.experienceTextView addSubview:self.placeholderLabel];
    
    // Add Media Button
    self.addMediaButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.addMediaButton setTitle:@"📷 Add Photo or Video" forState:UIControlStateNormal];
    self.addMediaButton.titleLabel.font = [LifeFonts bodyBold];
    self.addMediaButton.backgroundColor = [LifeColors primary];
    [self.addMediaButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.addMediaButton.layer.cornerRadius = [LifeCornerRadius standard];
    self.addMediaButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.addMediaButton addTarget:self action:@selector(addMediaButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.addMediaButton];
    
    // Media Preview Image View
    self.mediaPreviewImageView = [[UIImageView alloc] init];
    self.mediaPreviewImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.mediaPreviewImageView.clipsToBounds = YES;
    self.mediaPreviewImageView.layer.cornerRadius = [LifeCornerRadius standard];
    self.mediaPreviewImageView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    self.mediaPreviewImageView.hidden = YES;
    self.mediaPreviewImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.mediaPreviewImageView];
    
    // Stats Label
    UILabel *statsLabel = [[UILabel alloc] init];
    statsLabel.text = @"Stats (Optional)";
    statsLabel.font = [LifeFonts bodyBold];
    statsLabel.textColor = [LifeColors textPrimary];
    statsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:statsLabel];
    
    // ViewsCount Field
    self.distanceField = [self createTextField:@"ViewsCount (km)"];
    self.distanceField.keyboardType = UIKeyboardTypeDecimalPad;
    [self.contentView addSubview:self.distanceField];
    
    // SavesCount Field
    self.durationField = [self createTextField:@"SavesCount (min)"];
    self.durationField.keyboardType = UIKeyboardTypeNumberPad;
    [self.contentView addSubview:self.durationField];
    
    // SharesCount Field
    self.caloriesField = [self createTextField:@"SharesCount"];
    self.caloriesField.keyboardType = UIKeyboardTypeNumberPad;
    [self.contentView addSubview:self.caloriesField];
    
    // Constraints
    [NSLayoutConstraint activateConstraints:@[
        [self.contentView.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor],
        [self.contentView.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor],
        [self.contentView.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor],
        [self.contentView.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor],
        [self.contentView.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor],
        
        [sportTypeLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:padding],
        [sportTypeLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:padding],
        
        [self.sportTypeControl.topAnchor constraintEqualToAnchor:sportTypeLabel.bottomAnchor constant:12],
        [self.sportTypeControl.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:padding],
        [self.sportTypeControl.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-padding],
        
        [experienceLabel.topAnchor constraintEqualToAnchor:self.sportTypeControl.bottomAnchor constant:padding*1.5],
        [experienceLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:padding],
        
        [self.experienceTextView.topAnchor constraintEqualToAnchor:experienceLabel.bottomAnchor constant:12],
        [self.experienceTextView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:padding],
        [self.experienceTextView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-padding],
        [self.experienceTextView.heightAnchor constraintEqualToConstant:160],
        
        [self.placeholderLabel.topAnchor constraintEqualToAnchor:self.experienceTextView.topAnchor constant:12],
        [self.placeholderLabel.leadingAnchor constraintEqualToAnchor:self.experienceTextView.leadingAnchor constant:16],
        
        [self.addMediaButton.topAnchor constraintEqualToAnchor:self.experienceTextView.bottomAnchor constant:padding],
        [self.addMediaButton.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:padding],
        [self.addMediaButton.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-padding],
        [self.addMediaButton.heightAnchor constraintEqualToConstant:50],
        
        [self.mediaPreviewImageView.topAnchor constraintEqualToAnchor:self.addMediaButton.bottomAnchor constant:padding],
        [self.mediaPreviewImageView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:padding],
        [self.mediaPreviewImageView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-padding],
        [self.mediaPreviewImageView.heightAnchor constraintEqualToConstant:200],
        
        [statsLabel.topAnchor constraintEqualToAnchor:self.mediaPreviewImageView.bottomAnchor constant:padding*1.5],
        [statsLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:padding],
        
        [self.distanceField.topAnchor constraintEqualToAnchor:statsLabel.bottomAnchor constant:12],
        [self.distanceField.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:padding],
        [self.distanceField.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-padding],
        [self.distanceField.heightAnchor constraintEqualToConstant:50],
        
        [self.durationField.topAnchor constraintEqualToAnchor:self.distanceField.bottomAnchor constant:12],
        [self.durationField.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:padding],
        [self.durationField.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-padding],
        [self.durationField.heightAnchor constraintEqualToConstant:50],
        
        [self.caloriesField.topAnchor constraintEqualToAnchor:self.durationField.bottomAnchor constant:12],
        [self.caloriesField.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:padding],
        [self.caloriesField.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-padding],
        [self.caloriesField.heightAnchor constraintEqualToConstant:50],
        [self.caloriesField.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-padding*2],
    ]];
}

- (UITextField *)createTextField:(NSString *)placeholder {
    UITextField *textField = [[UITextField alloc] init];
    textField.placeholder = placeholder;
    textField.font = [LifeFonts body];
    textField.textColor = [LifeColors textPrimary];
    textField.backgroundColor = [UIColor whiteColor];
    textField.layer.cornerRadius = [LifeCornerRadius standard];
    textField.layer.borderColor = [LifeColors border].CGColor;
    textField.layer.borderWidth = 1;
    textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, 0)];
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    return textField;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    self.placeholderLabel.hidden = textView.text.length > 0;
}

#pragma mark - Media Picker

- (void)addMediaButtonTapped {
    PHPickerConfiguration *config = [[PHPickerConfiguration alloc] initWithPhotoLibrary:[PHPhotoLibrary sharedPhotoLibrary]];
    
    // Support both images and videos
    NSMutableArray *filters = [NSMutableArray array];
    [filters addObject:[PHPickerFilter imagesFilter]];
    [filters addObject:[PHPickerFilter videosFilter]];
    config.filter = [PHPickerFilter anyFilterMatchingSubfilters:filters];
    
    config.selectionLimit = 1;
    config.preferredAssetRepresentationMode = PHPickerConfigurationAssetRepresentationModeCurrent;
    
    PHPickerViewController *picker = [[PHPickerViewController alloc] initWithConfiguration:config];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)picker:(PHPickerViewController *)picker didFinishPicking:(NSArray<PHPickerResult *> *)results {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    if (results.count == 0) {
        return; // User cancelled
    }
    
    PHPickerResult *result = results.firstObject;
    
    // Load image
    if ([result.itemProvider canLoadObjectOfClass:[UIImage class]]) {
        [result.itemProvider loadObjectOfClass:[UIImage class] completionHandler:^(__kindof id<NSItemProviderReading> _Nullable object, NSError * _Nullable error) {
            if ([object isKindOfClass:[UIImage class]]) {
                UIImage *image = (UIImage *)object;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.selectedImage = image;
                    self.mediaPreviewImageView.image = image;
                    self.mediaPreviewImageView.hidden = NO;
                    [self.addMediaButton setTitle:@"✓ Media Added (Tap to change)" forState:UIControlStateNormal];
                });
            }
        }];
    }
}

#pragma mark - Actions

- (void)updateStarsLabel {
    NSInteger stars = [[DataService shared] getCurrentUserStars];
    self.starsLabel.text = [NSString stringWithFormat:@"⭐️ %ld stars", (long)stars];
}

- (void)cancelTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)postTapped {
    // Posting is now FREE - no star check required
    /*
    if (![[DataService shared] hasEnoughStars:STARS_PER_POST]) {
        [self showInsufficientStarsAlert];
        return;
    }
    */
    
    // Validate and create post
    NSString *content = self.experienceTextView.text;
    if (content.length == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" 
                                                                       message:@"Please share your experience" 
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    NSString *category = self.categories[self.sportTypeControl.selectedSegmentIndex];
    
    // Get current user
    User *currentUser = [[DataService shared] getCurrentUser];
    
    // Parse stats
    NSNumber *viewsCount = self.distanceField.text.length > 0 ? @([self.distanceField.text doubleValue]) : @0;
    NSNumber *savesCount = self.durationField.text.length > 0 ? @([self.durationField.text integerValue]) : @0;
    NSNumber *sharesCount = self.caloriesField.text.length > 0 ? @([self.caloriesField.text integerValue]) : @0;
    
    // Save image to disk if user uploaded one
    NSString *savedImagePath = nil;
    if (self.selectedImage) {
        savedImagePath = [self saveImageToDisk:self.selectedImage];
    }
    
    // Create new post
    Post *newPost = [[Post alloc] initWithId:[[NSUUID UUID] UUIDString]
                                        user:currentUser
                                   category:category
                                     content:content
                                      images:savedImagePath ? @[savedImagePath] : @[@"placeholder.jpg" /* Using local asset instead of external URL */]
                                    videoUrl:nil
                                    viewsCount:viewsCount
                                    savesCount:savesCount
                                    sharesCount:sharesCount
                                  likesCount:0
                               commentsCount:0
                                   timestamp:[NSDate date]
                                    location:@"My Location"];
    
    // Store the actual uploaded image in memory for immediate display
    if (self.selectedImage) {
        newPost.selectedImage = self.selectedImage;
    }
    
    // Deduct stars for posting
    BOOL success = [[DataService shared] deductStars:STARS_PER_POST];
    if (!success) {
        // This shouldn't happen as we checked beforehand, but just in case
        DLog(@"Failed to deduct stars!");
    }
    
    DLog(@"Created post: %@, Sport: %@. Deducted %d stars.", content, category, STARS_PER_POST);
    
    // Notify delegate
    if (self.delegate && [self.delegate respondsToSelector:@selector(createPostViewController:didCreatePost:)]) {
        [self.delegate createPostViewController:self didCreatePost:newPost];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)saveImageToDisk:(UIImage *)image {
    // Get Documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    
    // Create unique filename
    NSString *filename = [NSString stringWithFormat:@"post_image_%@.jpg", [[NSUUID UUID] UUIDString]];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:filename];
    
    // Convert to JPEG data and save
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    BOOL success = [imageData writeToFile:filePath atomically:YES];
    
    if (success) {
        DLog(@"Successfully saved image to: %@", filePath);
        // Return ONLY the filename, not the full path
        return filename;
    } else {
        DLog(@"Failed to save image");
        return nil;
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)showInsufficientStarsAlert {
    NSInteger currentStars = [[DataService shared] getCurrentUserStars];
    NSString *message = [NSString stringWithFormat:@"You need %d stars to post, but you only have %ld stars. Would you like to buy more stars?", STARS_PER_POST, (long)currentStars];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Insufficient Stars"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Buy Stars" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        PremiumSubscriptionView *storeVC = [[PremiumSubscriptionView alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:storeVC];
        [self presentViewController:nav animated:YES completion:nil];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
