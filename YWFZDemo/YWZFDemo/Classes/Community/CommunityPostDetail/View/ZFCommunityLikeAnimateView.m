//
//  ZFCommunityLikeAminateView.m
//  ZZZZZ
//
//  Created by YW on 2019/5/5.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityLikeAnimateView.h"
#import "Constants.h"


@interface ZFCommunityLikeAnimateView()
<
CAAnimationDelegate
>

@property (nonatomic, strong) UIImageView *originImageView;
@property (nonatomic, strong) UIImageView *animateImageView;

@end

@implementation ZFCommunityLikeAnimateView

+ (instancetype)shareManager {
    static ZFCommunityLikeAnimateView *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (UIImageView *)originImageView {
    if (!_originImageView) {
        _originImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 42, 40)];
        _originImageView.image = [UIImage imageNamed:@"community_likeBig"];
    }
    return _originImageView;
}


- (UIImageView *)animateImageView {
    if (!_animateImageView) {
        _animateImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 42, 40)];
        _animateImageView.image = [UIImage imageNamed:@"community_likeBig"];
    }
    return _animateImageView;
}

- (void)showview:(UIView *)superView completion:(void (^)(void))completion {
    if (self.isAnimating) {
        return;
    }
    if (self.superview) {
        [self removeFromSuperview];
    }
    if (superView) {
        self.frame = CGRectMake(100, 200, 42, 40);
        self.center = superView.center;
        self.hidden = NO;
        
        self.animateImageView.hidden = YES;
        [self addSubview:self.animateImageView];
        [self addSubview:self.originImageView];
        [superView addSubview:self];
        
        self.isAnimating = YES;
        [self.originImageView.layer addAnimation:[self showLikeOrangeAnimateViewAnimation] forKey:@"kShowLikeOrangeAnimateViewAnimation"];
    }
}

- (void)startAnimate {
    self.animateImageView.hidden = NO;
    [self.animateImageView.layer addAnimation:[self showLikeAnimatePanViewAnimation] forKey:@"kShowLikeAnimatePanViewAnimation"];

}

- (CASpringAnimation *)showLikeOrangeAnimateViewAnimation {
    
    CASpringAnimation * ani = [CASpringAnimation animationWithKeyPath:@"transform.scale"];
    ani.mass = 10.0; //质量，影响图层运动时的弹簧惯性，质量越大，弹簧拉伸和压缩的幅度越大
    ani.stiffness = 5000; //刚度系数(劲度系数/弹性系数)，刚度系数越大，形变产生的力就越大，运动越快
    ani.damping = 100.0;//阻尼系数，阻止弹簧伸缩的系数，阻尼系数越大，停止越快
    ani.initialVelocity = 5.f;//初始速率，动画视图的初始速度大小;速率为正数时，速度方向与运动方向一致，速率为负数时，速度方向与运动方向相反
    ani.duration = 0.8f;//ani.settlingDuration;
    ani.fromValue = @(0.75);
    ani.toValue = @(1);//[NSValue valueWithCGRect:self.originImageView.bounds];
    ani.removedOnCompletion = NO;
    ani.fillMode = kCAFillModeForwards;
    ani.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    ani.delegate = self;
    return ani;
}

- (CAAnimationGroup *)showLikeAnimatePanViewAnimation {
    
    CABasicAnimation *panViewAnimation = [CABasicAnimation animation];
    panViewAnimation.keyPath = @"transform.translation";
    panViewAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(-self.animateImageView.frame.size.width * 0.5 / 4.0, -86)];
    
    CABasicAnimation *scaleViewAnimation = [CABasicAnimation animation];
    scaleViewAnimation.keyPath = @"transform.scale";
    scaleViewAnimation.toValue = @(1.5);
    
    CABasicAnimation *opacityViewAnimation = [CABasicAnimation animation];
    opacityViewAnimation.keyPath = @"opacity";
    opacityViewAnimation.fromValue = @(0.7);
    opacityViewAnimation.toValue = @(0.3);
    
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[panViewAnimation, scaleViewAnimation,opacityViewAnimation];
    group.duration = 0.75f;
    group.removedOnCompletion = NO;
    group.repeatCount = 0;
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    group.delegate = self;
    group.fillMode = kCAFillModeForwards;

    return group;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    //暂时去掉上移动画
//    if ([anim isKindOfClass:[CASpringAnimation class]]) {
//        [self startAnimate];
//
//    } else {
        self.hidden = YES;
        self.isAnimating = NO;
        if (self.superview) {
            [self removeFromSuperview];
        }
        if (self.originImageView.superview) {
            [self.originImageView removeFromSuperview];
        }
        if (self.animateImageView.superview) {
            [self.animateImageView removeFromSuperview];
        }
        [self.originImageView.layer removeAnimationForKey:@"kShowLikeOrangeAnimateViewAnimation"];
//        [self.animateImageView.layer removeAnimationForKey:@"kShowLikeAnimatePanViewAnimation"];
//    }
}
@end
