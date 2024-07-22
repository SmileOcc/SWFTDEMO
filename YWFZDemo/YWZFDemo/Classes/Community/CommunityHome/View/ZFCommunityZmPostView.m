//
//  ZFCommunityZmPostView.m
//  ZZZZZ
//
//  Created by YW on 2019/7/5.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityZmPostView.h"

#import "ZFCommunityOutfitPostVC.h"
#import "ZFCommunityShowPostViewController.h"
#import "ZFCommunityTopicDetailPageViewController.h"

#import "PostPhotosManager.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "UIView+ZFViewCategorySet.h"
#import "SystemConfigUtils.h"
#import "YWCFunctionTool.h"

#import "ZFShareButton.h"
#import "ZFShowOutfitButton.h"
#import <pop/POP.h>
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "UIView+LayoutMethods.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

#define kZmPostHomeBarHeight1          (IPHONE_X_5_15 ? 110 : 0)
#define kZmMainViewHeight                 (270.0 + kZmPostHomeBarHeight1)
#define kZmItemHeight                     88.0

@interface ZFCommunityZmPostView ()

@property (nonatomic, strong) UIVisualEffectView     *backgroudView;
/** 0.9 alpha 透明度 白色背景图 */
@property (nonatomic, strong) UIView                 *backAlpaView;
@property (nonatomic, strong) UIView                 *mainView;
@property (nonatomic, strong) ZFShowOutfitButton     *showButton;
@property (nonatomic, strong) ZFShowOutfitButton     *outfitsButton;
@property (nonatomic, strong) UIButton               *closeButton;
/** 头像 */
@property (nonatomic, strong) UIImageView            *iconImgView;
/** 文字描述 */
@property (nonatomic, strong) UILabel                *titleLabel;

@property (nonatomic, strong) UIView                 *topicView;
@property (nonatomic, strong) UILabel                *topicTipLable;


@property (nonatomic, strong) ZFCommunityViewModel   *communityViewModel;

@end

@implementation ZFCommunityZmPostView

- (void)dealloc {
    YWLog(@"dealloc:%@",NSStringFromClass(self.class));
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self zfInitView];
        [self zfAutoLayoutView];
        
        self.iconImgView.hidden = YES;
        self.titleLabel.hidden = YES;
        
        UITapGestureRecognizer *tap           = [[UITapGestureRecognizer alloc] init];
        [tap addTarget:self action:@selector(tapAction)];
        [self.backgroudView addGestureRecognizer:tap];
        
        [self.communityViewModel requestReviewTopicList:nil completion:^(NSArray<ZFCommunityHotTopicModel *> *results) {
            
        }];
    }
    return self;
}

- (void)showHotTopicView {
    
    NSArray *topItems = self.topicView.subviews;
    for (UIView *subView in topItems) {
        if ([subView isKindOfClass:[ZFCommunityHotTopicItemView class]]) {
            [subView removeFromSuperview];
        }
    }
    
    @weakify(self)
    [self.communityViewModel requestHotTopicList:NO completion:^(NSArray<ZFCommunityHotTopicModel *> *results) {
        @strongify(self)
        [self handleHotTopic:results];
    }];
}


- (void)handleHotTopic:(NSArray <ZFCommunityHotTopicModel*> *)hotDatas {
    if (ZFJudgeNSArray(hotDatas)) {
        UIView *tempView;
        CGFloat kwidth = (KScreenWidth - 18 * 2 - 14 * 2) / 3.0;
        
        if (hotDatas.count > 0) {
            self.topicView.hidden = NO;
        }
        for (int i=0; i<3; i++) {
            if (hotDatas.count > i) {
                ZFCommunityHotTopicItemView *itemView = [[ZFCommunityHotTopicItemView alloc] initWithFrame:CGRectZero];
                itemView.tag = 20190 + i;
                itemView.layer.cornerRadius = 4;
                itemView.layer.masksToBounds = YES;
                [itemView addTarget:self action:@selector(actionHotTopic:) forControlEvents:UIControlEventTouchUpInside];
                itemView.hotTopicModel = hotDatas[i];
                [self.topicView addSubview:itemView];
                
                if (!tempView) {
                    [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.mas_equalTo(self.topicTipLable.mas_bottom).offset(18);
                        make.leading.mas_equalTo(self.topicView.mas_leading).offset(18);
                        make.width.mas_equalTo(kwidth);
                        make.height.mas_equalTo(64);
                    }];
                } else {
                    [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.mas_equalTo(self.topicTipLable.mas_bottom).offset(18);
                        make.leading.mas_equalTo(tempView.mas_trailing).offset(14);
                        make.width.mas_equalTo(kwidth);
                        make.height.mas_equalTo(64);
                    }];
                }
                
                tempView = itemView;
                
                if (i == 0) {
                    itemView.backgroundColor = ColorHex_Alpha(0xF52C3E, 0.05);
                    itemView.tipLabel.backgroundColor = ColorHex_Alpha(0xEB3848, 1.0);
                    itemView.topicLabel.textColor = ColorHex_Alpha(0xEB3848, 1.0);
                } else if(i == 1) {
                    itemView.backgroundColor = ColorHex_Alpha(0x3D76B9, 0.04);
                    itemView.tipLabel.backgroundColor = ColorHex_Alpha(0x2A7CDA, 1.0);
                    itemView.topicLabel.textColor = ColorHex_Alpha(0x2A7CDA, 1.0);
                } else {
                    itemView.backgroundColor = ColorHex_Alpha(0xF8A802, 0.06);
                    itemView.tipLabel.backgroundColor = ColorHex_Alpha(0xF8A802, 1.0);
                    itemView.topicLabel.textColor = ColorHex_Alpha(0xF8A802, 1.0);
                }
                
            }
        }
    }
}

- (void)zfInitView {
    [self.backgroudView.contentView addSubview:self.backAlpaView];
    [self.backgroudView.contentView addSubview:self.mainView];
    [self.backgroudView.contentView addSubview:self.iconImgView];
    [self.backgroudView.contentView addSubview:self.titleLabel];
    [self.mainView addSubview:self.showButton];
    [self.mainView addSubview:self.outfitsButton];
    [self.mainView addSubview:self.closeButton];
    
    [self.backgroudView.contentView addSubview:self.topicView];
    [self.topicView addSubview:self.topicTipLable];
}

- (void)zfAutoLayoutView {
    self.backgroudView.frame = [UIScreen mainScreen].bounds;
    self.backAlpaView.frame  = [UIScreen mainScreen].bounds;
    self.mainView.frame      = CGRectMake(0.0, self.backgroudView.height - kZmMainViewHeight, self.backgroudView.frame.size.width, kZmMainViewHeight);
    CGFloat offsetX          = (self.mainView.width - self.showButton.width * 2) / 3;
    self.showButton.frame    = CGRectMake(offsetX, self.mainView.height, self.showButton.width, self.showButton.height);
    self.outfitsButton.frame = CGRectMake(self.showButton.x + self.showButton.width + offsetX, self.showButton.y, self.outfitsButton.width, self.outfitsButton.height);
    
    self.closeButton.frame   = CGRectMake(0.0, self.mainView.frame.size.height - 10.0 - (IPHONE_X_5_15?36.0:36.0) - kiphoneXHomeBarHeight, 36.0, 36.0);
    self.closeButton.centerX = self.mainView.centerX;
    
    [self.iconImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(96 + (IPHONE_X_5_15?20:0));
        make.centerX.offset(0);
        make.size.mas_equalTo(CGSizeMake(80, 80));
    }];
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.iconImgView.mas_bottom).offset(16);
        make.centerX.offset(0);
    }];
    
    [self.topicView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self.backgroudView);
    }];
    
//    [self.topicTipLable mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.mas_equalTo(self.topicView.mas_leading).offset(60);
//        make.trailing.mas_equalTo(self.topicView.mas_trailing).offset(-60);
//        make.top.mas_equalTo(kiphoneXTopOffsetY + 32);
//        make.bottom.mas_equalTo(self.topicView.mas_bottom).offset(-100);
//    }];
    
    [self.topicTipLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.topicView.mas_leading).offset(60);
        make.trailing.mas_equalTo(self.topicView.mas_trailing).offset(-60);
        make.top.mas_equalTo(kiphoneXTopOffsetY + 45);
        make.bottom.mas_equalTo(self.topicView.mas_bottom).offset(-100);
    }];
}

- (void)hiddenViewAnimation:(BOOL)animation {
    [self dismiss:animation];
}

- (void)show {
    
    if (self.superview) {
        [self removeFromSuperview];
    }
    if (self.backgroudView.superview) {
        [self.backgroudView removeFromSuperview];
    }
    self.backgroudView.hidden = NO;
    self.backgroudView.alpha = 1.0;
    self.mainView.alpha = 1.0;
    [[UIApplication sharedApplication].keyWindow addSubview:self.backgroudView];
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        
        self.mainView.alpha                = 1.0;
        self.mainView.backgroundColor = [UIColor clearColor];
        self.closeButton.transform         = CGAffineTransformMakeRotation((M_PI / 2));
        
    } completion:^(BOOL finished) {
        self.mainView.alpha                = 1.0;
        self.mainView.backgroundColor = [UIColor clearColor];
    }];
    [self showAnimation];
}

- (void)dismiss:(BOOL)animation {
    
    if (!animation) {
        self.backgroudView.hidden = YES;
    }
    [self dismissAnimation];
    [UIView animateWithDuration:0.3 animations:^{
        self.closeButton.transform = CGAffineTransformMakeRotation(0);
    }];
    
    [UIView animateWithDuration:0.3 delay:(2 * 0.04) options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.backgroudView.alpha = 0.0;
        self.backgroudView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
        self.mainView.alpha                = 0.0;
        
    } completion:^(BOOL finished) {
        self.backgroudView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
        self.mainView.alpha                = 0.0;
        [self.backgroudView removeFromSuperview];

    }];
}

#pragma mark - animation
- (void)showAnimation {
    [self showButtonAnimation:self.showButton];
    [self showButtonAnimation:self.outfitsButton];
}

- (void)dismissAnimation {
    [self dismissButtonAnimation:self.showButton];
    [self dismissButtonAnimation:self.outfitsButton];
}

- (void)showButtonAnimation:(ZFShowOutfitButton *)button {
    double dy            = button.tag * 0.035f;
    CFTimeInterval delay = dy + CACurrentMediaTime();
    CGFloat offsetY      = (button.y - button.height) / 2;
    CGRect toRect        = CGRectMake(button.x, offsetY, button.width, button.width);
    CGRect fromRect      = button.frame;
    [self startViscousAnimationFormValue:fromRect ToValue:toRect Delay:delay Object:button HideDisplay:false];
}

- (void)dismissButtonAnimation:(ZFShowOutfitButton *)button {
    double d             = 2 * 0.04;
    double dy            = d - button.tag * 0.04;
    CFTimeInterval delay = dy + CACurrentMediaTime();
    CGRect toRect        = CGRectMake(button.x, self.mainView.height, button.width, button.width);
    CGRect fromRect      = button.frame;
    [self startViscousAnimationFormValue:fromRect ToValue:toRect Delay:delay Object:button HideDisplay:false];
}

- (void)startViscousAnimationFormValue:(CGRect)fromValue ToValue:(CGRect)toValue Delay:(CFTimeInterval)delay Object:(UIView*)obj HideDisplay:(BOOL)hideDisplay {
    CGFloat toV, fromV;
    CGFloat springBounciness = 9.f;
    toV                      = !hideDisplay;
    fromV                    = hideDisplay;
    
    if (hideDisplay) {
        POPBasicAnimation* basicAnimationCenter = [POPBasicAnimation animationWithPropertyNamed:kPOPViewCenter];
        basicAnimationCenter.toValue            = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(toValue), CGRectGetMidY(toValue))];
        basicAnimationCenter.fromValue          = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(fromValue), CGRectGetMidY(fromValue))];
        basicAnimationCenter.timingFunction     = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        basicAnimationCenter.beginTime          = delay;
        basicAnimationCenter.duration           = 0.18;
        [obj pop_addAnimation:basicAnimationCenter forKey:basicAnimationCenter.name];
        
        POPBasicAnimation* basicAnimationScale  = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleX];
        basicAnimationScale.removedOnCompletion = YES;
        basicAnimationScale.beginTime           = delay;
        basicAnimationScale.toValue             = @(0.7);
        basicAnimationScale.fromValue           = @(1);
        basicAnimationScale.duration            = 0.18;
        basicAnimationScale.timingFunction      = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        [obj.layer pop_addAnimation:basicAnimationScale forKey:basicAnimationScale.name];
    } else {
        POPSpringAnimation* basicAnimationCenter = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
        basicAnimationCenter.beginTime           = delay;
        basicAnimationCenter.springSpeed         = 10.0;
        basicAnimationCenter.springBounciness    = springBounciness;
        basicAnimationCenter.toValue             = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(toValue), CGRectGetMidY(toValue))];
        basicAnimationCenter.fromValue           = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(fromValue), CGRectGetMidY(fromValue))];
        
        POPBasicAnimation* basicAnimationScale = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleX];
        basicAnimationScale.beginTime          = delay;
        basicAnimationScale.toValue            = @(1);
        basicAnimationScale.fromValue          = @(0.7);
        basicAnimationScale.duration           = 0.3f;
        basicAnimationScale.timingFunction     = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        [obj.layer pop_addAnimation:basicAnimationScale forKey:basicAnimationScale.name];
        
        POPBasicAnimation* basicAnimationAlpha  = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
        basicAnimationAlpha.removedOnCompletion = YES;
        basicAnimationAlpha.duration            = 0.1f;
        basicAnimationAlpha.timingFunction      = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        basicAnimationAlpha.beginTime           = delay;
        basicAnimationAlpha.toValue             = @(toV);
        basicAnimationAlpha.fromValue           = @(fromV);
        
        [obj pop_addAnimation:basicAnimationAlpha forKey:basicAnimationAlpha.name];
        [obj pop_addAnimation:basicAnimationCenter forKey:basicAnimationCenter.name];
    }
}

#pragma mark - event

- (void)actionHotTopic:(ZFCommunityHotTopicItemView *)sender {
    
    ZFCommunityHotTopicModel *hotTopicModel = sender.hotTopicModel;
    if (hotTopicModel) {
        
        [self dismiss:YES];

        ZFCommunityTopicDetailPageViewController *topicDetailController = [[ZFCommunityTopicDetailPageViewController alloc] init];
        topicDetailController.topicId = hotTopicModel.idx;
        topicDetailController.hotTopicModel = hotTopicModel;
        UIViewController *currentViewController = [UIViewController currentTopViewController];
        [currentViewController.navigationController pushViewController:topicDetailController animated:YES];
    }
}
- (void)communityShow {
    if (self.showsBlock) {
        [self dismiss:YES];
        self.showsBlock();
    }
    [self pushShowPostController:nil];
}

- (void)communityOutfits {
    if (self.outfitsBlock) {
        [self dismiss:YES];
        self.outfitsBlock();
    }
    
    [self pushOutfitPostController:@""];
}

- (void)communityClose {
    [self dismiss:YES];
}

- (void)tapAction {
    [self dismiss:YES];
}

- (void)pushOutfitPostController:(NSString *)topic {
    ZFCommunityOutfitPostVC *outfitPostViewController = [[ZFCommunityOutfitPostVC alloc] init];
    
    // v5.3.0版本，优先使用ZmPostView带入的
    if (self.hotTopicModel) {
        outfitPostViewController.selectHotTopicModel = self.hotTopicModel;
    } else {
        ZFCommunityHotTopicModel *hotTopicModel = [[ZFCommunityHotTopicModel alloc] init];
        hotTopicModel.label = ZFToString(topic);
        outfitPostViewController.selectHotTopicModel = hotTopicModel;
    }
    
    UIViewController *currentViewController = [UIViewController currentTopViewController];
    ZFNavigationController *navigationController = [[ZFNavigationController alloc] initWithRootViewController:outfitPostViewController];
    [currentViewController.navigationController presentViewController:navigationController animated:YES completion:nil];
}
- (void)pushShowPostController:(NSString *)topic {
    
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
    ZFCommunityShowPostViewController *postVC = [[ZFCommunityShowPostViewController alloc] init];
    // v5.3.0版本，优先使用ZmPostView带入的
    if (self.hotTopicModel) {
        postVC.selectHotTopicModel = self.hotTopicModel;

    } else {
        ZFCommunityHotTopicModel *hotTopicModel = [[ZFCommunityHotTopicModel alloc] init];
        hotTopicModel.label = ZFToString(topic);
        postVC.selectHotTopicModel = hotTopicModel;
    }
    postVC.modalPresentationStyle = UIModalPresentationFullScreen;
    UIViewController *currentViewController1 = [UIViewController currentTopViewController];
    [currentViewController1 presentViewController:postVC animated:YES completion:nil];
}


#pragma mark - getter/setter
- (UIVisualEffectView *)backgroudView {
    if (!_backgroudView) {
        _backgroudView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        _backgroudView.frame = [UIScreen mainScreen].bounds;
        _backgroudView.userInteractionEnabled = YES;
    }
    return _backgroudView;
}

- (UIView *)mainView {
    if (!_mainView) {
        _mainView                 = [[UIView alloc] init];
        _mainView.backgroundColor = [UIColor clearColor];
    }
    return _mainView;
}

- (ZFShowOutfitButton *)showButton {
    if (!_showButton) {
        NSString *title       = ZFLocalizedString(@"community_show_new", nil);
        NSString *imageName   = @"community_z_shows";
        //@"community_show_bg"
        _showButton = [[ZFShowOutfitButton alloc] initWithBackImage:@"" Image:imageName Title:title TransitionType:ZFShowOutfitButtonTransitionTypeWave];
        _showButton.tag       = 0;
        [_showButton addTarget:self action:@selector(communityShow) forControlEvents:UIControlEventTouchUpInside];
    }
    return _showButton;
}

- (ZFShowOutfitButton *)outfitsButton {
    if (!_outfitsButton) {
        NSString *title          = ZFLocalizedString(@"community_outfit_new", nil);
        NSString *imageName      = @"community_z_outfit";
        //community_outfit_bg
        _outfitsButton = [[ZFShowOutfitButton alloc] initWithBackImage:@"" Image:imageName Title:title TransitionType:ZFShowOutfitButtonTransitionTypeWave];
        _outfitsButton.tag       = 1;
        [_outfitsButton addTarget:self action:@selector(communityOutfits) forControlEvents:UIControlEventTouchUpInside];
    }
    return _outfitsButton;
}

- (UIView *)backAlpaView {
    if (!_backAlpaView) {
        _backAlpaView = [[UIView alloc] init];
        _backAlpaView.backgroundColor = ZFC0xFFFFFF();
    }
    return _backAlpaView;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"login_dismiss"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(communityClose) forControlEvents:UIControlEventTouchUpInside];
        _closeButton.adjustsImageWhenHighlighted = NO;
    }
    return _closeButton;
}

- (UIImageView *)iconImgView{
    if (!_iconImgView) {
        _iconImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_iconImgView  yy_setImageWithURL:[NSURL URLWithString:[AccountManager sharedManager].account.avatar]
                              placeholder:[UIImage imageNamed:@"account_head"]
                                  options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                 progress:nil
                                transform:nil
                               completion:nil];
        
        _iconImgView.layer.cornerRadius = 40.0;
        _iconImgView.clipsToBounds = YES;
    }
    return _iconImgView;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = ZFLocalizedString(@"community_showoutfit_title", nil);
        _titleLabel.textColor = ZFCOLOR(45, 45, 45, 1);
        _titleLabel.font = [UIFont systemFontOfSize:16];
    }
    return _titleLabel;
}

- (UIView *)topicView {
    if (!_topicView) {
        _topicView = [[UIView alloc] initWithFrame:CGRectZero];
        _topicView.hidden = YES;
    }
    return _topicView;
}

- (UILabel *)topicTipLable {
    if (!_topicTipLable) {
        _topicTipLable = [[UILabel alloc] initWithFrame:CGRectZero];
        _topicTipLable.textColor = ZFC0x999999();
        _topicTipLable.font = [UIFont systemFontOfSize:16];
        _topicTipLable.textAlignment = NSTextAlignmentCenter;
        _topicTipLable.numberOfLines = 0;
//        _topicTipLable.text = ZFLocalizedString(@"Community_GetGift", nil);
        _topicTipLable.text = @"";
        _topicTipLable.hidden = YES;
    }
    return _topicTipLable;
}

- (ZFCommunityViewModel *)communityViewModel {
    if (!_communityViewModel) {
        _communityViewModel = [[ZFCommunityViewModel alloc] init];
    }
    return _communityViewModel;
}

@end



@implementation ZFCommunityHotTopicItemView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addSubview:self.tipLabel];
        [self addSubview:self.topicLabel];
        [self addSubview:self.topicDescLabel];
        
        [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).offset(7);
            make.top.mas_equalTo(self.mas_top).offset(9);
            make.size.mas_equalTo(CGSizeMake(16, 16));
        }];
        
        [self.topicLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.tipLabel.mas_trailing).offset(2);
            make.top.mas_equalTo(self.tipLabel.mas_top);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-7);
        }];
        
        [self.topicDescLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.topicLabel.mas_leading);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-7);
            make.top.mas_equalTo(self.topicLabel.mas_bottom).offset(2);
        }];
        
    }
    return self;
}

- (void)setHotTopicModel:(ZFCommunityHotTopicModel *)hotTopicModel {
    _hotTopicModel = hotTopicModel;
    
    NSString *hotTopicStr = ZFToString(hotTopicModel.label);
    if ([hotTopicStr hasPrefix:@"#"]) {
        hotTopicStr = [hotTopicStr substringFromIndex:1];
    }
    self.topicLabel.text = hotTopicStr;
    self.topicDescLabel.text = ZFToString(hotTopicModel.hot_content);
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tipLabel.text = @"#";
        _tipLabel.font = [UIFont boldSystemFontOfSize:14];
        _tipLabel.textColor = ZFC0xFFFFFF();
        _tipLabel.layer.cornerRadius = 8;
        _tipLabel.layer.masksToBounds = YES;
        _tipLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _tipLabel;
}

- (UILabel *)topicLabel {
    if (!_topicLabel) {
        _topicLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _topicLabel.font = [UIFont boldSystemFontOfSize:14];
        _topicLabel.textColor = ZFC0xFE5269();
        _topicLabel.numberOfLines = 2;
    }
    return _topicLabel;
}

- (UILabel *)topicDescLabel {
    if (!_topicDescLabel) {
        _topicDescLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _topicDescLabel.font = [UIFont systemFontOfSize:12];
        _topicDescLabel.textColor = ZFC0x999999();
    }
    return _topicDescLabel;
}



@end
