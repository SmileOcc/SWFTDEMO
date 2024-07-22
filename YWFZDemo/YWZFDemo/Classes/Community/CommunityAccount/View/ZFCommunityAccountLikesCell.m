//
//  ZFCommunityAccountLikesCell.m
//  ZZZZZ
//
//  Created by YW on 2017/8/2.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityAccountLikesCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFCommunityAccountLikesModel.h"
#import "CommunityEnumComm.h"
#import "ZFThemeManager.h"
#import "YYText.h"
#import <YYWebImage/YYWebImage.h>
#import "NSStringUtils.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "BigClickAreaButton.h"
#import "ZFCommunityImageLayoutView.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "UIButton+ZFButtonCategorySet.h"

@interface ZFCommunityAccountLikesCell () <ZFInitViewProtocol>
@property (nonatomic, strong) UIImageView               *iconImageView;
@property (nonatomic, strong) UILabel                   *nameLabel;
@property (nonatomic, strong) UILabel                   *timeLabel;
@property (nonatomic, strong) UIButton                  *followButton;
@property (nonatomic, strong) YYLabel                   *contentLabel;
@property (nonatomic, strong) ZFCommunityImageLayoutView  *contentImageView;
@property (nonatomic, strong) BigClickAreaButton        *likeButton;
@property (nonatomic, strong) UILabel                   *likeNumberLabel;
@property (nonatomic, strong) BigClickAreaButton        *reviewButton;
@property (nonatomic, strong) UILabel                   *reviewNumberLabel;
@property (nonatomic, strong) BigClickAreaButton        *shareButton;
@end

@implementation ZFCommunityAccountLikesCell
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
    if (self.communityAccountLikeFollowUserCompletionHandler) {
        self.communityAccountLikeFollowUserCompletionHandler(self.model);
    }
}

- (void)shareButtonAction:(UIButton *)sender {
    if (self.communityAccountLikesShareCompletionHandler) {
        self.communityAccountLikesShareCompletionHandler(self.model);
    }
}

- (void)likeButtonAction:(UIButton *)sender {
    if (self.communityAccountLikesLikeCompletionHandler) {
        self.communityAccountLikesLikeCompletionHandler(self.model);
    }
}

- (void)reviewButtonAction:(UIButton *)sender {
    if (self.communityAccountLikesReviewCompletionHandler) {
        self.communityAccountLikesReviewCompletionHandler();
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
    [self.contentView addSubview:self.reviewNumberLabel];
    [self.contentView addSubview:self.likeButton];
    [self.contentView addSubview:self.likeNumberLabel];
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
        make.size.mas_equalTo(CGSizeMake(96, 26));
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
    
    [self.shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.contentView.mas_leading).offset(KScreenWidth / 6.0);
        make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(28);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-12);
    }];
    
    [self.reviewButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.contentView.mas_leading).offset(KScreenWidth / 2.0);
        make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(28);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-12);
    }];
    
    [self.reviewNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.reviewButton.mas_centerY);
        make.centerX.mas_equalTo(self.contentView.mas_leading).offset(KScreenWidth / 2.0+30);
    }];
    
    [self.likeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.contentView.mas_leading).offset(KScreenWidth / 6.0 * 5.0);
        make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(28);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-12);
        make.size.mas_equalTo(CGSizeMake(24, 24));
    }];
    
    [self.likeNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.likeButton.mas_centerY);
        make.centerX.mas_equalTo(self.contentView.mas_leading).offset(KScreenWidth / 6.0 * 5.0+30);
    }];

}

#pragma mark - setter
- (void)setModel:(ZFCommunityAccountLikesModel *)model {
    _model = model;
    [self.iconImageView yy_setImageWithURL:[NSURL URLWithString:_model.avatar]
                              placeholder:[UIImage imageNamed:@"index_cat_loading"]
                                   options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                  progress:^(NSInteger receivedSize, NSInteger expectedSize) { }
                                 transform:^UIImage *(UIImage *image, NSURL *url) {
                                     image = [image yy_imageByResizeToSize:CGSizeMake(39,39) contentMode:UIViewContentModeScaleAspectFill];
                                     return [image yy_imageByRoundCornerRadius:19.5];
                                 }
                                completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
                                }];
    //昵称
    self.nameLabel.text = _model.nickName;
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
        [content yy_setColor:ZFCOLOR(255, 168, 0, 1.0) range:range];
        [content yy_setTextHighlightRange:range color:ZFCOLOR(255, 168, 0, 1.0) backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            NSString *labName = [content.string substringWithRange:range];
            if (self.communityAccountLikesTopicCompletionHandler) {
                self.communityAccountLikesTopicCompletionHandler(labName);
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
//            if (self.communityAccountLikesTopicCompletionHandler) {
//                self.communityAccountLikesTopicCompletionHandler(labName);
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
    self.likeNumberLabel.text = [NSString stringWithFormat:@"%ld",(long)[_model.likeCount integerValue]];
    if (_model.isLiked) {
        self.likeButton.selected = YES;
        self.likeNumberLabel.textColor = ZFCOLOR(255, 168, 0, 1.0);
    }else {
        self.likeButton.selected = NO;
        if ([_model.likeCount isEqualToString:@"0"]) {
            self.likeNumberLabel.text = nil;
        }else {
            self.likeNumberLabel.textColor = ZFCOLOR(102, 102, 102, 1.0);
        }
    }
    //回复数
    if ([_model.replyCount isEqualToString:@"0"]) {
        self.reviewNumberLabel.text = nil;
    }else {
        self.reviewNumberLabel.text = _model.replyCount;
    }

}

#pragma mark - getter
- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFill;
        _iconImageView.clipsToBounds = YES;
        _iconImageView.userInteractionEnabled = YES;
        @weakify(self);
        [_iconImageView addTapGestureWithComplete:^(UIView * _Nonnull view) {
            @strongify(self);
            if (self.communityAccountLikesUserAccountCompletionHandler) {
                self.communityAccountLikesUserAccountCompletionHandler(self.model.userId);
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
        _followButton.tag = followBtnTag;
        _followButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _followButton.layer.borderColor = ZFC0x2D2D2D().CGColor;
        [_followButton setTitleColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        [_followButton setTitle:[NSString stringWithFormat:@"%@",ZFLocalizedString(@"Community_Follow",nil)] forState:UIControlStateNormal];
        _followButton.backgroundColor = ZFC0xFFFFFF();
        
        _followButton.layer.borderWidth = 1;
        _followButton.layer.cornerRadius = 2;
        _followButton.layer.masksToBounds = YES;
        [_followButton addTarget:self action:@selector(followButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
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
    }
    return _contentImageView;
}

- (BigClickAreaButton *)likeButton {
    if (!_likeButton) {
        _likeButton = [BigClickAreaButton buttonWithType:UIButtonTypeCustom];
        _likeButton.clickAreaRadious = 44;
        [_likeButton addTarget:self action:@selector(likeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_likeButton setImage:[UIImage imageNamed:@"collection"] forState:UIControlStateNormal];
        [_likeButton setImage:[UIImage imageNamed:@"collection_on"] forState:UIControlStateSelected];
        [_likeButton.imageView convertUIWithARLanguage];

    }
    return _likeButton;
}

- (UILabel *)likeNumberLabel {
    if (!_likeNumberLabel) {
        _likeNumberLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _likeNumberLabel.font = [UIFont systemFontOfSize:12];
        _likeNumberLabel.textColor = ZFCOLOR(255, 168, 0, 1.0);
    }
    return _likeNumberLabel;
}

- (BigClickAreaButton *)reviewButton {
    if (!_reviewButton) {
        _reviewButton = [BigClickAreaButton buttonWithType:UIButtonTypeCustom];
        _reviewButton.clickAreaRadious = 44;
        [_reviewButton addTarget:self action:@selector(reviewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_reviewButton setImage:[UIImage imageNamed:@"comment"] forState:UIControlStateNormal];
        [_reviewButton.imageView convertUIWithARLanguage];

    }
    return _reviewButton;
}

- (UILabel *)reviewNumberLabel {
    if (!_reviewNumberLabel) {
        _reviewNumberLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _reviewNumberLabel.font = [UIFont systemFontOfSize:12];
        _reviewNumberLabel.textColor = ZFCOLOR(255, 168, 0, 1.0);
    }
    return _reviewNumberLabel;
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
@end
