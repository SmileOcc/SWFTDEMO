//
//  ZFShareButton.m
//  HyPopMenuView
//
//  Created by Tsang_Fa on 2017/8/4.
//  Copyright © 2017年 ZZZZZ. All rights reserved.
//

#import "ZFShareButton.h"
#import "UIColor+ImageGetColor.h"
#import "ZFThemeManager.h"
#import "ZFFrameDefiner.h"

static NSString *kScaleanimationKey = @"transform.scale";
static NSString *kOpacityanimationKey = @"opacity";
static CGFloat kFontSize    = 14.0f;
static CGFloat kButtonWidth = 93.0f;
static CGFloat kImageWidth  = 48.0f;
static CGFloat kTitleHeight = 20.0f;
static CGFloat kImageViewY  = 11.5f;
static CGFloat kTitleY      = 63.5f;


@interface ZFShareButton ()
@property (nonatomic, strong) UIImage   *buttonImage;
@end

@implementation ZFShareButton
+ (instancetype)buttonWithImage:(NSString *)image Title:(NSString *)title TransitionType:(ZFShareButtonTransitionType)type {
    ZFShareButton *button = [[ZFShareButton alloc] init];
    button.bounds = CGRectMake(0, 0, kButtonWidth, kButtonWidth);
    [button setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    UIColor *fontColor = [UIColor colorWithRed:(51)/255.0 green:(51)/255.0 blue:(51)/255.0 alpha:1];
    [button setTitleColor:fontColor forState:UIControlStateNormal];
    button.transitionType = type;
    return button;
}

+ (instancetype __nonnull)buttonWithBackImage:(NSString *__nonnull)backImage Image:(NSString *__nonnull)image Title:(NSString *__nonnull)title TransitionType:(ZFShareButtonTransitionType)type{
    ZFShareButton *button = [[ZFShareButton alloc] init];
    button.bounds = CGRectMake(0, 0, (KScreenWidth - 55 *2 - 24)/2, (KScreenWidth - 55 *2 - 24)/2 * 160/121);
    [button setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:backImage] forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.transitionType = type;
    return button;
}

- (instancetype __nonnull)init {
    self = [super initWithFrame:CGRectNull];
    if (self) {
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont systemFontOfSize:kFontSize];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = true;
        self.adjustsImageWhenHighlighted = false; //取消高亮
        
        [self addTarget:self action:@selector(scaleToSmall)
       forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragEnter];
        [self addTarget:self action:@selector(scaleToDefault)
       forControlEvents:UIControlEventTouchDragExit];
        self.layer.masksToBounds = true;
    }
    return self;
}

- (CGRect)adjustImageRect {
    CGFloat imageWidth  = kImageWidth;
    CGFloat imageX      = (kButtonWidth - imageWidth) / 2;
    CGFloat imageHeight = imageWidth;
    CGFloat imageY      = kImageViewY;
    return CGRectMake(imageX, imageY, imageWidth, imageHeight);
}

- (CGRect)adjustTitleRect {
    CGFloat titleX      = 0;
    CGFloat titleHeight = kTitleHeight;
    CGFloat titleY      = kTitleY;
    CGFloat titleWidth  = kButtonWidth;
    return CGRectMake(titleX, titleY, titleWidth, titleHeight);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect{
    if (!CGRectIsEmpty(self.titleRect) && !CGRectEqualToRect(self.titleRect, CGRectZero)) {
        return self.titleRect;
    }
    return [super titleRectForContentRect:contentRect];
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    if (!CGRectIsEmpty(self.imageRect) && !CGRectEqualToRect(self.imageRect, CGRectZero)) {
        return self.imageRect;
    }
    return [super imageRectForContentRect:contentRect];
}

- (void)scaleToSmall {
    CABasicAnimation *theAnimation = [CABasicAnimation animationWithKeyPath:kScaleanimationKey];
    theAnimation.delegate = self;
    theAnimation.duration = 0.1;
    theAnimation.repeatCount = 0;
    theAnimation.removedOnCompletion = FALSE;
    theAnimation.fillMode = kCAFillModeForwards;
    theAnimation.autoreverses = NO;
    theAnimation.fromValue = [NSNumber numberWithFloat:1];
    theAnimation.toValue = [NSNumber numberWithFloat:1.2f];
    [self.imageView.layer addAnimation:theAnimation forKey:theAnimation.keyPath];
}

- (void)scaleToDefault {
    CABasicAnimation *theAnimation = [CABasicAnimation animationWithKeyPath:kScaleanimationKey];
    theAnimation.delegate = self;
    theAnimation.duration = 0.1;
    theAnimation.repeatCount = 0;
    theAnimation.removedOnCompletion = FALSE;
    theAnimation.fillMode = kCAFillModeForwards;
    theAnimation.autoreverses = NO;
    theAnimation.fromValue = [NSNumber numberWithFloat:1.2f];
    theAnimation.toValue = [NSNumber numberWithFloat:1];
    [self.imageView.layer addAnimation:theAnimation forKey:theAnimation.keyPath];
}

- (void)waveAnimation {
    CABasicAnimation* scaleAnimation = [CABasicAnimation animationWithKeyPath:kScaleanimationKey];
    scaleAnimation.delegate = self;
    scaleAnimation.duration = 0.2;
    scaleAnimation.repeatCount = 0;
    scaleAnimation.removedOnCompletion = FALSE;
    scaleAnimation.fillMode = kCAFillModeForwards;
    scaleAnimation.autoreverses = NO;
    scaleAnimation.fromValue = @1;
    scaleAnimation.toValue = @1.4;
    
    CABasicAnimation* opacityAnimation = [CABasicAnimation animationWithKeyPath:kOpacityanimationKey];
    opacityAnimation.delegate = self;
    opacityAnimation.duration = 0.2;
    opacityAnimation.repeatCount = 0;
    opacityAnimation.removedOnCompletion = FALSE;
    opacityAnimation.fillMode = kCAFillModeForwards;
    opacityAnimation.autoreverses = NO;
    opacityAnimation.fromValue = @1;
    opacityAnimation.toValue = @0;
    
    [self.layer addAnimation:scaleAnimation forKey:scaleAnimation.keyPath];
    [self.layer addAnimation:opacityAnimation forKey:opacityAnimation.keyPath];
}

- (void)circleAnimation {
    self.userInteractionEnabled = false;
    self.layer.cornerRadius = CGRectGetWidth(self.bounds) / 2;
    UIImage *image = self.imageView.image;
    self.buttonImage = image;
    [self setImage:nil forState:UIControlStateNormal];
    UIColor *color = [UIColor getPixelColorAtLocation:CGPointMake(50, 20) inImage:image];
    [self setBackgroundColor:color];
    [self setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];

    CABasicAnimation* expandAnim = [CABasicAnimation animationWithKeyPath:kScaleanimationKey];
    expandAnim.fromValue = @(1.0);
    expandAnim.toValue = @(33.0);
    expandAnim.timingFunction = [CAMediaTimingFunction functionWithControlPoints:1 :0 :0.75 :1];
    expandAnim.duration = 0.35;
    expandAnim.delegate = self;
    expandAnim.fillMode = kCAFillModeForwards;
    expandAnim.removedOnCompletion = false;
    expandAnim.autoreverses = NO;
    [self.layer addAnimation:expandAnim forKey:expandAnim.keyPath];
}

- (void)selectdAnimation {
    switch (_transitionType) {
        case ZFShareButtonTransitionTypeWave:{
            [self waveAnimation];
        }
            break;
        case ZFShareButtonTransitionTypeCircle:{
            [self circleAnimation];
        }
            break;
    }
}

- (void)cancelAnimation {
    CABasicAnimation* scaleAnimation = [CABasicAnimation animationWithKeyPath:kScaleanimationKey];
    scaleAnimation.delegate = self;
    scaleAnimation.duration = 0.3;
    scaleAnimation.repeatCount = 0;
    scaleAnimation.removedOnCompletion = FALSE;
    scaleAnimation.fillMode = kCAFillModeForwards;
    scaleAnimation.autoreverses = NO;
    scaleAnimation.fromValue = @1;
    scaleAnimation.toValue = @0.3;
    
    CABasicAnimation* opacityAnimation = [CABasicAnimation animationWithKeyPath:kOpacityanimationKey];
    opacityAnimation.delegate = self;
    opacityAnimation.duration = 0.3;
    opacityAnimation.beginTime = 0;
    opacityAnimation.repeatCount = 0;
    opacityAnimation.removedOnCompletion = false;
    opacityAnimation.fillMode = kCAFillModeForwards;
    opacityAnimation.autoreverses = NO;
    opacityAnimation.fromValue = @1;
    opacityAnimation.toValue = @0;
    //CGAffineTransformIdentity
    [self.layer addAnimation:scaleAnimation forKey:[NSString stringWithFormat:@"cancel%@", scaleAnimation.keyPath]];
    [self.layer addAnimation:opacityAnimation forKey:opacityAnimation.keyPath];
}

- (void)animationDidStop:(CAAnimation*)anim finished:(BOOL)flag {
    CABasicAnimation* cab = (CABasicAnimation*)anim;
    if ([cab.toValue floatValue] == 33.0f || [cab.toValue floatValue] == 1.4f) {
        [self setUserInteractionEnabled:true];
        [self setTitleColor:[UIColor colorWithRed:(51)/255.0 green:(51)/255.0 blue:(51)/255.0 alpha:1] forState:UIControlStateNormal];
        if (self.completionAnimation) {
            self.completionAnimation(self);
        }
    }
    [self.imageView.layer removeAllAnimations];
}

- (void)resetAllAnimation {
    [self.imageView.layer removeAllAnimations];
    [self.layer removeAllAnimations];
    self.backgroundColor = [UIColor clearColor];
    [self setTitleColor:ZFCOLOR(51, 51, 51, 1) forState:0];
    if (self.buttonImage) {
        [self setImage:self.buttonImage forState:0];
    } else {
        [self setImage:self.imageView.image forState:0];
    }
}

@end
