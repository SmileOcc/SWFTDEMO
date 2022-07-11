//
//  NotificationService.h
//  NotificationService
//
//  Created by odd on 2020/12/10.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UserNotifications/UserNotifications.h>

typedef NS_OPTIONS(NSInteger, LocalHostEnvOptionType) {
    LocalHostEnvOptionTypeTrunk                     = 1 << 0,
    LocalHostEnvOptionTypePre                       = 1 << 1,
    LocalHostEnvOptionTypeDis                       = 1 << 2,
    LocalHostEnvOptionTypeInput                     = 1 << 3,
};


@interface NotificationService : UNNotificationServiceExtension

@end
