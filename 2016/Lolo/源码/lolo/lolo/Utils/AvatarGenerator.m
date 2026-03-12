//
//  AvatarGenerator.m
//  lolo
//
//  Created on 2026/1/30.
//

#import "AvatarGenerator.h"

@interface AvatarGenerator ()
@property (nonatomic, strong) NSArray<UIColor *> *colors;
@end

@implementation AvatarGenerator

+ (AvatarGenerator *)shared {
    static AvatarGenerator *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _colors = @[
            [UIColor colorWithRed:1.0 green:0.42 blue:0.21 alpha:1.0], // primary
            [UIColor colorWithRed:0.31 green:0.80 blue:0.77 alpha:1.0], // accent
            [UIColor colorWithRed:0.35 green:0.78 blue:0.98 alpha:1.0], // blue
            [UIColor colorWithRed:0.56 green:0.35 blue:0.98 alpha:1.0], // purple
            [UIColor colorWithRed:1.0 green:0.35 blue:0.60 alpha:1.0], // pink
            [UIColor colorWithRed:1.0 green:0.76 blue:0.35 alpha:1.0]  // orange
        ];
    }
    return self;
}

- (nullable UIImage *)generateAvatarForName:(NSString *)name {
    return [self generateAvatarForName:name size:CGSizeMake(100, 100)];
}

- (nullable UIImage *)generateAvatarForName:(NSString *)name size:(CGSize)size {
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size];
    
    return [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull context) {
        // 1. Background
        NSUInteger colorIndex = labs([name hash]) % self.colors.count;
        UIColor *color = self.colors[colorIndex];
        
        [color setFill];
        [context fillRect:CGRectMake(0, 0, size.width, size.height)];
        
        // 2. Initials
        NSString *initials = [self getInitialsFromName:name];
        NSDictionary *attributes = @{
            NSFontAttributeName: [UIFont systemFontOfSize:size.height * 0.4 weight:UIFontWeightBold],
            NSForegroundColorAttributeName: [UIColor whiteColor]
        };
        
        CGSize textSize = [initials sizeWithAttributes:attributes];
        CGRect textRect = CGRectMake(
            (size.width - textSize.width) / 2,
            (size.height - textSize.height) / 2,
            textSize.width,
            textSize.height
        );
        
        [initials drawInRect:textRect withAttributes:attributes];
    }];
}

- (NSString *)getInitialsFromName:(NSString *)name {
    NSArray<NSString *> *components = [name componentsSeparatedByString:@" "];
    
    if (components.count > 1 && components.firstObject.length > 0 && components.lastObject.length > 0) {
        unichar first = [[components.firstObject uppercaseString] characterAtIndex:0];
        unichar last = [[components.lastObject uppercaseString] characterAtIndex:0];
        return [NSString stringWithFormat:@"%C%C", first, last];
    } else if (name.length > 0) {
        unichar first = [[name uppercaseString] characterAtIndex:0];
        return [NSString stringWithFormat:@"%C", first];
    }
    
    return @"?";
}

@end
