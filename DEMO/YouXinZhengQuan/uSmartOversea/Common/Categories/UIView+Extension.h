//
//  UIView+Extension.h
//  垂直采1.0
//
//  Created by Leo on 16/2/19.
//  Copyright © 2016年 chuizhicai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Extension)

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign, readonly) CGFloat left;
@property (nonatomic, assign, readonly) CGFloat right;
@property (nonatomic, assign, readonly) CGFloat top;
@property (nonatomic, assign, readonly) CGFloat bottom;

+ (UIView *)creatLineView;

// 国际认购标签
+ (UIView *)ECMTag;

+ (UIView *)ECMProfessionTagWithText:(NSString *)text;

// 自定义标签
+ (UIView *)ECMCustomTagWithText:(NSString *)text;

// 自定义港版标签
+ (UIView *)commonBlueTagWithText:(NSString *)text;

//以下是常用动画

/**
    左右抖动 (用于输入框错误提示 抖动)
 */
- (void)startShakeAimation;

/**
 有弹性的出现.
 */
- (void)startBouncesAnimation;

- (UIViewController*)viewController;

//画虚线
- (void)addBorderToLayerWithColor:(UIColor *)color;

+ (void)drawDashLine:(UIView *)lineView lineLength:(int)lineLength lineSpacing:(int)lineSpacing lineColor:(UIColor *)lineColor;


@end
