//
//  HomeViewModel.m
//  lolo
//
//  Created on 2026/1/30.
//

#import "HomeViewModel.h"
#import "DataService.h"
#import "Post.h"
#import "User.h"
#import "LifeModels.h"

@interface HomeViewModel ()
@property (nonatomic, strong, readwrite) NSArray<Post *> *posts;
@property (nonatomic, strong, readwrite) NSArray<Activity *> *activities;
@property (nonatomic, strong, readwrite) NSArray<Venue *> *venues;
@end

@implementation HomeViewModel

- (void)loadData {
    // Load all posts from DataService (includes user posts + mock data)
    NSArray *allPosts = [[DataService shared] getPosts];
    // Apply pinned sorting
    self.posts = [[DataService shared] sortPostsWithPinnedFirst:allPosts];
    self.activities = [[DataService shared] getActivities];
    self.venues = [[DataService shared] getVenues];
    
    if (self.onDataUpdated) {
        self.onDataUpdated();
    }
}

- (void)addNewPost:(Post *)post {
    // Posts are already managed by DataService
    // Just reload from DataService to get the updated list
    NSArray *allPosts = [[DataService shared] getPosts];
    self.posts = [[DataService shared] sortPostsWithPinnedFirst:allPosts];
    
    if (self.onDataUpdated) {
        self.onDataUpdated();
    }
}

@end
