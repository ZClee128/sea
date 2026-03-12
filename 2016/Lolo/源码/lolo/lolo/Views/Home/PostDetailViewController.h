//
//  PostDetailViewController.h
//  lolo
//
//  Created on 2026/2/3.
//

#import <UIKit/UIKit.h>
@class Post;

NS_ASSUME_NONNULL_BEGIN

@interface PostDetailViewController : UIViewController

- (instancetype)initWithPost:(Post *)post;

@end

NS_ASSUME_NONNULL_END
