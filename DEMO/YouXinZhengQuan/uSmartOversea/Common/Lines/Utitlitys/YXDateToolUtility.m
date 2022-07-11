//
//  YXDateToolUtility.m
//  uSmartOversea
//
//  Created by 姜轶群 on 2019/1/7.
//  Copyright © 2019年 RenRenDai. All rights reserved.
//

#import "YXDateToolUtility.h"
#import <NSDate+YYAdd.h>
#import "uSmartOversea-Swift.h"

@implementation YXDateToolUtility
//timeString格式: 20190107192136000
+ (YXDateModel *)dateTimeWithTimeString:(NSString *)timeString {
    
    timeString = [timeString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    timeString = [timeString stringByReplacingOccurrencesOfString:@" " withString:@""];
    timeString = [timeString stringByReplacingOccurrencesOfString:@":" withString:@""];
    
    YXDateModel *dateModel = [[YXDateModel alloc] init];
    //年
    if (timeString.length >= 4) {
        dateModel.year = [timeString substringWithRange:NSMakeRange(0, 4)];
    } else {
        dateModel.year = @"";
    }
    
    //月
    if (timeString.length >= 6) {
       dateModel.month = [timeString substringWithRange:NSMakeRange(4, 2)];
    } else {
        dateModel.month = @"";
    }
    
    //日
    if (timeString.length >= 8) {
        dateModel.day = [timeString substringWithRange:NSMakeRange(6, 2)];
    } else {
        dateModel.day = @"";
    }
    

    //时
    if (timeString.length >= 10) {
        dateModel.hour = [timeString substringWithRange:NSMakeRange(8, 2)];
    } else {
        dateModel.hour = @"";
    }
    
    //分
    if (timeString.length >= 12) {
        dateModel.minute = [timeString substringWithRange:NSMakeRange(10, 2)];
    } else {
        dateModel.minute = @"";
    }
    
    
    //秒
    if (timeString.length >= 14) {
        dateModel.second = [timeString substringWithRange:NSMakeRange(12, 2)];
    } else {
        dateModel.second = @"";
    }
    
    dateModel.week = @"";
    
    return dateModel;
}

+ (YXDateModel *)dateTimeAndWeekWithTimeValue:(NSTimeInterval)timeValue {
    char *buffer;
    asprintf(&buffer, "%lf", timeValue);
    NSString *valueString = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
    free(buffer);
    return [self dateTimeAndWeekWithTimeString:valueString];
}

+ (YXDateModel *)dateTimeAndWeekWithTimeString:(NSString *)timeString {
    YXDateModel *dateModel = [YXDateToolUtility dateTimeWithTimeString:timeString];
    
    // 星期
    NSDateFormatter *formatter = [NSDateFormatter en_US_POSIXFormatter];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dateTime = [NSString stringWithFormat:@"%@-%@-%@ %@:%@", dateModel.year, dateModel.month, dateModel.day, dateModel.hour, dateModel.minute];
    // 当前默认服务器给的是北京时间，所以取上海中国时区
    NSDate *date = [[formatter dateFromString:dateTime] dateByAddingSeconds:[[NSTimeZone timeZoneWithName:@"Asia/Shanghai"] secondsFromGMT]];
    NSString *weekday;
    switch (date.weekday) {
        case 1:
            weekday = [YXLanguageUtility kLangWithKey:@"common_Sunday"];
            break;
        case 2:
            weekday = [YXLanguageUtility kLangWithKey:@"common_Monday"];
            break;
        case 3:
            weekday = [YXLanguageUtility kLangWithKey:@"common_Tuesday"];
            break;
        case 4:
            weekday = [YXLanguageUtility kLangWithKey:@"common_Wednesday"];
            break;
        case 5:
            weekday = [YXLanguageUtility kLangWithKey:@"common_Thursday"];
            break;
        case 6:
            weekday = [YXLanguageUtility kLangWithKey:@"common_Friday"];
            break;
        case 7:
            weekday = [YXLanguageUtility kLangWithKey:@"common_Saturday"];
            break;
        default:
            break;
    }
    dateModel.week = weekday;
    
    return dateModel;
}

+ (YXDateModel *)dateTimeAndWeekWithTimeString:(NSString *)timeString addZone:(BOOL)addZone {
    YXDateModel *dateModel = [YXDateToolUtility dateTimeWithTimeString:timeString];
    
    // 星期
    NSDateFormatter *formatter = [NSDateFormatter en_US_POSIXFormatter];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dateTime = [NSString stringWithFormat:@"%@-%@-%@ %@:%@", dateModel.year, dateModel.month, dateModel.day, dateModel.hour, dateModel.minute];
    // 当前默认服务器给的是北京时间，所以取上海中国时区
    NSDate *date;
    if (addZone) {
        date = [[formatter dateFromString:dateTime] dateByAddingSeconds:[[NSTimeZone timeZoneWithName:@"Asia/Shanghai"] secondsFromGMT]];
    } else {
        date = [formatter dateFromString:dateTime];
    }
    NSString *weekday;
    switch (date.weekday) {
        case 1:
            weekday = @"周日";
            break;
        case 2:
            weekday = @"周一";
            break;
        case 3:
            weekday = @"周二";
            break;
        case 4:
            weekday = @"周三";
            break;
        case 5:
            weekday = @"周四";
            break;
        case 6:
            weekday = @"周五";
            break;
        case 7:
            weekday = @"周六";
            break;
        default:
            break;
    }
    dateModel.week = weekday;
    
    return dateModel;
}


+ (YXDateModel *)dateTimeWithTimeValue:(NSTimeInterval)timeValue {
    char *buffer;
    asprintf(&buffer, "%lf", timeValue);
    NSString *valueString = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
    free(buffer);
    return [self dateTimeWithTimeString:valueString];
}

+ (NSInteger)numberOfDaysWithFromDate:(NSString *)fromDate toDate:(NSString *)toDate {
    
    NSDateFormatter *dateFormatter = [NSDateFormatter en_US_POSIXFormatter];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
    NSDate *startDate = [dateFormatter dateFromString:fromDate];
    NSDate *endDate = [dateFormatter dateFromString:toDate];
    NSCalendarUnit unit = NSCalendarUnitDay;//只比较天数差异
    //比较的结果是NSDateComponents类对象
    //利用NSCalendar比较日期的差异
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *delta = [calendar components:unit fromDate:startDate toDate:endDate options:0];
    return delta.day;
    
}

+ (NSInteger)numberOfSecondWithFromDate:(NSString *)fromDate toDate:(NSString *)toDate{
    NSDateFormatter *dateFormatter = [NSDateFormatter en_US_POSIXFormatter];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH-mm-ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
    NSDate *startDate = [dateFormatter dateFromString:fromDate];
    NSDate *endDate = [dateFormatter dateFromString:toDate];
    NSCalendarUnit unit = NSCalendarUnitSecond;
    //比较的结果是NSDateComponents类对象
    //利用NSCalendar比较日期的差异
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *delta = [calendar components:unit fromDate:startDate toDate:endDate options:0];
    return delta.second;
}

+(NSString *)getcurrentTime {
    // 星期
    NSDateFormatter *formatter = [NSDateFormatter en_US_POSIXFormatter];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
   
    NSString * dateString = [formatter stringFromDate:[NSDate date]];
        
    return dateString;
}

+ (NSInteger)numberOfMonthsWithFromDate:(NSString *)fromDate toDate:(NSString *)toDate {
    
    NSDateFormatter *dateFormatter = [NSDateFormatter en_US_POSIXFormatter];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
    NSDate *startDate = [dateFormatter dateFromString:fromDate];
    NSDate *endDate = [dateFormatter dateFromString:toDate];
    NSCalendarUnit unit = NSCalendarUnitMonth;//只比较月数差异
    //比较的结果是NSDateComponents类对象
    //利用NSCalendar比较日期的差异
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *delta = [calendar components:unit fromDate:startDate toDate:endDate options:0];
    
    return delta.month;
}

+ (NSInteger)numOfMinuteWithFromDate:(NSString *)fromDate toDate:(NSString *)toDate {
    NSDateFormatter *dateFormatter = [NSDateFormatter en_US_POSIXFormatter];
    [dateFormatter setDateFormat:@"HH-mm-ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
    NSDate *startDate = [dateFormatter dateFromString:fromDate];
    NSDate *endDate = [dateFormatter dateFromString:toDate];
    NSCalendarUnit unit = NSCalendarUnitMinute;
    //比较的结果是NSDateComponents类对象
    //利用NSCalendar比较日期的差异
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *delta = [calendar components:unit fromDate:startDate toDate:endDate options:0];
    return delta.minute;
}

+(NSDate *)getMonthEndDayWithDate:(NSDate *) date {
    double interval = 0;
    NSDate *beginDate = nil;
    NSDate *endDate = nil;
    NSCalendar * calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:2]; //设定周一为周首日
    
    BOOL ok = [calendar rangeOfUnit:NSCalendarUnitMonth startDate:&beginDate interval:&interval forDate:date];
    //分别修改为 NSDayCalendarUnit NSWeekCalendarUnit NSYearCalendarUnit
    if (ok) {
        endDate = [beginDate dateByAddingTimeInterval:interval-1];
    }else {
        return [NSDate date];
    }
    
    return  endDate;
}

//拿到当前date月份的第一天
+(NSDate *)getMonthBeginDayWithDate:(NSDate *) date {
    double interval = 0;
    NSDate *beginDate = nil;
    NSDate *endDate = nil;
    NSCalendar * calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:2]; //设定周一为周首日
    
    BOOL ok = [calendar rangeOfUnit:NSCalendarUnitMonth startDate:&beginDate interval:&interval forDate:date];
    //分别修改为 NSDayCalendarUnit NSWeekCalendarUnit NSYearCalendarUnit
    if (ok) {
        endDate = [beginDate dateByAddingTimeInterval:interval-1];
    }else {
        return [NSDate date];
    }
    
    return  beginDate;
}

@end
