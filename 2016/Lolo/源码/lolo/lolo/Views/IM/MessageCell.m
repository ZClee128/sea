//
//  MessageCell.m
//  lolo
//
//  Created on 2026/2/3.
//

#import "MessageCell.h"
#import "Constants.h"
#import "ImageLoader.h"

@interface MessageCell ()
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@end

@implementation MessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    CGFloat padding = [LifeSpacing medium];
    
    // Avatar
    self.avatarImageView = [[UIImageView alloc] init];
    self.avatarImageView.layer.cornerRadius = 26;
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.backgroundColor = [UIColor lightGrayColor];
    self.avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.avatarImageView];
    
    // Name
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.font = [LifeFonts bodyBold];
    self.nameLabel.textColor = [LifeColors textPrimary];
    self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.nameLabel];
    
    // Message preview
    self.messageLabel = [[UILabel alloc] init];
    self.messageLabel.font = [LifeFonts body];
    self.messageLabel.textColor = [LifeColors textSecondary];
    self.messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.messageLabel];
    
    // Time
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.font = [LifeFonts caption];
    self.timeLabel.textColor = [LifeColors textSecondary];
    self.timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.timeLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.avatarImageView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:padding],
        [self.avatarImageView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        [self.avatarImageView.widthAnchor constraintEqualToConstant:52],
        [self.avatarImageView.heightAnchor constraintEqualToConstant:52],
        
        [self.nameLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:padding],
        [self.nameLabel.leadingAnchor constraintEqualToAnchor:self.avatarImageView.trailingAnchor constant:padding],
        [self.nameLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.timeLabel.leadingAnchor constant:-8],
        
        [self.messageLabel.topAnchor constraintEqualToAnchor:self.nameLabel.bottomAnchor constant:4],
        [self.messageLabel.leadingAnchor constraintEqualToAnchor:self.nameLabel.leadingAnchor],
        [self.messageLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-padding],
        [self.messageLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-padding],
        
        [self.timeLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:padding],
        [self.timeLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-padding],
    ]];
}

- (void)configureWithAvatar:(NSString *)avatar name:(NSString *)name message:(NSString *)message time:(NSString *)time {
    self.nameLabel.text = name;
    self.messageLabel.text = message;
    self.timeLabel.text = time;
    
    [self.avatarImageView loadImageFromURLString:avatar 
                                      placeholder:@"person.circle.fill" 
                                         username:name];
}

@end
