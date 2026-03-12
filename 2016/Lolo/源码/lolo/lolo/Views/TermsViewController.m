//
//  TermsViewController.m
//  lolo
//
//  Created on 2026/2/5.
//

#import "TermsViewController.h"
#import "Constants.h"

@interface TermsViewController ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UITextView *termsTextView;
@property (nonatomic, strong) UIButton *acceptButton;
@property (nonatomic, strong) UIButton *declineButton;
@end

@implementation TermsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Terms of Service";
    
    [self setupUI];
}

- (void)setupUI {
    CGFloat padding = [LifeSpacing medium];
    
    // Scroll view
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.scrollView];
    
    // Terms text view
    self.termsTextView = [[UITextView alloc] init];
    self.termsTextView.editable = NO;
    self.termsTextView.font = [UIFont systemFontOfSize:14];
    self.termsTextView.textColor = [LifeColors textPrimary];
    self.termsTextView.text = [self termsText];
    self.termsTextView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.termsTextView];
    
    // Accept button
    self.acceptButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.acceptButton setTitle:@"Accept and Continue" forState:UIControlStateNormal];
    self.acceptButton.titleLabel.font = [LifeFonts bodyBold];
    self.acceptButton.backgroundColor = [LifeColors primary];
    [self.acceptButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.acceptButton.layer.cornerRadius = [LifeCornerRadius standard];
    self.acceptButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.acceptButton addTarget:self action:@selector(acceptTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.acceptButton];
    
    // Decline button
    self.declineButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.declineButton setTitle:@"Decline" forState:UIControlStateNormal];
    self.declineButton.titleLabel.font = [LifeFonts body];
    [self.declineButton setTitleColor:[LifeColors textSecondary] forState:UIControlStateNormal];
    self.declineButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.declineButton addTarget:self action:@selector(declineTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.declineButton];
    
    // Constraints
    [NSLayoutConstraint activateConstraints:@[
        [self.termsTextView.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor constant:padding],
        [self.termsTextView.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor constant:padding],
        [self.termsTextView.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor constant:-padding],
        [self.termsTextView.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor constant:-2*padding],
        [self.termsTextView.heightAnchor constraintGreaterThanOrEqualToConstant:400],
        [self.termsTextView.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor constant:-padding],
        
        [self.acceptButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:padding],
        [self.acceptButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-padding],
        [self.acceptButton.bottomAnchor constraintEqualToAnchor:self.declineButton.topAnchor constant:-12],
        [self.acceptButton.heightAnchor constraintEqualToConstant:50],
        
        [self.declineButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.declineButton.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-padding],
        [self.declineButton.heightAnchor constraintEqualToConstant:44],
    ]];
}

- (NSString *)termsText {
    return @"TERMS OF SERVICE AND USER-GENERATED CONTENT POLICY\n\n"
           @"Welcome to our sports community app. By using this app, you agree to the following terms:\n\n"
           @"1. USER-GENERATED CONTENT POLICY\n\n"
           @"Our app allows users to create and share sports-related content. We are committed to maintaining a safe and respectful community.\n\n"
           @"WE HAVE ZERO TOLERANCE FOR:\n"
           @"• Objectionable, offensive, or inappropriate content\n"
           @"• Harassment, bullying, or threatening behavior\n"
           @"• Spam, scams, or misleading information\n"
           @"• Hate speech, discrimination, or violence\n"
           @"• Sexually explicit or suggestive content\n"
           @"• Content that violates others' intellectual property rights\n\n"
           @"2. CONTENT MODERATION\n\n"
           @"• All user-generated content is subject to review\n"
           @"• Users can report inappropriate content using the 'Report' feature available on all posts\n"
           @"• Our moderation team reviews all reports within 24 hours\n"
           @"• Violating users will be immediately banned from the platform\n"
          @"• We reserve the right to remove any content that violates these terms\n\n"
           @"3. REPORTING MECHANISM\n\n"
           @"If you encounter inappropriate content:\n"
           @"• Tap the menu icon (⋯) on any post\n"
           @"• Select 'Report'\n"
           @"• Choose the reason for reporting\n"
           @"• Our team will review and take action within 24 hours\n\n"
           @"4. USER RESPONSIBILITIES\n\n"
           @"By accepting these terms, you agree to:\n"
           @"• Only post content that you own or have rights to share\n"
           @"• Respect other users and the community guidelines\n"
           @"• Report any inappropriate content you encounter\n"
           @"• Not engage in any behavior that harms the community\n\n"
           @"5. CONSEQUENCES OF VIOLATIONS\n\n"
           @"Users who violate these terms will face:\n"
           @"• Immediate content removal\n"
           @"• Account suspension or permanent ban\n"
           @"• Possible legal action for severe violations\n\n"
           @"6. PRIVACY AND DATA\n\n"
           @"• We collect and use data as described in our Privacy Policy\n"
           @"• Your content may be visible to other users\n"
           @"• We do not sell your personal information\n\n"
           @"7. CHANGES TO TERMS\n\n"
           @"We may update these terms from time to time. Continued use of the app constitutes acceptance of updated terms.\n\n"
           @"By tapping 'Accept and Continue', you acknowledge that you have read, understood, and agree to be bound by these Terms of Service.\n\n"
           @"Last Updated: February 5, 2026";
}

- (void)acceptTapped {
    // Save acceptance
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasAcceptedTerms"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Notify delegate
    if (self.delegate && [self.delegate respondsToSelector:@selector(termsViewControllerDidAccept)]) {
        [self.delegate termsViewControllerDidAccept];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)declineTapped {
    UIAlertController *alert = [UIAlertController 
        alertControllerWithTitle:@"Terms Required"
        message:@"You must accept the Terms of Service to use this app."
        preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction 
        actionWithTitle:@"OK"
        style:UIAlertActionStyleDefault
        handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
