//
//  HomeViewModel.h
//  lolo
//
//  Created on 2026/1/30.
//

#import <Foundation/Foundation.h>
@class Post, Activity, Venue;

NS_ASSUME_NONNULL_BEGIN

typedef void (^DataUpdatedBlock)(void);

@interface HomeViewModel : NSObject

@property (nonatomic, strong, readonly) NSArray<Post *> *posts;
@property (nonatomic, strong, readonly) NSArray<Activity *> *activities;
@property (nonatomic, strong, readonly) NSArray<Venue *> *venues;
@property (nonatomic, copy, nullable) DataUpdatedBlock onDataUpdated;

- (void)loadData;
- (void)addNewPost:(Post *)post;

@end

NS_ASSUME_NONNULL_END
