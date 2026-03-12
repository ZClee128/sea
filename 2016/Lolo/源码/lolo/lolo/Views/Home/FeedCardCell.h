//
//  FeedCardCell.h
//  lolo
//
//  Created on 2026/2/3.
//

#import <UIKit/UIKit.h>
@class Post;

NS_ASSUME_NONNULL_BEGIN

@class FeedCardCell;

@protocol FeedCardCellDelegate <NSObject>
@optional
- (void)feedCardCell:(FeedCardCell *)cell didTapCommentForPost:(Post *)post;
- (void)feedCardCell:(FeedCardCell *)cell didTapReportForPost:(Post *)post;
- (void)feedCardCell:(FeedCardCell *)cell didTapPinForPost:(Post *)post;
@end

@interface FeedCardCell : UITableViewCell

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *sportBadgeLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIImageView *mediaImageView;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UILabel *distanceLabel;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UILabel *caloriesLabel;
@property (nonatomic, strong) UIButton *likeButton;
@property (nonatomic, strong) UIButton *tipButton;
@property (nonatomic, strong) UIButton *commentButton;
@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, weak) id<FeedCardCellDelegate> delegate;
@property (nonatomic, strong) NSString *currentUserId; // To check if viewing own post
@property (nonatomic, strong) UIButton *pinButton; // Pin button for own posts
@property (nonatomic, strong) UILabel *pinnedBadge; // Badge showing pinned status

- (void)configureWithPost:(Post *)post;
- (void)playVideo;
- (void)pauseVideo;

@end

NS_ASSUME_NONNULL_END
