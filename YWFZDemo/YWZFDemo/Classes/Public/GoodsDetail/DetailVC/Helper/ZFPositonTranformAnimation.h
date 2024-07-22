//
//  ZFPositonTranformAnimation.h
//  ZZZZZ
//
//  Created by YW on 2018/6/27.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 位置变动转场动画
 */
@interface ZFPositonTranformAnimation : NSObject <UIViewControllerAnimatedTransitioning>

/**
 *  初始化动画过渡代理
 */
+ (instancetype)transitionWithType:(UINavigationControllerOperation)type sourceView:(UIView *)sourceView;

@end
