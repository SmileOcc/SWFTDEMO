//
//  STLNotificationRequestManager.h
//  NotificationService
//
//  Created by odd on 2020/12/10.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface STLNotificationRequestManager : NSObject

/**
 统计远程推送达到率

 @param URL 统计地址
 @param dic 上报数据
 */
+ (void)POST:(NSString *)URL parameters:(NSDictionary *)dic;
@end

NS_ASSUME_NONNULL_END
