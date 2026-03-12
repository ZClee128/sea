//
//  ReportManager.m
//  lolo
//
//  Created for App Store compliance - Guideline 1.2
//

#import "ReportManager.h"
#import "Report.h"
#import "Post.h"
#import "User.h"
#import "DebugLogger.h"


@interface ReportManager()
@property (nonatomic, strong) NSMutableArray<Report *> *reports;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<NSString *> *> *blockedUsers; // userId -> [blockedUserIds]
@end

@implementation ReportManager

+ (instancetype)shared {
    static ReportManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _reports = [NSMutableArray array];
        _blockedUsers = [NSMutableDictionary dictionary];
        [self loadPersistedData];
    }
    return self;
}

#pragma mark - Report Content

- (void)reportPost:(Post *)post 
            reason:(NSString *)reason 
 additionalComments:(NSString *)comments
        reportedBy:(NSString *)userId {
    
    Report *report = [[Report alloc] initWithPostId:post.postId 
                                             userId:post.user.userId 
                                         reportedBy:userId 
                                             reason:reason];
    report.additionalComments = comments;
    
    [self.reports addObject:report];
    
    // Auto-flag the post
    post.isFlagged = YES;
    if (!post.reportReasons) {
        post.reportReasons = @[reason];
    } else {
        NSMutableArray *reasons = [post.reportReasons mutableCopy];
        [reasons addObject:reason];
        post.reportReasons = [reasons copy];
    }
    
    [self savePersistedData];
    
    DLog(@"📝 Post reported: %@ for reason: %@", post.postId, reason);
    
    // Simulate admin action (in real app, this would be server-side)
    [self notifyAdminOfReport:report];
}

- (void)notifyAdminOfReport:(Report *)report {
    // In a real app, this would send a notification to admin/moderation system
    DLog(@"🚨 ADMIN NOTIFICATION: New report received - ID: %@, Reason: %@", report.reportId, report.reason);
}

#pragma mark - Block User

- (void)blockUser:(User *)user blockedBy:(NSString *)currentUserId {
    if (!self.blockedUsers[currentUserId]) {
        self.blockedUsers[currentUserId] = [NSMutableArray array];
    }
    
    if (![self.blockedUsers[currentUserId] containsObject:user.userId]) {
        [self.blockedUsers[currentUserId] addObject:user.userId];
        [self savePersistedData];
        
        DLog(@"🚫 User %@ blocked by %@", user.userId, currentUserId);
    }
}

- (BOOL)isUserBlocked:(NSString *)userId byUser:(NSString *)currentUserId {
    return [self.blockedUsers[currentUserId] containsObject:userId];
}

- (NSArray<NSString *> *)blockedUserIdsForUser:(NSString *)userId {
    return self.blockedUsers[userId] ?: @[];
}

#pragma mark - Content Moderation

- (void)removePost:(Post *)post {
    post.isRemoved = YES;
    post.isFlagged = YES;
    
    [self savePersistedData];
    
    DLog(@"🗑 Post removed: %@", post.postId);
}

- (void)flagPost:(Post *)post {
    post.isFlagged = YES;
    [self savePersistedData];
    
    DLog(@"⚠️ Post flagged: %@", post.postId);
}

- (NSArray<Report *> *)getAllReports {
    return [self.reports copy];
}

- (NSArray<Report *> *)getUnresolvedReports {
    NSMutableArray *unresolved = [NSMutableArray array];
    for (Report *report in self.reports) {
        if (!report.isResolved) {
            [unresolved addObject:report];
        }
    }
    return unresolved;
}

- (BOOL)shouldHidePost:(Post *)post forUser:(NSString *)userId {
    // Hide if post is removed
    if (post.isRemoved) {
        return YES;
    }
    
    // Hide if post author is blocked by current user
    if ([self isUserBlocked:post.user.userId byUser:userId]) {
        return YES;
    }
    
    return NO;
}

#pragma mark - Persistence

- (void)loadPersistedData {
    // Load blocked users from UserDefaults
    NSDictionary *saved = [[NSUserDefaults standardUserDefaults] objectForKey:@"BlockedUsers"];
    if (saved) {
        self.blockedUsers = [saved mutableCopy];
    }
    
    // In a real app, reports would be loaded from server/database
    // For now, reports are only kept in memory during app session
}

- (void)savePersistedData {
    // Save blocked users to UserDefaults
    [[NSUserDefaults standardUserDefaults] setObject:self.blockedUsers forKey:@"BlockedUsers"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // In a real app, reports would be synced to server
}

@end
