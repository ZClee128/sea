//
//  Report.h
//  lolo
//
//  Created for App Store compliance - Guideline 1.2
//

#import <Foundation/Foundation.h>

@interface Report : NSObject

@property (nonatomic, strong) NSString *reportId;
@property (nonatomic, strong) NSString *reportedPostId;
@property (nonatomic, strong) NSString *reportedUserId;
@property (nonatomic, strong) NSString *reportedByUserId;
@property (nonatomic, strong) NSString *reason;
@property (nonatomic, strong) NSString *additionalComments;
@property (nonatomic, strong) NSDate *reportDate;
@property (nonatomic, assign) BOOL isResolved;

- (instancetype)initWithPostId:(NSString *)postId 
                        userId:(NSString *)userId
                     reportedBy:(NSString *)reportedBy
                        reason:(NSString *)reason;

@end
