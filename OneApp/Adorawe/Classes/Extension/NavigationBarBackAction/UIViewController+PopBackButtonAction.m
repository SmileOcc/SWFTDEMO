//
//  UIViewController+PopBackButtonAction.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/20.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "UIViewController+PopBackButtonAction.h"

@implementation UIViewController (PopBackButtonAction)

@end

// UINavigationController Category 写在一起避免要写两个Category 还要引入头文件的问题
@implementation UINavigationController (ShouldPopOnBackButton)

// 重写
- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    // 验证判断 层级
    if([self.viewControllers count] < [navigationBar.items count]) {
        return YES;
    }
    BOOL shouldPop = YES;
    // 代理返回
    UIViewController* viewController = [self topViewController];
    if([viewController respondsToSelector:@selector(navigationShouldPopOnBackButton)]) {
        shouldPop = [viewController navigationShouldPopOnBackButton];
    }
    /**
     *  此处为什么要写这个呢，因为当你
     1、A --> B --> C ;
     2、C --> A 之后 你再进入 B 之后，B不能返回 A的情况
     所以 一般改变等级后 直接返回 return NO (navigationShouldPopOnBackButton)
     */
    if(shouldPop) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self popViewControllerAnimated:YES];
        });
    } else {
        for(UIView *subview in [navigationBar subviews]) {
            if(0. < subview.alpha && subview.alpha < 1.) {
                [UIView animateWithDuration:.25 animations:^{
                    subview.alpha = 1.;
                }];
            }
        }
    }
    return NO;
}

@end
