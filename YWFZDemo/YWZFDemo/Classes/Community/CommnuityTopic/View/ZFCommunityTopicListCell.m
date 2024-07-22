//
//  ZFCommunityTopicListCell.m
//  ZZZZZ
//
//  Created by YW on 2017/8/8.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityTopicListCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFCommunityPostListModel.h"
#import "CommunityEnumComm.h"
#import "ZFThemeManager.h"
#import "YYText.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import <YYWebImage/UIImage+YYWebImage.h>
#import "NSStringUtils.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "BigClickAreaButton.h"
#import "ZFCommunityImageLayoutView.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "UIImage+ZFExtended.h"

@interface ZFCommunityTopicListCell () <ZFInitViewProtocol>
@property (nonatomic, strong) UIImageView               *iconImageView;
@property (nonatomic, strong) UILabel                   *nameLabel;
@property (nonatomic, strong) UILabel                   *timeLabel;
@property (nonatomic, strong) UIButton                  *followButton;
@property (nonatomic, strong) YYLabel                   *contentLabel;
@property (nonatomic, strong) ZFCommunityImageLayoutView  *contentImageView;
@property (nonatomic, strong) BigClickAreaButton        *likeButton;
@property (nonatomic, strong) BigClickAreaButton        *reviewButton;
@property (nonatomic, strong) BigClickAreaButton        *shareButton;

@property (nonatomic, strong) UIImageView               *rankImageView;

@property (nonatomic, strong) UIView                    *separateView;


@end

@implementation ZFCommunityTopicListCell
#pragma mark - init methods
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}


#pragma mark - action methods
- (void)followButtonAction:(UIButton *)sender {
    if (self.communityTopicListFollowCompletionHandler) {
        self.communityTopicListFollowCompletionHandler(self.model);
    }
}

- (void)shareButtonAction:(UIButton *)sender {
    if (self.communityTopicListShareCompletionHandler) {
        self.communityTopicListShareCompletionHandler(self.model);
    }
}

- (void)reviewButtonAction:(UIButton *)sender {
    if (self.communityTopicListReviewCompletionHandler) {
        self.communityTopicListReviewCompletionHandler();
    }
}

- (void)likeButtonAction:(UIButton *)sender {
    if (self.communityTopicListLikeCompletionHandler) {
        self.communityTopicListLikeCompletionHandler(self.model);
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

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.followButton];
    [self.contentView addSubview:self.contentImageView];
    [self.contentView addSubview:self.contentLabel];
    [self.contentView addSubview:self.shareButton];
    [self.contentView addSubview:self.reviewButton];
    [self.contentView addSubview:self.likeButton];
    [self.contentView addSubview:self.rankImageView];
    [self.contentView addSubview:self.separateView];

}

- (void)zfAutoLayoutView {
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
        make.top.mas_equalTo(self.contentView.mas_top).offset(16);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(20);
        make.leading.mas_equalTo(self.iconImageView.mas_trailing).offset(16);
        make.height.mas_equalTo(16);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(2);
        make.leading.mas_equalTo(self.nameLabel.mas_leading);
    }];
    
    
    [self.followButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
        make.top.mas_equalTo(self.contentView.mas_top).offset(20);
        make.size.mas_equalTo(CGSizeMake(80, 26));
        make.leading.mas_equalTo(self.nameLabel.mas_trailing).offset(5);
    }];
    
    [self.contentImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
        make.top.mas_equalTo(self.iconImageView.mas_bottom).offset(16);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentImageView.mas_bottom).offset(8);
        make.leading.trailing.mas_equalTo(self.contentImageView);
    }];
    
    [self.separateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.contentView);
        make.height.mas_equalTo(12);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
    }];
    
    [self.likeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(KScreenWidth / 6.0 - 12.0);
        make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(10);
        make.bottom.mas_equalTo(self.separateView.mas_top).offset(-12);
        make.height.mas_equalTo(44);
        make.width.mas_greaterThanOrEqualTo(44);
    }];
    
    [self.reviewButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(KScreenWidth / 2.0 - 12.0);
        make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(10);
        make.bottom.mas_equalTo(self.separateView.mas_top).offset(-12);
        make.height.mas_equalTo(44);
        make.width.mas_greaterThanOrEqualTo(44);
    }];
    
    [self.shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(KScreenWidth / 6.0 * 5.0 - 12.0);
        make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(10);
        make.bottom.mas_equalTo(self.separateView.mas_top).offset(-12);
        make.width.mas_greaterThanOrEqualTo(44);
    }];
    
    [self.rankImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.iconImageView.mas_trailing);
        make.bottom.mas_equalTo(self.iconImageView.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
}

#pragma mark - setter
- (void)setModel:(ZFCommunityPostListModel *)model {
    _model = model;
    [self.iconImageView yy_setImageWithURL:[NSURL URLWithString:_model.avatar]
                                placeholder:[UIImage imageNamed:@"index_cat_loading"] options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                 completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                                     
                                 }];
    //昵称
    self.nameLabel.text = _model.nickname;
    //评论时间
    self.timeLabel.text = [self timer:_model.addTime];
    
    if ([USERID isEqualToString: _model.userId]) {
        self.followButton.hidden = YES;
    }else {
        //        self.followBtn.hidden = NO;
        //是否关注
        if (_model.isFollow) {
            self.followButton.hidden = YES;
        }else{
            self.followButton.hidden = NO;
        }
    }
    
    NSMutableString *contentStr = [NSMutableString string];
    if (_model.topicList.count>0) {
        for (NSString *str in _model.topicList) {
            [contentStr appendString:[NSString stringWithFormat:@"%@ ", str]];
        }
    }
    [contentStr appendString:_model.content];
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:contentStr];
    
    //    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithData:[contentStr dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    content.yy_font = [UIFont systemFontOfSize:14];
    content.yy_color = ZFCOLOR(102, 102, 102, 1.0);
    
    NSArray <NSValue *> *rangeValues = [NSStringUtils matchString:content.string reg:RegularExpression matchOptions:NSMatchingReportProgress];
    [rangeValues enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange range = [obj rangeValue];
        [content yy_setColor:ZFC0x3D76B9() range:range];
        [content yy_setTextHighlightRange:range color:ZFC0x3D76B9() backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            NSString *labName = [content.string substringWithRange:range];
            if (self.communityTopicListTopicCompletionHandler) {
                self.communityTopicListTopicCompletionHandler(labName);
            }
        }];
    }];
//    NSArray *cmps = [contentStr componentsMatchedByRegex:RegularExpression];
//
//    [cmps enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSRange range = [contentStr rangeOfString:cmps[idx]];
//        [content yy_setColor:ZFCOLOR(255, 168, 0, 1.0) range:range];
//        [content yy_setTextHighlightRange:range color:ZFCOLOR(255, 168, 0, 1.0) backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
//            NSString *labName = cmps[idx];
//            if (self.communityTopicListTopicCompletionHandler) {
//                self.communityTopicListTopicCompletionHandler(labName);
//            }
//        }];
//    }];
    
    if ([SystemConfigUtils isRightToLeftShow]) {
        // NSParagraphStyle
        NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
        paraStyle.alignment = NSTextAlignmentRight;
        [content addAttribute:NSParagraphStyleAttributeName value:paraStyle range:NSMakeRange(0, content.length)];
    }
    
    //评论内容
    self.contentLabel.attributedText = content;
    self.contentImageView.imagePaths = [_model.reviewPic valueForKeyPath:@"bigPic"];
    
    //用户是否点赞
    NSInteger likeNum = (long)[self.model.likeCount integerValue];
    if (likeNum>0) {
        self.likeButton.selected = self.model.isLiked;
        UIControlState state = self.likeButton.selected ? UIControlStateSelected : UIControlStateNormal;
        
        NSString *likeStr = [NSString stringWithFormat:@"%zd",likeNum];
        [self.likeButton setTitle:likeStr forState:state];
        self.likeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        
    } else {
        self.likeButton.selected = NO;
        [self.likeButton setTitle:@"0" forState:UIControlStateNormal];
        self.likeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    }
    
    //回复数
    if (ZFIsEmptyString(_model.replyCount)) {
        [self.reviewButton setTitle:@"0" forState:UIControlStateNormal];
    }else {
        [self.reviewButton setTitle:ZFToString(_model.replyCount) forState:UIControlStateNormal];
    }
    
    self.rankImageView.hidden = YES;
    if ([_model.identify_type integerValue] > 0) {
        [self.rankImageView yy_setImageWithURL:[NSURL URLWithString:_model.identify_icon] options:kNilOptions];
        self.rankImageView.hidden = NO;
    }
}


#pragma mark - getter
- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFill;
        _iconImageView.clipsToBounds = YES;
        _iconImageView.layer.cornerRadius = 20;
        _iconImageView.userInteractionEnabled = YES;
        @weakify(self);
        [_iconImageView addTapGestureWithComplete:^(UIView * _Nonnull view) {
            @strongify(self);
            if (self.communityTopicListAccountCompletionHandler) {
                self.communityTopicListAccountCompletionHandler(self.model);
            }
        }];
    }
    return _iconImageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.font = [UIFont systemFontOfSize:16];
        _nameLabel.textColor = ZFCOLOR(51, 51, 51, 1);
    }
    return _nameLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = ZFCOLOR(170, 170, 170, 1.0);
    }
    return _timeLabel;
}

- (UIButton *)followButton {
    if (!_followButton) {
        _followButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _followButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _followButton.titleLabel.textColor = ZFCOLOR(255, 168, 0, 1);
        _followButton.layer.cornerRadius = 2;
        _followButton.layer.masksToBounds = YES;
        _followButton.layer.borderWidth = MIN_PIXEL;
        [_followButton addTarget:self action:@selector(followButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _followButton.layer.borderColor = ZFC0x2D2D2D().CGColor;
        [_followButton setTitleColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        _followButton.backgroundColor = ZFC0xFFFFFF();
        [_followButton setTitle:[NSString stringWithFormat:@"%@",ZFLocalizedString(@"Community_Follow",nil)] forState:UIControlStateNormal];        
    }
    return _followButton;
}

- (YYLabel *)contentLabel {
    if (!_contentLabel) {
        YYTextLinePositionSimpleModifier *modifier = [YYTextLinePositionSimpleModifier new];
        modifier.fixedLineHeight = 18;//行高
        _contentLabel = [YYLabel new];
        _contentLabel.numberOfLines = 5;
        _contentLabel.linePositionModifier = modifier;
        _contentLabel.preferredMaxLayoutWidth = KScreenWidth-20;
        _contentLabel.font = [UIFont systemFontOfSize:14];
        _contentLabel.textColor = ZFCOLOR(102, 102, 102, 1.0);
        
        if ([SystemConfigUtils isRightToLeftShow]) {
            _contentLabel.textAlignment = NSTextAlignmentRight;
        }
    }
    return _contentLabel;
}

- (ZFCommunityImageLayoutView *)contentImageView {
    if (!_contentImageView) {
        _contentImageView = [[ZFCommunityImageLayoutView alloc] initWithFrame:CGRectZero];
        _contentImageView.fixedSpacing = 5;
        _contentImageView.contentWidth = KScreenWidth - 32;
    }
    return _contentImageView;
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

- (UIImageView *)rankImageView {
    if (!_rankImageView) {
        _rankImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _rankImageView.backgroundColor = [UIColor clearColor];
        _rankImageView.userInteractionEnabled = YES;
        _rankImageView.hidden = YES;
    }
    return _rankImageView;
}


- (UIView *)separateView {
    if (!_separateView) {
        _separateView = [[UIView alloc] initWithFrame:CGRectZero];
        _separateView.backgroundColor = ZFC0xF2F2F2();
    }
    return _separateView;
}

@end
