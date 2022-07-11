//
//  YXTimerSingleton.h
//  YouXinZhengQuan
//
//  Created by ellison on 2018/11/9.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef UInt32 YXTimerFlag;

typedef void (^YXTimeOperaion)(YXTimerFlag flag);

@interface YXTimerSingleton : NSObject

+ (instancetype)shareInstance;


/**
 添加Timer事件

 @param operaion 事件处理Block
 @param interval 循环间隔，最小为1
 @param times 循环次数 最大NSIntegerMax
 @param atOnce 添加事件时是否立即处理
 @return 时间序列号
 */
- (YXTimerFlag)transactOperation:(YXTimeOperaion)operaion
                    timeInterval:(NSTimeInterval)interval
                     repeatTimes:(NSInteger)times
                          atOnce:(BOOL)atOnce;

/**
 单一事件失效

 @param flag 事件序列号
 */
- (void)invalidOperationWithFlag:(YXTimerFlag)flag;

/**
 所有事件失效
 */
- (void)invalidate;

/**
 单一事件暂停

 @param flag 事件序列号
 */
- (void)pauseOperationWithFlag:(YXTimerFlag)flag;

/**
 单一事件恢复
 
 @param flag 事件序列号
 */
- (void)resumeOperationWithFlag:(YXTimerFlag)flag;


@end

NS_ASSUME_NONNULL_END
