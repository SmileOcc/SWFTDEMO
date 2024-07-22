//
//  ZFCommnuityTopicDetailCollectionView.m
//  ZZZZZ
//
//  Created by YW on 2018/9/15.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFCommnuityTopicDetailBigCCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "NSStringUtils.h"
#import "SystemConfigUtils.h"

#import <YYWebImage/UIImageView+YYWebImage.h>
#import <YYWebImage/UIImage+YYWebImage.h>
#import <YYImage/YYImage.h>
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "UIView+ZFViewCategorySet.h"
#import "UIImage+ZFExtended.h"

#import "YYLabel.h"
#import "YYText.h"

#import "ZFCommunityImageLayoutView.h"
#import "BigClickAreaButton.h"
#import "ZFConcaveArrowTipView.h"

#import "ZFCommunityPictureModel.h"

@interface ZFCommnuityTopicDetailBigCCell ()<ZFInitViewProtocol>

@property (nonatomic, strong) UIView                *userInforView;
@property (nonatomic, strong) UIImageView           *userHeadImageView;
@property (nonatomic, strong) UIImageView           *rankImageView;
@property (nonatomic, strong) UILabel               *nameLabel;
@property (nonatomic, strong) UILabel               *timeLabel;
@property (nonatomic, strong) UIButton              *followButton;

@property (nonatomic, strong) ZFCommunityImageLayoutView   *contentImageView;
@property (nonatomic, strong) YYLabel               *commentLabel;

@property (nonatomic, strong) UIView                *bottomEventView;
@property (nonatomic, strong) BigClickAreaButton    *likeButton;
@property (nonatomic, strong) BigClickAreaButton    *reviewButton;
@property (nonatomic, strong) BigClickAreaButton    *shareButton;

@property (nonatomic, strong) ZFConcaveArrowTipView *tipMarkArrowView;

@property (nonatomic, strong) UIButton              *waterFlowTopButton;

@property (nonatomic, strong) UIView                *separateView;




@end


@implementation ZFCommnuityTopicDetailBigCCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - Life Cycle

- (void)zfInitView {
    
    [self.contentView addSubview:self.userInforView];
    [self.contentView addSubview:self.userHeadImageView];
    [self.contentView addSubview:self.rankImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.followButton];
    
    [self.contentView addSubview:self.contentImageView];
    [self.contentView addSubview:self.commentLabel];
    
    [self.contentView addSubview:self.bottomEventView];
    [self.contentView addSubview:self.likeButton];
    [self.contentView addSubview:self.reviewButton];
    [self.contentView addSubview:self.shareButton];
    
//    [self.contentView addSubview:self.tipMarkArrowView];
    [self.contentView addSubview:self.waterFlowTopButton];
    [self.contentView addSubview:self.separateView];
    
}

- (void)zfAutoLayoutView {
    
    [self.userInforView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
        make.top.mas_equalTo(self);
        make.height.mas_equalTo(72);
    }];
    
    [self.userHeadImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.userInforView.mas_centerY);
        make.leading.mas_equalTo(self.userInforView.mas_leading);
        make.width.height.mas_offset(40);
    }];
    self.userHeadImageView.layer.cornerRadius = 40.0 / 2;
    
    [self.rankImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.userHeadImageView.mas_trailing);
        make.bottom.mas_equalTo(self.userHeadImageView.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.userHeadImageView.mas_trailing).offset(8);
        make.bottom.mas_equalTo(self.userHeadImageView.mas_centerY).offset(-2);
        make.trailing.mas_offset(-115);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.nameLabel.mas_leading);
        make.top.mas_equalTo(self.userHeadImageView.mas_centerY).offset(2);
    }];

    [self.followButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.userInforView.mas_trailing);
        make.centerY.mas_equalTo(self.userInforView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(80, 26));
    }];
    
    [self.contentImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.userInforView.mas_leading);
        make.top.mas_equalTo(self.userInforView.mas_bottom);
        make.trailing.mas_equalTo(self.userInforView.mas_trailing);
    }];
    
    
    [self.commentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentImageView.mas_bottom).offset(8);
        make.leading.trailing.mas_equalTo(self.contentImageView);
        make.height.mas_equalTo(12);
    }];
    
    
    [self.separateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.contentView);
        make.height.mas_equalTo(12);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
    }];
    
    [self.bottomEventView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.userInforView);
        make.bottom.mas_equalTo(self.separateView.mas_top);
        make.height.mas_equalTo(kTopicDetailBottomHeight);
    }];
    
    //FIXME: occ Bug 1101 最好分成两个
    [self.likeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.bottomEventView.mas_leading).offset(KScreenWidth / 6.0 - 12.0);
        make.centerY.mas_equalTo(self.bottomEventView.mas_centerY);
        make.height.mas_equalTo(44);
        make.width.mas_greaterThanOrEqualTo(44);
    }];
    
    [self.reviewButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(KScreenWidth / 2.0 - 12.0);
        make.centerY.mas_equalTo(self.bottomEventView.mas_centerY);
        make.height.mas_equalTo(44);
        make.width.mas_greaterThanOrEqualTo(44);
    }];
    
    [self.shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(KScreenWidth / 6.0 * 5.0 - 12.0);
        make.centerY.mas_equalTo(self.bottomEventView.mas_centerY);
        make.width.mas_greaterThanOrEqualTo(44);
    }];
    
//    [self.tipMarkArrowView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.mas_equalTo(self.contentImageView.mas_leading);
//        make.top.mas_equalTo(self.userInforView.mas_bottom).offset(12);
//        make.width.mas_lessThanOrEqualTo(KScreenWidth - 24);
//    }];
    
    [self.waterFlowTopButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentImageView.mas_leading);
        make.top.mas_equalTo(self.userInforView.mas_bottom).offset(12);
        make.width.mas_lessThanOrEqualTo(KScreenWidth - 24);
        make.height.mas_equalTo(16);
    }];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 但外部 是其他两行的瀑布流cell时，刷新成 这个（每行一个cell时），这个视图不见了，？？？？
    [self.userInforView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
        make.top.mas_equalTo(self);
        make.height.mas_equalTo(72);
    }];
}

#pragma mark - Action

- (void)followButtonAction:(UIButton *)sender {
    if (self.tapEventBlock) {
        self.tapEventBlock(CommunityTopicDetailCellEventFllow, self.model, sender);
    }
}
- (void)likeButtonAction:(UIButton *)sender {
    if (self.tapEventBlock) {
        self.tapEventBlock(CommunityTopicDetailCellEventLike, self.model, sender);
    }
}

- (void)reviewButtonAction:(UIButton *)sender {
    if (self.tapEventBlock) {
        self.tapEventBlock(CommunityTopicDetailCellEventReview, self.model, sender);
    }
}

- (void)shareButtonAction:(UIButton *)sender {
    if (self.tapEventBlock) {
        self.tapEventBlock(CommunityTopicDetailCellEventShare, self.model, sender);
    }
}

- (void)setModel:(ZFCommunityTopicDetailListModel *)model {
    _model = model;
    
    @weakify(self)
    _model.touchTopicAttrTextBlcok = ^(NSString *topicName) {
        @strongify(self)
        if (self.tapLabBlock) {
            self.tapLabBlock(topicName);
        }
    };
    
    [self.userHeadImageView yy_setImageWithURL:[NSURL URLWithString:model.avatar]
                                   placeholder:[UIImage imageNamed:@"public_user"]
                                       options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                      progress:nil
                                     transform:nil
                                    completion:nil];
    
    self.nameLabel.text = model.nickname;
    self.timeLabel.text = [self timer:_model.addTime];

    if ([USERID isEqualToString: _model.userId]) {
        self.followButton.hidden = YES;
    }else {//是否关注
        self.followButton.hidden = _model.isFollow;
    }

    NSMutableArray *bigPicArray = [[NSMutableArray alloc] init];
    for (ZFCommunityPictureModel *pictureModel in _model.reviewPic) {
        [bigPicArray addObject:ZFToString(pictureModel.bigPic)];
    }
    self.contentImageView.imagePaths = bigPicArray;
    
    //前3个显示: 1 2 3
    if (self.contentImageView.imagePaths.count > 0 && model.positionIndex < 3 && model.isShowMark) {
        NSString *topStr = [NSString stringWithFormat:@"%@ %li",ZFLocalizedString(@"Community_shows_top", nil),(long)(model.positionIndex + 1)];
        if (model.positionIndex == 0) {
            topStr = ZFLocalizedString(@"Community_topic_post_1st", nil);
        } else if (model.positionIndex == 1) {
            topStr = ZFLocalizedString(@"Community_topic_post_2nd", nil);
        } else if (model.positionIndex == 2) {
            topStr = ZFLocalizedString(@"Community_topic_post_3rd", nil);
        } 
//        ZFConcaveArrowTipDirect arArrowDirect = [SystemConfigUtils isRightToLeftShow] ? ZFConcaveArrowTipDirectLeftNoOffset : ZFConcaveArrowTipDirectRightNoOffset;
//        [self.tipMarkArrowView updateTipArrowOffset:-1 direct:arArrowDirect cotent:topStr];
//        self.tipMarkArrowView.hidden = NO;

        [self.waterFlowTopButton setTitle:topStr forState:UIControlStateNormal];
        self.waterFlowTopButton.hidden = NO;
    } else {
//        self.tipMarkArrowView.hidden = YES;
        self.waterFlowTopButton.hidden = YES;
    }
    
    self.rankImageView.hidden = YES;
    if ([model.identify_type integerValue] > 0) {
        [self.rankImageView yy_setImageWithURL:[NSURL URLWithString:model.identify_icon] options:kNilOptions];
        self.rankImageView.hidden = NO;
    }
    
    //评论内容
    self.commentLabel.attributedText = _model.contentAttributedText;

    CGFloat tempCommentH = _model.commentHeight;
    [self.commentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(tempCommentH);
    }];
    
    NSInteger likeNum = (long)[self.model.likeCount integerValue];
    if (likeNum > 0) {
        self.likeButton.selected = self.model.isLiked;
        UIControlState state = self.likeButton.selected ? UIControlStateSelected : UIControlStateNormal;
        
        NSString *likeStr = [NSString stringWithFormat:@"%zd",likeNum];
        [self.likeButton setTitle:likeStr forState:state];
        self.likeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        
    } else {
        self.likeButton.selected = NO;
        [self.likeButton setTitle:@"" forState:UIControlStateNormal];
        self.likeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    }
    
    //回复数
    if ([_model.replyCount isEqualToString:@"0"]) {
        [self.reviewButton setTitle:@"" forState:UIControlStateNormal];
    }else {
        [self.reviewButton setTitle:ZFToString(_model.replyCount) forState:UIControlStateNormal];
    }
    
}

#pragma mark - private methods
- (NSString*)timer:(NSString*)timer {
    NSInteger intervalTime = [timer integerValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:intervalTime];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"MMM dd, yyyy";
    NSString *time = [df stringFromDate:date];
    return time;
}

#pragma mark - Property Method

- (UIView *)userInforView {
    if (!_userInforView) {
        _userInforView = [[UIView alloc] initWithFrame:CGRectZero];
        _userInforView.backgroundColor = ZFC0xFFFFFF();
    }
    return _userInforView;
}
- (UIImageView *)userHeadImageView {
    if (!_userHeadImageView) {
        _userHeadImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _userHeadImageView.contentMode = UIViewContentModeScaleToFill;
        _userHeadImageView.userInteractionEnabled = YES;
        _userHeadImageView.clipsToBounds = YES;
    }
    return _userHeadImageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.font = [UIFont systemFontOfSize:16];
        _nameLabel.textColor = ZFCOLOR(51, 51, 51, 1.0);
    }
    return _nameLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = ZFC0x999999();
    }
    return _timeLabel;
}


- (UIButton *)followButton {
    if (!_followButton) {
        _followButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _followButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _followButton.layer.borderWidth = MIN_PIXEL;
        _followButton.layer.cornerRadius = 2;
        _followButton.layer.masksToBounds = YES;
        [_followButton addTarget:self action:@selector(followButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _followButton.layer.borderColor = ZFC0x2D2D2D().CGColor;
        [_followButton setTitleColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        [_followButton setTitle:[NSString stringWithFormat:@"%@",ZFLocalizedString(@"Community_Follow",nil)] forState:UIControlStateNormal];
    }
    return _followButton;
}


- (ZFCommunityImageLayoutView *)contentImageView {
    if (!_contentImageView) {
        _contentImageView = [[ZFCommunityImageLayoutView alloc] initWithFrame:CGRectZero];
        _contentImageView.leadingSpacing = 0;
        _contentImageView.trailingSpacing = 0;
        _contentImageView.contentWidth = KScreenWidth - 24;
        _contentImageView.fixedSpacing = 5;
    }
    return _contentImageView;
}

- (YYLabel *)commentLabel {
    if (!_commentLabel) {
        YYTextLinePositionSimpleModifier *modifier = [YYTextLinePositionSimpleModifier new];
        modifier.fixedLineHeight = 18;//行高
        _commentLabel = [YYLabel new];
        _commentLabel.numberOfLines = 2;
        _commentLabel.linePositionModifier = modifier;
        _commentLabel.preferredMaxLayoutWidth = KScreenWidth - 24;
        _commentLabel.font = ZFFontSystemSize(14);
        _commentLabel.textColor = ZFC0x666666();
        _commentLabel.textVerticalAlignment = YYTextVerticalAlignmentTop;
    }
    return _commentLabel;
}

- (UIView *)bottomEventView {
    if (!_bottomEventView) {
        _bottomEventView = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomEventView.backgroundColor = ZFC0xFFFFFF();
    }
    return _bottomEventView;
}

- (BigClickAreaButton *)likeButton {
    if (!_likeButton) {
        _likeButton = [BigClickAreaButton buttonWithType:UIButtonTypeCustom];
        _likeButton.clickAreaRadious = 44;
        [_likeButton addTarget:self action:@selector(likeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_likeButton setImage:[UIImage imageNamed:@"Community_like_black_24"] forState:UIControlStateNormal];
        [_likeButton setImage:[[UIImage imageNamed:@"Community_like_red_24"] imageWithColor:ZFC0xFE5269()] forState:UIControlStateSelected];
        [_likeButton setTitleColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        [_likeButton setTitleColor:ZFC0xFE5269() forState:UIControlStateSelected];
        _likeButton.titleLabel.font = ZFFontSystemSize(12.0);
        
        if ([SystemConfigUtils isRightToLeftShow]) {
            _likeButton.imageEdgeInsets = UIEdgeInsetsMake(0, 3, 0, -3);
            _likeButton.titleEdgeInsets = UIEdgeInsetsMake(4, -3, 0, 3);
        } else {
            _likeButton.imageEdgeInsets = UIEdgeInsetsMake(0, -3, 0, 3);
            _likeButton.titleEdgeInsets = UIEdgeInsetsMake(4, 3, 0, -3);
        }
        [_likeButton.imageView convertUIWithARLanguage];
    }
    return _likeButton;
}

- (BigClickAreaButton *)reviewButton {
    if (!_reviewButton) {
        _reviewButton = [BigClickAreaButton buttonWithType:UIButtonTypeCustom];
        _reviewButton.clickAreaRadious = 44;
        [_reviewButton addTarget:self action:@selector(reviewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_reviewButton setImage:[UIImage imageNamed:@"community_newmessage"] forState:UIControlStateNormal];
        [_reviewButton setTitleColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        _reviewButton.titleLabel.font = ZFFontSystemSize(12.0);
        
        if ([SystemConfigUtils isRightToLeftShow]) {
            _reviewButton.imageEdgeInsets = UIEdgeInsetsMake(0, 3, 0, -3);
            _reviewButton.titleEdgeInsets = UIEdgeInsetsMake(4, -3, 0, 3);
        } else {
            _reviewButton.imageEdgeInsets = UIEdgeInsetsMake(0, -3, 0, 3);
            _reviewButton.titleEdgeInsets = UIEdgeInsetsMake(4, 3, 0, -3);
        }
        [_reviewButton.imageView convertUIWithARLanguage];

    }
    return _reviewButton;
}

- (BigClickAreaButton *)shareButton {
    if (!_shareButton) {
        _shareButton = [BigClickAreaButton buttonWithType:UIButtonTypeCustom];
        _shareButton.clickAreaRadious = 44;
        [_shareButton addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_shareButton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
        [_shareButton.imageView convertUIWithARLanguage];

    }
    return _shareButton;
}

//- (ZFConcaveArrowTipView *)tipMarkArrowView {
//    if (!_tipMarkArrowView) {
//
//        ZFConcaveArrowTipDirect direct = [SystemConfigUtils isRightToLeftShow] ? ZFConcaveArrowTipDirectLeftNoOffset : ZFConcaveArrowTipDirectRightNoOffset;
//        _tipMarkArrowView = [[ZFConcaveArrowTipView alloc] initTipArrowOffset:-1 direct:direct content:ZFLocalizedString(@"Community_shows_top", nil) arrowWidth:-1 arrowHeight:-1 topSpace:2 leadSpace:3 textFont:ZFFontSystemSize(12) textColor:ZFC0xFFFFFF() textBackgroundColor:nil backgroundColor:ZFCThemeColor()];
//        _tipMarkArrowView.hidden = YES;
//    }
//    return _tipMarkArrowView;
//}

- (UIButton *)waterFlowTopButton{
    if (!_waterFlowTopButton) {
        _waterFlowTopButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_waterFlowTopButton setTitle:ZFLocalizedString(@"Community_shows_top", nil) forState:UIControlStateNormal];
        _waterFlowTopButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_waterFlowTopButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _waterFlowTopButton.backgroundColor = ZFC0xFE5269();
        _waterFlowTopButton.contentEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 6);
        _waterFlowTopButton.layer.cornerRadius = 2;
        _waterFlowTopButton.layer.masksToBounds = YES;
        _waterFlowTopButton.hidden = YES;
    }
    return _waterFlowTopButton;
}



- (UIView *)separateView {
    if (!_separateView) {
        _separateView = [[UIView alloc] initWithFrame:CGRectZero];
        _separateView.backgroundColor = ZFC0xF2F2F2();
    }
    return _separateView;
}

- (UIImageView *)rankImageView {
    if (!_rankImageView) {
        _rankImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _rankImageView.backgroundColor = [UIColor clearColor];
        _rankImageView.userInteractionEnabled = YES;
        _rankImageView.hidden = YES;
    }
    return _rankImageView;
}

@end
