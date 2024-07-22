//
//  NotificationService.m
//  NotificationService
//
//  Created by YW on 2018/9/18.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "NotificationService.h"
#import <UIKit/UIKit.h>
#import "ZFNotificationRequestManager.h"
#import "ZFDeviceInfoManager.h"
#import "Configuration.h"

static NSString *const Debug_Displaydata =  @"http://leancloud.gloapi.com.master.php5.egomsl.com/api/sync-displaydata";
static NSString *const Release_Displaydata =  @"https://leancloud.gloapi.com/api/sync-displaydata";

typedef NS_OPTIONS(NSInteger, LocalHostEnvOptionType) {
    LocalHostEnvOptionTypeTrunk                     = 1 << 0,
    LocalHostEnvOptionTypePre                       = 1 << 1,
    LocalHostEnvOptionTypeDis                       = 1 << 2,
    LocalHostEnvOptionTypeInput                     = 1 << 3,
};

@interface NotificationService ()
@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;
@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    NSDictionary *userInfo = request.content.userInfo;
    //NSLog(@"远程通知来了--%@",userInfo);
    
    // 统计远程推送到达率
    [self postDisplaydata:userInfo];

    NSString *soundName = nil;
    NSString *title = nil;
    NSString *body = nil;
    NSString *subtitle = nil;
    NSString *imagePath = userInfo[@"image"];
    
    NSDictionary *apsDic = userInfo[@"aps"];
    if ([apsDic isKindOfClass:[NSDictionary class]]) {
        soundName = apsDic[@"sound"];
        
        NSDictionary *alertDic = apsDic[@"alert"];
        if ([alertDic isKindOfClass:[NSDictionary class]]) {
            title = alertDic[@"title"];
            subtitle = alertDic[@"subtitle"];
            body = alertDic[@"body"];
            
            if (apsDic[@"image"]) {
                imagePath = apsDic[@"image"];
            }
        }
    }
    
    if ([body isKindOfClass:[NSString class]] && body.length>0) {
        self.bestAttemptContent.body = body;
    }
    if ([title isKindOfClass:[NSString class]] && title.length>0) {
        self.bestAttemptContent.title = title;
    }
    if ([subtitle isKindOfClass:[NSString class]] && subtitle.length>0) {
        self.bestAttemptContent.subtitle = subtitle;
    }
    self.bestAttemptContent.launchImageName = @"guide_PushNotifycation_en";
    
    if ([soundName isKindOfClass:[NSString class]] && soundName.length>0) {
        self.bestAttemptContent.sound = [UNNotificationSound soundNamed:soundName];
    }
    
    if (![imagePath isKindOfClass:[NSString class]] || imagePath.length==0) {
        self.contentHandler(self.bestAttemptContent);
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSURL *imageURL = [NSURL URLWithString:imagePath];
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        
        NSString *userDocument = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *path = [NSString stringWithFormat:@"%@/notifications.jpg", userDocument];
        
        // 一定要先删除老的图片
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        [imageData writeToFile:path atomically:YES];
        
        NSURL *url = [NSURL fileURLWithPath:path];
        UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:@"attachment" URL:url options:nil error:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (attachment) {
                self.bestAttemptContent.attachments = @[attachment];
            }
            self.contentHandler(self.bestAttemptContent);
        });
    });
}

- (void)postDisplaydata:(NSDictionary *)userInfo {
    
    NSString *postUrl = @"";
    NSString *pid = @"";
    NSString *campagin = @"";
    NSString *pushId = @"";
    NSString *pushTime = @"";
    
    if ([self isDevelopStatus]) {
        postUrl = Debug_Displaydata;
    } else {
        postUrl = Release_Displaydata;
    }
    
    if ([userInfo isKindOfClass:[NSDictionary class]]) {
        campagin = userInfo[@"c"];
        pid = userInfo[@"pid"];
        pushId = userInfo[@"push_id"];
        pushTime = userInfo[@"push_time"];
        
        if ([userInfo[@"af"] isKindOfClass:[NSDictionary class]]) {
            pid = userInfo[@"af"][@"pid"];
            campagin = userInfo[@"af"][@"c"];
        }
    }
    NSUserDefaults *myDefaults = [[NSUserDefaults alloc]initWithSuiteName:@"group.com.ZZZZZ.ZZZZZ"];
    NSString *appsFlyerid = [myDefaults objectForKey:@"appsFlyerid"];
    
    NSDictionary *dict =  @{@"apnsTopic"       : @"ZZZZZ",
                            @"deviceType"      : @"ios",
                            @"mediaSource"     : ZFNotifyToString(pid),
                            @"campagin"        : ZFNotifyToString(campagin),
                            @"pushId"          : ZFNotifyToString(pushId),
                            @"pushTime"        : ZFNotifyToString(pushTime),
                            @"deviceId"        : ZFNotifyToString([ZFDeviceInfoManager sharedManager].device_id),
                            @"displayTime"     : ZFNotifyToString([[ZFDeviceInfoManager sharedManager] getCurrentTimestamp]),
                            @"appVersion"      : ZFNotifyToString([[ZFDeviceInfoManager sharedManager] getAppVersion]),
                            @"appsFlyerid"     : ZFNotifyToString(appsFlyerid),
                            @"deviceName"      : ZFNotifyToString([[ZFDeviceInfoManager sharedManager] getDeviceType]),
                            @"osVersion"       : ZFNotifyToString([[ZFDeviceInfoManager sharedManager] getDeviceVersion])
                            };
    [ZFNotificationRequestManager POST:postUrl parameters:dict];
}


NSString * ZFNotifyToString(id obj) {
    if (![obj isKindOfClass:[NSString class]]) {
         return @"";
    } else {
        return obj;
    }
}

/**
 * 当前环境是否为线上布生产模式 (打包发布审核环境)
 */
- (BOOL)isDistributionOnlineRelease {
    BOOL isDistributionOnlineRelease = NO;
#if DEBUG
#else
    if (AppRequestType == 2) { //线上发布生产环境
        isDistributionOnlineRelease = YES;
    }
#endif
    return isDistributionOnlineRelease;
}

/**
 * 当前环境是否为开发环境
 */
- (BOOL)isDevelopStatus {
    if ([self isDistributionOnlineRelease]) {//线上发布直接返回
        return NO;
    }
    NSUserDefaults *myDefaults = [[NSUserDefaults alloc]initWithSuiteName:@"group.com.ZZZZZ.ZZZZZ"];
    NSInteger envType = [[myDefaults objectForKey:@"EnvSettingTypeKey"] integerValue];
    return envType & LocalHostEnvOptionTypeTrunk || envType & LocalHostEnvOptionTypeInput;
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end
