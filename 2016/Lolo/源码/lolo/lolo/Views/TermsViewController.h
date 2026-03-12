//
//  TermsViewController.h
//  lolo
//
//  Created on 2026/2/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TermsViewControllerDelegate <NSObject>
- (void)termsViewControllerDidAccept;
@end

@interface TermsViewController : UIViewController

@property (nonatomic, weak) id<TermsViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
