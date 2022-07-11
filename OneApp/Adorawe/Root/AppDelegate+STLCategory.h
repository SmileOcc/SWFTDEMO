//
//  AppDelegate+STLCategory.h
// XStarlinkProject
//
//  Created by odd on 2020/7/10.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "AppDelegate.h"
#import "RealReachability.h"
#import "CacheFileManager.h"
#import "AFImageDownloader.h"
#import "OSSVAdvsEventsManager.h"
#import "OSSVCountrysCheckAip.h"

#import "OSSWMHomeVC.h"
#import "OSSVLanuchsAdvView.h"


@interface AppDelegate (STLCategory)


- (void)launchingSetting:(NSDictionary *)launchOptions;
/// 切换语言时需要重置
- (void)initAppRootVC;

- (void)networkStatusChangeHandle:(RealReachability *)reachability;


///app版本首次（注册推送）+ 广告处理
+ (void)appVersionAdvertRegisterNotificationBlock:(void(^)(void))registerBlock;

+ (void)showHomeAdv;

+ (void)handleReceiveMemoryWarning;

+ (OSSVTabBarVC *)mainTabBar;


/**
 * 显示启动倒计时广告
 */
+ (void)showLaunchAdvertView:(OSSVAdvsEventsModel *)bannerModel
                   imageData:(NSData *)imageData
             completeHandler:(void(^)(void))completeHandler;

+ (void)firstDownloadImage:(NSString *)imagerUrl;


/// 获取app的安装或者更新时间
+ (NSDate *)getAppInstallOrUpdateTime;
@end
