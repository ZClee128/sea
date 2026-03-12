//
//  ReportViewController.h
//  lolo
//
//  Created for App Store compliance - Guideline 1.2
//

#import <UIKit/UIKit.h>
@class Post;

NS_ASSUME_NONNULL_BEGIN

@interface ReportViewController : UIViewController

- (instancetype)initWithPost:(Post *)post;

@end

NS_ASSUME_NONNULL_END
