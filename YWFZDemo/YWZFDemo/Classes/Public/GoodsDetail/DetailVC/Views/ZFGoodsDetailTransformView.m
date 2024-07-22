//
//  ZFGoodsDetailTransformView.m
//  ZZZZZ
//
//  Created by YW on 2018/6/27.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFGoodsDetailTransformView.h"
#import "ZFGoodsDetailAddCartView.h"
#import <Lottie/Lottie.h>
#import "ZFColorDefiner.h"
#import "ZFThemeManager.h"
#import "ZFFrameDefiner.h"
#import "ZFBTSManager.h"
#import "Constants.h"
#import "Masonry.h"
#import "UIView+ZFBadge.h"

#define kgradientLayerWidth             (KScreenWidth * 0.3)
static const CGFloat kLoadingViewHeight = 30.0f;

@interface ZFGoodsDetailTransformView ()
@property (nonatomic, strong) CABasicAnimation          *translate;
@property (nonatomic, strong) UIImageView               *rightImageView; //第二张默认占位图
@property (nonatomic, strong) UIImageView               *paneImageView;//骨架方格图
@property (nonatomic, strong) UIImageView               *slideImageView;//滑动视图
@property (nonatomic, strong) ZFGoodsDetailAddCartView  *addCartBarView;
@property (nonatomic, strong) LOTAnimationView          *animView;
@property (nonatomic, assign) BOOL                      hasFinishLoading;
@property (nonatomic, assign) BOOL                      finishTransition;
@end

@implementation ZFGoodsDetailTransformView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
        [self setupView];
        [self zfInitView];
        [self zfAutoLayoutView];
        [self addNotification];
    }
    return self;
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)appBecomeActive {
    if (self.alpha != 0 && self.hidden == NO) {
        [self startShimmer];
        if (self.showZLoadng) {
            _animView.hidden = NO;
            [_animView play];
        }
    }
}

- (void)setupView {
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = [UIColor whiteColor];
    self.userInteractionEnabled = YES;
    self.clipsToBounds = YES;
}

- (void)zfInitView {
    [self addSubview:self.paneImageView];
    [self.paneImageView addSubview:self.slideImageView];
    [self addSubview:self.addCartBarView];
    [self addSubview:self.rightImageView];
    [self addSubview:self.imageView];
}

- (void)zfAutoLayoutView {
    [self.addCartBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self);
    }];
    
    [self.paneImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self);
        make.top.mas_equalTo(self.mas_top).offset(kBannerViewHeight);
        make.bottom.mas_equalTo(self.addCartBarView.mas_top);
    }];
    
    [self.slideImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.paneImageView.mas_leading);
        make.top.mas_equalTo(self.paneImageView.mas_top).offset(-20);
        make.bottom.mas_equalTo(self.paneImageView.mas_bottom).offset(50);
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.showZLoadng) {
        //(KScreenWidth - kLoadingViewHeight) / 2,  CGRectGetMaxY(self.imageView.frame) + 12.0)
        _animView.center = self.center;
    }
}

- (void)setShowZLoadng:(BOOL)showZLoadng {
    _showZLoadng = showZLoadng;
    if (showZLoadng) {
        [self addSubview:self.animView];
    } else if (_animView){
        _animView.hidden = YES;
    }
}

- (void)startShimmer {
    self.slideImageView.hidden = NO;
    [self.slideImageView.layer removeAllAnimations];
    [self.slideImageView.layer addAnimation:self.translate forKey:nil];
}

- (CABasicAnimation *)translate {
    if (!_translate) {
        _translate = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
        _translate.fromValue = [NSNumber numberWithFloat:-kgradientLayerWidth];
        _translate.toValue = [NSNumber numberWithFloat:KScreenWidth*1.6];
        _translate.repeatCount = MAXFLOAT;
        _translate.duration = 1.5;
        _translate.autoreverses = NO;
    }
    return _translate;
}

- (void)tapPlaceHoldeImageAction {
    if (self.tapPopHandle) {
        self.tapPopHandle();
    }
}

#pragma mark - getter/setter
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.image = [UIImage imageNamed:@"loading_product"];
        _imageView.frame = CGRectMake(0.0, 0.0, kBannerViewWidth-4, kBannerViewHeight-4);
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        _imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
        [tapGesture addTarget:self action:@selector(tapPlaceHoldeImageAction)];
        [_imageView addGestureRecognizer:tapGesture];
    }
    return _imageView;
}

- (UIImageView *)rightImageView {
    if (!_rightImageView) {
        _rightImageView = [[UIImageView alloc] init];
        _rightImageView.contentMode = UIViewContentModeScaleAspectFill;
        _rightImageView.image = [UIImage imageNamed:@"loading_product"];
        CGFloat x = CGRectGetMaxX(self.imageView.frame) + 5;
        _rightImageView.frame = CGRectMake(x, 0.0, kBannerViewWidth-4, kBannerViewHeight-4);
        _rightImageView.contentMode = UIViewContentModeScaleAspectFill;
        _rightImageView.hidden = YES;
    }
    return _rightImageView;
}

- (UIImageView *)paneImageView {
    if (!_paneImageView) {
        _paneImageView = [[UIImageView alloc] init];
        _paneImageView.backgroundColor = [UIColor clearColor];
        _paneImageView.image = [UIImage imageNamed:@"goods_detail_big_placehoder"];
        //_paneImageView.contentMode = UIViewContentModeScaleAspectFit;不同手机有变形
    }
    return _paneImageView;
}

- (UIImageView *)slideImageView {
    if (!_slideImageView) {
        _slideImageView = [[UIImageView alloc] init];
        _slideImageView.backgroundColor = [UIColor clearColor];
        _slideImageView.image = [UIImage imageNamed:@"goods_detail_slide_layer"];
        _slideImageView.contentMode = UIViewContentModeScaleAspectFill;
        _slideImageView.hidden = YES;
    }
    return _slideImageView;
}

- (ZFGoodsDetailAddCartView *)addCartBarView {
    if (!_addCartBarView) {
        _addCartBarView = [[ZFGoodsDetailAddCartView alloc] initWithFrame:CGRectZero];
        _addCartBarView.userInteractionEnabled = NO;
        [_addCartBarView.cartButton.imageView clearBadge];
    }
    return _addCartBarView;
}

- (LOTAnimationView *)animView {
    if (!_animView) {
        _animView = [LOTAnimationView animationNamed:@"ZZZZZ_loading_downloading"];
        _animView.contentMode   = UIViewContentModeScaleAspectFit;
        _animView.loopAnimation = YES;
        _animView.hidden        = YES;
        _animView.frame         = CGRectMake(0, 0, kLoadingViewHeight, kLoadingViewHeight);
        _animView.center        = self.center;
    }
    return _animView;
}

- (void)setHasFinishTransition {
    self.rightImageView.hidden = NO;
    
//    self.finishTransition = YES;
//    if (self.finishTransition) {
//        [self startLoading];
//    } else {
//        [self endLoading];
//    }
}

- (void)startLoading {
    self.alpha = 1.0;
    self.hidden = NO;
    [self startShimmer];
    
    if (self.showZLoadng) {
        _animView.hidden = NO;
        [_animView play];
    }
}

- (void)endLoading {
//    self.hasFinishLoading = YES;
//    if (self.hasFinishLoading) return;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.slideImageView.layer removeAllAnimations];
        self.hidden = YES;
        //[self removeFromSuperview];
    }];
}

@end
