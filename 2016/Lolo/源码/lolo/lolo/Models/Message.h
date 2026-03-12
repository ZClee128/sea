//
//  Message.h
//  lolo
//
//  Created on 2026/1/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MessageType) {
    MessageTypeText,
    MessageTypeImage,
    MessageTypeSportInvitation
};

@interface Message : NSObject

@property (nonatomic, copy) NSString *messageId;
@property (nonatomic, copy) NSString *senderId;
@property (nonatomic, copy) NSString *receiverId;
@property (nonatomic, assign) MessageType type;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy, nullable) NSString *imageUrl;
@property (nonatomic, strong) NSDate *timestamp;
@property (nonatomic, assign) BOOL isRead;

- (instancetype)initWithId:(NSString *)messageId
                  senderId:(NSString *)senderId
                receiverId:(NSString *)receiverId
                      type:(MessageType)type
                   content:(NSString *)content
                  imageUrl:(nullable NSString *)imageUrl
                 timestamp:(NSDate *)timestamp
                    isRead:(BOOL)isRead;

@end

NS_ASSUME_NONNULL_END
