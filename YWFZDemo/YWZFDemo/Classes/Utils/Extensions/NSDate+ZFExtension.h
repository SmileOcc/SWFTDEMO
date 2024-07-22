//
//  NSObject+ZFExtension.h
//  ZZZZZ
//
//  Created by YW on 2018/3/27.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZFDateItem : NSObject
@property (nonatomic, assign) NSInteger day;
@property (nonatomic, assign) NSInteger hour;
@property (nonatomic, assign) NSInteger minute;
@property (nonatomic, assign) NSInteger second;
@end

@interface NSDate (ZFExtension)

- (NSDateFormatter *)queryZFDateFormatter;

- (NSString *)dateStringWithDateFormatter:(NSDateFormatter *)formatter;

+ (NSDate *)dateFromString:(NSString *)string withDateFormatter:(NSDateFormatter *)formatter;

- (ZFDateItem *)ok_timeIntervalSinceDate:(NSDate *)anotherDate;

- (BOOL)ok_isToday;

- (BOOL)ok_isYesterday;

- (BOOL)ok_isTomorrow;

- (BOOL)ok_isThisYear;

/**
 *  得到当前时间 格式：yyyyMMddHHmmssSSS
 */
+ (NSString *)nowDate;

/**
 *  得到今天的日期
 *
 *  @return yyyyMMdd
 */
+ (NSString *)todayDateString;

//获取今天周几
+ (NSInteger)nowWeekday;

/**
 * 得到精确的时间间隔
 */
+ (NSTimeInterval)calculateTimeIntervalStarTime:(NSString *)starTime endTime:(NSString *)endTime;

/**
 * 根绝秒数获取时间
 */
+ (NSString *)fetchCustomDataBySeconds:(NSString *)seconds;

//将某个时间转化成 时间戳
+ (NSInteger)timeSwitchTimestamp:(NSString *)formatTime andFormatter:(NSString *)format;

@end

