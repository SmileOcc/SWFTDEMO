//
//  ZFCommunityShowPostTransitionDelegate.m
//  ZZZZZ
//
//  Created by YW on 2019/10/9.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityShowPostTransitionDelegate.h"

#pragma mark - 自定义动画拦截器

@implementation ZFCommunityShowPostTransitionDelegate

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    ZFCommunityShowPostTransitionBegan *begain = [[ZFCommunityShowPostTransitionBegan alloc] init];
    begain.height = self.height;
    return begain;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    ZFCommunityShowPostTransitionEnd *end = [[ZFCommunityShowPostTransitionEnd alloc] init];
    return end;
}


@end

#pragma mark - 自定义动画实现

@implementation ZFCommunityShowPostTransitionBegan

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.25;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    fromVC.view.layer.zPosition = -1;
    fromVC.view.layer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    
    
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    toVC.view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, self.height?:[UIScreen mainScreen].bounds.size.height);
    [[transitionContext containerView] addSubview:toVC.view];
    toVC.view.layer.zPosition = MAXFLOAT;
    
    if ([toVC isKindOfClass:[ZFBaseViewController class]]) {
        ZFBaseViewController *baseVC = (ZFBaseViewController *)toVC;
        if (baseVC.backgroundView) {
            if (baseVC.backgroundView.superview) {
                [baseVC.backgroundView removeFromSuperview];
            }
            [fromVC.view addSubview:baseVC.backgroundView];
        }
    }
    
    CGFloat duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect frame = toVC.view.frame;
        frame.origin.y = [UIScreen mainScreen].bounds.size.height - self.height?:[UIScreen mainScreen].bounds.size.height;
        toVC.view.frame = frame;
    } completion:^(BOOL finished){
        [transitionContext completeTransition:YES];
    }];
}


@end

@implementation ZFCommunityShowPostTransitionEnd

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.25;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController * toVC =
    [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIViewController * fromVC =
    [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    if ([fromVC isKindOfClass:[ZFBaseViewController class]]) {
        ZFBaseViewController *baseVC = (ZFBaseViewController *)fromVC;
        if (baseVC.backgroundView && baseVC.backgroundView.superview) {
            [baseVC.backgroundView removeFromSuperview];
        }
    }
    
    CGFloat duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect frame = fromVC.view.frame;
        frame.origin.y = [UIScreen mainScreen].bounds.size.height;
        fromVC.view.frame = frame;
        toVC.view.layer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    } completion:^(BOOL finished){
        [transitionContext completeTransition:YES];
    }];
}

@end

