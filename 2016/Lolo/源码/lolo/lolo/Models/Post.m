//
//  Post.m
//  lolo
//
//  Created on 2026/1/30.
//

#import "Post.h"
#import "User.h"

@implementation Post

- (instancetype)initWithId:(NSString *)postId
                      user:(User *)user
                 category:(NSString *)category
                   content:(NSString *)content
                    images:(NSArray<NSString *> *)images
                  videoUrl:(nullable NSString *)videoUrl
                  viewsCount:(nullable NSNumber *)viewsCount
                  savesCount:(nullable NSNumber *)savesCount
                  sharesCount:(nullable NSNumber *)sharesCount
                likesCount:(NSInteger)likesCount
             commentsCount:(NSInteger)commentsCount
                 timestamp:(NSDate *)timestamp
                  location:(nullable NSString *)location {
    self = [super init];
    if (self) {
        _postId = [postId copy];
        _user = user;
        _category = [category copy];
        _content = [content copy];
        _images = [images copy];
        _videoUrl = [videoUrl copy];
        _viewsCount = viewsCount;
        _savesCount = savesCount;
        _sharesCount = sharesCount;
        _likesCount = likesCount;
        _tipsCount = 0;
        _commentsCount = commentsCount;
        _timestamp = timestamp;
        _location = [location copy];
        _isPinned = NO;
        _pinnedUntil = nil;
    }
    return self;
}

@end
