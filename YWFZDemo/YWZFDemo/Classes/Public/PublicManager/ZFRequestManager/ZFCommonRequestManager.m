//
//  ZFCommonRequestManager.m
//  ZZZZZ
//
//  Created by YW on 2018/5/4.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommonRequestManager.h"
#import "RateModel.h"
#import "FilterManager.h"
#import "ZFBannerModel.h"
#import "NSUserDefaults+SafeAccess.h"
#import "ZFSkinViewModel.h"
#import "ZFHomeAnalysis.h"
#import "SYNetworkCacheManager.h"
#import "ZFLoadingAnimationView.h"
#import "ZFAppUpgradeView.h"
#import "ZFUpgradeModel.h"
#import "NSDate+ZFExtension.h"
#import "YWLocalHostManager.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "NSStringUtils.h"
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"
#import "NSDictionary+SafeAccess.h"
#import "ZFAnalytics.h"
#import "ZFAnalyticsTimeManager.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "YSAlertView.h"
#import "ZFRequestModel.h"
#import "Constants.h"
#import "ZFAddressLibraryManager.h"
#import "ZFDeviceInfoManager.h"
#import "ZFProgressHUD.h"

#import "MyOrdersModel.h"

#import "ZFUnpaidOrderAlertView.h"
#import "ZFOrderDetailViewController.h"
#import "ZFOrderPayTools.h"
#import "UIViewController+ZFViewControllerCategorySet.h"

#import "ZFHomePageViewController.h"
#import "ZFOrderSuccessViewController.h"
#import "ZFOrderFailureViewController.h"
#import "ZFHomeCMSViewController.h"
#import "NSDate+ZFExtension.h"
#import "JumpManager.h"
#import "BannerManager.h"
#import "ZFAppsflyerAnalytics.h"
#import "NSDate+ZFExtension.h"
#import "UITabBarController+ZFExtension.h"
#import "ZFCommunityViewModel.h"
#import "ZFOrderQuestionViewController.h"
#import "ZFMyOrderListViewController.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "ZFOrderInformationViewModel.h"
#import "ZFGrowingIOAnalytics.h"
#import "ZFBranchAnalytics.h"
#import "ZFBTSManager.h"
#import <GGBrainKeeper/BrainKeeperManager.h>
#import "ZFCategoryParentViewController.h"
#import <Bugly/Bugly.h>
#import "ZFFireBaseAnalytics.h"

@interface ZFCommonRequestManager ()

@end

@implementation ZFCommonRequestManager

/**
 *  ZFNetwork私有网络请求库的所有公共配置信息
 *  (2018年12月05日11:24:53 启动速度优化，把+load方法移入initialize)
 */
+ (void)initialize {
    ZFNetworkConfigPlugin *zfNetworkPlus = [ZFNetworkConfigPlugin sharedInstance];
    zfNetworkPlus.signPrivateKey = [YWLocalHostManager appPrivateKey];
    
    // ZZZZZ社区的机密key
    zfNetworkPlus.communitySignPrivateKey = [YWLocalHostManager appCommunityPrivateKey];
    
    // 请求转圈的UI对象类型
    zfNetworkPlus.requestLaodingCalss = [ZFLoadingAnimationView class];
    
    // 请求打印日志的测试分支标题
    zfNetworkPlus.networkTitle = [YWLocalHostManager currentLocalHostTitle];
    
    // 请求失败的默认提示文案
    zfNetworkPlus.requestFailDefaultToast = ZFLocalizedString(@"Global_VC_NO_DATA", nil);
    
    // 是否为发布审核环境<此标识供测试人员抓取日志使用>
    zfNetworkPlus.isDistributionOnlineRelease = [YWLocalHostManager isDistributionOnlineRelease];
    
    // 监听请求失败Code为202的通知
    zfNetworkPlus.errorCodeNotifyDict = @{ kNeedLoginNotification : @(202)};
    
    // 关闭网络库打印统计日志
    zfNetworkPlus.closeStatisticsPrintfLog = YES;
    
    // 关闭网络库打印接口响应日志
    zfNetworkPlus.closeUrlResponsePrintfLog = NO;
    
    // 默认不上传接口响应日志
    zfNetworkPlus.uploadResponseJsonToLogSystem = !ZFIsEmptyString(GetUserDefault(kInputCatchLogTagKey));
}

+ (CGFloat)randomSecondsForMaxMillisecond:(NSInteger)maxMillisecond {
    if (maxMillisecond <= 0) {
        return 0;
    }
    return arc4random() % maxMillisecond / 1000.0;
}
/**
 * 启动时异步请求必要接口数据 (在App启动时,首页从无网络到有网络时调用)
 */
+ (void)requestNecessaryData {
    
    // 推送通知打开 延迟请求处理
    BOOL isLaunchRemoteNotif = [YWLocalHostManager stateLaunchOptionsRemoteOpenApp];
    
    CGFloat afterTime = isLaunchRemoteNotif ? [self randomSecondsForMaxMillisecond:1000]: [self randomSecondsForMaxMillisecond:600];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(afterTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 请求汇率接口 随机延时
        [self requestExchangeData:nil];
    });
    
    // 请求基础信息接口
    [self requestInitializeData:nil];
}

/**
 * 在首页viewDidLoad中调用
 */
+ (void)asyncRequestOtherApi {
    // 请求cod接口
    [self requestCurrencyData];
    
    // 请求是否要切换AppIcon
    [self requestConvertAppIcon];

    // 请求是否新用户
    [self requestIsNewUser];
    
    // 推送通知打开 延迟请求处理
    BOOL isLaunchRemoteNotif = [YWLocalHostManager stateLaunchOptionsRemoteOpenApp];
    
    CGFloat afterTime = isLaunchRemoteNotif ? [self randomSecondsForMaxMillisecond:1000] + 3 : [self randomSecondsForMaxMillisecond:800];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(afterTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 请求启动页321倒计时广告接口 (⚠️考虑主页页面请求太多,延迟请求)
        [self performSelector:@selector(requestLaunchAD) withObject:nil afterDelay:5];
        
        // 请求首页半透明大浮窗接口
        [self requestHomeFloatViewData];
        
        // 请求TabBar未读消息 随机延时
        [self requestTabBarRedDotMessage];
    });

}

/**
 * 请求是否需要清除缓存数据
 */
+ (void)requestiSNeedCleanAppData {
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.url = API(Port_update_cache);
    requestModel.parmaters = @{@"device_version" : @(kiOSSystemVersion)};
    
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        NSDictionary *resultDic = responseObject[ZFResultKey];
        if (!ZFJudgeNSDictionary(resultDic)) return ;

        // 启动时就获取服务端是否需要App请求走cdn的配置开关
        [AccountManager sharedManager].appShouldRequestCdn = [resultDic[@"is_use_cdn"] boolValue];
        
        // 链路上传开关
        [BrainKeeperManager sharedManager].isOpenBrainKeeper = [resultDic[@"is_open_brain_keeper"] boolValue];
        
        // 配置cms的超时时间
        NSString *cms_time_out = resultDic[@"cmsTimeOut"];
        if (cms_time_out) {
            [AccountManager sharedManager].cmsTimeOutDuration = @([cms_time_out integerValue]);
        }
                                  
        // 清除缓存标识  0 不更新  1更新
        NSString *clear_app_cache = resultDic[@"clear_app_cache"];
        if (clear_app_cache && [clear_app_cache integerValue] == 1) {
            [ZFCommonRequestManager cleanAppNetWorkCahceData];
        }
        
        // 临时强制更新App  0 不更新 1更新
        NSString *force_app_update = resultDic[@"force_app_update"];
        if (force_app_update && [force_app_update integerValue] == 1) {
            NSString *message = resultDic[@"force_app_update_message"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [ZFCommonRequestManager forceUpgradeZFApp:message];
            });
        }
    } failure:nil];
}

/**
 * 清除所有的YYCache缓存
 */
+ (void)cleanAppNetWorkCahceData {
    YWLog(@"清除所有的YYCache缓存");
    // 清除新网络库的所有缓存
    [[ZFNetworkConfigPlugin sharedInstance].networkDiskCache removeAllObjects];
    [ZFNetworkHttpRequest clearZFNetworkHttpRequestCache];
    // 清除老网络库的所有缓存
    [[SYNetworkCacheManager sharedInstance] clearCache];
}

/**
 * 版本强制更新
 */
+ (void)forceUpgradeZFApp:(NSString *)message {
    YWLog(@"版本强制更新");
    NSString *alertTitle = ZFLocalizedString(@"ForceUpgrade_title",nil);
    NSString *alertMessage = ZFIsEmptyString(message) ? ZFLocalizedString(@"ForceUpgrade_message",nil) : message;
    NSString *alertCancel = ZFLocalizedString(@"SettingViewModel_Cache_Alert_OK",nil);
    
    // (临时强制更新是因为: 有时有紧急bug导致的App不能启动, 提示用户需要卸载此版本重新安装)
    [AccountManager sharedManager].hasShowTempForceUpgrade = YES;
    
    ShowAlertView(alertTitle, alertMessage, nil, nil, alertCancel, ^(id cancelTitle){
        // 跳下载页面
        NSURL *appInfoUrl = [NSURL URLWithString:ZFAppStoreUrl];
        [[UIApplication sharedApplication] openURL:appInfoUrl];
        
        // 退到桌面
        [YWLocalHostManager logOutApplication];
    });
}

/**
 * 请求TabBar未读消息（只调一次现在只关于消息)
 */
+ (void)requestTabBarRedDotMessage {
    if (![AccountManager sharedManager].isSignIn) return;
    [ZFCommunityViewModel requestMessageCountNetwork:USERID completion:^(NSInteger msgCount) {
        if (msgCount > 0) {
            [APPDELEGATE.tabBarVC showBadgeOnItemIndex:TabBarIndexCommunity];
        }
    } failure:nil];
}

/**
 * 请求汇率接口
 */
+ (void)requestExchangeData:(void(^)(BOOL success))completeHandler {
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.url = API(Port_rate);
    requestModel.needToCache = NO;
    requestModel.tryAgainTimesWhenFailure = 10;
    
    [[ZFAnalyticsTimeManager sharedManager] requestSuccessTimeWithRequestAction:Port_rate requestTime:ZFRequestTimeBegin];
    [ZFNetworkHttpRequest sendExtensionRequestWithParmaters:requestModel success:^(id responseObject) {
        NSArray *array = [NSArray yy_modelArrayWithClass:[RateModel class] json:responseObject[ZFResultKey]];
        [ExchangeManager saveLocalExchange:array];
    
        if (completeHandler && !requestModel.isCacheData) {
            completeHandler(YES);
        }
    } failure:^(NSError *error) {
        if (completeHandler) {
            completeHandler(NO);
        }
    }];
}

/**
 * 请求是否要切换AppIcon
 */
+ (void)requestConvertAppIcon {
    //以后换icon都打在包里面
    return;
//    ZFRequestModel *requestModel = [ZFRequestModel new];
//    requestModel.url = API(Port_changeAppIcon);
//    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
//        NSDictionary *resultDict = [responseObject ds_dictionaryForKey:@"result"];
//        NSInteger returnCode     = [resultDict ds_integerForKey:@"returnCode"];
//        if (returnCode != 0) return ;
//
//        NSArray *returnInfoArray = [resultDict ds_arrayForKey:@"returnInfo"];
//        NSDictionary *returnInfoDict = [returnInfoArray firstObject];
//        BOOL isShow = [returnInfoDict ds_boolForKey:@"isShow"];
//        NSString *iconName = nil;
//        iconName = [returnInfoDict ds_stringForKey:@"deskIconName"];
//        iconName = isShow ? iconName : nil;
//
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            // 切换桌面icon图标
//            if (@available(iOS 10.3, *)) {
//                if ([[UIApplication sharedApplication] supportsAlternateIcons]) {
//                    [[UIApplication sharedApplication] setAlternateIconName:iconName completionHandler:^(NSError * _Nullable error) {
//                        if (error) {
//                            YWLog(@"切换桌面icon图标失败=== %@", error.description);
//                        }
//                    }];
//                }
//            }
//        });
//    } failure:nil];
}

/**
 * 用户信息定位接口
 */
+ (void)requestLocationInfo{
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.url = API(Port_locationInfo);
    requestModel.needToCache = YES;
    
    [ZFNetworkHttpRequest sendExtensionRequestWithParmaters:requestModel success:^(id responseObject) {
        NSDictionary *result = responseObject[ZFResultKey];
        if (ZFJudgeNSDictionary(result)) {
            SaveUserDefault(kLocationInfoCountryId, ZFToString(result[@"country_id"]));
            SaveUserDefault(kLocationInfoCountryCode, ZFToString(result[@"country_code"]));
            SaveUserDefault(kLocationInfoPipeline, ZFToString(result[@"pipeline"]));
            [AccountManager sharedManager].br_is_show_icon = [result[@"br_is_show_icon"] boolValue];
        };
    } failure:nil];
}

/**
 * 请求基础信息接口
 */
+ (void)requestInitializeData:(void(^)(BOOL success))completeHandler {
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.url = API(Port_initialization);
    requestModel.needToCache = YES;
    
    [ZFNetworkHttpRequest sendExtensionRequestWithParmaters:requestModel success:^(id responseObject) {
        NSDictionary *result = responseObject[ZFResultKey];
        if (ZFJudgeNSDictionary(result)) {
            // 保存SessId
            NSString *sess_id = [result ds_stringForKey:ZFApiSessId];
            if (!ZFIsEmptyString(sess_id)) {
                NSString *oldSess_id = [[NSUserDefaults standardUserDefaults] valueForKey:kSessionId];
                if (ZFIsEmptyString(oldSess_id)) { //警告：如果之前有sess_id则不能存
                    [[NSUserDefaults standardUserDefaults] setValue:sess_id forKey:kSessionId];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
            @try {
                /// 这里防止服务端传回来的数据字典中有空对象,先把它转成模型在转成字典存储
                ZFInitializeModel *tmpInitializeModel = [ZFInitializeModel yy_modelWithJSON:result];
                NSData *jsonData = [(NSString *)[tmpInitializeModel yy_modelToJSONString] dataUsingEncoding : NSUTF8StringEncoding];
                
                if (jsonData) {
                    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
                    
                    if ([dic isKindOfClass:[NSDictionary class]]){
                        [[NSUserDefaults standardUserDefaults] setObject:dic forKey:kInitialize];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    };
                }
                
            } @catch (NSException *exception) {
                [Bugly reportExceptionWithCategory:3
                                              name:ZFToString(exception.name)
                                            reason:ZFToString(exception.reason)
                                         callStack:@[]
                                         extraInfo:exception.userInfo
                                      terminateApp:NO];
            }

            //这里把初始化数据存到本地
            [[AccountManager sharedManager] saveInitializeData:result];
            
            ZFInitializeModel *initializeModel = [AccountManager sharedManager].initializeModel;
            ZFInitCountryInfoModel *initCountryInfo = initializeModel.countryInfo;
            ZFInitExchangeModel *initExchangeInfo = initializeModel.exchange;
            
            // initia接口回来每次都要保存更改国家信息
            ZFAddressCountryModel *accountCountryModel = [ZFAddressCountryModel new];
            accountCountryModel.region_code = initCountryInfo.region_code;
            accountCountryModel.region_id = initCountryInfo.region_id;
            accountCountryModel.region_name = initCountryInfo.region_name;
            accountCountryModel.is_emerging_country = initCountryInfo.is_emerging_country;
            
            ZFCountryExchangeModel *exchange = [ZFCountryExchangeModel new];
            exchange.name = initExchangeInfo.name;
            exchange.sign = initExchangeInfo.sign;
            exchange.rate = initExchangeInfo.rate;
            exchange.exponet = initExchangeInfo.exponet;
            exchange.position = initExchangeInfo.position;
            exchange.thousandSign = initExchangeInfo.thousandSign;
            exchange.decimalSign = initExchangeInfo.decimalSign;
            accountCountryModel.exchange = exchange;
            
            [AccountManager sharedManager].accountCountryModel = accountCountryModel;
//            if (!requestModel.isCacheData) {
//                [AccountManager saveLeandCloudData];
//            }
            
            // 判断login_expired=1 代表token失效,需要重新登录
            if (initializeModel != nil && !ZFIsEmptyString(initializeModel.login_expired)) {
                if ([initializeModel.login_expired integerValue] == 1) {
                    [[AccountManager sharedManager] clearUserInfo];
                    UIViewController *tempVC = [UIViewController currentTopViewController];
                    [tempVC judgePresentLoginVCCompletion:nil];
                }
            }
        };
        
        // 刷新当前国家信息 initialization接口
        [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshCountryExchangeInfo object:responseObject];
        
        if (completeHandler && !requestModel.isCacheData) {
            completeHandler(YES);
        }
    } failure:^(NSError *error) {
        if (completeHandler) {
            completeHandler(NO);
        }
        ShowToastToViewWithText(nil, ZFLocalizedString(@"Global_VC_NO_DATA", nil));
    }];
}

/**
 * 请求cod接口
 */
+ (void)requestCurrencyData {
    
    // 推送通知打开 延迟请求处理
    BOOL isLaunchRemoteNotif = [YWLocalHostManager stateLaunchOptionsRemoteOpenApp];
    
    CGFloat afterTime = isLaunchRemoteNotif ? [self randomSecondsForMaxMillisecond:1000] + 1 : [self randomSecondsForMaxMillisecond:800];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(afterTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ZFRequestModel *requestMode = [ZFRequestModel new];
        requestMode.url = API(Port_currency);
        requestMode.needToCache = YES;
        requestMode.tryAgainTimesWhenFailure = 10;
        
        [ZFNetworkHttpRequest sendExtensionRequestWithParmaters:requestMode success:^(id responseObject) {
            [FilterManager saveLocalFilter:responseObject[ZFResultKey]];
        } failure:nil];
    });
    
}


///是否新用户接口
+ (void)requestIsNewUser{
    ZFRequestModel *requestMode = [ZFRequestModel new];
    requestMode.url = API(Port_IsNewUser);
    requestMode.tryAgainTimesWhenFailure = 5;
    
    [ZFNetworkHttpRequest sendExtensionRequestWithParmaters:requestMode success:^(id responseObject) {
        NSDictionary *params = responseObject[@"result"];
        if (ZFJudgeNSDictionary(params)) {
            NSString *user_type = ZFToString(params[@"is_new_user"]);
            [AccountManager sharedManager].af_user_type = user_type;
        }
    } failure:nil];
}

/**
 * 所有的CMS广告数据接口
 */
+ (void)requestCMSAppAdvertsWithTpye:(ZFCMSAppAdvertsType)advertsType
                             otherId:(NSString *)other
                          completion:(void (^)(NSDictionary *responseObject))completion
                              target:(id)target
{
    ZFRequestModel *requestModel = [self gainCmsRequestModelWithTpye:advertsType otherId:other target:target];
    [ZFNetworkHttpRequest sendExtensionRequestWithParmaters:requestModel success:^(id responseObject) {
        if (completion) {
            completion(responseObject);
        }
    } failure:^(NSError *error) {
        if (completion) {
            completion(nil);
        }
    }];
}

+ (ZFRequestModel *)gainCmsRequestModelWithTpye:(ZFCMSAppAdvertsType)advertsType
                                        otherId:(NSString *)other
                                         target:(id)target
{
    NSString *user_center = @"";// 是否为个人中心
    NSString *adverts_id = @""; // 广告类型
    NSString *screen_type = @""; // 手机分辨率类型化
    NSString *order_status = @""; // 订单详情页面状态
    if (advertsType == ZFCMSAppAdvertsType_AppLaunching) {
        adverts_id = @"8";
        screen_type = ZFToString(other);
        other = @"";
        
    } else if (advertsType == ZFCMSAppAdvertsType_HomeBigFloating) {
        adverts_id = @"1";
        
    } else if (advertsType == ZFCMSAppAdvertsType_HomeSmallFloating) {
        adverts_id = @"2";
        
    } else if (advertsType == ZFCMSAppAdvertsType_PaySuccess) {
        adverts_id = @"6";
        
    } else if (advertsType == ZFCMSAppAdvertsType_CategoryPage) {
        adverts_id = @"7";
        
    } else if (advertsType == ZFCMSAppAdvertsType_UserCenter) {
        adverts_id = @"";  // 个人中心传时空, 由user_center字段控制
        user_center = @"1"; // 是否为个人中心
        
    } else if (advertsType == ZFCMSAppAdvertsType_OrderDetail) {
        adverts_id = @"15";
        order_status = ZFToString(other);
    }
    NSString *user_type = ZFToString([AccountManager sharedManager].af_user_type);//新老客
    
    if (![YWLocalHostManager isOnlineRelease]){ //⚠️警告: 只供测试时使用,线上环境时不能传
        NSDictionary *siftDict = GetUserDefault(kTestCMSParmaterSiftKey);
        if (ZFJudgeNSDictionary(siftDict)) {
            NSString *is_new_customer = siftDict[@"is_new_customer"];
            if (!ZFIsEmptyString(is_new_customer)) {
                user_type = is_new_customer;
            }
        }
    }
    if (ZFIsEmptyString(user_type)) {
        user_type = @"1";
    }
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.taget = target;
    requestModel.eventName = @"cms_adverts";
    requestModel.url = CMS_API(Port_cms_appAdverts);
    requestModel.forbidEncrypt = YES;
    
    ZFAddressCountryModel *accountModel = [AccountManager sharedManager].accountCountryModel;
    NSString *language = ZFToString([ZFLocalizationString shareLocalizable].nomarLocalizable);
    
    requestModel.parmaters = @{
        @"platform"         :   @"2",
        @"website"          :   @"ZF",
        @"user_type"        :   ZFToString(user_type),
        @"country_acronym"  :   ZFToString(accountModel.region_code),
        @"user_info"        :   [[AccountManager sharedManager] userInfo],
        @"language"         :   ZFToString(language),
        @"screen_type"      :   ZFToString(screen_type),
        @"user_center"      :   ZFToString(user_center),
        @"adverts_id"       :   ZFToString(adverts_id),
        @"order_status"     :   ZFToString(order_status),
    };
    return requestModel;
}

/**
 * V4.5.3采用cms的接口获取首页大浮窗数据
 */
+ (void)requestHomeFloatViewData {
    [ZFCommonRequestManager requestCMSAppAdvertsWithTpye:(ZFCMSAppAdvertsType_HomeBigFloating) otherId:nil completion:^(NSDictionary *responseObject) {
        NSArray *resultArray = responseObject[ZFDataKey];
        
        BOOL shouldShow = YES;
        if (!ZFJudgeNSArray(resultArray)) {
            shouldShow = NO;
        }
        NSDictionary *resultDic = [resultArray firstObject];
        if(!ZFJudgeNSDictionary(resultDic)) {
            shouldShow = NO;
        }
        NSArray *listArray = [resultDic ds_arrayForKey:@"list"];
        NSDictionary *bannerDict = [listArray firstObject];
        if (!ZFJudgeNSDictionary(bannerDict)) {
            shouldShow = NO;
        }
        
        if (!shouldShow) { //V5.5.0修改:如果返回为空则不显示
            NSData *floatModelData = GetUserDefault(kHomeFloatModelKey);
            ZFBannerModel *floatModel = [NSKeyedUnarchiver unarchiveObjectWithData:floatModelData];
            if ([floatModel isKindOfClass:[ZFBannerModel class]]) {
                floatModel.popupNumber = @"-1"; //负数本地表示不显示
                NSData *saveModelData = [NSKeyedArchiver archivedDataWithRootObject:floatModel];
                SaveUserDefault(kHomeFloatModelKey, saveModelData);
            }
            return;
        }
        
        ZFBannerModel *bannerModel = [[ZFBannerModel alloc] init];
        bannerModel.image = [bannerDict ds_stringForKey:@"img"];
        bannerModel.name = [bannerDict ds_stringForKey:@"name"];
        bannerModel.banner_id = [bannerDict ds_stringForKey:@"advertsId"];
        bannerModel.colid = [bannerDict ds_stringForKey:@"colId"];
        bannerModel.componentId = [bannerDict ds_stringForKey:@"componentId"];
        bannerModel.menuid = [bannerDict ds_stringForKey:@"menuId"];
        NSString *popupNumber = [bannerDict ds_stringForKey:@"alertNum"];
        if (ZFIsEmptyString(popupNumber)) {
            popupNumber = @"0"; // 如果没取到就写死0,表示一直弹
        }
        bannerModel.popupNumber = ZFToString(popupNumber);
        
        NSString *actionType = [bannerDict ds_stringForKey:@"actionType"];
        NSString *url = [bannerDict ds_stringForKey:@"url"];
        
        //如果actionType=-2,则特殊处理自定义完整ddeplink
        if (actionType.integerValue == -2) {
            bannerModel.deeplink_uri = ZFToString(ZFEscapeString(url, YES));
        } else {
            bannerModel.deeplink_uri = [NSString stringWithFormat:ZFCMSConvertDeepLinkString, actionType, url, bannerModel.name];
        }
        
        // 去除首尾空格和换行：
        NSString *imageURL = [bannerModel.image stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        bannerModel.image = imageURL;
        
        //先下载图片完成后再显示出来
        [[YYWebImageManager sharedManager] requestImageWithURL:[NSURL URLWithString:imageURL] options:(YYWebImageOptionShowNetworkActivity) progress:nil transform:nil completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
            
            NSData *oldModelData = GetUserDefault(kHomeFloatModelKey);
            ZFBannerModel *oldFloatModel = [NSKeyedUnarchiver unarchiveObjectWithData:oldModelData];
            if ([oldFloatModel isKindOfClass:[ZFBannerModel class]]
                && [bannerModel.banner_id isEqualToString:oldFloatModel.banner_id]) {
                bannerModel.hasShowPopupNum = oldFloatModel.hasShowPopupNum;
            }
            
            NSData *floatModelData = [NSKeyedArchiver archivedDataWithRootObject:bannerModel];
            SaveUserDefault(kHomeFloatModelKey, floatModelData);
            
            YWLog(@"首页大半透明浮窗图片已下载完成,直接显示==%@", [NSThread currentThread]);
            dispatch_async(dispatch_get_main_queue(), ^{
                [AppDelegate judgeShowHomeFloatView];
            });
        }];
    } target:[ZFHomePageViewController new]];
}

/**
 * V4.5.3采用cms的接口获取启动广告数据
 * 请求启动页321倒计时广告接口
 */
+ (void)requestLaunchAD {
    NSString *kind = @"";
    if (IPHONE_4X_3_5) {
        kind = @"1";
    } else if (IPHONE_5X_4_0) {
        kind = @"2";
    } else if (IPHONE_6X_4_7) {
        kind = @"3";
    } else if (IPHONE_6P_5_5 || IPHONE_7P_5_5) {
        kind = @"4";
    } else if (IPHONE_X_5_15) {
        kind = @"5";
    } else {
        kind = @"6";
    }
    [ZFCommonRequestManager requestCMSAppAdvertsWithTpye:(ZFCMSAppAdvertsType_AppLaunching) otherId:kind completion:^(NSDictionary *responseObject) {
        // 异步获取启动倒计时广告资源
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            NSArray *resultArray = responseObject[ZFDataKey];
            if (!ZFJudgeNSArray(resultArray)) return;
            
            NSDictionary *resultDic = [resultArray firstObject];
            if(!ZFJudgeNSDictionary(resultDic)) return;
            
            // 安卓么有清除广告数据
            //[[NSUserDefaults standardUserDefaults] removeObjectForKey:kLaunchAdvertDataDictiontryKey];
            
            NSMutableArray *imageDataArr = [NSMutableArray array];
            NSArray *listArray = [resultDic ds_arrayForKey:@"list"];
            
            for (NSDictionary *bannerDic in listArray) {
                NSString *imageUrl = bannerDic[@"img"];
                if (ZFIsEmptyString(imageUrl)) continue;
                
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
                if (imageData.length == 0) continue;
                
                NSDictionary *finalBannerDic = [bannerDic deleteAllNullValue];
                if (!ZFJudgeNSDictionary(finalBannerDic)) continue;
                
                // 这里需要把CMS广告数据包装成ZFBnnerModel字典数据
                NSString *title = [finalBannerDic ds_stringForKey:@"name"];
                NSMutableDictionary *bannerDic = [NSMutableDictionary dictionary];
                bannerDic[@"name"] = title;
                bannerDic[@"image"] = [finalBannerDic ds_stringForKey:@"img"];
                bannerDic[@"width"] = [finalBannerDic ds_stringForKey:@"width"];
                bannerDic[@"height"] = [finalBannerDic ds_stringForKey:@"height"];
                bannerDic[@"banner_id"] = [finalBannerDic ds_stringForKey:@"advertsId"];
                bannerDic[@"colid"] = [finalBannerDic ds_stringForKey:@"colId"];
                bannerDic[@"componentId"] = [finalBannerDic ds_stringForKey:@"componentId"];
                bannerDic[@"menuid"] = [finalBannerDic ds_stringForKey:@"menuId"];
                NSString *actionType = [finalBannerDic ds_stringForKey:@"actionType"];
                NSString *url = [finalBannerDic ds_stringForKey:@"url"];
                
                //如果actionType=-2,则特殊处理自定义完整ddeplink
                if (actionType.integerValue == -2) {
                    bannerDic[@"url"] = ZFToString(ZFEscapeString(url, YES));
                } else {
                    bannerDic[@"url"] = [NSString stringWithFormat:ZFCMSConvertDeepLinkString, actionType, url, title];
                }
                if ([imageData isKindOfClass:[NSData class]] &&
                    [bannerDic isKindOfClass:[NSDictionary class]]) {
                    [imageDataArr addObject:@{kLaunchAdvertImageDataKey: imageData,
                                              kLaunchAdvertModelJsonKey: bannerDic}];
                }
            }
            [[NSUserDefaults standardUserDefaults] setObject:imageDataArr forKey:kLaunchAdvertDataDictiontryKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        });
    } target:[ZFHomePageViewController new]];
}

/**
 * 检查App版本更新
 */
+ (void)checkUpgradeZFApp:(void(^)(BOOL hasNoNewVersion))finishBlock {
    
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.url = API(Port_get_upgrade_data);
    requestModel.parmaters = @{@"device_version" : @(kiOSSystemVersion)};
    
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        
        [AccountManager sharedManager].hasCheckAppStoreVersion = YES;
        [AccountManager sharedManager].hasRequestUpgradeAppUrl = YES;
        NSArray *resultArr = responseObject[ZFResultKey];

        if (ZFJudgeNSArray(resultArr) && resultArr.count>0) {
            ZFUpgradeModel *model = [ZFUpgradeModel yy_modelWithJSON:[resultArr firstObject]];
            /**
             * 弹窗次数: show_update_time; 1 仅提醒一次，2 每天提醒一次，4一直提醒
             * 是否提示: show_update; 1 是 0 不是
             */
            //比较服务器最新版本号与当前App两个版本大小, 若服务器版本号大于本地版本号则需要升级App
            BOOL needUpgrade = [model.version compare:ZFSYSTEM_VERSION] == NSOrderedDescending;
            
            if (needUpgrade && !ZFIsEmptyString(model.show_update) && [model.show_update isEqualToString:@"1"]) {
                // 需要判断弹框次数
                BOOL shouldShowAlert = YES;
                NSMutableDictionary *upgradeShowDict = GetUserDefault(kAppUpgradeDataKey);
                if ([upgradeShowDict[kUpgradeShowVersion] isEqualToString:ZFSYSTEM_VERSION] &&
                    !ZFIsEmptyString(model.show_update_time)) {
                    if ([model.show_update_time isEqualToString:@"1"]) { //仅提醒一次
                        shouldShowAlert = NO;
                        
                    } else if ([model.show_update_time isEqualToString:@"2"]) { //每天提醒一次
                        if ([upgradeShowDict[kUpgradeShowDate] isEqualToString:[NSDate todayDateString]]) {
                            if ([upgradeShowDict[kUpgradeShowTimes] integerValue] == 1) {
                                shouldShowAlert = NO;
                            }
                        }
                    } else if ([model.show_update_time isEqualToString:@"4"]) { //一直提醒
                        shouldShowAlert = YES;
                    }
                }
                
                // 弹出App升级弹框
                if (shouldShowAlert) {
                    [ZFAppUpgradeView showUpgradeView:model upgradeAppBlock:^{
                        NSURL *url = [NSURL URLWithString:ZFAppStoreUrl];
                        [[UIApplication sharedApplication] openURL:url];
                        //非强制更新时关闭当前弹框
                        if (ZFIsEmptyString(model.is_forced) || [model.is_forced isEqualToString:@"0"]) {
                            if (finishBlock) {
                                finishBlock(NO);
                            }
                        }
                    } upgradeCloseBlock:^{
                        if (finishBlock) {
                            finishBlock(NO);
                        }
                    }];
                    return;
                }
            }
        }
        if (finishBlock) {
            finishBlock(YES);
        }
        
    } failure:^(NSError *error) {
        [AccountManager sharedManager].hasCheckAppStoreVersion = YES;
        if (finishBlock) {
            finishBlock(YES);
        }
    }];
}

/**
 * 请求换肤
 */
+ (void)requestZFSkin {
    
    // 推送通知打开 延迟请求处理
    BOOL isLaunchRemoteNotif = [YWLocalHostManager stateLaunchOptionsRemoteOpenApp];
    
    CGFloat afterTime = isLaunchRemoteNotif ? [self randomSecondsForMaxMillisecond:1000] + 3 : [self randomSecondsForMaxMillisecond:800];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(afterTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 首页假导航, 底部tabbar, 子页面导航 换肤
        [ZFSkinViewModel requestSkinData:^(ZFSkinModel *skinModel){
            YWLog(@"====回调主页换肤请求====%@", skinModel);
            [AccountManager sharedManager].currentHomeSkinModel = skinModel;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // 处理子页面换肤
                [self dealwithSubNavChangrSkin];
                
                // 请求成功,发通知换肤
                ZFPostNotification(kChangeSkinNotification, nil);
            });
        }];
    });
}

/**
 * 通知各子页面导航栏换肤
 */
+ (void)dealwithSubNavChangrSkin {
    ZFSkinModel *homeSkinModel = [AccountManager sharedManager].currentHomeSkinModel;
    if (!homeSkinModel) return;
    
    UIColor *navBgColor = ZFCOLOR_WHITE;
    UIColor *navIconColor = ZFCOLOR(51, 51, 51, 1.0);
    UIColor *navFontColor = ZFCOLOR(51, 51, 51, 1.0);
    UIImage *appNavBgImage = nil;
    UIImage *appAccountHeadImage = nil;
    BOOL shouldChangeSkin = NO;
    
    NSString *navColorStr = homeSkinModel.navColor;
    if (!ZFIsEmptyString(navColorStr)) {
        UIColor *changeNavBgColor = [UIColor colorWithHexString:navColorStr];
        if ([changeNavBgColor isKindOfClass:[UIColor class]]) {
            navBgColor = changeNavBgColor;
            shouldChangeSkin = YES;
        }
    }
    
    NSString *navFontColorStr = homeSkinModel.navFontColor;
    if (!ZFIsEmptyString(navFontColorStr)) {
        UIColor *changeNavFontColor = [UIColor colorWithHexString:navFontColorStr];
        if ([changeNavFontColor isKindOfClass:[UIColor class]]) {
            navFontColor = changeNavFontColor;
        }
    }
    
    NSString *navIconColorStr = homeSkinModel.navIconColor;
    if (!ZFIsEmptyString(navIconColorStr)) {
        UIColor *changeNavIconColor = [UIColor colorWithHexString:navIconColorStr];
        if ([changeNavIconColor isKindOfClass:[UIColor class]]) {
            navIconColor = changeNavIconColor;
        }
    }
    
    UIImage *subNavigationBgImage = [ZFSkinViewModel subNavigationBgImage];
    if ([subNavigationBgImage isKindOfClass:[UIImage class]]) {
        appNavBgImage = subNavigationBgImage;
    }
    
    UIImage *accountHeadImage = [ZFSkinViewModel accountHeadImage];
    if ([accountHeadImage isKindOfClass:[UIImage class]]) {
        appAccountHeadImage = accountHeadImage;
    }
    
    // 覆盖颜色值
    [AccountManager sharedManager].needChangeAppSkin = shouldChangeSkin;
    [AccountManager sharedManager].appNavBgColor = navBgColor;
    [AccountManager sharedManager].appNavFontColor = navFontColor;
    [AccountManager sharedManager].appNavIconColor = navIconColor;
    [AccountManager sharedManager].appNavBgImage = appNavBgImage;
    [AccountManager sharedManager].appAccountHeadImage = appAccountHeadImage;
}

/**
 * 请求当前国家信息
 */
//+ (void)requestCountryName:(void (^)(NSDictionary *countryInfoDic))completion {
//    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
//    requestModel.url = API(Port_get_cur_country_info);
//
//    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
//        NSDictionary *resultDic = responseObject[ZFResultKey];
//        if (completion) {
//            if (ZFJudgeNSDictionary(resultDic)) {
//                completion(resultDic);
//            }
//        }
//
//        if (ZFJudgeNSDictionary(resultDic)) {
//            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
//            NSString *country = [resultDic ds_stringForKey:@"country"];
//            [user setObject:country forKey:kCountryName];
//            [user synchronize];
//        }
//    } failure:^(NSError *error) {
//        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
//        [user setObject:@"United States" forKey:kCountryName];
//        [user synchronize];
//    }];
//}

/**
 * 请求搜索关键词
 */
+ (void)requestHotSearchKeyword:(NSString *)catId completion:(void (^)(NSArray *array))completion {
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.url = API(Port_recommendSearch);
    requestModel.parmaters = @{@"catId" : ZFToString(catId)};
    
    // 推送通知打开 延迟请求处理
    BOOL isLaunchRemoteNotif = [YWLocalHostManager stateLaunchOptionsRemoteOpenApp];
    
    CGFloat afterTime = isLaunchRemoteNotif ? [self randomSecondsForMaxMillisecond:1000] + 3 : [self randomSecondsForMaxMillisecond:800];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(afterTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
            id result = responseObject[ZFResultKey];
            if (completion) {
                if (ZFJudgeNSArray(result)) {
                    completion(result);
                }
            }
        } failure:nil];
    });
    
}

/**
 * 保存FCM推送的信息到leancloud
 */
+(void)saveFCMUserInfo:(NSString *)paid_order_number
             pushPower:(BOOL)pushPower
              fcmToken:(NSString *)fcmToken
{
    //语言应该传简码,国家应该传全称
    NSDictionary *params = @{@"apnsTopic"       : @"ZZZZZ",
                             @"orderCount"      : ZFToString(paid_order_number),
                             @"appsFlyerid"     : ZFToString([[AppsFlyerTracker sharedTracker] getAppsFlyerUID]),
                             @"deviceId"        : ZFToString([AccountManager sharedManager].device_id),
                             @"deviceType"      : @"iOS",
                             @"country"     : ZFToString([AccountManager sharedManager].accountCountryModel.region_name),
                             @"fcmtoken"        : ZFToString(fcmToken),
                             @"language"        : ZFToString([[ZFLocalizationString shareLocalizable] currentLanguageMR]),
                             @"userid"          : ZFToString([[AccountManager sharedManager] userId]),
                             @"timestamp"       : [NSStringUtils getCurrentTimestamp],
                             @"ip"              : @"",
                             @"promotions"      : @"YES",
                             @"orderMessages"   : @"YES",
                             @"pushPower"       : @(pushPower),
                             @"deviceName"      : ZFToString([[ZFDeviceInfoManager sharedManager] getDeviceType]),
                             @"osVersion"       : ZFToString([[ZFDeviceInfoManager sharedManager] getDeviceVersion]),
                             @"deviceToken"     : ZFToString([AccountManager sharedManager].appDeviceToken)
                             };
    
    NSString *paramsJson = [params yy_modelToJSONString];
    NSString *md5String = [YWLocalHostManager leancloudUrlMd5Key];
    NSString *md5AppName = [NSStringUtils ZFNSStringMD5:[NSString stringWithFormat:@"%@ZZZZZ", md5String]];
    NSString *paramsMd5Json = [md5AppName stringByAppendingString:paramsJson];
    NSString *apiToken = [NSStringUtils ZFNSStringMD5:paramsMd5Json];
    
    ZFRequestModel *model = [[ZFRequestModel alloc] init];
    model.url = [YWLocalHostManager fCMTokenUserInfoUrl];
    model.forbidEncrypt = YES; //走原生AF请求不加密
    model.timeOut = 30;//默认请求超时时间30秒
    model.parmaters = @{@"apiToken" : ZFToString(apiToken),
                        @"data" : paramsJson };
    
    [ZFNetworkHttpRequest sendRequestWithParmaters:model success:^(id responseObject) {
        YWLog(@"保存FCM推送的信息到leancloud成功===%@===\n%@", responseObject, params);
        
    } failure:^(NSError *error) {
        YWLog(@"保存FCM推送的信息到leancloud失败===%@===\n%@", error, params);
    }];
}

/**
 * 同步点击远程推送的信息给服务端
 */
+(void)syncClickRemotePushWithPid:(NSString *)pid
                          cString:(NSString *)cString
                           pushId:(NSString *)pushId
{
    NSMutableDictionary *infoDict = [NSMutableDictionary dictionary];
    infoDict[@"apnsTopic"] = @"ZZZZZ";//站点名称, 如:ZZZZZ
    infoDict[@"mediaSource"] = ZFToString(pid);//渠道参数, (取pid的值)
    infoDict[@"campagin"] = ZFToString(cString);//活动参数, (取c的值)
    infoDict[@"pushId"] = ZFToString(pushId); //推送ID, (取push_id的值)
    infoDict[@"deviceType"] = @"ios";//设备类型, android 或 ios, 使用小写字母
    infoDict[@"deviceId"] = ZFToString([AccountManager sharedManager].device_id);//设备ID
    infoDict[@"userId"] = ZFIsEmptyString(USERID) ? @"0" : USERID;//用户ID,没有登录则传0
    infoDict[@"receiverTime"] = [NSStringUtils getCurrentTimestamp];//APP接收到消息的时间(无法获取推送的时间)
    infoDict[@"clickTime"] = [NSStringUtils getCurrentTimestamp];//用户点击消息时间(0时区时间戳)
    infoDict[@"appVersion"] = ZFSYSTEM_VERSION;//APP版本号,如:3.8.1
    //用户语言,简码如:en, fr, es
    infoDict[@"language"] = ZFToString([[ZFLocalizationString shareLocalizable] currentLanguageMR]);
    //用户国家, 供后期每个接口运营配置数据
    ZFAddressCountryModel *accountModel = [AccountManager sharedManager].accountCountryModel;
    infoDict[@"country"] = ZFIsEmptyString(accountModel.region_name) ? @"United States" : ZFToString(accountModel.region_name);
    //系统时区
    infoDict[@"Location"] = [[NSTimeZone systemTimeZone] name];
    
    infoDict[@"deviceName"] = ZFToString([[ZFDeviceInfoManager sharedManager] getDeviceType]);
    infoDict[@"osVersion"] = ZFToString([[ZFDeviceInfoManager sharedManager] getDeviceVersion]);
    infoDict[@"appsFlyerid"] = ZFToString([[AppsFlyerTracker sharedTracker] getAppsFlyerUID]);
    
    NSString *md5String = [YWLocalHostManager leancloudUrlMd5Key];
    NSString *md5AppName = [NSStringUtils ZFNSStringMD5:[NSString stringWithFormat:@"%@ZZZZZ", md5String]];
    NSString *paramsJson = [md5AppName stringByAppendingString:[infoDict yy_modelToJSONString]];
    NSString *apiToken = [NSStringUtils ZFNSStringMD5:paramsJson];
    
    //apiToken :通信token(必填), 加密方式:  md5( md5( 接口秘钥 + 站点名称 ) + data )
    NSDictionary *requestParams = @{@"apiToken" : ZFToString(apiToken),
                                    @"data" : [infoDict yy_modelToJSONString]};
    
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.forbidEncrypt = YES;//禁止加密时底层不做任何处理,走AFNetwork原生请求
    requestModel.tryAgainTimesWhenFailure = 5;
    requestModel.url = [YWLocalHostManager syncPushClickDataUrl];
    requestModel.parmaters = requestParams;
    
    [ZFNetworkHttpRequest sendExtensionRequestWithParmaters:requestModel success:^(id responseObject) {
        YWLog(@"点击远程推送同步信息给服务端成功===%@", responseObject);
    } failure:^(NSError *error) {
        YWLog(@"点击远程推送同步信息给服务端失败===%@", error);
    }];
}


+ (void)firstOpenPOSTGoogleApi {
    BOOL isfirstOpen = [[NSUserDefaults standardUserDefaults] boolForKey:@"ZF_Google_FirstOpen"];
    if (isfirstOpen) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ZF_Google_FirstOpen"];
    NSString *osAndVersion = [[UIDevice currentDevice] systemVersion];
    NSString *currentTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppLaunchingTime"];
    BOOL advertisingTrackingEnabled = [[ZFDeviceInfoManager sharedManager] getAdvertisingTrackingEnabled];
    NSString *appVersion = ZFSYSTEM_VERSION;
    
    NSDictionary *params = @{
                             @"dev_token"       : @"NnMVzDiA6iLTwHltjAUbSw",
                             @"link_id"         : @"7832D6C1E1BBA3A6C42688C758BB770E",
                             @"app_event_type"  : @"first_open",
                             @"rdid"            : ZFToString([[ZFDeviceInfoManager sharedManager] getIDFA]),
                             @"id_type"         : @"idfa",
                             @"lat"             : @(advertisingTrackingEnabled),
                             @"os_version"      : ZFToString(osAndVersion),
                             @"app_version"     : ZFToString(appVersion),
                             @"sdk_version"     : ZFToString(appVersion),
                             @"timestamp"       : ZFToString(currentTime)
                             };
    
    NSMutableString *url = [@"https://www.googleadservices.com/pagead/conversion/app/1.0" mutableCopy];
    static BOOL first = YES;
    [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (first) {
            first = NO;
            [url appendFormat:@"?%@=%@", key, obj];
        }else{
            [url appendFormat:@"&%@=%@", key, obj];
        }
    }];
    
    /*  {
     "ad_events": [{
     "ad_event_id": "Q2owS0VRancwZHk0QlJDdXVMX2U1TQ",
     "conversion_metric": "conversion",
     "interaction_type": null,
     "campaign_type": "UAC",
     "campaign_id": 123456789,
     "campaign_name": "My App Campaign",
     "ad_type": "ClickToDownload",
     "external_customer_id": 123456789,
     "location": 21144,
     "network_type": "Search",
     "network_subtype": "GoogleSearch",
     "video_id": null,
     "keyword": null,
     "match_type": null,
     "placement": null,
     "ad_group_id": null,
     "creative_id": null,
     "timestamp": 1432681913.123456
     }],
     "errors": [],
     "attributed": true
     }*/
    ZFRequestModel *model = [[ZFRequestModel alloc] init];
    model.timeOut = 30;
    model.forbidEncrypt = YES;
    model.requestHttpHeaderField = @{ @"Content-Length" : @"0"};
    model.url = url;
    
    [ZFNetworkHttpRequest sendRequestWithParmaters:model success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            BOOL resultStatus = [responseObject[@"attributed"] boolValue];
            if (resultStatus) {
                NSArray *events = responseObject[@"ad_events"];
                NSDictionary *event = events.firstObject;
                NSString *campaign_id = [NSString stringWithFormat:@"%@", event[@"campaign_id"]];
                if (!ZFIsEmptyString(campaign_id)) {
                    [self requestDeeplinkWithGoogleCampaignId:campaign_id];
                }
            }
        }
    } failure:^(NSError *error) {
        YWLog(@"google first open error ===%@", error);
    }];
}

+ (void)requestDeeplinkWithGoogleCampaignId:(NSString *)campaignId
{
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.url = API(@"selection/get_deferred_deeplink");
    requestModel.parmaters = @{
                               //1707074618
                               /*
                                1727218013
                                1727218034
                                1727218682
                                1727219027
                                1727573452
                                1727573881
                                1727574145
                                1728317886
                                1727231204
                                1727312543
                                1728410382
                                1728410547
                                1728410634
                                1728410340
                                1728410796
                                1728415386
                                1727675455
                                */
                               @"campaign_id" : ZFToString(campaignId)
                               };
    
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *result = responseObject[ZFResultKey];
            if ([result isKindOfClass:[NSDictionary class]]) {
                NSString *deeplink = result[@"deeplink"];
                if (ZFIsEmptyString(deeplink)) return ;
                UIViewController *currentViewController = [UIViewController currentTopViewController];
                if ([NSStringFromClass(currentViewController.class) isEqualToString:@"ZFHomeCMSViewController"] ||
                    [NSStringFromClass(currentViewController.class) isEqualToString:@"ZFHomePageViewController"]) {
                    NSDictionary *deepParams = [[BannerManager parseDeeplinkParamDicWithURL:[NSURL URLWithString:ZFToString(deeplink)]] copy];
                    [BannerManager jumpDeeplinkTarget:[UIViewController currentTopViewController] deeplinkParam:deepParams];
                }
            }
        }
    } failure:^(NSError *error) {
        YWLog(@"%@", error);
    }];
}

/**
 * 请求 主页提示有未支付订单接口
 */
+ (void)requestHasNoPayOrderTodo:(void (^)(MyOrdersModel *orderModel))completion
                       failBlcok:(void(^)(NSError *error))failBlcok
                          target:(id)target {
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.url = API(Port_order_index_prompt);
    requestModel.parmaters = @{@"token": ZFToString(TOKEN) };
    requestModel.taget = target;
    requestModel.eventName = @"no_pay_orders";
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        NSDictionary *resultDic = responseObject[ZFResultKey];
        if (completion && ZFJudgeNSDictionary(resultDic)) {
            MyOrdersModel *orderModel = [MyOrdersModel yy_modelWithJSON:resultDic];
            completion(orderModel);
        } else {
            if (completion) {
                completion(nil);
            }
        }
    } failure:^(NSError *error) {
        if (failBlcok) {
            failBlcok(error);
        }
    }];
}

/**
 * 展示未支付订单提示弹框
 * 需求: 72小时以内每笔订单每天只弹一次
 */
+ (void)requestUnpaidOrderDate {
    if (!ISLOGIN) return;
    [AccountManager sharedManager].hasRequestUnpaidOrderAlertUrl = YES;
    
    // 推送通知打开 延迟请求处理
    BOOL isLaunchRemoteNotif = [YWLocalHostManager stateLaunchOptionsRemoteOpenApp];
    
    CGFloat afterTime = isLaunchRemoteNotif ? [self randomSecondsForMaxMillisecond:1000] + 3: [self randomSecondsForMaxMillisecond:600];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(afterTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [ZFCommonRequestManager requestHasNoPayOrderTodo:^(MyOrdersModel *orderModel) {
            if (![orderModel isKindOfClass:[MyOrdersModel class]]) return ;
            [self showUnpaidOrderViewToHomeVC:orderModel];
            
        } failBlcok:nil target:[ZFHomePageViewController new]];
    });
}

/**
 * 在主页上展示未支付订单提示弹框
 */
+ (void)showUnpaidOrderViewToHomeVC:(MyOrdersModel *)orderModel {
    
    // 此弹框只能在主页的控制器上弹出
    if (![AppDelegate judgeCurrentIsHomeNavVC]) {
        APPDELEGATE.unpaidOrderModel = orderModel;
        return;
    }
    APPDELEGATE.unpaidOrderModel = nil;
    
    NSString *unpaidOrderIdKey = [NSString stringWithFormat:@"%@-%@", kAlertUnpaidViewUserDefaultKey, orderModel.order_id];
    NSDictionary *showDict = GetUserDefault(unpaidOrderIdKey);
    NSString *today = [NSDate todayDateString];
    NSString *nowDate = [NSDate nowDate];
    
    // 相同订单的显示条件
    if (ZFJudgeNSDictionary(showDict)) {
        // 每天只弹出一次
        NSString *hasShowDate = showDict[kHasShowUnpaidViewDateKey];
        if ([hasShowDate isEqualToString:today]) {
            return;
        }
        
        // 时间差大于72小时就不显示弹框
        NSString *statrTime = showDict[kHasShowUnpaidViewTimeKey];
        NSTimeInterval timeInterval = [NSDate calculateTimeIntervalStarTime:statrTime endTime:nowDate];
        if (timeInterval > 3600 * 24 * 3) {
            return;
        }
        
        // 记录弹出未支付订单视图的时间
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:showDict];
        dict[kHasShowUnpaidViewDateKey] = ZFToString(today);
        SaveUserDefault(unpaidOrderIdKey, dict);
        
        /// 在主页上展示未支付订单提示弹框、必须是二次相同订单才弹
        
        [ZFUnpaidOrderAlertView showUnpaidOrderAlertView:orderModel unpaidOrderAlertBlock:^(ZFUnpaidOrderAlertViewActionType actionType) {
            if (actionType == ZFCarHeaderAction_GoOrderDetail) {
                [self gotoOrderDetail:orderModel orderReloadBlock:nil];
                
            } else if (actionType == ZFCarHeaderAction_PayButton) {
                [self gotoPayOrderInfo:orderModel];
            }
        }];
        
    } else {
        // 记录获取未支付订单数据的时间
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[kHasShowUnpaidViewTimeKey] = ZFToString(nowDate);
        SaveUserDefault(unpaidOrderIdKey, dict);
    }

}

/**
 *  获取登录用户的oxxo和bolote的支付成功订单并补齐统计
 */
+ (void)requestUserOfflinePaySuccessOrder
{
    BOOL isLogin = [[AccountManager sharedManager] isSignIn];
    if (isLogin) {
        ZFRequestModel *model = [[ZFRequestModel alloc] init];
        model.url = API(@"order/get_offline_order");
        model.isCacheData = NO;
        [ZFNetworkHttpRequest sendRequestWithParmaters:model success:^(id responseObject) {
            NSArray *orderList = [NSArray yy_modelArrayWithClass:[MyOrdersModel class] json:responseObject[@"result"][@"order"]];
            for (int i = 0; i < orderList.count; i++) {
                MyOrdersModel *orderModel = orderList[i];
                [self analyticsOffline:orderModel];
            }
        } failure:^(NSError *error) {
            
        }];
    }
}

+ (void)savePlaceOrderUnpaidMark:(NSString *)orderId {
    
    if (!ZFIsEmptyString(orderId)) {
        NSString *unpaidOrderIdKey = [NSString stringWithFormat:@"%@-%@", kAlertUnpaidViewUserDefaultKey, orderId];
        NSString *nowDate = [NSDate nowDate];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[kHasShowUnpaidViewTimeKey] = ZFToString(nowDate);
        SaveUserDefault(unpaidOrderIdKey, dict);
    }
}

/**
 * 查看订单详情
 */
+ (void)gotoOrderDetail:(MyOrdersModel *)orderModel orderReloadBlock:(void (^)(void))orderReloadBlock {
    UIViewController *homeVC = [UIViewController currentTopViewController];
    if (homeVC) {
        ZFOrderDetailViewController *detailVC = [[ZFOrderDetailViewController alloc] init];
        detailVC.orderId = orderModel.order_id;
        detailVC.contactLinkUrl = orderModel.contact_us;
        detailVC.orderDetailReloadListInfoCompletionHandler = ^(OrderDetailOrderModel *statusModel) {
            if (orderReloadBlock) {
                orderReloadBlock();
            }
        };
        [homeVC.navigationController pushViewController:detailVC animated:YES];
    }
}

/**
* 去支付
*/
+ (void)dealWithGotoPayWithOrderModel:(MyOrdersModel *)orderModel {
    UIViewController *tempVC = (ZFHomePageViewController *)[UIViewController currentTopViewController];
    
    // v4.1.0 接入原生支付SDK,需要先请求后台接口获取token
    ZFOrderPayTools *paytools = [ZFOrderPayTools paytools];
    paytools.channel = PayChannel_Default;
    paytools.payUrl = orderModel.pay_url;
    paytools.orderId = orderModel.order_id;
    paytools.parentViewController = tempVC;
    
    // 给tempVC对象关联一个key,防止paytools的Block释放, 一定记得释放
    NSString *associatedKey = @"kZFOrderPayTools";
    
    @weakify(self)
    paytools.paySuccessCompletionHandle = ^(ZFOrderPayResultModel * _Nonnull orderPayResultMoedl){
        ///SOA 支付成功
        @strongify(self)
        ZFOrderSuccessViewController *finischVC = [[ZFOrderSuccessViewController alloc] init];
        finischVC.orderPayResultModel = orderPayResultMoedl;
        //拿出最终的支付方式
        orderModel.realPayment = orderPayResultMoedl.payChannelCode;
        finischVC.fromType = ZFOrderPayResultSource_Other;
        finischVC.baseOrderModel = orderModel;
        finischVC.toAccountOrHomeblock = ^(BOOL gotoOrderList){
            @weakify(tempVC)
            [tempVC dismissViewControllerAnimated:NO completion:^{
                @strongify(tempVC)
                if (gotoOrderList) {
                    //跳转订单详情
                    [self jumpToOrderDetail:orderModel];
                }else{
                    [tempVC.navigationController popToRootViewControllerAnimated:NO];
                    ZFTabBarController *tabBarVC = APPDELEGATE.tabBarVC;
                    [tabBarVC setZFTabBarIndex:TabBarIndexHome];
                }
            }];
        };
        ZFNavigationController *nav = [[ZFNavigationController alloc] initWithRootViewController:finischVC];
        [tempVC presentViewController:nav animated:YES completion:nil];
        objc_setAssociatedObject(tempVC, [associatedKey cStringUsingEncoding:NSASCIIStringEncoding], nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    };
    
    paytools.payFailureCompletionHandle = ^{
        ZFOrderFailureViewController *failureVC = [[ZFOrderFailureViewController alloc] init];
        failureVC.orderFailureBlock = ^{
            [tempVC dismissViewControllerAnimated:NO completion:^{
                [self jumpToOrderDetail:orderModel];
            }];
        };
        [tempVC presentViewController:failureVC animated:YES completion:nil];
        objc_setAssociatedObject(tempVC, [associatedKey cStringUsingEncoding:NSASCIIStringEncoding], nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    };
    
    paytools.payCancelCompolementHandle = ^{
        [tempVC.navigationController popViewControllerAnimated:YES];
        objc_setAssociatedObject(tempVC, [associatedKey cStringUsingEncoding:NSASCIIStringEncoding], nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    };
    
    paytools.paymentSurveyHandle = ^{
        ZFOrderQuestionViewController *questionVC = [[ZFOrderQuestionViewController alloc] init];
        questionVC.ordersn = orderModel.order_sn;
        questionVC.orderId = orderModel.order_id;
        questionVC.fd_interactivePopDisabled = NO;
        questionVC.didClickGoShoppingHandle = ^{
            //继续购物
            [tempVC.navigationController popToRootViewControllerAnimated:NO];
            ZFTabBarController *tabBarVC = APPDELEGATE.tabBarVC;
            [tabBarVC setZFTabBarIndex:TabBarIndexHome];
        };
        questionVC.didClickbackToOrdersBlockHandle = ^{
            //跳转订单详情
            [self jumpToOrderDetail:orderModel];
        };
        [tempVC.navigationController pushViewController:questionVC animated:YES];
    };
    
    [paytools startPay];
    objc_setAssociatedObject(tempVC, [associatedKey cStringUsingEncoding:NSASCIIStringEncoding], paytools, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

/**
 * 首页未支付订单弹框点击 -> 去支付
 */
+ (void)gotoPayOrderInfo:(MyOrdersModel *)orderModel {
    
    [self dealWithGotoPayWithOrderModel:orderModel];
    
    // appflyer统计
    NSDictionary *appsflyerParams = @{
                                      @"af_content_type"    : @"Home_Alert_btn",
                                      @"af_reciept_id"      : orderModel.order_sn,
                                      @"af_country_code"    : ZFToString([AccountManager sharedManager].accountCountryModel.region_code)
                                      };    
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_unpaid_Alert_btn_click" withValues:appsflyerParams];
}

+ (void)jumpToOrderDetail:(MyOrdersModel *)orderModel
{
    //跳转订单详情
    UIViewController *tempVC = (ZFHomePageViewController *)[UIViewController currentTopViewController];
    ZFTabBarController *tabbar = (ZFTabBarController *)tempVC.tabBarController;
    [tabbar setZFTabBarIndex:TabBarIndexAccount];
    ZFNavigationController *nav = [tabbar navigationControllerWithMoudle:TabBarIndexAccount];
    if (nav) {
        if (nav.viewControllers.count>1) {
            [nav popToRootViewControllerAnimated:NO];
        }
        ZFMyOrderListViewController *orderListVC = [[ZFMyOrderListViewController alloc] init];
        //取消、失败需要传入订单ID到后面支付这个订单时，是否弹窗远程通知视图
        [nav pushViewController:orderListVC animated:NO];
        ZFOrderDetailViewController *orderDetailVC = [[ZFOrderDetailViewController alloc] init];
        orderDetailVC.orderId = orderModel.order_id;
        [orderListVC.navigationController pushViewController:orderDetailVC animated:YES];
    }
}

///线下支付获取支付成功订单补全统计
+ (void)analyticsOffline:(MyOrdersModel *)orderModel
{
    //赋值真实支付方式
    orderModel.realPayment = orderModel.pay_id;
    orderModel.hacker_point.order_pay_way = orderModel.pay_id;
    /*谷歌统计*/
    [ZFAnalytics settleAccountProcedureWithProduct:orderModel.goods step:3 option:nil screenName:@"PaySuccess"];
    [ZFAnalytics trasactionAccountWithProduct:orderModel screenName:@"PaySuccess"];
    
    __block NSString *goodsStr = @"";
    __block NSString *goodsPriceStr = @"";
    __block NSString *goodsNumStr = @"";
    
    NSMutableArray <BranchUniversalObject *>*goodsArray = [NSMutableArray array];
    NSMutableArray *bigDataParamsList = [NSMutableArray array];
    [orderModel.goods enumerateObjectsUsingBlock:^(MyOrderGoodListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        goodsStr = [NSString stringWithFormat:@"%@%@,", goodsStr, obj.goods_sn];
        goodsPriceStr = [NSString stringWithFormat:@"%@%@,", goodsPriceStr, obj.goods_price];
        goodsNumStr = [NSString stringWithFormat:@"%@%@,", goodsNumStr, obj.goods_number];
        
        // Create a BranchUniversalObject with your content data:
        BranchUniversalObject *branchUniversalObject = [BranchUniversalObject new];
        branchUniversalObject.contentMetadata.contentSchema    = BranchContentSchemaCommerceProduct;
        branchUniversalObject.contentMetadata.quantity         = obj.goods_number.doubleValue;
        if (!ZFIsEmptyString(obj.goods_price)) {
            branchUniversalObject.contentMetadata.price            = [NSDecimalNumber decimalNumberWithString:ZFToString(obj.goods_price)];
        }
        branchUniversalObject.contentMetadata.currency         = BNCCurrencyUSD;
        branchUniversalObject.contentMetadata.sku              = ZFToString(obj.goods_sn);
        branchUniversalObject.contentMetadata.productName      = ZFToString(obj.goods_title);
        branchUniversalObject.contentMetadata.productBrand     = ZFToString(obj.goods_brand);
        [goodsArray addObject:branchUniversalObject];
        
        NSDictionary *params = [obj gainAnalyticsParams];
        [bigDataParamsList addObject:params];
    }];
    goodsStr = [goodsStr substringToIndex:goodsStr.length-1];
    goodsPriceStr = [goodsPriceStr substringToIndex:goodsPriceStr.length-1];
    goodsNumStr = [goodsNumStr substringToIndex:goodsNumStr.length-1];
    
    //branch统计
    [[ZFBranchAnalytics sharedManager] branchAnalyticsOrderModel:orderModel goodsList:goodsArray];
    
    //付款订单统计量
    [ZFAnalytics appsFlyerTrackFinishGoodsIds:goodsStr
                                  goodsPrices:goodsPriceStr
                                    quantitys:goodsNumStr
                                      orderSn:orderModel.order_sn
                                 orderPayMent:orderModel.hacker_point.order_pay_way
                                 orderRealPay:orderModel.hacker_point.order_real_pay_amount
                                      payment:orderModel.pay_id
                                     btsModel:nil
                                bigDataParams:bigDataParamsList];
    
    
    //Firebase
    [ZFFireBaseAnalytics finishedPurchaseWithOrderModel:orderModel];
    //growingIO统计
    [ZFGrowingIOAnalytics ZFGrowingIOPayOrderSuccessWithBaseOrderModel:orderModel paySource:@"OrderDetail"];
}

/** 商品图片AB样式展示
 *  A版本：原始版本
 *  B版本：商品首图片替换显示博主图
 *  C版本：商品所有图片替换为博主图
 */
+ (void)requestProductPhotoBts:(void (^)(ZFBTSModel *))completionHandler {
    [ZFBTSManager asynGetBtsModel:kZFBtsProductPhoto
                    defaultPolicy:kZFBts_A
                  timeoutInterval:3
                completionHandler:^(ZFBTSModel * _Nonnull model, NSError * _Nonnull error) {
                    if (completionHandler) {
                        completionHandler(model);
                    }
                }];
}

@end
