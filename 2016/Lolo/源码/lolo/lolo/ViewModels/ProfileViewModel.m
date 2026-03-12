//
//  ProfileViewModel.m
//  lolo
//
//  Created on 2026/1/30.
//

#import "ProfileViewModel.h"
#import "DataService.h"
#import "User.h"
#import "Post.h"
#import "LifeModels.h"

@interface ProfileViewModel ()
@property (nonatomic, strong, readwrite) User *currentUser;
@property (nonatomic, strong, readwrite) NSArray<Post *> *posts;
@property (nonatomic, strong, readwrite) NSArray<HabitRecord *> *sportRecords;
@end

@implementation ProfileViewModel

- (void)loadData {
    self.currentUser = [[DataService shared] getCurrentUser];
    // Get only current user's posts, not all posts (no mock data)
    self.posts = [[DataService shared] getCurrentUserPosts];
    self.sportRecords = [[DataService shared] getSportRecords];
    
    if (self.onDataUpdated) {
        self.onDataUpdated();
    }
}

@end
