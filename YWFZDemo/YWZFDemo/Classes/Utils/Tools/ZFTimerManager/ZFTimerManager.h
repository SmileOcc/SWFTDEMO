//
//  ZFTimerManager.h
//  WZHLibrary
//
//  Created by YW on 2017/5/16.
//  Copyright © 2017年 karl.luo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString * const kTimerManagerUpdate;


@interface ZFTimerModel : NSObject
@property (nonatomic, assign) NSTimeInterval startTimeInterval;
@end

@interface ZFTimerManager : NSObject

@property (nonatomic, assign) CGFloat duration;   // 倒计时间隔，默认1秒

+ (instancetype)shareInstance;
- (void)startTimer:(NSString *)operaterKey;
- (void)stopTimer:(NSString *)operaterKey;
- (NSTimeInterval)timeInterval:(NSString *)operaterKey;

@end
