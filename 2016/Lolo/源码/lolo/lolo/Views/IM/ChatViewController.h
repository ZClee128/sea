//
//  ChatViewController.h
//  lolo
//
//  Created on 2026/2/3.
//

#import <UIKit/UIKit.h>

@class User;

NS_ASSUME_NONNULL_BEGIN

@interface ChatViewController : UIViewController

- (instancetype)initWithUser:(User *)user;

@end

NS_ASSUME_NONNULL_END
