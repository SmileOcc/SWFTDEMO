//
//  NSDate+YXExtension.h
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/5/18.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (YXExtension)
/** 比较当前时间和from时间的差值*/
-(NSDateComponents *)deltaFrom:(NSDate *)from;

/** 是否为今年*/
-(BOOL)isThisYear;

/** 是否为今天*/
-(BOOL)isToday;

/** 是否为昨天*/
-(BOOL)isYesterday;

/** 是否为同一天*/
- (BOOL)isSameDay:(long)iTime1 Time2:(long)iTime2;
@end

NS_ASSUME_NONNULL_END
