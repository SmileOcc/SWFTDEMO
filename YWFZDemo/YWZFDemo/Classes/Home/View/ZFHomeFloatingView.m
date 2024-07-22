//
//  ZFHomeFloatingView.m
//  ZZZZZ
//
//  Created by YW on 2018/11/31.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFHomeFloatingView.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import <YYImage/YYImage.h>
#import "ZFFrameDefiner.h"
#import "Constants.h"

@interface ZFHomeFloatingView ()
@property (nonatomic, strong) NSString                  *imageurl;
@property (nonatomic, strong) YYAnimatedImageView       *imageView;
@property (nonatomic, strong) UIButton                  *closeButton;
@property (nonatomic, copy)   void (^tapBlock)(void);   //点击事件回调
@property (nonatomic, copy)   void (^closeBlock)(void); //关闭事件回调
@end

@implementation ZFHomeFloatingView

/**
 * 显示首页浮窗
 */
+ (void)showFloatingViewWithUrl:(NSString *)imageurl
                       tapBlock:(void(^)(void))tapBlock
                     closeBlock:(void(^)(void))closeBlock
{
    UIWindow* window = [UIApplication sharedApplication].delegate.window;
    
    UIView *oldFloatingView = [window viewWithTag:kHomeFloatingViewTag];
    if (oldFloatingView && [oldFloatingView isKindOfClass:[ZFHomeFloatingView class]]) {
        [oldFloatingView removeFromSuperview];//防止走两次
    }
    
    if (!imageurl) return;
    ZFHomeFloatingView *floatingView = [[ZFHomeFloatingView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    floatingView.tag = kHomeFloatingViewTag;
    floatingView.tapBlock = tapBlock;
    floatingView.closeBlock = closeBlock;
    [window addSubview:floatingView];
    floatingView.imageurl = imageurl;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
        self.alpha = 1.0;
        [self addSubview:self.imageView];
        [self addSubview:self.closeButton];
    }
    return self;
}

#pragma mark -===========点击事件===========

- (void)tunrToInfoAction {
    [self removeFromSuperview];
    if (self.tapBlock) {
        self.tapBlock();
    }
}

- (void)closeAtion {
    [self removeFromSuperview];
    if (self.closeBlock) {
        self.closeBlock();
    }
}

- (void)setImageurl:(NSString *)imageurl {
    if (!imageurl) {
        [self closeAtion];
        return;
    };
    
    [self.imageView yy_setImageWithURL:[NSURL URLWithString:imageurl]
                          placeholder:[UIImage imageNamed:@"loading_AdvertBg"]
                               options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                              progress:nil
                             transform:nil
                            completion:nil];
}

#pragma mark - getter/setter

- (YYAnimatedImageView *)imageView {
    if (!_imageView) {
        _imageView = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.userInteractionEnabled = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        CGFloat width = 300 * ScreenWidth_SCALE;
        CGFloat height = 300 * ScreenWidth_SCALE;
        CGFloat imgX = (KScreenWidth - width) / 2;
        CGFloat imgY = (KScreenHeight - (height + 20.0 + 40)) / 2;
        _imageView.frame = CGRectMake(imgX, imgY, width, height);
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
        [tapGesture addTarget:self action:@selector(tunrToInfoAction)];
        [_imageView addGestureRecognizer:tapGesture];
    }
    return _imageView;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.backgroundColor = [UIColor clearColor];
        [_closeButton setBackgroundImage:[UIImage imageNamed:@"home_suspension_close"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeAtion) forControlEvents:UIControlEventTouchUpInside];
        CGFloat btnSize = 40.0;
        _closeButton.frame = CGRectMake(0.0, 0.0, btnSize, btnSize);
        _closeButton.center = CGPointMake(KScreenWidth / 2, CGRectGetMaxY(self.imageView.frame) + btnSize + btnSize / 2.0);
    }
    return _closeButton;
}

@end
