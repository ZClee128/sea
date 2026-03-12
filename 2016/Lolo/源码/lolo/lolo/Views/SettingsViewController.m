//
//  SettingsViewController.m
//  lolo
//
//  Created on 2026/2/5.
//

#import "SettingsViewController.h"
#import "DataService.h"
#import "Constants.h"
#import "User.h"


@interface SettingsViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Settings";
    self.view.backgroundColor = [LifeColors background];
    
    // Add close button
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(closeTapped)];
    self.navigationItem.leftBarButtonItem = closeButton;
    
    [self setupTableView];
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleInsetGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [LifeColors background];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.tableView];
}

- (void)closeTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1; // Only "Delete Account" for now
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"SettingsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        cell.textLabel.text = @"Delete Account";
        cell.textLabel.textColor = [UIColor systemRedColor];
        cell.textLabel.font = [LifeFonts body];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self showDeleteAccountConfirmation];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Account";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @"Deleting your account will permanently remove all your data including posts, messages, and profile information. This action cannot be undone.";
}

#pragma mark - Account Deletion

- (void)showDeleteAccountConfirmation {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete Account?"
                                                                   message:@"This will permanently delete all your data including:\n\n• All posts you've created\n• All messages\n• Your profile information\n\nThis action cannot be undone."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Delete"
                                              style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction * _Nonnull action) {
        [self performAccountDeletion];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)performAccountDeletion {
    // Delete all user data
    [[DataService shared] deleteCurrentUserAccount];
    
    // Dismiss settings
    [self dismissViewControllerAnimated:YES completion:^{
        // Notify app delegate to reset to terms screen
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AccountDeleted" object:nil];
    }];
}

@end
