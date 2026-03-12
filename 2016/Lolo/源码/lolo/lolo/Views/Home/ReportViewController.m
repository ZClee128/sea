//
//  ReportViewController.m
//  lolo
//
//  Created for App Store compliance - Guideline 1.2
//

#import "ReportViewController.h"
#import "Post.h"
#import "User.h"
#import "Constants.h"
#import "ReportManager.h"
#import "DebugLogger.h"

@interface ReportViewController () <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>
@property (nonatomic, strong) Post *post;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITextView *commentTextView;
@property (nonatomic, strong) NSArray<NSString *> *reportReasons;
@property (nonatomic, strong) NSString *selectedReason;
@end

@implementation ReportViewController

- (instancetype)initWithPost:(Post *)post {
    self = [super init];
    if (self) {
        _post = post;
        _reportReasons = @[
            @"Spam or misleading",
            @"Harassment or bullying",
            @"Hate speech or symbols",
            @"Violence or dangerous content",
            @"Nudity or sexual content",
            @"False information",
            @"Other"
        ];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Report Post";
    self.view.backgroundColor = [LifeColors background];
    
    // Cancel button
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" 
                                                                      style:UIBarButtonItemStylePlain 
                                                                     target:self 
                                                                     action:@selector(cancelTapped)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    [self setupUI];
}

- (void)setupUI {
    CGFloat padding = [LifeSpacing medium];
    
    // Header label
    UILabel *headerLabel = [[UILabel alloc] init];
    headerLabel.text = @"Why are you reporting this post?";
    headerLabel.font = [LifeFonts bodyBold];
    headerLabel.textColor = [LifeColors textPrimary];
    headerLabel.numberOfLines = 0;
    headerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:headerLabel];
    
    // Table view for reasons
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.layer.cornerRadius = [LifeCornerRadius standard];
    self.tableView.scrollEnabled = NO;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ReasonCell"];
    [self.view addSubview:self.tableView];
    
    // Additional comments label
    UILabel *commentsLabel = [[UILabel alloc] init];
    commentsLabel.text = @"Additional comments (optional)";
    commentsLabel.font = [LifeFonts body];
    commentsLabel.textColor = [LifeColors textPrimary];
    commentsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:commentsLabel];
    
    // Text view for comments
    self.commentTextView = [[UITextView alloc] init];
    self.commentTextView.font = [LifeFonts body];
    self.commentTextView.textColor = [LifeColors textPrimary];
    self.commentTextView.backgroundColor = [UIColor whiteColor];
    self.commentTextView.layer.cornerRadius = [LifeCornerRadius standard];
    self.commentTextView.layer.borderColor = [LifeColors border].CGColor;
    self.commentTextView.layer.borderWidth = 1;
    self.commentTextView.textContainerInset = UIEdgeInsetsMake(12, 12, 12, 12);
    self.commentTextView.delegate = self;
    self.commentTextView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.commentTextView];
    
    // Submit button
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [submitButton setTitle:@"Submit Report" forState:UIControlStateNormal];
    submitButton.titleLabel.font = [LifeFonts bodyBold];
    submitButton.backgroundColor = [LifeColors primary];
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    submitButton.layer.cornerRadius = [LifeCornerRadius standard];
    submitButton.translatesAutoresizingMaskIntoConstraints = NO;
    [submitButton addTarget:self action:@selector(submitTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:submitButton];
    
    // Block user button
    UIButton *blockButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [blockButton setTitle:@"Block User" forState:UIControlStateNormal];
    blockButton.titleLabel.font = [LifeFonts body];
    [blockButton setTitleColor:[UIColor systemRedColor] forState:UIControlStateNormal];
    blockButton.translatesAutoresizingMaskIntoConstraints = NO;
    [blockButton addTarget:self action:@selector(blockUserTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:blockButton];
    
    // Constraints
    CGFloat tableHeight = self.reportReasons.count * 44;
    
    [NSLayoutConstraint activateConstraints:@[
        [headerLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:padding],
        [headerLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:padding],
        [headerLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-padding],
        
        [self.tableView.topAnchor constraintEqualToAnchor:headerLabel.bottomAnchor constant:padding],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:padding],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-padding],
        [self.tableView.heightAnchor constraintEqualToConstant:tableHeight],
        
        [commentsLabel.topAnchor constraintEqualToAnchor:self.tableView.bottomAnchor constant:padding],
        [commentsLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:padding],
        
        [self.commentTextView.topAnchor constraintEqualToAnchor:commentsLabel.bottomAnchor constant:8],
        [self.commentTextView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:padding],
        [self.commentTextView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-padding],
        [self.commentTextView.heightAnchor constraintEqualToConstant:100],
        
        [submitButton.topAnchor constraintEqualToAnchor:self.commentTextView.bottomAnchor constant:padding],
        [submitButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:padding],
        [submitButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-padding],
        [submitButton.heightAnchor constraintEqualToConstant:50],
        
        [blockButton.topAnchor constraintEqualToAnchor:submitButton.bottomAnchor constant:padding],
        [blockButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
    ]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.reportReasons.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReasonCell" forIndexPath:indexPath];
    cell.textLabel.text = self.reportReasons[indexPath.row];
    cell.textLabel.font = [LifeFonts body];
    cell.textLabel.textColor = [LifeColors textPrimary];
    
    if ([self.reportReasons[indexPath.row] isEqualToString:self.selectedReason]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.selectedReason = self.reportReasons[indexPath.row];
    [self.tableView reloadData];
}

#pragma mark - Actions

- (void)cancelTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)submitTapped {
    if (!self.selectedReason) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select a Reason" 
                                                                       message:@"Please select a reason for reporting this post" 
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    // Submit report
    [[ReportManager shared] reportPost:self.post 
                                reason:self.selectedReason 
                     additionalComments:self.commentTextView.text 
                            reportedBy:@"current_user_id"]; // In real app, get actual user ID
    
    // Show confirmation
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Report Submitted" 
                                                                   message:@"Thank you for your report. We will review this content within 24 hours." 
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)blockUserTapped {
    NSString *username = self.post.user.username ?: @"this user";
    NSString *message = [NSString stringWithFormat:@"Are you sure you want to block %@? You will no longer see their posts.", username];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Block User" 
                                                                   message:message 
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Block" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [[ReportManager shared] blockUser:self.post.user blockedBy:@"current_user_id"]; // In real app, get actual user ID
        
        UIAlertController *confirmation = [UIAlertController alertControllerWithTitle:@"User Blocked" 
                                                                               message:[NSString stringWithFormat:@"You have blocked %@", username]
                                                                        preferredStyle:UIAlertControllerStyleAlert];
        [confirmation addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:confirmation animated:YES completion:nil];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
