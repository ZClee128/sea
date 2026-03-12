//
//  ReportManager.h
//  lolo
//
//  Created for App Store compliance - Guideline 1.2
//

#import <Foundation/Foundation.h>
@class Report;
@class Post;
@class User;

NS_ASSUME_NONNULL_BEGIN

@interface ReportManager : NSObject

+ (instancetype)shared;

// Report content
- (void)reportPost:(Post *)post 
            reason:(NSString *)reason 
 additionalComments:(nullable NSString *)comments
        reportedBy:(NSString *)userId;

// Block user
- (void)blockUser:(User *)user blockedBy:(NSString *)currentUserId;
- (BOOL)isUserBlocked:(NSString *)userId byUser:(NSString *)currentUserId;
- (NSArray<NSString *> *)blockedUserIdsForUser:(NSString *)userId;

// Content moderation
- (void)removePost:(Post *)post;
- (void)flagPost:(Post *)post;
- (NSArray<Report *> *)getAllReports;
- (NSArray<Report *> *)getUnresolvedReports;

// Check if content should be hidden
- (BOOL)shouldHidePost:(Post *)post forUser:(NSString *)userId;

@end

NS_ASSUME_NONNULL_END
