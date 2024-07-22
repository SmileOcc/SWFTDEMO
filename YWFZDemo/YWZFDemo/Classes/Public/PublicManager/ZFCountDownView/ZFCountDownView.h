//
//  ZFCountDownView.h
//  ZZZZZ
//
//  Created by YW on 14/5/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZFCountDownView : UIView

/**
 初始化倒计时视图

 @param frame 布局位置
 @param timerSizeHeight 字体高度
 @param showDay 是否显示"天"
 @return 倒计时视图
 */
- (instancetype)initWithFrame:(CGRect)frame tierSizeHeight:(CGFloat)timerSizeHeight showDay:(BOOL)showDay;

/** 配置背景颜色：默认 .... */
@property (nonatomic, strong) UIColor *timerBackgroundColor;
/** 配置字体颜色：默认 2D2D2D */
@property (nonatomic, strong) UIColor *timerTextColor;
/** 配置字体背景颜色：默认 FFFFFF */
@property (nonatomic, strong) UIColor *timerTextBackgroundColor;
/** 配置冒号:颜色：默认 2D2D2D */
@property (nonatomic, strong) UIColor *timerDotColor;
/** 配置小区块圆角大小：默认 12 */
@property (nonatomic, assign) CGFloat timerCircleRadius;
/** 配置字体大小大小：默认 14*/
@property (nonatomic, assign) CGFloat fontSize;
/** 配置dot间距：默认 4*/
@property (nonatomic, assign) CGFloat dotPadding;
/**
 *  根据相应的key开启倒计时
 */
- (void)startTimerWithStamp:(NSString *)timeStamp timerKey:(NSString *)timerKey;

/**
 *  根据相应的key开启倒计时
 *  completeBlock : 倒计时完成回调
 */
- (void)startTimerWithStamp:(NSString *)timeStamp
                   timerKey:(NSString *)timerKey
              completeBlock:(void(^)(void))completeBlock;

/**
 * 小区块高度
 */
- (CGFloat)heightTimerLump;

@end
