//
//  NSObject+ZFExtension.m
//  ZZZZZ
//
//  Created by YW on 2018/3/27.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "NSDate+ZFExtension.h"
#import "Constants.h"

static NSDateFormatter *_okFormatter = nil;

//精确的时间格式
#define kExactitudeTimeFormaterType         @"yyyyMMddHHmmssSSS"
#define kTodayDateFormaterType              @"yyyyMMdd"

@implementation ZFDateItem
- (NSString *)description
{
    return [NSString stringWithFormat:@"%zd天%zd小时%zd分%zd秒", self.day, self.hour, self.minute, self.second];
}
@end


@implementation NSDate (ZFExtension)

- (NSDateFormatter *)queryZFDateFormatter {
    return _okFormatter;
}

/**
 *  创建静态时间格式化
 */
+ (void)initialize
{
    //因为官方说明，时间格式化类很耗时，所以初始化一个公用时间格式化类
    _okFormatter = [[NSDateFormatter alloc] init];
}

- (NSString *)dateStringWithDateFormatter:(NSDateFormatter *)formatter {
    if (!formatter) {
        return nil;
    }
    return [formatter stringFromDate:self];
}

+ (NSDate *)dateFromString:(NSString *)string withDateFormatter:(NSDateFormatter *)formatter {
    if (!string.length || !formatter) {
        return nil;
    }
    return [formatter dateFromString:string];
}

- (ZFDateItem *)ok_timeIntervalSinceDate:(NSDate *)anotherDate
{
    // createdAtDate和nowDate之间的时间间隔
    NSTimeInterval interval = [self timeIntervalSinceDate:anotherDate];
    
    ZFDateItem *item = [[ZFDateItem alloc] init];
    
    // 相差多少天
    int intInterval = (int)interval;
    int secondsPerDay = 24 * 3600;
    item.day = intInterval / secondsPerDay;
    
    // 相差多少小时
    int secondsPerHour = 3600;
    item.hour = (intInterval % secondsPerDay) / secondsPerHour;
    
    // 相差多少分钟
    int secondsPerMinute = 60;
    item.minute = ((intInterval % secondsPerDay) % secondsPerHour) / secondsPerMinute;
    
    // 相差多少秒
    item.second = ((intInterval % secondsPerDay) % secondsPerHour) % secondsPerMinute;
    
    return item;
}

- (BOOL)ok_isToday
{
    // 判断self这个日期对象是否为今天
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    
    NSDateComponents *selfCmps = [calendar components:unit fromDate:self];
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[NSDate date]];
    
    // 如果selfCmps和nowCmps的所有元素都一样，就返回YES，否则返回NO
    return [selfCmps isEqual:nowCmps];
    //    return selfCmps.year == nowCmps.year
    //    && selfCmps.month == nowCmps.month
    //    && selfCmps.day == nowCmps.day;
}


- (BOOL)ok_isYesterday
{
    // 判断self这个日期对象是否为昨天
    
    // self 2015-12-09 22:10:01 -> 2015-12-09 00:00:00
    // now  2015-12-10 12:10:01 -> 2015-12-01 00:00:00
    // 昨天：0year 0month 1day 0hour 0minute 0second
    
    
    // NSDate * -> NSString * -> NSDate *
    
    _okFormatter.dateFormat = @"yyyyMMdd";
    
    // 生成只有年月日的字符串对象
    NSString *selfString = [_okFormatter stringFromDate:self];
    NSString *nowString = [_okFormatter stringFromDate:[NSDate date]];
    
    // 生成只有年月日的日期对象
    NSDate *selfDate = [_okFormatter dateFromString:selfString];
    NSDate *nowDate = [_okFormatter dateFromString:nowString];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *cmps = [calendar components:unit fromDate:selfDate toDate:nowDate options:0];
    return cmps.year == 0
    && cmps.month == 0
    && cmps.day == 1;
}

- (BOOL)ok_isTomorrow
{
    _okFormatter.dateFormat = @"yyyyMMdd";
    
    // 生成只有年月日的字符串对象
    NSString *selfString = [_okFormatter stringFromDate:self];
    NSString *nowString = [_okFormatter stringFromDate:[NSDate date]];
    
    // 生成只有年月日的日期对象
    NSDate *selfDate = [_okFormatter dateFromString:selfString];
    NSDate *nowDate = [_okFormatter dateFromString:nowString];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *cmps = [calendar components:unit fromDate:selfDate toDate:nowDate options:0];
    return cmps.year == 0
    && cmps.month == 0
    && cmps.day == -1;
}

- (BOOL)ok_isThisYear
{
    // 判断self这个日期对象是否为今年
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSInteger selfYear = [calendar components:NSCalendarUnitYear fromDate:self].year;
    NSInteger nowYear = [calendar components:NSCalendarUnitYear fromDate:[NSDate date]].year;
    
    return selfYear == nowYear;
}

/**
 *  得到当前时间
 *
 *  @return yyyyMMddHHmmssSSS
 */
+ (NSString *)nowDate
{
    NSDate *senddate = [NSDate date];
    [_okFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [_okFormatter setDateFormat:kExactitudeTimeFormaterType];
    NSString *locationString = [_okFormatter stringFromDate:senddate];
    return locationString;
}

/**
 *  得到今天的日期
 *
 *  @return yyyyMMdd
 */
+ (NSString *)todayDateString
{
    NSDate *senddate = [NSDate date];
    [_okFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [_okFormatter setDateFormat:kTodayDateFormaterType];
    NSString *locationString = [_okFormatter stringFromDate:senddate];
    return locationString;
}

//获取今天周几
+ (NSInteger)nowWeekday {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday |
    NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDate *now = [NSDate date];
    // 话说在真机上需要设置区域，才能正确获取本地日期，天朝代码:zh_CN
    calendar.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    comps = [calendar components:unitFlags fromDate:now];
    return [comps day];
}


/**
 * 得到精确的时间间隔
 */
+ (NSTimeInterval)calculateTimeIntervalStarTime:(NSString *)starTime endTime:(NSString *)endTime
{
    if (!starTime || !endTime) return 0.0;
    
    [_okFormatter setDateFormat:kExactitudeTimeFormaterType];
    NSDate *startDate = [_okFormatter dateFromString:starTime];
    NSDate *endDate = [_okFormatter dateFromString:endTime];
    NSTimeInterval time = [endDate timeIntervalSinceDate:startDate];
    return time;
}

/**
 * 根绝秒数获取时间
 */
+ (NSString *)fetchCustomDataBySeconds:(NSString *)seconds
{
    NSInteger intervalTime = [seconds integerValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:intervalTime];
    _okFormatter.dateFormat = @"MMM dd, yyyy";
    NSString *time = [_okFormatter stringFromDate:date];
    return time;
}

//将某个时间转化成 时间戳
+(NSInteger)timeSwitchTimestamp:(NSString *)formatTime andFormatter:(NSString *)format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:format]; //(@"YYYY-MM-dd hh:mm:ss") ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    [formatter setTimeZone:timeZone];
    NSDate *date = [formatter dateFromString:formatTime]; //------------将字符串按formatter转成nsdate
    
    //时间转时间戳的方法:
    NSInteger timeSp = [[NSNumber numberWithDouble:[date timeIntervalSince1970]] integerValue];
    YWLog(@"时间戳的值=====: %ld",(long)timeSp); //时间戳的值
    return timeSp;
}

@end

