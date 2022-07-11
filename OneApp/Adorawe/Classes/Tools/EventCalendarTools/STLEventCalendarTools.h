//
//  STLEventCalendarTools.h
// XStarlinkProject
//
//  Created by fan wang on 2021/6/10.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface STLEventCalendarTools : NSObject

+(instancetype)shared;
/**
 *  将App事件添加到系统日历提醒事项，实现闹铃提醒的功能
 *
 *  @param title      事件标题
 *  @param startDate  开始时间
 *  @param endDate    结束时间
 *  @param allDay     是否全天
 *  @param alarmArray 闹钟集合
 */
- (void)createEventCalendarTitle:(NSString *)title
                            tips:(NSString *)tips
                          urlStr:(NSString *)urlStr
                       startDate:(NSDate *)startDate
                         endDate:(NSDate *)endDate
                          allDay:(BOOL)allDay
                      alarmArray:(NSArray *)alarmArray
                        success:(void(^)(void))successd;


///根据notes 内容删除
-(void)deleteEventWith:(NSString *)notes
             startDate:(NSDate *)startDate
               endDate:(NSDate *)enddate
               success:(void(^)(void))successd;


@end

