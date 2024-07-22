//
//  ZFOrderDetailCountDownView.h
//  ZZZZZ
//
//  Created by YW on 2018/11/22.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//  订单详情倒计时视图

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *const kZFCountDownKey = @"kOrderDetailCountDownKey";

@interface ZFOrderDetailCountDownView : UIView

///倒计时时间
@property (nonatomic, copy) NSString *countDownTime;

///显示倒计时到某个视图的中心点
- (void)showCountTimePositionView:(UIView *)view countDownKey:(NSString *)key;

///停止倒计时并移除
- (void)stopCountTime:(NSString *)key;

- (NSString *)countDownKey:(NSString *)customId;

@end

NS_ASSUME_NONNULL_END
