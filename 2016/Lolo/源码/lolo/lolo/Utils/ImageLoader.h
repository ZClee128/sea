//
//  ImageLoader.h
//  lolo
//
//  Created on 2026/1/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageLoader : NSObject

@property (class, nonatomic, readonly) ImageLoader *shared;

- (void)loadImageFromURLString:(NSString *)urlString 
                  intoImageView:(UIImageView *)imageView 
                    placeholder:(nullable NSString *)placeholder 
                       username:(nullable NSString *)username;

@end

@interface UIImageView (ImageLoader)

- (void)loadImageFromURLString:(NSString *)urlString 
                    placeholder:(nullable NSString *)placeholder 
                       username:(nullable NSString *)username;

@end

NS_ASSUME_NONNULL_END
