//
//  LifeProfileViewController.m (Updated with ProfileHeaderView)
//  lolo
//
//  Created on 2026/2/3.
//

#import "ViewControllers.h"
#import "Constants.h"
#import "ProfileViewModel.h"
#import "ProfileHeaderView.h"
#import "FeedCardCell.h"
#import "User.h"
#import "Post.h"
#import "SettingsViewController.h"

@interface LifeProfileViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) ProfileViewModel *viewModel;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) ProfileHeaderView *headerView;
@end

@implementation LifeProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Profile";
    self.view.backgroundColor = [LifeColors background];
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    
    // Add settings button
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"gearshape.fill"]
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(settingsTapped)];
    settingsButton.tintColor = [LifeColors primary];
    self.navigationItem.rightBarButtonItem = settingsButton;
    
    // Initialize ViewModel
    self.viewModel = [[ProfileViewModel alloc] init];
    
    // Setup UI
    [self setupHeaderView];
    [self setupTableView];
    [self setupBindings];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Reload data every time view appears to ensure fresh data after account deletion
    [self.viewModel loadData];
}

- (void)setupHeaderView {
    self.headerView = [[ProfileHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 480)];
    [self.headerView setNeedsLayout];
    [self.headerView layoutIfNeeded];
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [LifeColors background];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.estimatedRowHeight = 400;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.tableHeaderView = self.headerView;
    
    [self.tableView registerClass:[FeedCardCell class] forCellReuseIdentifier:@"FeedCardCell"];
    
    [self.view addSubview:self.tableView];
}

- (void)setupBindings {
    __weak typeof(self) weakSelf = self;
    self.viewModel.onDataUpdated = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.headerView configureWithUser:weakSelf.viewModel.currentUser];
            [weakSelf.tableView reloadData];
        });
    };
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.posts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FeedCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedCardCell" forIndexPath:indexPath];
    Post *post = self.viewModel.posts[indexPath.row];
    [cell configureWithPost:post];
    return cell;
}

#pragma mark - Actions

- (void)settingsTapped {
    SettingsViewController *settingsVC = [[SettingsViewController alloc] init];
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    navVC.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:navVC animated:YES completion:nil];
}

@end
