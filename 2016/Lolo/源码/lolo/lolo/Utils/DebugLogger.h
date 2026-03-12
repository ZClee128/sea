//
//  DebugLogger.h
//  lolo
//
//  Debug logging utilities for development
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Conditional logging - only logs in DEBUG builds
#ifdef DEBUG
    #define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
    #define DLog(...) // Empty in release builds
#endif

// Always log (use sparingly, only for critical errors)
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

NS_ASSUME_NONNULL_END
