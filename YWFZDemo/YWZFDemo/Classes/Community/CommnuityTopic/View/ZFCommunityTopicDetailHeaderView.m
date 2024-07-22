//
//  ZFCommunityTopicDetailHeaderView.m
//  ZZZZZ
//
//  Created by YW on 2018/9/17.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFCommunityTopicDetailHeaderView.h"

#import "ZFInitViewProtocol.h"
#import "YYText.h"
#import "ZFCommunityTopicDetailNewViewModel.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "UIButton+ZFButtonCategorySet.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "NSStringUtils.h"
#import "YWCFunctionTool.h"
#import "ZFCountDownView.h"
#import "ZFTimerManager.h"

#import "UIImage+ZFExtended.h"
#import "UIView+ZFViewCategorySet.h"

@interface ZFCommunityTopicDetailHeaderView() <ZFInitViewProtocol>

@property (nonatomic, strong) YYAnimatedImageView     *topicImg;
@property (nonatomic, strong) UILabel                 *topicTitleLabel;
@property (nonatomic, strong) UIView                  *activityView;
@property (nonatomic, strong) ZFCountDownView         *activityCountDownView;
@property (nonatomic, strong) UILabel                 *activityMsgLabel;

@property (nonatomic, strong) UILabel                 *joinNumLabel;
@property (nonatomic, strong) UIButton                *joinBtn;
@property (nonatomic, strong) UIView                  *lineView;
@property (nonatomic, strong) YYLabel                 *likesNumberLabel;
@property (nonatomic, strong) YYLabel                 *contentLabel;
@property (nonatomic, strong) UILabel                 *viewLabel;
@property (nonatomic, strong) UIImageView             *viewArrowImgView;
@property (nonatomic, strong) UIView                  *bottomView;
@property (nonatomic, strong) UIButton                *outfisRuleButton;
@property (nonatomic, strong) UILabel                 *outfisRuleLabel;
@property (nonatomic, strong) UIImageView             *ourfisRuleImageview;

@property (nonatomic, strong) UIButton                *linkButton;



@property (nonatomic, assign)  CGFloat                baseFontSize;       //基准字体大小

@property (nonatomic, assign) CGFloat                 contentRealH;

@end

@implementation ZFCommunityTopicDetailHeaderView

- (void)dealloc {
    YWLog(@"---------%@ 释放啊 ",NSStringFromClass(self.class));
    [[ZFTimerManager shareInstance] stopTimer:_topicDetailHeadModel.countDownTimerKey];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.baseFontSize = 14;
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    [self addSubview:self.topView];
    
    [self.topView addSubview:self.topicImg];
    [self.topView addSubview:self.topicTitleLabel];
    [self.topView addSubview:self.activityView];
    
    [self.topView addSubview:self.joinNumLabel];
    [self.topView addSubview:self.joinBtn];
    [self.topView addSubview:self.likesNumberLabel];
    [self.topView addSubview:self.contentLabel];
    [self.topView addSubview:self.linkButton];
    [self.topView addSubview:self.lineView];
    [self.topView addSubview:self.viewLabel];
    [self.topView addSubview:self.viewArrowImgView];
    [self.topView addSubview:self.viewAllBtn];
    [self.topView addSubview:self.bottomView];
    
    [self.activityView addSubview:self.activityCountDownView];
    [self.activityView addSubview:self.activityMsgLabel];
    
    [self.topView addSubview:self.outfisRuleButton];
    [self.outfisRuleButton addSubview:self.outfisRuleLabel];
    [self.outfisRuleButton addSubview:self.ourfisRuleImageview];
    
}

- (void)zfAutoLayoutView {
    
    [self.topicImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topView).offset([ZFCommunityTopicDetailHeadLabelModel iphoneTopSpace]);
        make.leading.trailing.mas_equalTo(self.topView);
        make.height.mas_equalTo(160 *ScreenWidth_SCALE);
    }];
    
    [self.topicTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topicImg.mas_bottom).offset(10);
        make.leading.mas_equalTo(self.topView).offset(10);
        make.height.mas_equalTo(20);
    }];
    
    [self.outfisRuleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.topicTitleLabel.mas_centerY);
        make.trailing.mas_equalTo(self.topView.mas_trailing).offset(-12);
        make.leading.mas_equalTo(self.topicTitleLabel.mas_trailing).offset(5);
    }];
    
    [self.outfisRuleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.outfisRuleButton.mas_leading).offset(5);
        make.centerY.mas_equalTo(self.outfisRuleButton.mas_centerY);
    }];
    
    [self.ourfisRuleImageview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.outfisRuleButton.mas_trailing).offset(-5);
        make.centerY.mas_equalTo(self.outfisRuleButton.mas_centerY);
        make.leading.mas_equalTo(self.outfisRuleLabel.mas_trailing).offset(3);
    }];
    
    [self.activityView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.topView.mas_leading).offset(10);
        make.trailing.mas_equalTo(self.topView.mas_trailing).offset(-10);
        make.top.mas_equalTo(self.topicTitleLabel.mas_bottom);
    }];
    
    CGFloat tempHeight = [self.activityCountDownView heightTimerLump];
    [self.activityCountDownView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.activityView.mas_leading);
        make.top.mas_equalTo(self.activityView.mas_top).offset(8);
        make.height.mas_equalTo(tempHeight);
    }];
    
    [self.activityMsgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.activityView.mas_leading);
        make.trailing.mas_equalTo(self.activityView.mas_trailing);
        make.top.mas_equalTo(self.activityCountDownView.mas_bottom).offset(16);
        make.bottom.mas_equalTo(self.activityView.mas_bottom);
    }];
    
    [self.joinNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.activityView.mas_bottom).offset(5);
        make.leading.mas_equalTo(self.topView).offset(10);
        make.height.mas_equalTo(20);
        
    }];
    
    [self.joinBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.topView).offset(- 10);
        make.centerY.mas_equalTo(self.topicTitleLabel.mas_centerY).mas_offset(-15);
        make.width.height.mas_equalTo(74);
    }];
    
    [self.likesNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.joinNumLabel.mas_bottom).offset(5);
        make.leading.mas_equalTo(self.topView).offset(10);
        make.width.mas_equalTo(KScreenWidth - 20);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.likesNumberLabel.mas_bottom).offset(5);
        make.leading.mas_equalTo(self.topView).offset(10);
        make.width.mas_equalTo(KScreenWidth - 20);
    }];
    
    [self.linkButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.topView).offset(10);
        make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(0);
        make.height.mas_equalTo(0);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.linkButton.mas_bottom).offset(5);
        make.leading.mas_equalTo(self.topView.mas_leading);
        make.trailing.mas_equalTo(self.topView.mas_trailing);
        make.height.mas_equalTo(0);
    }];
    
    [self.viewAllBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.lineView.mas_bottom);
        make.centerX.mas_equalTo(self.topView.mas_centerX);
        make.height.mas_equalTo(40);
    }];
    
    [self.viewLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.viewAllBtn.mas_leading);
        make.centerY.mas_equalTo(self.viewAllBtn.mas_centerY);
    }];
    
    [self.viewArrowImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.viewLabel.mas_trailing).offset(4);
        make.trailing.mas_equalTo(self.viewAllBtn.mas_trailing);
        make.centerY.mas_equalTo(self.viewAllBtn.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(11, 11));
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.viewAllBtn.mas_bottom).offset(5);
        make.leading.mas_equalTo(self.topView.mas_leading);
        make.trailing.mas_equalTo(self.topView.mas_trailing);
        make.height.mas_equalTo(@12);
        make.bottom.mas_equalTo(self.topView.mas_bottom);
    }];
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(KScreenWidth);
        make.leading.top.trailing.mas_equalTo(self);
        make.bottom.mas_equalTo(self.mas_bottom);
    }];
    
    
    [self.topicTitleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.outfisRuleButton setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self.outfisRuleButton setContentHuggingPriority:260 forAxis:UILayoutConstraintAxisHorizontal];
    
}

#pragma mark - Action

- (void)clickEvent:(UIButton*)sender {
    
    // 显示部分内容
    BOOL isShowAll = NO;
    sender.selected = !sender.selected;
    
    if(sender.selected){
        // 显示全部内容
        isShowAll = YES;
        self.contentLabel.numberOfLines = 0;
        [UIView animateWithDuration:0.25 animations:^{
            CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI);
            [self.viewArrowImgView setTransform:transform];
        }];
        
        // 链接要在可以显示时，才显示
        NSString *deeplinkTitle = ZFToString(_topicDetailHeadModel.activity.link_name);
        if (!ZFIsEmptyString(self.deeplinkUrlString)) {
            self.linkButton.hidden = NO;
            if (ZFIsEmptyString(deeplinkTitle)) {
                deeplinkTitle = ZFLocalizedString(@"Community_post_detail_link", nil);
            }
            [self.linkButton setTitle:deeplinkTitle forState:UIControlStateNormal];
            [self.linkButton zfLayoutStyle:ZFButtonEdgeInsetsStyleLeft imageTitleSpace:3];
            [self.linkButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(2);
                make.height.mas_equalTo(35);
            }];
        } else {
            self.linkButton.hidden = NO;
            [self.linkButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(0);
                make.height.mas_equalTo(0);
            }];
        }
        
    }else{
        
        self.linkButton.hidden = YES;
        [self.linkButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(0);
            make.height.mas_equalTo(0);
        }];
        
        self.contentLabel.numberOfLines = 4;
        [UIView animateWithDuration:0.25 animations:^{
            CGAffineTransform transform = CGAffineTransformIdentity;
            [self.viewArrowImgView setTransform:transform];
        }];
    }
    
    self.topicDetailHeadModel.isShowAllContent = isShowAll;
    if (self.refreshHeadViewBlock) {
        self.refreshHeadViewBlock(isShowAll);
    }
}

- (void)actionRule:(UIButton *)sender {
    if (self.tapOutfiRuleBlock) {
        self.tapOutfiRuleBlock(@"");
    }
}

- (void)selectType:(NSInteger)btnTag {
    if (self.selectTypeEvent) {
        self.selectTypeEvent(btnTag);
    }
}

- (void)stopTimer {
    [[ZFTimerManager shareInstance] stopTimer:self.topicDetailHeadModel.countDownTimerKey];
}

- (void)joinBtnClickEvent:(UIButton*)sender {
    if (self.joinInMyStyleBlock) {
        self.joinInMyStyleBlock(self.topicTitleLabel.text);
    }
}

- (void)actionLink:(UIButton *)sender {
    if (self.deeplinkHandle) {
        self.deeplinkHandle(self.deeplinkUrlString);
    }
}

#pragma mark - setter

- (void)setTopicDetailHeadModel:(ZFCommunityTopicDetailHeadLabelModel *)topicDetailHeadModel {
    
    _topicDetailHeadModel = topicDetailHeadModel;
    @weakify(self)
    _topicDetailHeadModel.topicDetailBlock = ^(NSString *labName) {
        @strongify(self)
        if (self.topicDetailBlock) {
            self.topicDetailBlock(labName);
        }
    };
    [self.topicImg yy_setImageWithURL:[NSURL URLWithString:topicDetailHeadModel.iosDetailpic]
                          placeholder:[UIImage imageNamed:@"community_index_banner_loading"]
                              options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                             progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                             }
                            transform:^UIImage *(UIImage *image, NSURL *url) {
                                
                                return image;
                            }
                           completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
                               if (from == YYWebImageFromDiskCache) {
                                   YWLog(@"load from disk cache");
                               }
                           }];
    
    self.topicTitleLabel.text = topicDetailHeadModel.title;

    // 活动倒计时
    if ([_topicDetailHeadModel.activity.time integerValue] > 0 && ![_topicDetailHeadModel.activity.status isEqualToString:@"0"]) {
        self.activityView.hidden = NO;
        
        [[ZFTimerManager shareInstance] startTimer:_topicDetailHeadModel.countDownTimerKey];
        [self.activityCountDownView startTimerWithStamp:_topicDetailHeadModel.activity.time timerKey:_topicDetailHeadModel.countDownTimerKey];
        self.activityMsgLabel.text = ZFToString(_topicDetailHeadModel.activity.content);
        
        CGFloat timerHeight = [self.activityCountDownView heightTimerLump];
        [self.activityCountDownView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(timerHeight);
        }];
        
        [self.activityMsgLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.activityCountDownView.mas_bottom).offset(16);
        }];
        
    } else {
        self.activityView.hidden = YES;
        self.activityMsgLabel.text = @"";

        [self.activityCountDownView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        
        [self.activityMsgLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.activityCountDownView.mas_bottom);
        }];
    }
    
    self.likesNumberLabel.attributedText = _topicDetailHeadModel.likedNumAttributedText;
    if (ZFIsEmptyString(_topicDetailHeadModel.likedNumAttributedText.string)) {
        [self.likesNumberLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.joinNumLabel.mas_bottom);
        }];
    } else {
        [self.likesNumberLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.joinNumLabel.mas_bottom).offset(5);
        }];
    }
    self.contentLabel.attributedText = _topicDetailHeadModel.contentAttributedText;
    
    self.joinNumLabel.text = [NSString stringWithFormat:@"%@ %@",topicDetailHeadModel.joinNumber,ZFLocalizedString(@"Community_Big_Views",nil)];
    
    self.contentRealH = [ZFCommunityTopicDetailHeaderView TextHeight:topicDetailHeadModel.content FontSize:14 Width:KScreenWidth - 20];;

    self.deeplinkUrlString = ZFToString(_topicDetailHeadModel.activity.link_url);
    self.linkButton.hidden = YES;
    
    self.lineView.hidden = YES;
    self.viewAllBtn.hidden = YES;
    self.viewLabel.hidden = YES;
    self.viewArrowImgView.hidden = YES;
    self.contentLabel.numberOfLines = 4;
    if(self.contentRealH > 4 *self.baseFontSize){
        self.viewAllBtn.hidden = NO;
        self.viewLabel.hidden = NO;
        self.viewArrowImgView.hidden = NO;
        self.lineView.hidden = NO;
        
        [self.viewAllBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(40);
        }];
        if (_topicDetailHeadModel.isShowAllContent) {
            self.contentLabel.numberOfLines = 0;
        }
        
    } else {
        [self.viewAllBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }
}



//固定宽度，获取字符串的高度
+ (CGFloat)TextHeight:(NSString *)str2 FontSize:(CGFloat)fontsize Width:(CGFloat)width{
    NSString *str=[NSString stringWithFormat:@"%@",str2];
    CGSize constraint = CGSizeMake(width, MAXFLOAT);
    UILabel *lbl = [[UILabel alloc]init];
    UIFont *font =[UIFont fontWithName:lbl.font.familyName size:fontsize];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil];
    CGSize size = [str boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading  attributes:dic context:nil].size;
    
    return size.height;
}

#pragma mark - setter/getter

- (YYAnimatedImageView *)topicImg {
    if (!_topicImg) {
        _topicImg = [YYAnimatedImageView new];
        _topicImg.contentMode = UIViewContentModeScaleAspectFill;
        _topicImg.clipsToBounds = YES;
    }
    return _topicImg;
}

- (UILabel *)topicTitleLabel {
    if (!_topicTitleLabel) {
        _topicTitleLabel = [UILabel new];
        _topicTitleLabel.font = [UIFont systemFontOfSize:16];
        _topicTitleLabel.textColor = ColorHex_Alpha(0x2D2D2D, 1.0);
    }
    return _topicTitleLabel;
}

- (UIView *)activityView {
    if (!_activityView) {
        _activityView = [[UIView alloc] initWithFrame:CGRectZero];
        _activityView.hidden = YES;
    }
    return _activityView;
}

- (ZFCountDownView *)activityCountDownView {
    if (!_activityCountDownView) {
        _activityCountDownView = [[ZFCountDownView alloc] initWithFrame:CGRectZero tierSizeHeight:20 showDay:YES];
        _activityCountDownView.timerCircleRadius = 4;
        _activityCountDownView.timerTextBackgroundColor = ZFC0x333333();
        _activityCountDownView.timerTextColor = ZFC0xFFFFFF();
        _activityCountDownView.timerBackgroundColor = ZFC0xFFFFFF();
    }
    return _activityCountDownView;
}

- (UILabel *)activityMsgLabel {
    if (!_activityMsgLabel) {
        _activityMsgLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _activityMsgLabel.numberOfLines = 2;
        _activityMsgLabel.font = ZFFontSystemSize(14);
        _activityMsgLabel.textColor = ZFC0xFE5269();
    }
    return _activityMsgLabel;
}

- (UILabel *)joinNumLabel {
    if (!_joinNumLabel) {
        _joinNumLabel = [UILabel new];
        _joinNumLabel.font = [UIFont systemFontOfSize:12];
        _joinNumLabel.textColor = ColorHex_Alpha(0x999999, 1.0);
    }
    return _joinNumLabel;
}

- (UIButton *)joinBtn {
    if (!_joinBtn) {
        _joinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _joinBtn.backgroundColor = ZFCOLOR(255, 168, 0, 1.0);
        [_joinBtn initWithTitle:ZFLocalizedString(@"TopicDetailView_joinIn", nil) andImageName:@"joinin" andTopHeight:20 andTextColor:[UIColor whiteColor]];
        _joinBtn.clipsToBounds = YES;
        _joinBtn.layer.cornerRadius = 37;
        _joinBtn.layer.masksToBounds = YES;
        [_joinBtn addTarget:self action:@selector(joinBtnClickEvent:) forControlEvents:UIControlEventTouchUpInside];
        _joinBtn.hidden = YES;
    }
    return _joinBtn;
}

- (YYLabel *)likesNumberLabel {
    if (!_likesNumberLabel) {
        YYTextLinePositionSimpleModifier *modifier = [YYTextLinePositionSimpleModifier new];
        modifier.fixedLineHeight = 18;//行高
        _likesNumberLabel = [YYLabel new];
        _likesNumberLabel.linePositionModifier = modifier;
        _likesNumberLabel.preferredMaxLayoutWidth = KScreenWidth - 20;
        _likesNumberLabel.font = [UIFont systemFontOfSize:14];
        _likesNumberLabel.textColor = ZFC0x666666();
    }
    return _likesNumberLabel;
}

- (YYLabel *)contentLabel {
    if (!_contentLabel) {
        YYTextLinePositionSimpleModifier *modifier = [YYTextLinePositionSimpleModifier new];
        modifier.fixedLineHeight = 18;//行高
        _contentLabel = [YYLabel new];
        _contentLabel.linePositionModifier = modifier;
        _contentLabel.preferredMaxLayoutWidth = KScreenWidth - 20;
        _contentLabel.font = [UIFont systemFontOfSize:14];
        _contentLabel.textColor = ZFC0x666666();
    }
    return _contentLabel;
}

- (UIButton *)linkButton {
    if (!_linkButton) {
        _linkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_linkButton setImage:[UIImage imageNamed:@"community_link"] forState:UIControlStateNormal];
        [_linkButton setTitleColor:ZFC0xFE5269() forState:UIControlStateNormal];
        _linkButton.titleLabel.font = [UIFont systemFontOfSize:14];
        
        [_linkButton addTarget:self action:@selector(actionLink:) forControlEvents:UIControlEventTouchUpInside];
        [_linkButton zfLayoutStyle:ZFButtonEdgeInsetsStyleLeft imageTitleSpace:3];
        [_linkButton convertUIWithARLanguage];
    }
    return _linkButton;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor = ZFCOLOR(241, 241, 241, 1.0);
    }
    return _lineView;
}

- (UIButton *)viewAllBtn {
    if (!_viewAllBtn) {
        _viewAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _viewAllBtn.tag = 10;
        _viewAllBtn.backgroundColor = [UIColor clearColor];
        _viewAllBtn.titleLabel.font = ZFFontSystemSize(12);
        [_viewAllBtn setTitleColor:ColorHex_Alpha(0x2D2D2D, 1.0) forState:UIControlStateNormal];
        [_viewAllBtn addTarget:self action:@selector(clickEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _viewAllBtn;
}

- (UILabel *)viewLabel {
    if (!_viewLabel) {
        _viewLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _viewLabel.textColor = ColorHex_Alpha(0x2D2D2D, 1.0);
        _viewLabel.font = ZFFontSystemSize(14);
        _viewLabel.text = [NSStringUtils firstCharactersCapitalized:ZFLocalizedString(@"TopicDetailView_ViewAll", nil)];
    }
    return _viewLabel;
}

- (UIImageView *)viewArrowImgView {
    if (!_viewArrowImgView) {
        _viewArrowImgView = [[UIImageView alloc] init];
        _viewArrowImgView.image = [UIImage imageNamed:@"mine_coupon_arrow"];
    }
    return _viewArrowImgView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [UIView new];
        _bottomView.backgroundColor = ZFC0xF2F2F2();
    }
    return _bottomView;
}
/**
 * 初始化表格顶部view
 */
- (UIView *)topView {
    if(!_topView){
        _topView = [[UIView alloc] initWithFrame:CGRectZero];
        _topView.backgroundColor = ZFCOLOR(255, 255, 255, 0.5);
        CGRect rect = CGRectZero;
        rect.size = [_topView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        _topView.frame = rect;
    }
    return _topView;
}

- (UIButton *)outfisRuleButton {
    if (!_outfisRuleButton) {
        _outfisRuleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_outfisRuleButton addTarget:self action:@selector(actionRule:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _outfisRuleButton;
}

- (UILabel *)outfisRuleLabel {
    if (!_outfisRuleLabel) {
        _outfisRuleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _outfisRuleLabel.text = ZFLocalizedString(@"Community_outfit_rules", nil);
        _outfisRuleLabel.font = ZFFontSystemSize(13);
        _outfisRuleLabel.textColor = ZFC0x999999();
        _outfisRuleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _outfisRuleLabel;
}

- (UIImageView *)ourfisRuleImageview {
    if (!_ourfisRuleImageview) {
        _ourfisRuleImageview = [[UIImageView alloc] initWithFrame:CGRectZero];
        UIImage *arrowImage = [UIImage imageNamed:@"size_arrow_right"];
        _ourfisRuleImageview.image = arrowImage;
//        _ourfisRuleImageview.image = [arrowImage imageWithColor:ZFCThemeColor()];
        [_ourfisRuleImageview convertUIWithARLanguage];
        
    }
    return _ourfisRuleImageview;
}

@end
