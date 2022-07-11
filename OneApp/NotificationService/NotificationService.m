//
//  NotificationService.m
//  NotificationService
//
//  Created by odd on 2020/12/10.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "NotificationService.h"
#import "STLDeviceInfoManager.h"
#import "STLConstants.h"
#import "STLNotificationRequestManager.h"
#import "OSSVAnalyticsTool.h"
#import <CommonCrypto/CommonCrypto.h>

#define kNotification  0

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
        
    
    NSDictionary *userInfo = request.content.userInfo;
    
    // 统计远程推送到达率
    //数仓埋点已经去掉了
    //[self postDisplaydata:userInfo];
    [self postPushLogDisplaydata:userInfo];
    
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
        
        if ([self isDevelopStatus]) {
            NSString *appGroupPath = @"group.com.starlink.Adorawe";
            NSUserDefaults *myDefaults = [[NSUserDefaults alloc]initWithSuiteName:appGroupPath];
            
            BOOL isDev = [self isDevelopStatus];
            NSString *onleDomani = STLNotifyToString([myDefaults objectForKey:kCFgOnlineAppsOnleDomain]);
            NSString *deviceId = STLNotifyToString([myDefaults objectForKey:@"Device_Id"]);
            STLLog(@"====推送内容： %@",[NSString stringWithFormat:@"%@--%@--%@ isDEv: %i",title,onleDomani,deviceId,isDev]);
        }
    }
    if ([subtitle isKindOfClass:[NSString class]] && subtitle.length>0) {
        self.bestAttemptContent.subtitle = subtitle;
    }

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
        postUrl = @"http://47.242.168.163/api/adorawe/tracking";
    } else {
        postUrl = @"https://www.starlinkee.cn/api/adorawe/tracking";
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
    
    STLLog(@"GGGGGURL:%@",postUrl);
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString *timestamp = [NSString stringWithFormat:@"%.f", a];
    
    NSDictionary *dict =  @{@"key"         : @"app_receive_push",
                            @"Token"       : @"226198c70adf4b3e950aa9b546099188",
                            @"deviceType"      : @"ios",
                            @"timestamp"       : STLNotifyToString(timestamp),
                            @"af_push_id"          : STLNotifyToString(pushId),
                            };
    [STLNotificationRequestManager POST:postUrl parameters:dict];

}

- (void)postPushLogDisplaydata:(NSDictionary *)userInfo {
    
    
    NSString *appGroupPath = @"group.com.starlink.Adorawe";
    NSUserDefaults *myDefaults = [[NSUserDefaults alloc]initWithSuiteName:appGroupPath];
    
    NSString *postUrl = @"";
    NSString *postkey = @"";
    NSString *onleDomani = STLNotifyToString([myDefaults objectForKey:kCFgOnlineAppsOnleDomain]);
    NSString *deviceId = STLNotifyToString([myDefaults objectForKey:@"Device_Id"]);
    
    
    STLLog(@"kkkkkmmm: %@   %@ type:%i ",onleDomani,deviceId,AppRequestType);
    if ([self isDevelopStatus]) {
        postUrl = @"http://push.cloudsdlk.com.master.fpm.testsdlk.com/api/sync-fcm-receive-log";
        postkey = @"09FO08#1aAxT";
    } else {
        onleDomani = onleDomani.length > 0 ? onleDomani : @"adorawe.net";
        postUrl = [NSString stringWithFormat:@"https://push.%@/api/sync-fcm-receive-log",onleDomani];
        postkey = @"09FO08#1aAxT";
    }
    
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString *timestamp = [NSString stringWithFormat:@"%.f", a];
    
    //语言应该传简码,国家应该传全称
    NSDictionary *params = @{@"apnsTopic"       : @"adorawe",
                             @"deviceId"        : deviceId,
                             @"deviceType"      : @"iOS",
                             @"af_push_id"      : STLNotifyToString(userInfo[@"push_id"]),
                             @"af_push_c"       : STLNotifyToString(userInfo[@"c"]),
                             @"userid"          : @"",
                             @"timestamp"       : STLNotifyToString(timestamp),
                             };
    
    STLLog(@"GGGGGURL push: %@",params);

    NSString *paramsJson = [NotificationService convertToJsonData:params];
    NSString *md5AppName = [NotificationService stringMD5:[NSString stringWithFormat:@"%@%@", postkey,@"adorawe"]];
    NSString *paramsMd5Json = [md5AppName stringByAppendingString:paramsJson];
    NSString *apiToken = [NotificationService stringMD5:paramsMd5Json];
    

    STLLog(@"GGGGGURL push  aaa: %@ \n %@ \n %@",md5AppName,paramsMd5Json,apiToken);

    NSDictionary *requestParams =  @{@"apiToken" : STLNotifyToString(apiToken),
                                     @"data" : paramsJson };
    
    [STLNotificationRequestManager POST:postUrl parameters:requestParams];
}

+ (NSString *)stringMD5:(NSString *)string {
    if (!string) return nil;
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, (CC_LONG)data.length, result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0],  result[1],  result[2],  result[3],
            result[4],  result[5],  result[6],  result[7],
            result[8],  result[9],  result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+ (NSString *)convertToJsonData:(NSDictionary *)dict {
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return @"";
    }
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = @"";
    if (!jsonData) {
        //NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr;
}

NSString * STLNotifyToString(id obj) {
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
    if (AppRequestType == 2) { //线上发布生产环境
        isDistributionOnlineRelease = YES;
    }
    return isDistributionOnlineRelease;
}

/**
 * 当前环境是否为开发环境
 */
- (BOOL)isDevelopStatus {
    if ([self isDistributionOnlineRelease]) {//线上发布直接返回
        return NO;
    }
    NSUserDefaults *myDefaults = [[NSUserDefaults alloc]initWithSuiteName:@"group.com.starlink.Adorawe"];
    NSInteger envType = [[myDefaults objectForKey:@"EnvSettingTypeKey"] integerValue];

    BOOL isFlag = (envType != LocalHostEnvOptionTypeDis);

    STLLog(@"GGGGGURL evyType:%li --- %i",(long)envType,isFlag);

    return isFlag;
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

+ (NSString *)readAppUUID {
    NSMutableDictionary *keychainDataDict = (NSMutableDictionary *)[self load:@"KEY_IN_KEYCHAIN_UUID_ADORAWE"];
    
    if ([keychainDataDict isKindOfClass:[NSDictionary class]]) {
        NSString *saveUUID = [keychainDataDict objectForKey:@"KEY_UUID_ADORAWE"];
        if (saveUUID.length>0) {
            return saveUUID;
        }
    }
    return @"";
}


+ (id)load:(NSString *)service {
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    //Configure the search setting
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(__bridge_transfer id)kSecReturnData];
    [keychainQuery setObject:(__bridge_transfer id)kSecMatchLimitOne forKey:(__bridge_transfer id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((__bridge_retained CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge_transfer NSData *)keyData];
        } @catch (NSException *e) {
            STLLog(@"Unarchive of %@ failed: %@", service, e);
        } @finally {
        }
    }
    return ret;
}

+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (__bridge_transfer id)kSecClassGenericPassword,(__bridge_transfer id)kSecClass,
            service, (__bridge_transfer id)kSecAttrService,
            service, (__bridge_transfer id)kSecAttrAccount,
            (__bridge_transfer id)kSecAttrAccessibleAfterFirstUnlock,(__bridge_transfer id)kSecAttrAccessible,
            nil];
}
@end
