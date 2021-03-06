//
//  STLSTLPopCartAnimation.m
// XStarlinkProject
//
//  Created by odd on 2021/7/7.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "STLPopCartAnimation.h"

typedef NS_ENUM(NSInteger) {
    PopAnimationStatus_Start,
    PopAnimationStatus_Poping,
    PopAnimationStatus_End
}PopAnimationStatus;

@interface STLPopCartAnimation ()
<
    CAAnimationDelegate
>

@property (nonatomic, assign) CGFloat animationViewScale;
@property (nonatomic, copy) AnimationEndBlock endBlock;
@property (nonatomic, assign) PopAnimationStatus status;
@property (nonatomic, weak) UIView *animationTempView;
@end


@implementation STLPopCartAnimation

- (void)dealloc {
    STLLog(@"STLSTLPopCartAnimation dealloc");
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.animationDuration = 1.5f;
        self.animationViewScale = 0.2f;
        self.status = PopAnimationStatus_End;
    }
    return self;
}

+ (void)popDownRotationAnimation:(UIView *)animationView
{
    if (!animationView) {
        return;
    }
    if (animationView.layer.animationKeys) {
        return;
    }
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.fromValue = @((M_PI / 12));
    rotationAnimation.toValue = @(-(M_PI / 12));
    rotationAnimation.fillMode = kCAFillModeBoth;
    rotationAnimation.duration = 0.3;
    rotationAnimation.autoreverses = YES;
    [animationView.layer addAnimation:rotationAnimation forKey:nil];
    
}

- (void)startAnimation:(UIView *)superView endBlock:(AnimationEndBlock)block
{
    if (!self.animationImage) {
        // 防止没图
        self.animationImage = [UIImage imageNamed:@"ProductImageLogo"];
    }
    
    if (!superView) {
        if (self.noAnimationBlock) {
            self.noAnimationBlock();
        }
        return;
    }
    
    if (self.status != PopAnimationStatus_End) {
        if (self.noAnimationBlock) {
            self.noAnimationBlock();
        }
        return;
    }
    self.status = PopAnimationStatus_Start;
    
    _endBlock = block;

    UIImageView *popView = [[UIImageView alloc] init];
    popView.image = self.animationImage;
    popView.contentMode = UIViewContentModeScaleAspectFill;
    popView.layer.masksToBounds = YES;
    //调整缩放位置
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    popView.frame = CGRectMake(0, screenSize.height / 4.0, screenSize.width, screenSize.width);
    popView.layer.cornerRadius = popView.frame.size.height / 2;
    [superView addSubview:popView];
    [superView bringSubviewToFront:popView];
    self.animationTempView = popView;

    CASpringAnimation *springAnimation = [CASpringAnimation animationWithKeyPath:@"transform.scale"];
    springAnimation.fromValue = @(1);
    springAnimation.toValue = @(self.animationViewScale + 0.05);
    //质量，影响图层运动时的弹簧惯性，质量越大，弹簧拉伸和压缩的幅度越大
    springAnimation.mass = 1;  //1
    //刚度系数(劲度系数/弹性系数)，刚度系数越大，形变产生的力就越大，运动越快 Defaults to 100
    springAnimation.stiffness = 800; //800
    //阻尼系数，阻止弹簧伸缩的系数，阻尼系数越大，停止越快 Defaults to 10
//    springAnimation.damping = 35; //35
    springAnimation.damping = 100;
    //初始速率，动画视图的初始速度大小 Defaults to zero
    //速率为正数时，速度方向与运动方向一致，速率为负数时，速度方向与运动方向相反
    springAnimation.initialVelocity = 1; //1
    springAnimation.removedOnCompletion = NO;
    springAnimation.delegate = self;
    springAnimation.duration = springAnimation.settlingDuration;
    springAnimation.fillMode = kCAFillModeForwards;

    [popView.layer addAnimation:springAnimation forKey:@"springAnimation"];
}

- (void)secondTwoLineAnimation:(UIView *)cView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        //第一条路径
        UIBezierPath *startPath = [UIBezierPath bezierPath];
        [startPath moveToPoint:cView.center];
        CGPoint redRect = cView.center;
        CGPoint endPoint = CGPointMake(redRect.x, redRect.y + 200);
        [startPath addQuadCurveToPoint:endPoint controlPoint:CGPointMake(redRect.x + 200, redRect.y - 50)];
        
        //第二条路径
        UIBezierPath *secondPath = [UIBezierPath bezierPath];
        [secondPath moveToPoint:endPoint];
        [secondPath addQuadCurveToPoint:self.endPoint controlPoint:CGPointMake(endPoint.x - 120, endPoint.y + 120)];
        
        //合并路径
        [startPath appendPath:secondPath];
        
        //起点

        CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        pathAnimation.path = startPath.CGPath;
        
        CAMediaTimingFunction *timing = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        pathAnimation.timingFunction = timing;
        
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.fromValue = @(self.animationViewScale);
        scaleAnimation.toValue = @(0.0);
        
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.animations = @[pathAnimation, scaleAnimation];
        group.duration = self.animationDuration;
        group.removedOnCompletion = NO;
        group.repeatCount = 0;
        group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        group.delegate = self;
        group.fillMode = kCAFillModeForwards;
        
        [cView.layer addAnimation:group forKey:nil];
        //        [self.view.layer addSublayer:pathLayer];
    });
}


- (void)secondOneLineAnimation:(UIView *)cView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        //第一条路径
        UIBezierPath *startPath = [UIBezierPath bezierPath];
        [startPath moveToPoint:cView.center];
        CGPoint redRect = cView.center;
        CGFloat controlX = redRect.x + 200;
        
        //阿语适配
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            if (self.endPoint.x < 150) {
                controlX = redRect.x - 150;
            }
        }
        
        [startPath addQuadCurveToPoint:self.endPoint controlPoint:CGPointMake(controlX, redRect.y - 50)];

        CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        pathAnimation.path = startPath.CGPath;
        
        CAMediaTimingFunction *timing = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        pathAnimation.timingFunction = timing;
        
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.fromValue = @(self.animationViewScale);
        scaleAnimation.toValue = @(0.0);
        
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.animations = @[pathAnimation, scaleAnimation];
        group.duration = self.animationDuration;
        group.removedOnCompletion = NO;
        group.repeatCount = 0;
        group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        group.delegate = self;
        group.fillMode = kCAFillModeForwards;
        
        [cView.layer addAnimation:group forKey:nil];
    });
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if ([anim isKindOfClass:[CAAnimationGroup class]]) {
        //end
        [self endGroupAnimateBlock];
    }
    if ([anim isKindOfClass:[CASpringAnimation class]]) {
        [self secondOneLineAnimation:self.animationTempView];
    }
}

- (void)endGroupAnimateBlock {
    self.status = PopAnimationStatus_End;
    if (self.endBlock) {
        [self.self.animationTempView removeFromSuperview];
        self.animationTempView = nil;
        self.endBlock();
    }
}

@end
