//
//  CreatePostViewController.h
//  lolo
//
//  Created on 2026/2/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CreatePostViewController;

@protocol CreatePostViewControllerDelegate <NSObject>
- (void)createPostViewController:(CreatePostViewController *)controller didCreatePost:(id)post;
@end

@interface CreatePostViewController : UIViewController

@property (nonatomic, weak) id<CreatePostViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
