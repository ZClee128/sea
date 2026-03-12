//
//  Report.m
//  lolo
//
//  Created for App Store compliance - Guideline 1.2
//

#import "Report.h"

@implementation Report

- (instancetype)initWithPostId:(NSString *)postId 
                        userId:(NSString *)userId
                     reportedBy:(NSString *)reportedBy
                        reason:(NSString *)reason {
    self = [super init];
    if (self) {
        _reportId = [[NSUUID UUID] UUIDString];
        _reportedPostId = postId;
        _reportedUserId = userId;
        _reportedByUserId = reportedBy;
        _reason = reason;
        _reportDate = [NSDate date];
        _isResolved = NO;
    }
    return self;
}

@end
