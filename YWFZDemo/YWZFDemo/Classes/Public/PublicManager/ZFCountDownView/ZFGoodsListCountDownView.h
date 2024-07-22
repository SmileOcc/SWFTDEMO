//
//  ZFGoodsListCountDownView.h
//  ZZZZZ
//
//  Created by YW on 2019/4/25.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZFGoodsListCountDownView : UIView

/** 配置背景颜色：默认 .... */
@property (nonatomic, strong) UIColor *timerBackgroundColor;

/** 配置字体颜色：默认 2D2D2D */
@property (nonatomic, strong) UIColor *timerTextColor;
/** 配置字体背景颜色：默认 FFFFFF */
@property (nonatomic, strong) UIColor *timerTextBackgroundColor;
/** 配置冒号:颜色：默认 2D2D2D */
@property (nonatomic, strong) UIColor *timerDotColor;
/** 配置字体大小大小：默认 14 未实现 */

- (void)startTimerWithStamp:(NSString *)timeStamp timerKey:(NSString *)timerKey;

@end
