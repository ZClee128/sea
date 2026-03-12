//
//  TermsAgreementViewController.m
//  lolo
//
//  Created for App Store compliance - Guideline 1.2
//

#import "TermsAgreementViewController.h"
#import "TermsViewController.h"
#import "Constants.h"


@interface TermsAgreementViewController ()
@property (nonatomic, strong) UIButton *agreeButton;
@property (nonatomic, strong) UIButton *viewTermsButton;
@property (nonatomic, assign) BOOL hasAgreed;
@end

@implementation TermsAgreementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [LifeColors background];
    self.modalPresentationStyle = UIModalPresentationFullScreen;
    
    [self setupUI];
}

- (void)setupUI {
    CGFloat padding = [LifeSpacing medium];
    
    // Scroll view for content
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:scrollView];
    
    UIView *contentView = [[UIView alloc] init];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [scrollView addSubview:contentView];
    
    // Welcome label
    UILabel *welcomeLabel = [[UILabel alloc] init];
    welcomeLabel.text = @"Welcome to Lolo";
    welcomeLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightBold];
    welcomeLabel.textColor = [LifeColors textPrimary];
    welcomeLabel.textAlignment = NSTextAlignmentCenter;
    welcomeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:welcomeLabel];
    
    // Icon
    UIImageView *iconView = [[UIImageView alloc] init];
    iconView.image = [UIImage systemImageNamed:@"doc.text.fill"];
    iconView.tintColor = [LifeColors primary];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    iconView.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:iconView];
    
    // Main message
    UILabel *messageLabel = [[UILabel alloc] init];
    messageLabel.text = @"Terms of Service & Community Guidelines";
    messageLabel.font = [LifeFonts title];
    messageLabel.textColor = [LifeColors textPrimary];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.numberOfLines = 0;
    messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:messageLabel];
    
    // Important notice card
    UIView *noticeCard = [[UIView alloc] init];
    noticeCard.backgroundColor = [[UIColor systemRedColor] colorWithAlphaComponent:0.1];
    noticeCard.layer.cornerRadius = [LifeCornerRadius standard];
    noticeCard.layer.borderColor = [UIColor systemRedColor].CGColor;
    noticeCard.layer.borderWidth = 2;
    noticeCard.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:noticeCard];
    
    UILabel *importantLabel = [[UILabel alloc] init];
    importantLabel.text = @"⚠️ IMPORTANT";
    importantLabel.font = [LifeFonts bodyBold];
    importantLabel.textColor = [UIColor systemRedColor];
    importantLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [noticeCard addSubview:importantLabel];
    
    UILabel *noticeText = [[UILabel alloc] init];
    noticeText.text = @"We have ZERO TOLERANCE for:\n\n• Objectionable content\n• Abusive behavior\n• Harassment or bullying\n• Hate speech\n• Spam or misleading content\n\nViolations will result in immediate content removal and account termination.";
    noticeText.font = [LifeFonts body];
    noticeText.textColor = [LifeColors textPrimary];
    noticeText.numberOfLines = 0;
    noticeText.translatesAutoresizingMaskIntoConstraints = NO;
    [noticeCard addSubview:noticeText];
    
    // Features list
    UILabel *featuresLabel = [[UILabel alloc] init];
    featuresLabel.text = @"Community Safety Features:";
    featuresLabel.font = [LifeFonts bodyBold];
    featuresLabel.textColor = [LifeColors textPrimary];
    featuresLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:featuresLabel];
    
    UILabel *featuresList = [[UILabel alloc] init];
    featuresList.text = @"✓ Report inappropriate content\n✓ Block abusive users\n✓ 24-hour content review\n✓ Safe and respectful community";
    featuresList.font = [LifeFonts body];
    featuresList.textColor = [LifeColors textSecondary];
    featuresList.numberOfLines = 0;
    featuresList.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:featuresList];
    
    // View full terms button
    self.viewTermsButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.viewTermsButton setTitle:@"View Full Terms of Service" forState:UIControlStateNormal];
    self.viewTermsButton.titleLabel.font = [LifeFonts body];
    [self.viewTermsButton setTitleColor:[LifeColors primary] forState:UIControlStateNormal];
    self.viewTermsButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.viewTermsButton addTarget:self action:@selector(viewTermsTapped) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:self.viewTermsButton];
    
    // Agreement text
    UILabel *agreementLabel = [[UILabel alloc] init];
    agreementLabel.text = @"By tapping 'I Agree' below, you confirm that you have read and agree to our Terms of Service and commit to maintaining a safe, respectful community.";
    agreementLabel.font = [LifeFonts caption];
    agreementLabel.textColor = [LifeColors textSecondary];
    agreementLabel.textAlignment = NSTextAlignmentCenter;
    agreementLabel.numberOfLines = 0;
    agreementLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:agreementLabel];
    
    // Agree button
    self.agreeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.agreeButton setTitle:@"I Agree" forState:UIControlStateNormal];
    self.agreeButton.titleLabel.font = [LifeFonts bodyBold];
    self.agreeButton.backgroundColor = [LifeColors primary];
    [self.agreeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.agreeButton.layer.cornerRadius = [LifeCornerRadius standard];
    self.agreeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.agreeButton addTarget:self action:@selector(agreeTapped) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:self.agreeButton];
    
    // Constraints
    [NSLayoutConstraint activateConstraints:@[
        [contentView.topAnchor constraintEqualToAnchor:scrollView.topAnchor],
        [contentView.leadingAnchor constraintEqualToAnchor:scrollView.leadingAnchor],
        [contentView.trailingAnchor constraintEqualToAnchor:scrollView.trailingAnchor],
        [contentView.bottomAnchor constraintEqualToAnchor:scrollView.bottomAnchor],
        [contentView.widthAnchor constraintEqualToAnchor:scrollView.widthAnchor],
        
        [welcomeLabel.topAnchor constraintEqualToAnchor:contentView.topAnchor constant:60],
        [welcomeLabel.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:padding],
        [welcomeLabel.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-padding],
        
        [iconView.topAnchor constraintEqualToAnchor:welcomeLabel.bottomAnchor constant:padding],
        [iconView.centerXAnchor constraintEqualToAnchor:contentView.centerXAnchor],
        [iconView.widthAnchor constraintEqualToConstant:80],
        [iconView.heightAnchor constraintEqualToConstant:80],
        
        [messageLabel.topAnchor constraintEqualToAnchor:iconView.bottomAnchor constant:padding],
        [messageLabel.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:padding*2],
        [messageLabel.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-padding*2],
        
        [noticeCard.topAnchor constraintEqualToAnchor:messageLabel.bottomAnchor constant:padding*1.5],
        [noticeCard.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:padding],
        [noticeCard.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-padding],
        
        [importantLabel.topAnchor constraintEqualToAnchor:noticeCard.topAnchor constant:padding],
        [importantLabel.leadingAnchor constraintEqualToAnchor:noticeCard.leadingAnchor constant:padding],
        
        [noticeText.topAnchor constraintEqualToAnchor:importantLabel.bottomAnchor constant:8],
        [noticeText.leadingAnchor constraintEqualToAnchor:noticeCard.leadingAnchor constant:padding],
        [noticeText.trailingAnchor constraintEqualToAnchor:noticeCard.trailingAnchor constant:-padding],
        [noticeText.bottomAnchor constraintEqualToAnchor:noticeCard.bottomAnchor constant:-padding],
        
        [featuresLabel.topAnchor constraintEqualToAnchor:noticeCard.bottomAnchor constant:padding*1.5],
        [featuresLabel.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:padding],
        
        [featuresList.topAnchor constraintEqualToAnchor:featuresLabel.bottomAnchor constant:8],
        [featuresList.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:padding],
        [featuresList.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-padding],
        
        [self.viewTermsButton.topAnchor constraintEqualToAnchor:featuresList.bottomAnchor constant:padding],
        [self.viewTermsButton.centerXAnchor constraintEqualToAnchor:contentView.centerXAnchor],
        
        [agreementLabel.topAnchor constraintEqualToAnchor:self.viewTermsButton.bottomAnchor constant:padding*1.5],
        [agreementLabel.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:padding*2],
        [agreementLabel.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-padding*2],
        
        [self.agreeButton.topAnchor constraintEqualToAnchor:agreementLabel.bottomAnchor constant:padding],
        [self.agreeButton.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:padding*2],
        [self.agreeButton.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-padding*2],
        [self.agreeButton.heightAnchor constraintEqualToConstant:56],
        [self.agreeButton.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor constant:-padding*2],
    ]];
}

- (void)viewTermsTapped {
    TermsViewController *termsVC = [[TermsViewController alloc] init];
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:termsVC];
    [self presentViewController:navVC animated:YES completion:nil];
}

- (void)agreeTapped {
    // Save agreement to UserDefaults
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasAgreedToTerms"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Dismiss and let app continue to main interface
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TermsAgreed" object:nil];
    }];
}

// Prevent dismissing without agreeing
- (BOOL)modalPresentationCapturesStatusBarAppearance {
    return YES;
}

@end
