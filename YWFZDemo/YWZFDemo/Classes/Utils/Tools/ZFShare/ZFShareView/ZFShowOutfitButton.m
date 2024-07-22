//
//  ZFShowOutfitButton.m
//  ZZZZZ
//
//  Created by YW on 2018/7/10.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFShowOutfitButton.h"
#import "ZFInitViewProtocol.h"
#import "UIColor+ImageGetColor.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "ZFThemeManager.h"

static NSString *kScaleanimationKey = @"transform.scale";
static NSString *kOpacityanimationKey = @"opacity";

@interface ZFShowOutfitButton () <ZFInitViewProtocol>
@property (nonatomic, strong) UIImage   *buttonImage;
/** 按钮上的图片 */
@property (nonatomic, strong) UIImageView *btnImgView;
/** 按钮上的文字 */
@property (nonatomic, strong) UILabel *btnLabel;
@end

@implementation ZFShowOutfitButton

- (instancetype)initWithBackImage:(NSString *__nonnull)backImage Image:(NSString *__nonnull)image Title:(NSString *__nonnull)title TransitionType:(ZFShowOutfitButtonTransitionType)type
{
    self = [super init];
    if (self) {
        self.adjustsImageWhenHighlighted = false; //取消高亮
        [self addTarget:self action:@selector(scaleToSmall) forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragEnter];
        [self addTarget:self action:@selector(scaleToDefault) forControlEvents:UIControlEventTouchDragExit];
        self.bounds = CGRectMake(0, 0, (KScreenWidth - 55 * 2 - 24)/2, (KScreenWidth - 55 * 2 - 24)/ 2 * 160/121);
        [self setBackgroundImage:[UIImage imageNamed:backImage] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.btnImgView.image = [UIImage imageNamed:image];
        self.btnLabel.text = title;
        self.transitionType = type;
        
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)zfInitView{
    [self addSubview:self.btnImgView];
    [self addSubview:self.btnLabel];
}

-(void)zfAutoLayoutView{
    [self.btnImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.centerY.offset(-10);
        make.size.mas_equalTo(80);
    }];
    
    [self.btnLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.btnImgView.mas_bottom).offset(6);
        make.centerX.offset(0);
        make.leading.mas_equalTo(self.mas_leading).offset(3);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-3);
    }];
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
        case ZFShowOutfitButtonTransitionTypeWave:{
            [self waveAnimation];
        }
            break;
        case ZFShowOutfitButtonTransitionTypeCircle:{
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
        //[self setTitleColor:[UIColor colorWithRed:(51)/255.0 green:(51)/255.0 blue:(51)/255.0 alpha:1] forState:UIControlStateNormal];
        if (self.completionAnimation) {
            self.completionAnimation(self);
        }
    }
    [self.imageView.layer removeAllAnimations];
}

- (UIImageView *)btnImgView{
    if (!_btnImgView) {
        _btnImgView = [[UIImageView alloc] init];
        _btnImgView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _btnImgView;
}

-(UILabel *)btnLabel{
    if (!_btnLabel) {
        _btnLabel = [[UILabel alloc] init];
        _btnLabel.textColor = ZFC0x666666();
        _btnLabel.textAlignment = NSTextAlignmentCenter;
        _btnLabel.font = [UIFont boldSystemFontOfSize:18];
        _btnLabel.numberOfLines = 0;
    }
    return _btnLabel;
}


@end
