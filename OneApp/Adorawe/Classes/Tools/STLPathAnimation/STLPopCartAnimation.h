//
//  STLSTLPopCartAnimation.h
// XStarlinkProject
//
//  Created by odd on 2021/7/7.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void(^AnimationEndBlock)(void);


@interface STLPopCartAnimation : NSObject

///动画结束点
@property (nonatomic, assign) CGPoint endPoint;

///动画视图
@property (nonatomic, strong) UIImage *animationImage;

///下落动画时长 默认 1.5s
@property (nonatomic, assign) CGFloat animationDuration;

@property (nonatomic, copy) AnimationEndBlock noAnimationBlock;

- (void)startAnimation:(UIView *)superView endBlock:(AnimationEndBlock)block;

//抖动动画
+ (void)popDownRotationAnimation:(UIView *)animationView;

@end

