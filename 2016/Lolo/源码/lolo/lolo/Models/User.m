//
//  User.m
//  lolo
//
//  Created on 2026/1/30.
//

#import "User.h"

@implementation User

- (instancetype)initWithId:(NSString *)userId
                  username:(NSString *)username
                    avatar:(NSString *)avatar
                       bio:(NSString *)bio
            followersCount:(NSInteger)followersCount
            followingCount:(NSInteger)followingCount
             totalViews:(double)totalViews
             totalShares:(NSInteger)totalShares
             totalTips:(NSInteger)totalTips
              starsBalance:(NSInteger)starsBalance {
    self = [super init];
    if (self) {
        _userId = [userId copy];
        _username = [username copy];
        _avatar = [avatar copy];
        _bio = [bio copy];
        _followersCount = followersCount;
        _followingCount = followingCount;
        _totalViews = totalViews;
        _totalShares = totalShares;
        _totalTips = totalTips;
        _starsBalance = starsBalance;
    }
    return self;
}

@end
