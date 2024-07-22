//
//  ZFPositonTranformAnimation.m
//  ZZZZZ
//
//  Created by YW on 2018/6/27.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFPositonTranformAnimation.h"
#import "ZFGoodsDetailViewController.h"
#import "AppDelegate.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "Constants.h"

@interface ZFPositonTranformAnimation ()
@property (nonatomic, assign) UINavigationControllerOperation type;
@property (nonatomic, strong) UIImageView *sourceView;
@end

@implementation ZFPositonTranformAnimation

+ (instancetype)transitionWithType:(UINavigationControllerOperation)type sourceView:(UIView *)sourceView {
    return [[self alloc] initWithTransitionType:type sourceView:sourceView];
}

- (instancetype)initWithTransitionType:(UINavigationControllerOperation)type sourceView:(UIView *)sourceView {
    if (self = [super init]) {
        self.type = type;
        self.sourceView = (UIImageView *)sourceView;
    }
    return self;
}

- (void)animateTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext {
    switch (self.type) {
        case UINavigationControllerOperationPop:
            [self popAnimation:transitionContext];
            break;
        case UINavigationControllerOperationPush:
            [self pushAnimation:transitionContext];
            break;
        default:
            break;
    }
}

- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.35;
}

- (void)pushAnimation:(id<UIViewControllerContextTransitioning>)transitionContext
{
    ZFGoodsDetailViewController *toVC = (ZFGoodsDetailViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    if (toVC.fd_prefersNavigationBarHidden) {
        toView.frame = WINDOW.bounds;
    }
//    for (UIView *view in self.sourceView.subviews) {
//        [view removeFromSuperview];
//    }
    CGRect sourceFrame   = [self.sourceView convertRect:self.sourceView.frame toView:WINDOW];
    CGRect transformFrame = toVC.transformView.imageView.frame;
    CGRect toFrame = CGRectMake(CGRectGetMinX(transformFrame), 0,
                                CGRectGetWidth(transformFrame),
                                CGRectGetWidth(transformFrame) * CGRectGetHeight(sourceFrame) / CGRectGetWidth(sourceFrame));
    
    toVC.transformView.imageView.image = self.sourceView.image;
    toVC.transformView.imageView.frame = sourceFrame;
    [transitionContext.containerView addSubview:toVC.view];
    APPDELEGATE.tabBarVC.tabBar.hidden = YES;
    
//    toVC.transformView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
//    toVC.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
//    transitionContext.containerView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    
    //开始做动画
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration
                          delay:0
                        options:(UIViewAnimationOptionCurveEaseInOut)
                     animations:^{
//                         toVC.transformView.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
//                         toVC.view.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
//                         transitionContext.containerView.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
                         toVC.transformView.imageView.frame = toFrame;
                         
                     } completion:^(BOOL finished) {
                         [toVC.transformView setHasFinishTransition];
                         [transitionContext completeTransition:YES];
                     }];
}

- (void)popAnimation:(id<UIViewControllerContextTransitioning>)transitionContext {
    ZFGoodsDetailViewController *fromVC = (ZFGoodsDetailViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    UIView *snapshotView = [fromVC.transformView.imageView snapshotViewAfterScreenUpdates:YES];
    snapshotView.hidden = NO;
    toVC.view.hidden = NO;
    [containerView insertSubview:toVC.view atIndex:0];
    [containerView addSubview:snapshotView];

    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.tabBarVC.tabBar.alpha = 0.0;

    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        snapshotView.frame = [self.sourceView convertRect:self.sourceView.frame toView:[UIApplication sharedApplication].keyWindow];
        fromVC.view.alpha = 0;
        toVC.view.alpha = 1.0;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        if ([transitionContext transitionWasCancelled]) {
            fromVC.view.alpha = 1.0;
            toVC.view.alpha   = 0.0;
            [snapshotView removeFromSuperview];
        } else {
            fromVC.view.alpha = 0;
            toVC.view.alpha   = 1.0;
            [snapshotView removeFromSuperview];
            appDelegate.tabBarVC.tabBar.alpha = 1.0;
        }
    }];
}

@end
