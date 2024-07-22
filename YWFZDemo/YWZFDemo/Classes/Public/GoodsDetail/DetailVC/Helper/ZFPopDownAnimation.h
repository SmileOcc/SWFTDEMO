//
//  ZFPopDownAnimation.h
//  PathAnimation
//
//  Created by YW on 2018/11/24.
//  Copyright © 2018 610715. All rights reserved.
//  购物车加购动画

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^AnimationEndBlock)(void);

@interface ZFPopDownAnimation : NSObject

///动画结束点
@property (nonatomic, assign) CGPoint endPoint;

///动画视图
@property (nonatomic, strong) UIImage *animationImage;

///下落动画时长 默认 1.5s
@property (nonatomic, assign) CGFloat animationDuration;

- (void)startAnimation:(UIView *)superView endBlock:(AnimationEndBlock)block;

//抖动动画
+ (void)popDownRotationAnimation:(UIView *)animationView;

@end

NS_ASSUME_NONNULL_END
