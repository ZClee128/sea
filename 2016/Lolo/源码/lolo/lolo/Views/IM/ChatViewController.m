//
//  ChatViewController.m
//  lolo
//
//  Created on 2026/2/3.
//

#import "ChatViewController.h"
#import "User.h"
#import "Constants.h"
#import "ImageLoader.h"
#import "Message.h" // We might need a Message model, or just use strings for now

#import "DataService.h"
#import "DebugLogger.h"

@interface ChatViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) UITableView *tableView;
// Remove local messages array, use getter to fetch from service
@property (nonatomic, strong) UIView *inputContainer;
@property (nonatomic, strong) UITextField *inputField;
@property (nonatomic, strong) NSLayoutConstraint *bottomConstraint;
@end

@implementation ChatViewController

- (instancetype)initWithUser:(User *)user {
    self = [super init];
    if (self) {
        _user = user;
    }
    return self;
}

- (NSArray<NSString *> *)messages {
    return [[DataService shared] getMessagesForUser:self.user.userId];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.user.username;
    self.view.backgroundColor = [LifeColors background];
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    
    // Menu button
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"ellipsis"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(showMenu)];
    self.navigationItem.rightBarButtonItem = menuButton;
    
    [self setupUI];
    [self setupKeyboardObservers];
    
    // Add tap gesture to dismiss keyboard
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)setupUI {
    // TableView
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [LifeColors background];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.tableView];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ChatCell"];
    
    // Input Container
    self.inputContainer = [[UIView alloc] init];
    self.inputContainer.backgroundColor = [UIColor whiteColor];
    self.inputContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.inputContainer];
    
    // Top border
    UIView *border = [[UIView alloc] init];
    border.backgroundColor = [LifeColors border];
    border.translatesAutoresizingMaskIntoConstraints = NO;
    [self.inputContainer addSubview:border];
    
    // Input Field
    self.inputField = [[UITextField alloc] init];
    self.inputField.placeholder = @"Message...";
    self.inputField.font = [LifeFonts body];
    self.inputField.borderStyle = UITextBorderStyleRoundedRect;
    self.inputField.delegate = self;
    self.inputField.translatesAutoresizingMaskIntoConstraints = NO;
    [self.inputContainer addSubview:self.inputField];
    
    // Send Button
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [sendButton setImage:[UIImage systemImageNamed:@"arrow.up.circle.fill"] forState:UIControlStateNormal];
    sendButton.tintColor = [LifeColors primary];
    [sendButton addTarget:self action:@selector(sendTapped) forControlEvents:UIControlEventTouchUpInside];
    sendButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.inputContainer addSubview:sendButton];
    
    // Constraints
    self.bottomConstraint = [self.inputContainer.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.inputContainer.topAnchor],
        
        [self.inputContainer.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.inputContainer.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        self.bottomConstraint,
        [self.inputContainer.heightAnchor constraintEqualToConstant:60],
        
        [border.topAnchor constraintEqualToAnchor:self.inputContainer.topAnchor],
        [border.leadingAnchor constraintEqualToAnchor:self.inputContainer.leadingAnchor],
        [border.trailingAnchor constraintEqualToAnchor:self.inputContainer.trailingAnchor],
        [border.heightAnchor constraintEqualToConstant:1],
        
        [self.inputField.leadingAnchor constraintEqualToAnchor:self.inputContainer.leadingAnchor constant:16],
        [self.inputField.centerYAnchor constraintEqualToAnchor:self.inputContainer.centerYAnchor],
        [self.inputField.heightAnchor constraintEqualToConstant:36],
        
        [sendButton.leadingAnchor constraintEqualToAnchor:self.inputField.trailingAnchor constant:12],
        [sendButton.trailingAnchor constraintEqualToAnchor:self.inputContainer.trailingAnchor constant:-16],
        [sendButton.centerYAnchor constraintEqualToAnchor:self.inputContainer.centerYAnchor],
        [sendButton.widthAnchor constraintEqualToConstant:30],
        [sendButton.heightAnchor constraintEqualToConstant:30],
    ]];
    
    // Add tap gesture to dismiss keyboard
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)setupKeyboardObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Keyboard

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    self.bottomConstraint.constant = -kbSize.height + self.view.safeAreaInsets.bottom;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
        [self scrollToBottom];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    self.bottomConstraint.constant = 0;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)sendTapped {
    NSString *text = self.inputField.text;
    if (text.length > 0) {
        [[DataService shared] addMessage:text forUser:self.user.userId isFromCurrentUser:YES];
        [self.tableView reloadData];
        self.inputField.text = @"";
        [self scrollToBottom];
    }
}

- (void)scrollToBottom {
    if (self.messages.count > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
} 

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    
    NSString *msg = self.messages[indexPath.row];
    BOOL isMyMessage = [msg hasPrefix:@"ME:"];
    NSString *displayMsg = isMyMessage ? [msg substringFromIndex:3] : msg;
    
    cell.textLabel.text = displayMsg; 
    cell.textLabel.numberOfLines = 0;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (!isMyMessage) {
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.textLabel.textColor = [UIColor blackColor];
    } else {
        cell.textLabel.textAlignment = NSTextAlignmentRight;
        cell.textLabel.textColor = [LifeColors primary];
    }
    
    return cell;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self sendTapped];
    return YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Menu Actions

- (void)showMenu {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil 
                                                                   message:nil 
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Report User" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self showReportConfirmation];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Block User" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self showBlockConfirmation];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showReportConfirmation {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Report User" 
                                                                   message:@"Why do you want to report this user?" 
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSArray *reasons = @[@"Spam", @"Inappropriate Content", @"Harassment", @"Fake Account"];
    
    for (NSString *reason in reasons) {
        [alert addAction:[UIAlertAction actionWithTitle:reason style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self performAction:@"Report" withReason:reason];
        }]];
    }
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showBlockConfirmation {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Block User" 
                                                                   message:[NSString stringWithFormat:@"Are you sure you want to block %@? You won't receive messages from them anymore.", self.user.username]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Block" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self performAction:@"Block" withReason:nil];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)performAction:(NSString *)actionType withReason:(NSString *)reason {
    NSString *log = reason ? [NSString stringWithFormat:@"%@ user %@ for: %@", actionType, self.user.username, reason] : [NSString stringWithFormat:@"%@ user %@", actionType, self.user.username];
    DLog(@"%@", log);
    
    // Simulate API call and block locally
    if ([actionType isEqualToString:@"Block"]) {
        [[DataService shared] blockUser:self.user.userId];
    }
    
    NSString *msg = [NSString stringWithFormat:@"User has been %@ed.", actionType.lowercaseString];
    if ([actionType isEqualToString:@"Report"]) {
        msg = @"Report submitted. Thank you for helping keep our community safe.";
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success" 
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([actionType isEqualToString:@"Block"]) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
