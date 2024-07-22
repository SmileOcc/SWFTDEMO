//
//  ZFCommunityMessageListCell.m
//  ZZZZZ
//
//  Created by YW on 2017/8/1.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityMessageListCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFCommunityMessageModel.h"
#import "NSDate+ZFExtension.h"
#import "ZFThemeManager.h"
#import "YYText.h"
#import <YYWebImage/YYWebImage.h>
#import "UIView+ZFViewCategorySet.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFCommunityMessageListCell () <ZFInitViewProtocol>

@property (nonatomic, strong) UIImageView           *userHeadImageView;
@property (nonatomic, strong) YYLabel               *contentLabel;
@property (nonatomic, strong) YYLabel               *creatTimeLabel;
@property (nonatomic, strong) UIImageView           *photoImageView;
@property (nonatomic, strong) UIButton              *followButton;
@property (nonatomic, strong) UIView                *redDotView;
@property (nonatomic, strong) UIImageView           *rankImageView;

@end

@implementation ZFCommunityMessageListCell
- (void)prepareForReuse {
    [super prepareForReuse];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.userHeadImageView];
    [self.contentView addSubview:self.contentLabel];
    [self.contentView addSubview:self.creatTimeLabel];
    [self.contentView addSubview:self.photoImageView];
    [self.contentView addSubview:self.followButton];
    [self.contentView addSubview:self.redDotView];
    [self.contentView addSubview:self.rankImageView];

}

- (void)zfAutoLayoutView {
    [self.userHeadImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.mas_equalTo(self.contentView).offset(16);
        make.width.height.mas_equalTo(51);
    }];
    
    [self.redDotView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.userHeadImageView.mas_trailing).offset(-1);
        make.centerY.mas_equalTo(self.userHeadImageView.mas_top).offset(1);
        make.size.mas_equalTo(CGSizeMake(6, 6));
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.userHeadImageView.mas_trailing).offset(12);
        make.top.mas_equalTo(self.userHeadImageView);
    }];
    
    [self.creatTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.userHeadImageView.mas_trailing).offset(12);
        make.top.mas_equalTo(self.contentLabel.mas_bottom).mas_offset(4);
        make.height.mas_equalTo(14);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).mas_offset(-12);
    }];
    
    [self.photoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(16);
        make.trailing.mas_equalTo(self.contentView).offset(-16);
        make.width.height.mas_equalTo(51);
        make.bottom.mas_lessThanOrEqualTo(self.contentView.mas_bottom).mas_offset(-12);
    }];
    
    [self.followButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(16);
        make.trailing.mas_equalTo(self.contentView).offset(-16);
        make.width.height.mas_equalTo(51);
    }];
    
    [self.rankImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.userHeadImageView.mas_trailing);
        make.bottom.mas_equalTo(self.userHeadImageView.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
}

#pragma mark - action
- (void)followButtonAction:(UIButton *)sender {
    if (self.communityMessageListFollowUserCompletionHandler) {
        self.communityMessageListFollowUserCompletionHandler(self.model);
    }
}

- (void)showReadMark:(BOOL)show {
    self.redDotView.hidden = !show;
}
#pragma mark - getter/setter

- (void)setModel:(ZFCommunityMessageModel *)model {
    _model = model;
    [self.userHeadImageView yy_setImageWithURL:[NSURL URLWithString:_model.avatar]
                                 placeholder:[UIImage imageNamed:@"public_user_small"]
                                     options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                    progress:nil
                                   transform:^UIImage *(UIImage *image, NSURL *url) {
                                       return image;
                                   }
                                  completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
                                  }];
    
    //回复时间
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[_model.add_time integerValue]];
    NSDateFormatter *dateFormatter = date.queryZFDateFormatter;
    [dateFormatter setDateFormat:@"MMM.dd,yyyy  HH:mm:ss"];
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en"];
    
    NSString *currentDateStr = [dateFormatter stringFromDate:date];
    NSMutableString* newStr= [[NSMutableString alloc]initWithString:currentDateStr];
    [newStr insertString:@"at"atIndex:12];
    self.creatTimeLabel.text = newStr;
    
    NSString *contentStr = [ZFToString(_model.content) stringByRemovingPercentEncoding];
    if (_model.nickname.length > 0) {
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@",_model.nickname, contentStr]];

        CGFloat rangeX = 0;
//        if ([SystemConfigUtils isRightToLeftShow]) {
//            text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@",contentStr,_model.nickname]];
//            rangeX = text.length - _model.nickname.length;
//        }
        text.yy_font = [UIFont boldSystemFontOfSize:14.0f];
        text.yy_color = ZFCOLOR(170, 170, 170, 1);

        [text yy_setColor:ZFCOLOR(51, 51, 51, 1) range:NSMakeRange(rangeX, _model.nickname.length)];
        [text yy_setFont:[UIFont systemFontOfSize:16] range:NSMakeRange(rangeX, _model.nickname.length)];
        
        [text yy_setTextHighlightRange:NSMakeRange(rangeX, _model.nickname.length)//设置点击的位置
                                 color:ZFCOLOR(51, 51, 51, 1)
                       backgroundColor:nil
                             tapAction:^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect){
                             }];
        
        self.contentLabel.attributedText = text;
    }else{
        self.contentLabel.text = contentStr;
    }
    
    
    self.followButton.hidden = YES;
    self.photoImageView.hidden = YES;
    // 1.关注   2.评论   3.点赞   4.置顶
    if (_model.message_type == MessageListFollowTag) {
        
        self.photoImageView.hidden = YES;
        self.followButton.hidden = _model.isFollow ? YES : NO;
        
    } else if (_model.message_type == MessageListLikeTag
               || _model.message_type == MessageListCommendTag
               || _model.message_type == MessageListGainedPoints
               || _model.message_type == MessageListTypeCollect
               || _model.message_type == MessageListTypeJoinTopic) {
        
        self.followButton.hidden = YES;
        self.photoImageView.hidden = NO;
        [self.photoImageView yy_setImageWithURL:[NSURL URLWithString:_model.pic_src]
                                    placeholder:[UIImage imageNamed:@"community_loading_default"]
                                        options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                       progress:^(NSInteger receivedSize, NSInteger expectedSize) { }
                                      transform:^UIImage *(UIImage *image, NSURL *url) {
                                          //                                           image = [image yy_imageByResizeToSize:CGSizeMake(51,51) contentMode:UIViewContentModeScaleAspectFill];
                                          return image;
                                      }
                                     completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
                                     }];
        
    } else if (_model.message_type == MessageListTypePost) {
        
        self.followButton.hidden = YES;
        self.photoImageView.hidden = NO;
        [self.photoImageView yy_setImageWithURL:[NSURL URLWithString:_model.pic_src]
                                    placeholder:[UIImage imageNamed:@"community_loading_default"]
                                        options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                       progress:^(NSInteger receivedSize, NSInteger expectedSize) { }
                                      transform:^UIImage *(UIImage *image, NSURL *url) {
                                          //                                           image = [image yy_imageByResizeToSize:CGSizeMake(51,51) contentMode:UIViewContentModeScaleAspectFill];
                                          return image;
                                      }
                                     completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
                                     }];
    }
    
    //红点
    BOOL show = ![_model.is_read boolValue];
    [self showReadMark:show];
    
    self.rankImageView.hidden = YES;
    if ([_model.identify_type integerValue] > 0) {
        [self.rankImageView yy_setImageWithURL:[NSURL URLWithString:_model.identify_icon] options:kNilOptions];
        self.rankImageView.hidden = NO;
    }
}

- (UIImageView *)userHeadImageView {
    if (!_userHeadImageView) {
        _userHeadImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _userHeadImageView.contentMode = UIViewContentModeScaleToFill;
        _userHeadImageView.userInteractionEnabled = YES;
        _userHeadImageView.clipsToBounds = YES;
        _userHeadImageView.layer.cornerRadius = 25.5;
        _userHeadImageView.layer.masksToBounds = YES;
        @weakify(self);
        [_userHeadImageView addTapGestureWithComplete:^(UIView * _Nonnull view) {
            @strongify(self);
            if (self.communityMessageAccountDetailCompletioinHandler) {
                self.communityMessageAccountDetailCompletioinHandler(self.model);
            }
        }];
    }
    return _userHeadImageView;
}

- (YYLabel *)contentLabel {
    if (!_contentLabel) {
        YYTextLinePositionSimpleModifier *modifier = [YYTextLinePositionSimpleModifier new];
        modifier.fixedLineHeight = 18;//行高
        
        _contentLabel = [[YYLabel alloc] initWithFrame:CGRectZero];
        _contentLabel.font = [UIFont boldSystemFontOfSize:16];
        _contentLabel.textColor = ZFCOLOR(51, 51, 51, 1.0);
        _contentLabel.numberOfLines = 0;
        _contentLabel.userInteractionEnabled = YES;
        _contentLabel.linePositionModifier = modifier;
        _contentLabel.preferredMaxLayoutWidth = KScreenWidth - 75-80;
        _contentLabel.textVerticalAlignment = YYTextVerticalAlignmentTop;
    }
    return _contentLabel;
}

- (YYLabel *)creatTimeLabel {
    if (!_creatTimeLabel) {
        YYTextLinePositionSimpleModifier *modifiers = [YYTextLinePositionSimpleModifier new];
        modifiers.fixedLineHeight = 14;//行高
        
        _creatTimeLabel = [[YYLabel alloc] initWithFrame:CGRectZero];
        _creatTimeLabel.textAlignment = NSTextAlignmentLeft;
        _creatTimeLabel.font = [UIFont systemFontOfSize:12];
        _creatTimeLabel.textColor = ZFCOLOR(170, 170, 170, 1.0);
        _creatTimeLabel.linePositionModifier = modifiers;
    }
    return _creatTimeLabel;
}

- (UIImageView *)photoImageView {
    if (!_photoImageView) {
        _photoImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _photoImageView.contentMode = UIViewContentModeScaleAspectFill;
        _photoImageView.clipsToBounds = YES;
        _photoImageView.hidden = YES;

    }
    return _photoImageView;
}

- (UIButton *)followButton {
    if (!_followButton) {
        _followButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _followButton.layer.cornerRadius = 2;
        _followButton.layer.masksToBounds = YES;
        _followButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_followButton initWithTitle:ZFLocalizedString(@"Community_Follow",nil) andImageName:@"message_follow" andTopHeight:5 andTextColor:ZFCOLOR(255, 168, 0, 1)];
        _followButton.hidden = YES;
        [_followButton addTarget:self action:@selector(followButtonAction:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _followButton;
}

- (UIView *)redDotView {
    if (!_redDotView) {
        _redDotView = [[UIView alloc] initWithFrame:CGRectZero];
        _redDotView.backgroundColor = ZFC0xFE5269();
        _redDotView.layer.cornerRadius = 3.0;
        _redDotView.hidden = YES;
    }
    return _redDotView;
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
