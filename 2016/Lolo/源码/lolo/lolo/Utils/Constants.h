//
//  Constants.h
//  lolo
//
//  Created on 2026/1/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LifeColors : NSObject
@property (class, nonatomic, readonly) UIColor *primary;
@property (class, nonatomic, readonly) UIColor *accent;
@property (class, nonatomic, readonly) UIColor *background;
@property (class, nonatomic, readonly) UIColor *textPrimary;
@property (class, nonatomic, readonly) UIColor *textSecondary;
@property (class, nonatomic, readonly) UIColor *border;
@property (class, nonatomic, readonly) UIColor *lightGray;
@end

@interface LifeFonts : NSObject
@property (class, nonatomic, readonly) UIFont *largeTitle;
@property (class, nonatomic, readonly) UIFont *title;
@property (class, nonatomic, readonly) UIFont *headline;
@property (class, nonatomic, readonly) UIFont *body;
@property (class, nonatomic, readonly) UIFont *bodyBold;
@property (class, nonatomic, readonly) UIFont *caption;
@property (class, nonatomic, readonly) UIFont *smallCaption;
@property (class, nonatomic, readonly) UIFont *sectionHeader;
@end

@interface LifeSpacing : NSObject
@property (class, nonatomic, readonly) CGFloat small;
@property (class, nonatomic, readonly) CGFloat medium;
@property (class, nonatomic, readonly) CGFloat large;
@property (class, nonatomic, readonly) CGFloat extraLarge;
@end

@interface LifeCornerRadius : NSObject
@property (class, nonatomic, readonly) CGFloat standard;
@property (class, nonatomic, readonly) CGFloat large;
@property (class, nonatomic, readonly) CGFloat circle;
@end

@interface LifeCategories : NSObject
@property (class, nonatomic, readonly) NSArray<NSString *> *all;
@property (class, nonatomic, readonly) NSArray<NSString *> *allCases;
@end

NS_ASSUME_NONNULL_END
