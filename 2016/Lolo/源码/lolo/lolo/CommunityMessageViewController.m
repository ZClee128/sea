//
//  CommunityMessageViewController.m (Updated with MessageCell)
//  lolo
//
//  Created on 2026/2/3.
//

#import "ViewControllers.h"
#import "Constants.h"
#import "MessageCell.h"
#import "DataService.h"
#import "User.h"
#import "Views/IM/ChatViewController.h"

@interface CommunityMessageViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<User *> *users;
@property (nonatomic, strong) NSArray<NSString *> *messages;
@property (nonatomic, strong) NSArray<NSString *> *times;
@end

@implementation CommunityMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Messages";
    self.view.backgroundColor = [LifeColors background];
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    
    // Sample data
    self.users = [[DataService shared] getUsers];
    self.messages = @[
        @"Hey! Want to join the morning run tomor...",
        @"Great cycling session today!",
        @"The yoga class schedule has been upda...",
        @"See you at the game!"
    ];
    self.times = @[@"38m ago", @"1h ago", @"2h ago", @"4h ago"];
    
    // Setup UI
    [self setupTableView];
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.rowHeight = 76;
    
    [self.tableView registerClass:[MessageCell class] forCellReuseIdentifier:@"MessageCell"];
    
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MIN(self.users.count, self.messages.count);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Filter out blocked users
    NSMutableArray *activeUsers = [NSMutableArray array];
    NSArray *allUsers = [[DataService shared] getUsers];
    
    for (User *user in allUsers) {
        if (![[DataService shared] isUserBlocked:user.userId]) {
            [activeUsers addObject:user];
        }
    }
    self.users = activeUsers;
    
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell" forIndexPath:indexPath];
    
    User *user = self.users[indexPath.row];
    NSString *lastMessage = [[DataService shared] getLastMessageForUser:user.userId];
    NSString *time = [[DataService shared] getLastMessageTimeForUser:user.userId];
    
    [cell configureWithAvatar:user.avatar
                         name:user.username
                      message:lastMessage
                         time:time];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    User *user = self.users[indexPath.row];
    ChatViewController *chatVC = [[ChatViewController alloc] initWithUser:user];
    chatVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatVC animated:YES];
}

@end
