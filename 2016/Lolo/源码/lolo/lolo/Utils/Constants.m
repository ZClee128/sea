//
//  Constants.m
//  lolo
//
//  Created on 2026/1/30.
//

#import "Constants.h"


@implementation LifeColors

+ (UIColor *)primary {
    return [UIColor colorWithRed:1.0 green:0.42 blue:0.21 alpha:1.0]; // #FF6B35
}

+ (UIColor *)accent {
    return [UIColor colorWithRed:0.31 green:0.80 blue:0.77 alpha:1.0]; // #4ECDC4
}

+ (UIColor *)background {
    return [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1.0]; // #F7F7F7
}

+ (UIColor *)textPrimary {
    return [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
}

+ (UIColor *)textSecondary {
    return [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0];
}

+ (UIColor *)border {
    return [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0];
}

+ (UIColor *)lightGray {
    return [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
}

@end

@implementation LifeFonts

+ (UIFont *)largeTitle {
    return [UIFont systemFontOfSize:28 weight:UIFontWeightBold];
}

+ (UIFont *)title {
    return [UIFont systemFontOfSize:22 weight:UIFontWeightSemibold];
}

+ (UIFont *)headline {
    return [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
}

+ (UIFont *)body {
    return [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
}

+ (UIFont *)bodyBold {
    return [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
}

+ (UIFont *)caption {
    return [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
}

+ (UIFont *)smallCaption {
    return [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
}

+ (UIFont *)sectionHeader {
    return [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
}

@end

@implementation LifeSpacing

+ (CGFloat)small {
    return 8.0;
}

+ (CGFloat)medium {
    return 16.0;
}

+ (CGFloat)large {
    return 24.0;
}

+ (CGFloat)extraLarge {
    return 32.0;
}

@end

@implementation LifeCornerRadius

+ (CGFloat)standard {
    return 12.0;
}

+ (CGFloat)large {
    return 20.0;
}

+ (CGFloat)circle {
    return 999.0;
}

@end

@implementation LifeCategories

+ (NSArray<NSString *> *)all {
    static NSArray<NSString *> *categories = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        categories = @[
            @"Running",
            @"Cycling",
            @"Swimming",
            @"Basketball",
            @"Football",
            @"Tennis",
            @"Yoga",
            @"Gym",
            @"Hiking",
            @"Dancing"
        ];
    });
    return categories;
}

+ (NSArray<NSString *> *)allCases {
    return [self all];
}

@end
