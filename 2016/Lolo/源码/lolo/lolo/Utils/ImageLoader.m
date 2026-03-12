//
//  ImageLoader.m
//  lolo
//
//  Created on 2026/1/30.
//

#import "ImageLoader.h"
#import "AvatarGenerator.h"

@interface ImageLoader ()
@property (nonatomic, strong) NSCache<NSString *, UIImage *> *cache;
@end

@implementation ImageLoader

+ (ImageLoader *)shared {
    static ImageLoader *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _cache = [[NSCache alloc] init];
    }
    return self;
}

- (void)loadImageFromURLString:(NSString *)urlString 
                  intoImageView:(UIImageView *)imageView 
                    placeholder:(nullable NSString *)placeholder 
                       username:(nullable NSString *)username {
    // Reset image
    imageView.image = nil;
    
    // 0. Check if empty URL and have username
    if (urlString.length == 0 && username != nil) {
        imageView.image = [[AvatarGenerator shared] generateAvatarForName:username];
        return;
    }
    
    // 1. Check if it's a system symbol
    if (![urlString hasPrefix:@"http"] && urlString.length > 0) {
        UIImage *systemImage = [UIImage systemImageNamed:urlString];
        if (!systemImage && placeholder) {
            systemImage = [UIImage systemImageNamed:placeholder];
        }
        if (!systemImage) {
            systemImage = [UIImage systemImageNamed:@"photo"];
        }
        imageView.image = systemImage;
        return;
    }
    
    // 2. Check cache
    UIImage *cachedImage = [self.cache objectForKey:urlString];
    if (cachedImage) {
        imageView.image = cachedImage;
        return;
    }
    
    // 3. Download
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        if (username) {
            imageView.image = [[AvatarGenerator shared] generateAvatarForName:username];
        } else {
            imageView.image = [UIImage systemImageNamed:placeholder ?: @"photo"];
        }
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        if (data && !error) {
            UIImage *image = [UIImage imageWithData:data];
            if (image) {
                // Save to cache
                [strongSelf.cache setObject:image forKey:urlString];
                
                // Update UI on main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    imageView.image = image;
                });
                return;
            }
        }
        
        // Fallback on error
        dispatch_async(dispatch_get_main_queue(), ^{
            if (username) {
                imageView.image = [[AvatarGenerator shared] generateAvatarForName:username];
            } else {
                imageView.image = [UIImage systemImageNamed:placeholder ?: @"photo"];
            }
        });
    }];
    
    [task resume];
}

@end

@implementation UIImageView (ImageLoader)

- (void)loadImageFromURLString:(NSString *)urlString 
                    placeholder:(nullable NSString *)placeholder 
                       username:(nullable NSString *)username {
    [[ImageLoader shared] loadImageFromURLString:urlString 
                                   intoImageView:self 
                                     placeholder:placeholder 
                                        username:username];
}

@end
