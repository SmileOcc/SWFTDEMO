//
//  ZFCommunityShowPostTransitionDelegate.h
//  ZZZZZ
//
//  Created by YW on 2019/10/9.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZFBaseViewController.h"

#pragma mark - 自定义动画拦截器

@interface ZFCommunityShowPostTransitionDelegate : NSObject<UIViewControllerTransitioningDelegate>

@property (nonatomic, assign) CGFloat height;

@end

#pragma mark - 自定义动画实现

@interface ZFCommunityShowPostTransitionBegan : NSObject <UIViewControllerAnimatedTransitioning>


@property (nonatomic, assign) CGFloat height;

@end

@interface ZFCommunityShowPostTransitionEnd : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) CGFloat height;

@end
