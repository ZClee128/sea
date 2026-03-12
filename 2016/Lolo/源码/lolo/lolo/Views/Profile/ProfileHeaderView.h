//
//  ProfileHeaderView.h
//  lolo
//
//  Created on 2026/2/3.
//

#import <UIKit/UIKit.h>
@class User;

NS_ASSUME_NONNULL_BEGIN

@interface ProfileHeaderView : UIView

- (void)configureWithUser:(User *)user;

@end

NS_ASSUME_NONNULL_END
