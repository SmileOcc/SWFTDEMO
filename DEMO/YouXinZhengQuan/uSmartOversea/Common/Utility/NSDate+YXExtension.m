//
//  NSDate+YXExtension.m
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/5/18.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "NSDate+YXExtension.h"

@implementation NSDate (YXExtension)

-(NSDateComponents *)deltaFrom:(NSDate *)from
{
    //日历
    NSCalendar *calendar = [NSCalendar currentCalendar];
    //比较时间
    NSDateComponents *comps = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:from toDate:self options:0];
    return comps;
}
-(BOOL)isThisYear
{
    NSDate *now = [NSDate date];
    //日历
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger nowYear = [calendar component:NSCalendarUnitYear fromDate:now];
    NSInteger selfYear = [calendar component:NSCalendarUnitYear fromDate:self];
    
    return nowYear == selfYear;
    
}
/** 方法1:判断是否为今天*/
-(BOOL)isToday
{
    //日历
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    
    NSDateComponents *nowComps = [calendar components:unit fromDate:[NSDate date]];
    NSDateComponents *selfComps = [calendar components:unit fromDate:self];
    
    return nowComps.year == selfComps.year && nowComps.month == selfComps.month && nowComps.day == selfComps.day;
}

/** 判断是否为昨天*/
-(BOOL)isYesterday
{
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc]init];
    dateformatter.dateFormat = @"yyyy-MM-dd";
    NSDate *nowDate = [dateformatter dateFromString:[dateformatter stringFromDate:[NSDate date]]];
    NSDate *selfDate = [dateformatter dateFromString:[dateformatter stringFromDate:self]];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components: NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:selfDate toDate:nowDate options:0];
    return comps.year == 0 && comps.month == 0 && comps.day == 1;
}

- (BOOL)isSameDay:(long)iTime1 Time2:(long)iTime2
{
    //传入时间毫秒数
    NSDate *pDate1 = [NSDate dateWithTimeIntervalSince1970:iTime1/1000];
    NSDate *pDate2 = [NSDate dateWithTimeIntervalSince1970:iTime2/1000];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:pDate1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:pDate2];
    
    return [comp1 day]   == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];
}



@end
