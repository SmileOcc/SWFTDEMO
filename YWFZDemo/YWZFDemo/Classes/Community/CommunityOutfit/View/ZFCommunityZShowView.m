//
//  ZFCommunityZShowView.m
//  ZZZZZ
//
//  Created by YW on 2018/5/22.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityZShowView.h"
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

#define kiphoneXHomeBarHeight1          (IPHONE_X_5_15 ? 110 : 0)
#define kMainViewHeight                 (270.0 + kiphoneXHomeBarHeight1)
#define kItemHeight                     88.0

static ZFCommunityZShowView *communityZShowView = nil;
static dispatch_once_t onceToken;
@interface ZFCommunityZShowView ()

@property (nonatomic, strong) UIVisualEffectView *backgroudView;
/** 0.9 alpha 透明度 白色背景图 */
@property (nonatomic, strong) UIView *backAlpaView;
@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) ZFShowOutfitButton *showButton;
@property (nonatomic, strong) ZFShowOutfitButton *outfitsButton;
@property (nonatomic, strong) UIButton *closeButton;
/** 头像 */
@property (nonatomic, strong) UIImageView *iconImgView;
/** 文字描述 */
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation ZFCommunityZShowView

+ (instancetype)shareInstance {
    dispatch_once(&onceToken, ^{
        communityZShowView = [[ZFCommunityZShowView alloc] init];
    });
    return communityZShowView;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    [self zfInitView];
    [self zfAutoLayoutView];
}

- (void)zfInitView {
    [self.backgroudView.contentView addSubview:self.backAlpaView];
    [self.backgroudView.contentView addSubview:self.mainView];
    [self.backgroudView.contentView addSubview:self.iconImgView];
    [self.backgroudView.contentView addSubview:self.titleLabel];
    [self.mainView addSubview:self.showButton];
    [self.mainView addSubview:self.outfitsButton];
    [self.mainView addSubview:self.closeButton];
}

- (void)zfAutoLayoutView {
    self.backAlpaView.frame  = [UIScreen mainScreen].bounds;
    self.mainView.frame      = CGRectMake(0.0, self.backgroudView.height - kMainViewHeight, self.backgroudView.frame.size.width, kMainViewHeight);
    CGFloat offsetX          = (self.mainView.width - self.showButton.width * 2) / 3;
    self.showButton.frame    = CGRectMake(offsetX, self.mainView.height, self.showButton.width, self.showButton.height);
    self.outfitsButton.frame = CGRectMake(self.showButton.x + self.showButton.width + offsetX, self.showButton.y, self.outfitsButton.width, self.outfitsButton.height);
    
    self.closeButton.frame   = CGRectMake(0.0, self.mainView.frame.size.height - 10.0 - (IPHONE_X_5_15?36.0:36.0) - kiphoneXHomeBarHeight, 36.0, 36.0);
    self.closeButton.centerX = self.mainView.centerX;
}

- (void)show {
    [self.iconImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(96 + (IPHONE_X_5_15?20:0));
        make.centerX.offset(0);
        make.size.mas_equalTo(CGSizeMake(80, 80));
    }];
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.iconImgView.mas_bottom).offset(16);
        make.centerX.offset(0);
    }];
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

- (void)dismiss {
    [self dismissAnimation];
    [UIView animateWithDuration:0.3 animations:^{
        self.closeButton.transform = CGAffineTransformMakeRotation(0);
    }];
    
    double d = (2 * 0.04);
    
    [UIView animateWithDuration:0.3 delay:d options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.backgroudView.alpha = 0.0;
//        [self.iconImgView removeFromSuperview];
//        [self.titleLabel removeFromSuperview];
//        [self.showButton removeFromSuperview];
//        [self.outfitsButton removeFromSuperview];
        
        self.backgroudView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
        self.mainView.alpha                = 0.0;
        
    } completion:^(BOOL finished) {
        self.backgroudView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
        self.mainView.alpha                = 0.0;
        [self.backgroudView removeFromSuperview];
        onceToken = 0L;
        communityZShowView = nil;
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
- (void)communityShow {
    if (self.showsCallback) {
        [self dismiss];
        self.showsCallback();
    }
}

- (void)communityOutfits {
    if (self.outfitsCallback) {
        [self dismiss];
        self.outfitsCallback();
    }
}

- (void)communityClose {
    [self dismiss];
}

- (void)tapAction {
    [self dismiss];
}

#pragma mark - getter/setter
- (UIVisualEffectView *)backgroudView {
    if (!_backgroudView) {
        _backgroudView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        _backgroudView.frame = [UIScreen mainScreen].bounds;
        _backgroudView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap           = [[UITapGestureRecognizer alloc] init];
        [tap addTarget:self action:@selector(tapAction)];
        [_backgroudView addGestureRecognizer:tap];
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

@end
