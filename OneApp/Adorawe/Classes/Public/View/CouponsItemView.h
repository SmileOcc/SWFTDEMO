//
//  CouponsItemView.h
//  testLayer
//
//  Created by Starlinke on 2021/7/30.
//
//  优惠券组件--可通用
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// 卡片是否带圆角
typedef enum : NSUInteger {
    couponsCornerTypeNone,
    couponsCornerTypeCorner
} couponsCornerType;

// 卡片背景渐变方向
// 目前就这四种吧  当然还有四种对角渐变（没需求先不扩展了）
typedef enum : NSUInteger {
    couponsDiretionLeftToRight,
    couponsDiretionRightToLeft,
    couponsDiretionTopToBottom,
    couponsDiretionBottomToTop
} couponsDiretion;

@interface CouponsItemView : UIView

// 中部圆角缺口起始y的值
@property (nonatomic, assign) CGFloat startY;
// 缺角半径（不设置的话 就没有缺角了）
@property (nonatomic, assign) CGFloat radio;

/// 颜色统一设置为#12EFCD 这种模式
@property (nonatomic, copy) NSString *startColor;// 背景渐变色初始值
@property (nonatomic, copy) NSString *endColor;// 背景渐变色结束值
@property (nonatomic, copy) NSString *lineColor;// 虚线颜色
@property (nonatomic, copy) NSString *lineBorderColor;// border 颜色

// 卡片是否加圆角
//（默认不加 加了圆角 默认圆角度数为6 可以自定义）
@property (nonatomic, assign) couponsCornerType cornerType;// 是否加圆角
@property (nonatomic, assign) CGFloat cornerValue;// 圆角度数（size:12,12 度数为6）

// 卡片的颜色渐变方向
//(默认水平 从左到右)
@property (nonatomic, assign) couponsDiretion diretion;// 背景渐变方向

// 调用它开始绘制
- (void)startDrawView;

@end

NS_ASSUME_NONNULL_END
