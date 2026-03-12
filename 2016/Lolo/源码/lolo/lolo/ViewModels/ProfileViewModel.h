//
//  ProfileViewModel.h
//  lolo
//
//  Created on 2026/1/30.
//

#import <Foundation/Foundation.h>
@class User, Post, HabitRecord;

NS_ASSUME_NONNULL_BEGIN

typedef void (^DataUpdatedBlock)(void);

@interface ProfileViewModel : NSObject

@property (nonatomic, strong, readonly) User *currentUser;
@property (nonatomic, strong, readonly) NSArray<Post *> *posts;
@property (nonatomic, strong, readonly) NSArray<HabitRecord *> *sportRecords;
@property (nonatomic, copy, nullable) DataUpdatedBlock onDataUpdated;

- (void)loadData;

@end

NS_ASSUME_NONNULL_END
