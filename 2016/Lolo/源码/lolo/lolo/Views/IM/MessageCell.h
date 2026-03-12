//
//  MessageCell.h
//  lolo
//
//  Created on 2026/2/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MessageCell : UITableViewCell

- (void)configureWithAvatar:(NSString *)avatar name:(NSString *)name message:(NSString *)message time:(NSString *)time;

@end

NS_ASSUME_NONNULL_END
