//
//  UIView+Extensions.h
//  lolo
//
//  Created on 2026/1/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (LifeExtensions)

- (void)addShadowWithOpacity:(CGFloat)opacity radius:(CGFloat)radius offset:(CGSize)offset;
- (void)roundCornersWithRadius:(CGFloat)radius;

@end

@interface UIColor (LifeExtensions)

- (instancetype)initWithHexString:(NSString *)hexString;

@end

@interface NSDate (LifeExtensions)

- (NSString *)timeAgo;
- (NSString *)formattedWithFormat:(NSString *)format;

@end

@interface NSString (LifeExtensions)

- (nullable NSDate *)toDateWithFormat:(NSString *)format;

@end

NS_ASSUME_NONNULL_END
