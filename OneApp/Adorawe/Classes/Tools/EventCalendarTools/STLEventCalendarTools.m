//
//  STLEventCalendarTools.m
// XStarlinkProject
//
//  Created by fan wang on 2021/6/10.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "STLEventCalendarTools.h"
#import <EventKit/EventKit.h>

@interface STLEventCalendarTools ()
@end

@implementation STLEventCalendarTools

+(instancetype)shared{
    static STLEventCalendarTools *tools;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tools = [[STLEventCalendarTools alloc] init];
    });
    return tools;
}

-(void)createEventCalendarTitle:(NSString *)title
                           tips:(NSString *)tips
                         urlStr:(NSString *)urlStr
                      startDate:( NSDate * _Nonnull )startDate
                        endDate:(NSDate *)endDate
                         allDay:(BOOL)allDay alarmArray:(NSArray *)alarmArray
                        success:(void (^)(void))successd{
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]){
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error){
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error){
                    [HUDManager showHUDWithMessage:@"Not granted to operate calendar"];
                    NSLog(@"add event faild:%@",error);
                }else if (!granted){
                    
//                    [HUDManager showHUDWithMessage:@"Not granted to operate calendar"];
                    [self jumpToSettingsAlert];
                }else{
                    ///删除之前的
                    NSPredicate *predicate = [eventStore predicateForEventsWithStartDate:startDate endDate:endDate ?: [startDate dateByAddingTimeInterval:300] calendars:nil];
                    NSArray *events = [eventStore eventsMatchingPredicate:predicate];
                    for (EKEvent *event in events) {
                        if ([event.notes isEqualToString:tips]) {
                            [eventStore removeEvent:event span:EKSpanThisEvent error:nil];
                        }
                    }
                    
                    EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
                    event.title     = title;
                    event.startDate = startDate;
                    event.endDate   = endDate ?: [NSDate dateWithTimeInterval:60 * 30 sinceDate:startDate];
                    event.allDay = allDay;
                    event.notes = tips;
                    event.URL = [NSURL URLWithString:urlStr];
                    //添加提醒
                    if (alarmArray && alarmArray.count > 0) {
                        for (NSString *timeString in alarmArray) {
                            [event addAlarm:[EKAlarm alarmWithRelativeOffset:[timeString integerValue]]];
                        }
                    }
                    [event setCalendar:[eventStore defaultCalendarForNewEvents]];
                    NSError *err;
                    [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
                    if (err){
//                        [HUDManager showHUDWithMessage:@"Add failed"];
                        NSLog(@"add event faild:%@",err);
                    }else{
                        [HUDManager showHUDWithMessage:STLLocalizedString_(@"RemindAddSuccess", nil)];
                        NSDateFormatter *formatter = [NSDateFormatter new];
                        formatter.dateStyle = NSDateFormatterShortStyle;
                        NSLog(@"--start Date---%@\n--end Date--%@", [formatter stringFromDate:startDate], [formatter stringFromDate:endDate]);
                        if (successd) {
                            successd();
                        }
                    }
                }
                
            });
        }];
    }
}

-(void)deleteEventWith:(NSString *)notes startDate:(NSDate *)startDate endDate:(NSDate *)enddate success:(void (^)(void))successd{
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]){
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error){
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error){
//                    [HUDManager showHUDWithMessage:@"Not granted to operate calendar"];
                    NSLog(@"add event faild:%@",error);
                }else if (!granted){
//                    [HUDManager showHUDWithMessage:@"Not granted to operate calendar"];
                    [self jumpToSettingsAlert];
                }else{
                    NSPredicate *predicate = [eventStore predicateForEventsWithStartDate:startDate endDate:enddate ?: [startDate dateByAddingTimeInterval:300] calendars:nil];
                    NSArray *events = [eventStore eventsMatchingPredicate:predicate];
                    for (EKEvent *event in events) {
                        if ([event.notes isEqualToString:notes]) {
                            [eventStore removeEvent:event span:EKSpanThisEvent error:nil];
                        }
                    }
                    [HUDManager showHUDWithMessage:STLLocalizedString_(@"RemindCancelSuccess", nil)];
                    if (successd) {
                        successd();
                    }
                }
                
            });
        }];
    }
}

-(void)jumpToSettingsAlert{
    UIAlertController *alt = [UIAlertController alertControllerWithTitle:@"" message:STLLocalizedString_(@"canlendarAuth", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionOK = [UIAlertAction actionWithTitle:APP_TYPE == 3 ? STLLocalizedString_(@"ok", nil): STLLocalizedString_(@"ok", nil).uppercaseString style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [UIApplication.sharedApplication openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:APP_TYPE == 3 ? STLLocalizedString_(@"cancel", nil) : STLLocalizedString_(@"cancel", nil).uppercaseString style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alt addAction:actionOK];
    [alt addAction:actionCancel];
    [[UIViewController currentTopViewController] presentViewController:alt animated:YES completion:nil];
}

@end
