//
//  ZFCountDownButton.h
//  ZZZZZ
//
//  Created by YW on 2019/5/22.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//  倒计时按钮

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^EndCountDownEvent)(void);

@interface ZFCountDownButton : UIButton

///非倒计时按钮内容
@property (nonatomic, copy) NSString *normalTitle;
///倒计时按钮内容
@property (nonatomic, copy) NSString *countDownTitle;

///倒计时 默认 60s
@property (nonatomic, assign) NSInteger countDownInterval;

///结束倒计时事件
@property (nonatomic, copy) EndCountDownEvent endCountDownEvent;

///开始倒计时动画
- (void)startCountDownAnimation;

- (void)startCountDown;

- (void)stopConutDown;

@end

NS_ASSUME_NONNULL_END
