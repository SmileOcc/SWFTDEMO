//
//  OSSVAccountsManager.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/31.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVAccountsManager.h"
#import <sys/utsname.h>

#import "CountryListModel.h"
#import "CountryModel.h"
#import "CacheFileManager.h"
#import "STLPushManager.h"
#import "AppDelegate+STLThirdLibrary.h"
#import "SignViewController.h"
#import "UIViewController+STLCategory.h"
#import "STLKeychainDataManager.h"
#import "OSSVCommonnRequestsManager.h"
#import <RangersAppLog/BDAutoTrack.h>

//#define USER_NAME @"name"
//#define USER_EMAIL @"email"
//#define USER_PASSWORD @"password"
//#define USER_AGE @"age"

@implementation OSSVAccountsManager

+ (OSSVAccountsManager *)sharedManager {
    static OSSVAccountsManager *sharedAccountManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedAccountManagerInstance = [[self alloc] init];
        [sharedAccountManagerInstance readUserInfo];
    });
    return sharedAccountManagerInstance;
}

- (void)readUserInfo {
    if ([[NSFileManager defaultManager] fileExistsAtPath:[STL_PATH_DIRECTORY stringByAppendingPathComponent:kUserFileName]]) {
        NSData *data = [[NSData alloc] initWithContentsOfFile:[STL_PATH_DIRECTORY stringByAppendingPathComponent:kUserFileName]];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        [unarchiver setClass:AccountModel.class forClassName:kUserFileName];
        //解档出数据模型Student
        AccountModel *account = [unarchiver decodeObjectForKey:kArchiverDataKey];
        [unarchiver finishDecoding];//一定不要忘记finishDecoding，否则会报错
        self.account = account;
        if (self.account) {
            self.isSignIn = YES;
        }
    }
}

- (void)saveUserInfo:(AccountModel *)account {
    NSMutableData *data = [[NSMutableData alloc] init];
    [NSKeyedArchiver setClassName:kUserFileName forClass:account.class];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:account forKey:kArchiverDataKey];
    [archiver finishEncoding];
    BOOL isWriteSuccess = [data writeToFile:[STL_PATH_DIRECTORY stringByAppendingPathComponent:kUserFileName] atomically:YES];
    if (!isWriteSuccess) {
        STLLog(@"saveUserInfo Failed");
    }
    [self readUserInfo];
}

- (void)updateUserInfo:(AccountModel *)account {
    ///1.4.2 ab test
    [BDAutoTrack setCurrentUserUniqueID:STLToString(account.userid)]; //设置您自己的账号体系ID, 并保证其唯一性 ！
    [self saveUserInfo:account];
    [self readUserInfo];
}

- (void)clearUserInfo {
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[STL_PATH_DIRECTORY stringByAppendingPathComponent:kUserFileName]]) {
        [[NSFileManager defaultManager] removeItemAtPath:[STL_PATH_DIRECTORY stringByAppendingPathComponent:kUserFileName] error:nil];
        self.account = nil;
        self.isSignIn = NO;
    }
    
    STLLog(@"-------退出： %@",USERID_STRING);
    self.userToken = @"";
    [OSSVAnalyticsTool sensorsDynamicConfigure];
    [OSSVAnalyticsTool analyticsGASetUserID:USERID_STRING];
    [AppDelegate appsFlyerTracekerCustomerUserID];
    [[OSSVCartsOperateManager sharedManager] cartSaveValidGoodsAllCount:0];
    //登出的时候，发送通知更新首页悬浮的数据
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_updateHomeFloatBannerData object:nil];
}

- (NSString *)iosplatform {
    if (!_iosplatform) {
        struct utsname systemInfo;
        uname(&systemInfo);
        NSString*platform = [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];
        _iosplatform = platform;
    }
    return _iosplatform;
}

- (int)userId {
    int userId = 0;
    if ([OSSVAccountsManager sharedManager].isSignIn) {
        userId = [self.account.userid intValue];
    }
    return userId;
}

- (NSString *)userIdString {
    NSString *userId = @"";
    if ([OSSVAccountsManager sharedManager].isSignIn) {
        userId = STLToString(self.account.userid);
    }
    return userId;
}


- (void)saveUserToken:(NSString *)token {
    [STLKeychainDataManager saveUserToken:STLToString(token)];
    self.userToken = STLToString(token);
}

- (NSString *)userToken {
    if (!_userToken) {
        _userToken = [STLKeychainDataManager readUserToken];
    }
    _userToken = STLToString(_userToken);
    return _userToken;
}

+ (void)saveLeandCloudData {
    
    BOOL hasShowUserNotification = [STLUserDefaultsGet(kHadShowSystemNotificationAlert) boolValue];
    if (!hasShowUserNotification) return;  // 没注册推送前，不往服务器上传设备信息
    
    //保存FCM推送的信息
    [self uploadFCMTokenToServerToken:STLToString([FIRMessaging messaging].FCMToken)];
}

/**
 * 上传FCM推送的信息
 */
+ (void)uploadFCMTokenToServerToken:(NSString *)fcmToken {
    
    NSLog(@"\n\n===========FCMTOKEN===========:\n\n %@ \n\n %@\n\n===========FCMTOKEN===========\n\n",fcmToken,[FIRMessaging messaging].FCMToken);
    NSString *paid_order_number = @"0";
    if ([OSSVAccountsManager sharedManager].isSignIn) {
        if ([OSSVAccountsManager sharedManager].isSignIn) {
            paid_order_number = [NSString stringWithFormat:@"%ld",(long)[OSSVAccountsManager sharedManager].account.outstandingOrderNum];
        }
    }
    
    // pushPower: 是否开启系统推送权限, 1开启, 0关闭
    [STLPushManager isRegisterRemoteNotification:^(BOOL isRegister) {
        // 保存FCM推送的信息到leancloud
        [OSSVCommonnRequestsManager saveFCMUserInfo:paid_order_number pushPower:isRegister fcmToken:fcmToken];
    }];
}



+ (void)logout {
    
    [[OSSVAccountsManager sharedManager] clearUserInfo];
    [CacheFileManager clearDatabaseCache:STL_PATH_DATABASE_CACHE]; //清除数据库信息;
    [STLKeychainDataManager deleteUserToken];
    
    // 保存LeandCloud数据
    [OSSVAccountsManager saveLeandCloudData];
}

+ (void)reLogin {
    
    STLLog(@"---------token 失效");
    if (![OSSVAccountsManager sharedManager].isRelogining) {
        
        
        UIViewController *viewCtrl = (UIViewController *)[UIViewController currentTopViewController];
        if ([viewCtrl isMemberOfClass:[SignViewController class]]) {
            STLLog(@"---------token 失效");
            return;
        }
        [OSSVAccountsManager sharedManager].isRelogining = YES;
        SignViewController *signVC = [SignViewController new];
        signVC.modalPresentationStyle = UIModalPresentationFullScreen;
        signVC.signBlock = ^{
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [OSSVAccountsManager sharedManager].isRelogining = NO;
            }); 
        };
        signVC.closeBlock = ^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [OSSVAccountsManager sharedManager].isRelogining = NO;
            });
        };
        
        [viewCtrl presentViewController:signVC animated:YES completion:nil];
    }
}



- (NSString *)device_id {
    if (!_device_id) {
        _device_id = [STLKeychainDataManager readAppUUID];
        // 保存到数据共享组
        NSUserDefaults *myDefaults = [[NSUserDefaults alloc] initWithSuiteName:[[STLDeviceInfoManager sharedManager] appGroupSuitName]];
        [myDefaults setObject:STLToString(_device_id) forKey:@"Device_Id"];
    }
    _device_id = STLToString(_device_id);
    return _device_id;
}

+ (NSInteger)stlShareChannelSource {
    if (!STLIsEmptyString([OSSVAccountsManager sharedManager].shareChannelSource)) {
        if ([[OSSVAccountsManager sharedManager].shareChannelSource isEqualToString:@"Facebook"]) {
            return 1;
        } else  if ([[OSSVAccountsManager sharedManager].shareChannelSource isEqualToString:@"WhatsApp"]) {
            return 2;
        } else  if ([[OSSVAccountsManager sharedManager].shareChannelSource isEqualToString:@"Copylink"]) {
            return 3;
        }
    }
    return 0;
}

-(BOOL)needShowMember{
//    if (self.isSignIn &&
//        self.account.vip_url.length > 0 &&
//        self.account.is_show_vip ){
//        return true;
//    }
//    return false;
    //1.4.4一直显示
    return true;
}


+ (void)testLaunchMessage:(NSString *)msg {
    if (![OSSVConfigDomainsManager isDistributionOnlineRelease]) {
        [OSSVAccountsManager sharedManager].testMessage = [NSString stringWithFormat:@"%@##%@",[OSSVAccountsManager sharedManager].testMessage,msg];
    }
}
@end



@implementation LoginThirdModel

@end
