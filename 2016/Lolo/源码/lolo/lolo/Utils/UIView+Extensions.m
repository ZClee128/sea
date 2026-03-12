//
//  UIView+Extensions.m
//  lolo
//
//  Created on 2026/1/30.
//

#import "UIView+Extensions.h"
#import "Constants.h"

@implementation UIView (LifeExtensions)

- (void)addShadowWithOpacity:(CGFloat)opacity radius:(CGFloat)radius offset:(CGSize)offset {
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = opacity;
    self.layer.shadowRadius = radius;
    self.layer.shadowOffset = offset;
    self.layer.masksToBounds = NO;
}

- (void)roundCornersWithRadius:(CGFloat)radius {
    self.layer.cornerRadius = radius;
    self.layer.masksToBounds = YES;
}

@end

@implementation UIColor (LifeExtensions)

- (instancetype)initWithHexString:(NSString *)hexString {
    NSString *hexSanitized = [hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    hexSanitized = [hexSanitized stringByReplacingOccurrencesOfString:@"#" withString:@""];
    
    unsigned long long rgb = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexSanitized];
    [scanner scanHexLongLong:&rgb];
    
    CGFloat r = ((rgb & 0xFF0000) >> 16) / 255.0;
    CGFloat g = ((rgb & 0x00FF00) >> 8) / 255.0;
    CGFloat b = (rgb & 0x0000FF) / 255.0;
    
    return [self initWithRed:r green:g blue:b alpha:1.0];
}

@end

@implementation NSDate (LifeExtensions)

- (NSString *)timeAgo {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    NSCalendarUnit units = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekOfYear | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
    NSDateComponents *components = [calendar components:units fromDate:self toDate:now options:0];
    
    if (components.year > 0) {
        return [NSString stringWithFormat:@"%ldy ago", (long)components.year];
    }
    if (components.month > 0) {
        return [NSString stringWithFormat:@"%ldmo ago", (long)components.month];
    }
    if (components.weekOfYear > 0) {
        return [NSString stringWithFormat:@"%ldw ago", (long)components.weekOfYear];
    }
    if (components.day > 0) {
        return [NSString stringWithFormat:@"%ldd ago", (long)components.day];
    }
    if (components.hour > 0) {
        return [NSString stringWithFormat:@"%ldh ago", (long)components.hour];
    }
    if (components.minute > 0) {
        return [NSString stringWithFormat:@"%ldm ago", (long)components.minute];
    }
    return @"Just now";
}

- (NSString *)formattedWithFormat:(NSString *)format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = format;
    return [formatter stringFromDate:self];
}

@end

@implementation NSString (LifeExtensions)

- (nullable NSDate *)toDateWithFormat:(NSString *)format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = format;
    return [formatter dateFromString:self];
}

@end
