//
//  AvatarGenerator.h
//  lolo
//
//  Created on 2026/1/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AvatarGenerator : NSObject

@property (class, nonatomic, readonly) AvatarGenerator *shared;

- (nullable UIImage *)generateAvatarForName:(NSString *)name size:(CGSize)size;
- (nullable UIImage *)generateAvatarForName:(NSString *)name; // Default size 100x100

@end

NS_ASSUME_NONNULL_END
