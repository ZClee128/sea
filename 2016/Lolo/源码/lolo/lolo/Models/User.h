//
//  User.h
//  lolo
//
//  Created on 2026/1/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface User : NSObject

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *bio;
@property (nonatomic, assign) NSInteger followersCount;
@property (nonatomic, assign) NSInteger followingCount;

// Sport stats
@property (nonatomic, assign) double totalViews; // in km
@property (nonatomic, assign) NSInteger totalShares;
@property (nonatomic, assign) NSInteger totalTips;

// User blocking and moderation (App Store Guideline 1.2)
@property (nonatomic, copy, nullable) NSArray<NSString *> *blockedUserIds;
@property (nonatomic, assign) BOOL isBlocked; // User is blocked by admin

// Stars system
@property (nonatomic, assign) NSInteger starsBalance;

- (instancetype)initWithId:(NSString *)userId
                  username:(NSString *)username
                    avatar:(NSString *)avatar
                       bio:(NSString *)bio
            followersCount:(NSInteger)followersCount
            followingCount:(NSInteger)followingCount
             totalViews:(double)totalViews
             totalShares:(NSInteger)totalShares
             totalTips:(NSInteger)totalTips
              starsBalance:(NSInteger)starsBalance;

@end

NS_ASSUME_NONNULL_END
