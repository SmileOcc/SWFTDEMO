//
//  YXDateToolUtility.h
//  uSmartOversea
//
//  Created by 姜轶群 on 2019/1/7.
//  Copyright © 2019年 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YXDateModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXDateToolUtility : NSObject

+ (YXDateModel *)dateTimeWithTimeString:(NSString *)timeString;
+ (YXDateModel *)dateTimeAndWeekWithTimeString:(NSString *)timeString;
+ (YXDateModel *)dateTimeWithTimeValue:(NSTimeInterval )timeValue;
+ (YXDateModel *)dateTimeAndWeekWithTimeValue:(NSTimeInterval)timeValue;
+ (YXDateModel *)dateTimeAndWeekWithTimeString:(NSString *)timeString addZone:(BOOL)addZone;

/**
 两个日期之前间隔的天数

 @param fromDate 起始日期
 @param toDate 结束日期
 @return 间隔总天数
 */
+ (NSInteger)numberOfDaysWithFromDate:(NSString *)fromDate toDate:(NSString *)toDate;
/**
 两个日期之前间隔的秒

 @param fromDate 起始日期
 @param toDate 结束日期
 @return 间隔总天数
 */
+ (NSInteger)numberOfSecondWithFromDate:(NSString *)fromDate toDate:(NSString *)toDate;

//拿当前时间
+(NSString *)getcurrentTime;

/// 两个日期之前间隔的月数
/// @param fromDate 起始日期
/// @param toDate 结束日期
+ (NSInteger)numberOfMonthsWithFromDate:(NSString *)fromDate toDate:(NSString *)toDate;

/// 两个日期之前间隔的分钟数
/// @param fromDate 起始日期
/// @param toDate 结束日期
+ (NSInteger)numOfMinuteWithFromDate:(NSString *)fromDate toDate:(NSString *)toDate;

//拿到当前date月份的最后一天
+(NSDate *)getMonthEndDayWithDate:(NSDate *) date ;

+(NSDate *)getMonthBeginDayWithDate:(NSDate *) date;

@end

NS_ASSUME_NONNULL_END
