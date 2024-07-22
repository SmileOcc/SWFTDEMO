//
//  ZFNotificationRequestManager.h
//  NotificationService
//
//  Created by mac on 2019/2/18.
//  Copyright © 2019年 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFNotificationRequestManager : NSObject

/**
 统计远程推送达到率

 @param URL 统计地址
 @param dic 上报数据
 */
+ (void)POST:(NSString *)URL parameters:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
