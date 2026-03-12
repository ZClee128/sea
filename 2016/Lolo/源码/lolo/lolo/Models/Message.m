//
//  Message.m
//  lolo
//
//  Created on 2026/1/30.
//

#import "Message.h"

@implementation Message

- (instancetype)initWithId:(NSString *)messageId
                  senderId:(NSString *)senderId
                receiverId:(NSString *)receiverId
                      type:(MessageType)type
                   content:(NSString *)content
                  imageUrl:(nullable NSString *)imageUrl
                 timestamp:(NSDate *)timestamp
                    isRead:(BOOL)isRead {
    self = [super init];
    if (self) {
        _messageId = [messageId copy];
        _senderId = [senderId copy];
        _receiverId = [receiverId copy];
        _type = type;
        _content = [content copy];
        _imageUrl = [imageUrl copy];
        _timestamp = timestamp;
        _isRead = isRead;
    }
    return self;
}

@end
