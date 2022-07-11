//
//  OSSVCommonnRequestsManager.m
// XStarlinkProject
//
//  Created by odd on 2020/7/15.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVCommonnRequestsManager.h"
#import "OSSVLocaslHosstManager.h"
#import "OSSVAccountsManager.h"
#import "CountryModel.h"
#import "OSSVSaveFCMsTokenAip.h"
#import "OSSVChecksPushsAip.h"
#import "OSSVGetAppCopywritAip.h"
#import "OSSVwebsitesConfigsAip.h"
//#import <AppsFlyerLib/AppsFlyerTracker.h>
//#import <AppsFlyerLib/AppsFlyerLib.h>
#import "AppDelegate+STLCategory.h"
#import "OSSVJSONRequestsSerializer.h"
#import "STLSysInitModel.h"
#import "STLWebsitesGroupManager.h"
#import "Adorawe-Swift.h"

@implementation OSSVCommonnRequestsManager


+ (void)initialize {
    
    // 关闭网络库打印接口响应日志
    [OSSVRequestsConfigs sharedInstance].closeUrlResponsePrintfLog = NO;
    
    // 默认不上传接口响应日志
    NSString *localCatchKey = [OSSVConfigDomainsManager localCatchLogTagKey];
    [OSSVRequestsConfigs sharedInstance].uploadResponseJsonToLogSystem = [STLToString(localCatchKey) isEqualToString:STLOpenLogSystemTag] ? NO : YES;
}

+ (CGFloat)randomSecondsForMaxMillisecond:(NSInteger)maxMillisecond {
    if (maxMillisecond <= 0) {
        return 0;
    }
    return arc4random() % maxMillisecond / 1000.0;
}


+ (void)requestNecessaryData {
    
    @weakify(self)
    CGFloat afterTime = [self randomSecondsForMaxMillisecond:600];
    
//    [self requestExchangeData:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(afterTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self)
        // 请求基础信息接口
        if ([STLWebsitesGroupManager hasWebsitesData]) {
            [self checkUpadeApp:nil reuqestState:nil];
        }
        
        ///1.3.8 去掉启动app请求登录相关数据
//        if ([OSSVAccountsManager sharedManager].isSignIn) {
//            [self checkUpdateUserInfo:nil];
//        }
    });
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        @strongify(self)
//
//        //本地取消缓存了，
//        if ([OSSVAccountsManager sharedManager].countryList.count <= 0) {
//            [self supportGountryList:nil];
//        }
//    });

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self)
     //App获取文案
        [self getAppCopywriting];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [InitIconApi getAppIconInfo];
    });

}


+ (void)asyncRequestOtherApi {
    
    //下载并更新后台配置的tabbar icon
    //[[STLTabbarManager sharedInstance] setUp];
    
    //在登录注册调用
//    [self requestCountryCheck:nil];
    
    [self requestLaunchAdvData:nil];

}

/**
 * 请求汇率接口
 */
//+ (void)requestExchangeData:(void(^)(BOOL success))completeHandler {
//
//    //初始接口返回了，这个不需要了 one站功能
//    if (completeHandler) {
//        completeHandler(YES);
//    }
//    return;
//    [[STLNetworkStateManager sharedManager] networkState:^{
//
//           ExchangeApi *exchangeApi = [[ExchangeApi alloc] init];
//
//           [exchangeApi startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
//               id requestJSON = [OSSVNSStringTool desEncrypt:request];
//
//               if ([requestJSON[kStatusCode] integerValue] == kStatusCode_200) {
//                   NSArray *array = [NSArray yy_modelArrayWithClass:[RateModel class] json:requestJSON[kResult]];
//                   [ExchangeManager saveLocalExchange:array];
//                   NSUserDefaults *versionDefaults = [NSUserDefaults standardUserDefaults];
//
//                   if ([versionDefaults boolForKey:kIsSettingCurrentKey]) {
//                       ///如果手动设置过货币,更新最新的
//                       RateModel *currentRateModel = [ExchangeManager localCurrency];
//                       [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//
//                           RateModel *model = obj;
//                           if ([model.code isEqualToString:currentRateModel.code]) {
//                               [ExchangeManager updateLocalCurrencyWithRteModel:model];
//                               *stop = YES;
//                           }
//                       }];
//                   }
//               }
//
//               if (completeHandler) {
//                   completeHandler(YES);
//               }
//
//           } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
//               if (completeHandler) {
//                   completeHandler(NO);
//               }
//           }];
//    } exception:^{
//
//    }];
//}

//v1.4.0 occ注释国家请求
//+ (void)supportGountryList:(void(^)(BOOL success))completeHandler {
    
//    [[STLNetworkStateManager sharedManager] networkState:^{
//
//           CountryApi *countryApi = [[CountryApi alloc] initWithDict:@{}];
//
//           [countryApi startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
//               id requestJSON = [OSSVNSStringTool desEncrypt:request];
//               if ([requestJSON[kStatusCode] integerValue] == kStatusCode_200) {
//                   NSArray *array = [NSArray yy_modelArrayWithClass:[CountryListModel class] json:requestJSON[kResult]];
//                   [OSSVAccountsManager sharedManager].countryList = array;
//                }
//           } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
//
//           }];
//    } exception:^{
//
//    }];
//}
/**
 * 检查App版本更新
 */
+ (void)checkUpadeApp:(void(^)(BOOL hasNoNewVersion))finishBlock reuqestState:(void(^)(BOOL requestState))requestStateBlock {
    
    [[STLNetworkStateManager sharedManager] networkState:^{
        
        OSSVItuneAppAip *api = [[OSSVItuneAppAip alloc] init];

        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            [[OSSVAdvsViewsManager sharedManager] updateAppState:requestJSON];
            if (requestStateBlock) {
                requestStateBlock(YES);
            };
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            if (requestStateBlock) {
                requestStateBlock(false);
            };
        }];
    } exception:^{
        if (requestStateBlock) {
            requestStateBlock(false);
        };
    }];
}

#pragma mark --APP获取文案
+ (void)getAppCopywriting {
    
    [[STLNetworkStateManager sharedManager] networkState:^{
        OSSVGetAppCopywritAip *api = [[OSSVGetAppCopywritAip alloc] init];
        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            NSString *reg_page_text = @"";
            NSString *user_page_text = @"";
            NSString *taxText = @"";  //税务文案
            NSString *token = @"";  //税务文案

        id requestJSON = [OSSVNSStringTool desEncrypt:request];
            if ([requestJSON isKindOfClass:[NSDictionary class]]) {
                if ([requestJSON[kStatusCode] integerValue] == kStatusCode_200) {
                    NSDictionary *resultDic = requestJSON[@"result"];
                    if (STLJudgeNSDictionary(resultDic)) {
                        taxText = STLToString(resultDic[@"order_tax_text"]);
                        STLUserDefaultsSet(@"tax", taxText);
                        [[NSUserDefaults standardUserDefaults] synchronize];

                        reg_page_text = STLToString(resultDic[@"reg_page_text"]);
                        user_page_text = STLToString(resultDic[@"user_page_text"]);
                        token = STLToString(resultDic[@"token"]);
                        if (![OSSVNSStringTool isEmptyString:token]) {
                            [[OSSVAccountsManager sharedManager] saveUserToken:token];
                        }
                        
                        NSDictionary *bannerDic = resultDic[@"banner"];
                        if (STLJudgeNSDictionary(bannerDic)) {
                            [OSSVAccountsManager sharedManager].homeBanner = bannerDic[@"home"];
                            [OSSVAccountsManager sharedManager].goodsDetailBanner = bannerDic[@"goods_detail"];
                            
                            NSDictionary *homeDic = bannerDic[@"home"];
                            NSDictionary *goodsDic = bannerDic[@"goods_detail"];
                            [[NSUserDefaults standardUserDefaults] setObject:homeDic[@"id"] forKey:kHomeDisplayBannerID];
                            [[NSUserDefaults standardUserDefaults] setObject:goodsDic[@"id"] forKey:kGoodsDetailDisplayBannerID];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_getHomeBottomBannerSuccess object:nil];
                        }
                    }

                }
            }
            [STLPushManager sharedInstance].tip_reg_page_text = reg_page_text;
            [STLPushManager sharedInstance].tip_user_page_text = user_page_text;

        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
        
        }];
        
    } exception:^{
        
    }];
}

+ (void)checkPushTime:(void(^)(NSString *status, NSString *content, NSString *hours))completeHandler {
    
    [[STLNetworkStateManager sharedManager] networkState:^{
        
        OSSVChecksPushsAip *api = [[OSSVChecksPushsAip alloc] init];

        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            
            NSString *status = @"0";
            NSString *content = @"";
            NSString *hours = @"";
             if ([requestJSON isKindOfClass:[NSDictionary class]]) {
                if ([requestJSON[kStatusCode] integerValue] == kStatusCode_200) {
                    
                    NSDictionary *resultDic = requestJSON[kResult];
                    if ([resultDic isKindOfClass:[NSDictionary class]]) {
                                        
                        //去掉关于 push弹窗的功能
//                        NSDictionary *dataDic = resultDic[@"index_windows"];
//                        if (STLJudgeNSDictionary(dataDic)) {
//
//                            status = dataDic[@"is_valid"];
//                            content = STLToString(dataDic[@"coneten"]);
//                            hours = STLToString(dataDic[@"check_push_time"]);
//                        }
                        
                        //初始接口返回了，这个不需要了 one站功能
                        ///货币
//                        NSDictionary *exchnage_infoDic = resultDic[@"exchnage_info"];
//                        if (STLJudgeNSDictionary(exchnage_infoDic)) {
//
//                            ///根据客户的ip地址返回 货币和汇率
//                            NSUserDefaults *versionDefaults = [NSUserDefaults standardUserDefaults];
//                            if (![versionDefaults boolForKey:kIsSettingCurrentKey]) {  // 是否手动设置过货币
//                                RateModel *rateModel = [RateModel yy_modelWithJSON:exchnage_infoDic];
//                                [ExchangeManager updateLocalCurrencyWithRteModel:rateModel];
//                            }
//                        }
                        
                        ///登录注册方式
                        NSArray *app_login_account_info = resultDic[@"app_login_account_info"];
                        if (STLJudgeNSArray(app_login_account_info)) {
                            [OSSVAccountsManager sharedManager].loginThirdList = [NSArray yy_modelArrayWithClass:[LoginThirdModel class] json:app_login_account_info];
                        }
                        
                        STLSysInitModel *sysIniModel = [STLSysInitModel yy_modelWithJSON:resultDic];
                        [OSSVAccountsManager sharedManager].sysIniModel = sysIniModel;
                    }
                }
            }
            
//            [STLPushManager sharedInstance].pushShowAlertStatus = status;
//            [STLPushManager sharedInstance].pushShowAlertContent = content;
//            [STLPushManager sharedInstance].pushShowAlertHours = hours;
            [STLPushManager sharedInstance].pushShowAlertHasRequest = YES;
            if (completeHandler) {
                completeHandler(status,content,hours);
            }

        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            
            if (completeHandler) {
                completeHandler(@"",@"",@"");
            }
        }];
    } exception:^{
        if (completeHandler) {
            completeHandler(@"",@"",@"");
        }
    }];
}

+ (void)checkUpdateUserInfo:(void(^)(BOOL success))completeHandler {
    
    [[STLNetworkStateManager sharedManager] networkState:^{
        
        UpdateUserApi *api = [[UpdateUserApi alloc] init];

        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            
            if ([requestJSON[kStatusCode] integerValue] == kStatusCode_200) {
                AccountModel *userModel = [AccountModel yy_modelWithJSON:requestJSON[kResult]];
                //更新单例数据
                if (userModel != nil) {
                    [[OSSVAccountsManager sharedManager] updateUserInfo:userModel];
                    //将上述数据全部存储到NSUserDefaults中
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    //存储时，除NSNumber类型使用对应的类型意外，其他的都是使用setObject:forKey:
                    [userDefaults setValue:userModel.email forKey:kUserEmail];
                    //这里建议同步存储到磁盘中，但是不是必须的
                    [userDefaults synchronize];
                } else {
                    [[OSSVAccountsManager sharedManager] clearUserInfo];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_ChangeAccountRedDot object:nil];
            }
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            
        }];
    } exception:^{
        
    }];
}

+ (void)onlyGetUserInfo:(void(^)(BOOL success))completeHandler {
    
    UpdateUserApi *api = [[UpdateUserApi alloc] init];

    [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
        id requestJSON = [OSSVNSStringTool desEncrypt:request];
        
        if ([requestJSON[kStatusCode] integerValue] == kStatusCode_200) {
            AccountModel *userModel = [AccountModel yy_modelWithJSON:requestJSON[kResult]];
            //更新单例数据
            if (userModel != nil && !STLIsEmptyString(userModel.userid)) {
                [OSSVAccountsManager sharedManager].account = userModel;
                if (completeHandler) {
                    completeHandler(YES);
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_ChangeAccountRedDot object:nil];

        }
    } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
        
    }];
}

+ (void)requestLaunchAdvData:(void(^)(BOOL success))completeHandler {
    
    [[STLNetworkStateManager sharedManager] networkState:^{
        
        //启动页广告
        AdvertApi *advertApi = [[AdvertApi alloc] init];
        [advertApi startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            NSDictionary *dict = [OSSVNSStringTool desEncrypt:request];
            //如果有启动页广告
            if ([dict[kStatusCode] integerValue] == kStatusCode_200) {
                
                if (dict) {
                   [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"kAdvertApiData"];
                    STLLog(@"------启动页广告 数据存储成功");
                }
                
                OSSVAdvsEventsModel *advEventModel = [OSSVAdvsEventsModel yy_modelWithJSON:dict[kResult][@"advertInfo"]];
                if (advEventModel != nil) {
                    NSString *imageUrl = [OSSVNSStringTool retinaDifferentScreenUrlFromUrl:advEventModel.imageURL];
                    advEventModel.imageURL = imageUrl;
                    
                    [AppDelegate firstDownloadImage:imageUrl];
                }
            }
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            STLLog(@"请求失败");
            
        }];
    } exception:^{
        
    }];
}

+ (void)requestCountryCheck:(void(^)(BOOL success))completeHandler {
    
    OSSVCountrysCheckAip *countryCheckAip = [[OSSVCountrysCheckAip alloc] init];
    //国家信息
    [countryCheckAip startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
        //国家信息
        NSDictionary *countryCheckDic = [OSSVNSStringTool desEncrypt:request];

        if ([countryCheckDic[kStatusCode] integerValue] == kStatusCode_200) {
            NSDictionary *resultDic = countryCheckDic[kResult];
            
            [OSSVAdvsViewsManager sharedManager].isEURequrestSuccess = YES;
            if ([resultDic[@"alert"] integerValue] == 1) {
                [OSSVAdvsViewsManager sharedManager].isEU = YES;
            }
        }
        
    } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
        
    }];
    
}


+ (void)saveFCMUserInfo:(NSString *)paid_order_number pushPower:(BOOL)pushPower fcmToken:(NSString *)fcmToken{
    
    if (STLIsEmptyString(fcmToken)) {
        return;
    }
    
    NSString *currentLang = [STLLocalizationString shareLocalizable].nomarLocalizable;
    STLWebitesCountryModel *countryModel = [STLWebsitesGroupManager sharedManager].defaultCountryModel;
    
    //语言应该传简码,国家应该传全称
    NSDictionary *params = @{@"apnsTopic"       : [[OSSVLocaslHosstManager appName] lowercaseString],
                             @"orderCount"      : STLToString(paid_order_number),
                             //@"appsFlyerid"     : STLToString([[AppsFlyerLib shared] getAppsFlyerUID]),
                             @"deviceId"        : STLToString([OSSVAccountsManager sharedManager].device_id),
                             @"deviceType"      : @"iOS",
                             @"country"         : STLToString(countryModel.country_en),
                             @"country_code"    : STLToString(countryModel.country_code),
                             @"countrySite"     : STLToString([STLWebsitesGroupManager currentCountrySiteCode]),
                             @"fcmtoken"        : STLToString(fcmToken),
                             @"language"        : STLToString(currentLang),
                             @"userid"          : USERID_STRING,
                             @"timestamp"       : [OSSVNSStringTool getCurrentTimestamp],
                             @"ip"              : @"",
                             @"promotions"      : @"YES",
                             @"orderMessages"   : @"YES",
                             @"pushPower"       : @(pushPower),
                             @"deviceName"      : STLToString([[STLDeviceInfoManager sharedManager] getDeviceType]),
                             @"osVersion"       : STLToString([[STLDeviceInfoManager sharedManager] getDeviceVersion]),
                             @"deviceToken"     : STLToString([OSSVAccountsManager sharedManager].appDeviceToken),
                             @"pushType"        : @"",
                             @"pushToken"       : @"",
                             };
    NSString *paramsJson = [params yy_modelToJSONString];
    NSString *md5String = [OSSVLocaslHosstManager leancloudUrlMd5Key];
    NSString *md5AppName = [OSSVNSStringTool stringMD5:[NSString stringWithFormat:@"%@%@", md5String,[[OSSVLocaslHosstManager appName] lowercaseString]]];
    NSString *paramsMd5Json = [md5AppName stringByAppendingString:paramsJson];
    NSString *apiToken = [OSSVNSStringTool stringMD5:paramsMd5Json];
    

    NSDictionary *requestParams =  @{@"apiToken" : STLToString(apiToken),
                                     @"data" : paramsJson };
    
    STLLog(@"-------FCM---: %@",requestParams);

//    STLSaveFCMTokenApi *countryCheckAip = [[STLSaveFCMTokenApi alloc] initWithFCMParams:requestParams];
//
//    [countryCheckAip startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
//        NSDictionary *countryCheckDic = [OSSVNSStringTool desEncrypt:request];
//
//        if ([countryCheckDic[kStatusCode] integerValue] == kStatusCode_200) {
//            STLLog(@"保存FCM推送的信息到leancloud成功===%@===\n%@", countryCheckDic, requestParams);
//
//        }
//
//    } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
//        STLLog(@"保存FCM推送的信息到leancloud失败===%@===\n%@", error, requestParams);
//
//    }];
    
    
    NSString *url = [OSSVLocaslHosstManager pushApiUrl];
    //创建配置信息
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    //设置请求超时时间：7秒
    configuration.timeoutIntervalForRequest = 15;
    //创建会话
    NSURLSession *session = [NSURLSession sessionWithConfiguration: configuration delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    //设置请求方式：POST
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"content-Type"];
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Accept"];
    
    //data的字典形式转化为data
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:requestParams options:NSJSONWritingPrettyPrinted error:nil];
    //设置请求体
    [request setHTTPBody:jsonData];
    
    NSURLSessionDataTask * dataTask =[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            STLLog(@"url：%@",url);
            STLLog(@"%@",responseObject);
            STLLog(@"保存FCM推送的信息到leancloud成功======");
//            [self ttttt:paramsJson state:YES result:responseObject];
        }else{
            //NSLog(@"%@",error);
            STLLog(@"保存FCM推送的信息到leancloud失败======");
//            [self ttttt:paramsJson state:NO result:@{}];

        }
    }];
    [dataTask resume];
}


+ (void)getOnlineAddress:(NSInteger)index complete:(void(^)(BOOL success))completeHandler{
    
    //one 域名获取
    [OSSVCommonnRequestsManager getOnlineDomainComplete:^(BOOL success) {
        completeHandler(success);
    }];
}


//+ (void)getOnlineAddressComplete:(void(^)(BOOL success))completeHandler{
//
//
//    NSString *url =  [OSSVLocaslHosstManager securtyApiUrl:0];
//
//    STLLog(@"ecurtyApiUrl 请求:%@",url);
//    NSURL *urlRequest = [NSURL URLWithString:url];
//
//    //创建配置信息
//    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    //设置请求超时时间：7秒
//    configuration.timeoutIntervalForRequest = 15;
//    configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
//    //创建会话
//    NSURLSession *session = [NSURLSession sessionWithConfiguration: configuration delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
//    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:urlRequest];
//
//
//    //设置请求方式：POST
//    [request setHTTPMethod:@"GET"];
//    [request setValue:@"application/json" forHTTPHeaderField:@"content-Type"];
//    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Accept"];
//
//    NSURLSessionDataTask * dataTask =[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//
//        BOOL state = NO;
//        if (error == nil) {
//            NSString * str  =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//            STLLog(@"%@",str);
//
////            NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//            STLLog(@"securtyApiUrl成功====== %@",str);
//            if (!STLIsEmptyString(str)) {
//                [STLMasterModule sharedInstance].onlineAddress = str;
//                NSUserDefaults *myDefaults = [[NSUserDefaults alloc] initWithSuiteName:[[STLDeviceInfoManager sharedManager] appGroupSuitName]];
//                [myDefaults setObject:[STLMasterModule sharedInstance].onlineAddress forKey:kCFgOnlineAppsOnleDomain];
//                state = YES;
//            }
//
//        }else{
//            STLLog(@"securtyApiUrl失败======");
//        }
//
//        if (completeHandler) {//adorawe.net
//            completeHandler(state);
//        }
//    }];
//    [dataTask resume];
//
//
//
//}


+ (void)ttttt:(NSString *)tempRequestJson state:(BOOL)isSuccess result:(NSDictionary *)result{
    

    
    if ([OSSVConfigDomainsManager isDistributionOnlineRelease] || [OSSVRequestsConfigs sharedInstance].closeUrlResponsePrintfLog) {
        return;//线上发布环境不上传日志
    }
    
    // 只有在控制面板中设置了抓包日志才上传远程日志
    if (![OSSVRequestsConfigs sharedInstance].uploadResponseJsonToLogSystem) return;
    
    NSString *responseJSON = [result yy_modelToJSONString];

    AFHTTPSessionManager *manager = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
        manager = [AFHTTPSessionManager manager];
        manager.operationQueue.maxConcurrentOperationCount = 5;
        manager.requestSerializer = [OSSVJSONRequestsSerializer serializer];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/html", @"text/plain", nil];
        
//    });
    
    NSString *successFlag = isSuccess ? @"✅✅✅" : @"❌❌❌";
    NSString *requestStatus = isSuccess ? @"成功" : @"失败";
    
    NSMutableString *mutBody = [[NSMutableString alloc] init];
    NSString *requestUrl = [OSSVLocaslHosstManager pushApiUrl];
    

    
    [mutBody appendFormat:@"<br/>FCMMMMMM请求链接 : <br/> <font color='red'>%@</font>", requestUrl];
    
    [mutBody appendFormat:@"<br/>"];
    
    [mutBody appendFormat:@"请求参数 : <br/> <font color='yellow'>%@</font>", tempRequestJson];
    
    [mutBody appendFormat:@"<br/>"];
    
    [mutBody appendFormat:@"返回结果 :%@  %@ <br/><br/> <font>%@</font>",successFlag,requestStatus,responseJSON];
    
    [mutBody appendFormat:@"<br/><br/> =========================================================== <br/>"];
    
    [mutBody appendFormat:@"%@", [OSSVLocaslHosstManager appName]];


    NSString *requestJson = tempRequestJson;
    //    NSData *requestData = requestParmaterTask.originalRequest.HTTPBody;
    //    if (requestData) {
    //        requestJson = [[NSString alloc] initWithData:requestData encoding:(NSUTF8StringEncoding)];
    //    }
    
//    NSString *requestKey = nil;
//    NSString *requestValue = nil;
//    NSDictionary *httpHeadDic = request.allHTTPHeaderFields;
//    for (NSString *httpHeadStr in httpHeadDic.allKeys) {
//        if (httpHeadStr.length > 25) {
//            requestKey = httpHeadStr;
//            requestValue = httpHeadDic[httpHeadStr] ? : @"";
//            break;
//        }
//    }
    
    NSString *responseStr = [responseJSON yy_modelToJSONString];
    NSDictionary *requestParams = @{ @"body"     : STLToString(mutBody),
                                     @"level"    : @"iOS",
                                     @"domain"   : @"STL-iOS",
                                     @"platform" : [OSSVLocaslHosstManager appName],
                                     @"url"      : STLToString(requestUrl),
                                     @"request"  : STLToString(requestJson),
                                     @"response" : STLToString(responseStr),
    };
    
    NSString *uploadAddress = [OSSVConfigDomainsManager localRequestLogToUrl];
//    [manager POST:uploadAddress parameters:requestParams progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        STLLog(@"----日志上传成功");
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        STLLog(@"----日志上传失败");
//
//    }];
    [manager POST:uploadAddress parameters:requestParams headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        STLLog(@"----FCM 日志上传成功");

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        STLLog(@"----FCM 日志上传失败");

    }];
}

//参数数据
+ (void)testComment {
    
    NSString *jsonString = @"";
    //dD87UXn23Vw09qp3DnPQ7VB8kda9f3b1
    NSString *userToken = @"DS9h5BmGQAfTEDVTXWPdEfTVsjnRCEx6";
    if (APP_TYPE == 3) {
        userToken = @"dD87UXn23Vw09qp3DnPQ7VB8kda9f3b1";
    }
    NSDictionary *data = @{@"sku":@"XXPD01334001",
                           @"spu":@"XXPD00619",
                           @"num":@(3),
                           @"page":@(1),
                           @"type":@(0),
                           @"lang":@"en"};
    
    
    NSMutableDictionary *requestParams = @{@"client": @(1),
                               @"site": [OSSVLocaslHosstManager appName].lowercaseString,
                               @"version":@"4.5.3",
                               @"lang":@"en",
                               @"data":data}.mutableCopy;

    NSArray *keyArrays = @[@"client",@"data",@"lang",@"site",@"version"];

    NSArray *dataKeyArrays = @[@"sku",@"spu",@"num",@"page",@"type",@"lang"];

    NSString *str = userToken;
    NSString *dataJson = @"";
    jsonString = @"{";
    for (NSString *key in keyArrays) {
        NSString *value = requestParams[key];
        NSString *valueJson = value;
        if ([value isKindOfClass:[NSString class]]) {
            valueJson = [NSString stringWithFormat:@"\"%@\"",value];
        } else if([value isKindOfClass:[NSNumber class]]) {
            valueJson = [NSString stringWithFormat:@"%@",value];

        } else if ([value isKindOfClass:[NSDictionary class]]) {
            NSDictionary *valueDic = (NSDictionary *)value;
            valueJson = @"{";

            for (int i=0; i<dataKeyArrays.count; i++) {
                NSString *valueKey = dataKeyArrays[i];
                NSString *dataValue = valueDic[valueKey];

                if ([dataValue isKindOfClass:[NSString class]]) {
                    dataValue = [NSString stringWithFormat:@"\"%@\"",dataValue];
                }
                if (i == dataKeyArrays.count-1) {
                    valueJson = [NSMutableString stringWithFormat:@"%@\"%@\":%@}",valueJson,valueKey,dataValue];
                } else {
                    valueJson = [NSMutableString stringWithFormat:@"%@\"%@\":%@,",valueJson,valueKey,dataValue];
                }
            }
            dataJson = valueJson;
        }
        str = [NSString stringWithFormat:@"%@%@%@",str,key,valueJson];
        
        
    }
    str = [NSString stringWithFormat:@"%@%@",str,userToken];
    NSString *strMD5 = [OSSVRequestsUtils md5StringWithString:str];

    [requestParams setValue:strMD5 forKey:@"signature"];
    [requestParams setValue:@"replaceStrData" forKey:@"data"];
    
    jsonString = [requestParams yy_modelToJSONString];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\"replaceStrData\"" withString:dataJson];
    
    
    NSString *url = @"http://review.cloudsdlk.com.release.fpm.testsdlk.com/api/goods/review-list";
//    url = @"https://review.adorawe.net/api/goods/review-list";
    //创建配置信息
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    //设置请求超时时间：7秒
    configuration.timeoutIntervalForRequest = 15;
    //创建会话
    NSURLSession *session = [NSURLSession sessionWithConfiguration: configuration delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    //设置请求方式：POST
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"content-Type"];
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Accept"];
    
//    jsonString = @"{\"site\":\"adorawe\",\"client\":1,\"lang\":\"en\",\"data\":{\"sku\":\"PKJD00531001\",\"num\":3,\"page\":1,\"type\":0,\"lang\":\"en\"},\"signature\":\"e6d882280bf67b3ce08adf23e37c7a5e\",\"version\":\"4.5.3\"}";
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    //data的字典形式转化为data
//    jsonData = [NSJSONSerialization dataWithJSONObject:requestParams options:NSJSONWritingPrettyPrinted error:nil];
    //设置请求体
    [request setHTTPBody:jsonData];
    
    NSURLSessionDataTask * dataTask =[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            STLLog(@"url：%@",url);
            STLLog(@"%@",responseObject);
        }else{
            NSLog(@"%@",error);

        }
    }];
    [dataTask resume];
}

+ (void)getOnlineDomainComplete:(void(^)(BOOL success))completeHandler{
    
#if DEBUG
//
//    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
//    for (int i=0; i<6; i++) {
//        STLWebitesModel *model = [[STLWebitesModel alloc] init];
//        if (i == 0) {
//            model.site_group = @"Adorawe";
//            model.site_code = @"Adorawe";
//            model.api_domain = @"http://api.adorawe.net.shop.testsdlk.com/";
////            model.api_domain = @"http://api.adorawe-api.com.release.fpm.testsdlk.com/";
//
//            model.is_default = 1;
//        } else if(i == 1) {
//            model.site_group = @"Adorawe";
//            model.site_code = @"Adorawe线上";
//            model.api_domain = @"https://api.adorawe.net/";
////            model.api_domain = @"";
//            model.is_default = 0;
//
//        } else if(i == 2){
//            model.site_group = @"Soumlia";
//            model.site_code = @"Soumlia国际站测试";
//            model.api_domain = @"https://api.soulmiacollection.com.shop.devsdlk.com/";
//            model.is_default = 0;
//
//        } else if(i == 3) {
//            model.site_group = @"Soumlia";
//            model.site_code = @"Soumlia国际站线上";
//            model.api_domain = @"https://api.soulmiacollection.com/";
//            model.is_default = 0;
//
//        }  else if(i == 4) {
//            model.site_group = @"Soumlia";
//            model.site_code = @"Soumlia德国站线上";
//            model.api_domain = @"https://api-de.soulmiacollection.com/";
//            model.is_default = 0;
//        } else if(i == 5) {
//            model.site_group = @"Soumlia";
//            model.site_code = @"Soumlia德国站线上";
//            model.api_domain = @"https://api-de.soulmiacollection.com/";
//            model.is_default = 0;
//        }
//        [tempArray addObject:model];
//
//        NSMutableArray *langArray = [[NSMutableArray alloc] init];
//        NSMutableArray *currenciesArray = [[NSMutableArray alloc] init];
//        NSMutableArray *countriesArray = [[NSMutableArray alloc] init];
//
//        for (int j=0; j<3; j++) {
//            OSSVSupporteLangeModel *langModel = [[OSSVSupporteLangeModel alloc] init];
//            RateModel *raModel = [[RateModel alloc] init];
//
//            if (j == 0) {
//                langModel.code = @"en";
//                langModel.name = @"english";
//                langModel.is_default = 0;
//
//                raModel.code =@"USD";
//                raModel.symbol = @"$";
//                raModel.is_default = 0;
//
//            } else if(j == 1) {
//                langModel.code =@"ar";
//                langModel.name =  @"arSadiu";
//                langModel.is_default = 1;
//
//                raModel.code = @"EUR";
//                raModel.symbol = @"€";
//                raModel.is_default = 1;
//            } else {
//                langModel.code = @"pt-BR";
//                langModel.name = @"ptSadiu";
//                langModel.is_default = 0;
//
//                raModel.code = @"CNY";
//                raModel.symbol = @"￥";
//                raModel.is_default = 0;
//            }
//
//            [langArray addObject:langModel];
//
//
//
//            [currenciesArray addObject:raModel];
//
//            STLWebitesCountryModel *countryModel = [[STLWebitesCountryModel alloc] init];
//            countryModel.country_code = j==1 ? @"US" : @"CH";
//            countryModel.country_en = j==1 ? @"USName" : @"China";
//            countryModel.is_default = j==1 ? 1 : 0;
//            [countriesArray addObject:countryModel];
//        }
//
//        model.langs = langArray.copy;
//        model.currencies = currenciesArray;
//        model.countries = countriesArray.copy;
//    }
//
//    STLWebsitesGroupManager *websiteManager = [STLWebsitesGroupManager sharedManager];
//    websiteManager.websitesGroupModel = [[STLWebsitesGroupModel alloc] init];
//    websiteManager.websitesGroupModel.websites = tempArray.copy;
//    [websiteManager handCurrentWebSites];
//
//    if (completeHandler) {
//        completeHandler(YES);
//    }
//    return;
#endif
    
//    //正式环境添加cookie 不用
//    DomainType type = [OSSVConfigDomainsManager domainEnvironment];
//    if ([OSSVConfigDomainsManager isDistributionOnlineRelease] || type == DomainType_Release) {
//
//
//        NSURL *webUrl = [NSURL URLWithString:[OSSVLocaslHosstManager appLocalOnleHost]];
//
//        NSString *domani = [NSString stringWithFormat:@".%@",webUrl.host];
//
//        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//
//        NSHTTPCookie *stlink_cookie1 = [[NSHTTPCookie alloc] initWithProperties:@{
//            NSHTTPCookieName:@"onesite",
//            NSHTTPCookieValue:@"true",
//            NSHTTPCookieDomain:STLToString(domani),
//            NSHTTPCookiePath:@"/",
//        }];
//
//        [storage setCookie:stlink_cookie1];
//    }
   
    
    OSSVwebsitesConfigsAip *websiteApi = [[OSSVwebsitesConfigsAip alloc] init];
    [websiteApi startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
        
        id requestJSON = [OSSVNSStringTool desEncrypt:request];
        BOOL flag = NO;
        
        if ([requestJSON isKindOfClass:[NSDictionary class]]) {
            if ([requestJSON[kStatusCode] integerValue] == kStatusCode_200) {
                
                flag = YES;
                NSDictionary *resultDic = requestJSON[@"result"];
                STLWebsitesGroupModel *wetsiteGroupModel = [STLWebsitesGroupModel yy_modelWithDictionary:resultDic];
                
#if DEBUG
                if(APP_TYPE != 1){///A站不需要切换站点
                    NSString *siteCode = [[NSUserDefaults standardUserDefaults] objectForKey:STLSiteCode];
                    
                    BOOL isContainSiztCode = NO;
                    for (STLWebitesModel *siteModel in wetsiteGroupModel.websites) {
                        ///切换国家站 代码替换site_code
                        if ([siteModel.site_code isEqualToString:siteCode]) {
                            isContainSiztCode = YES;
                        }
                    }
                    
                    if (siteCode.length > 0 && isContainSiztCode) {

                        for (STLWebitesModel *siteModel in wetsiteGroupModel.websites) {
                            siteModel.is_default = 0;
                            ///切换国家站 代码替换site_code
                            if ([siteModel.site_code isEqualToString:siteCode]) {
                                siteModel.is_default = 1;
                                isContainSiztCode = YES;
                            }
                        }
                    }
                }
#endif
              ///测试代码
//                for (STLWebitesModel *siteModel in wetsiteGroupModel.websites) {
//                    siteModel.is_default = 0;
//                }
                ///没有默认取第一个
                NSArray *filterd = [wetsiteGroupModel.websites filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"is_default = 1"]];
                if (filterd.count == 0) {
                    wetsiteGroupModel.websites.firstObject.is_default = 1;
                }
                
                [STLWebsitesGroupManager sharedManager].websitesGroupModel = wetsiteGroupModel;
                [[STLWebsitesGroupManager sharedManager] handCurrentWebSites];
            }
        }
        if (completeHandler) {
            completeHandler(flag);
        }
    } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
        if (completeHandler) {
            completeHandler(NO);
        }
    }];
}

+ (void)refreshAppOnLineDomain {
    
//    DomainType type = [OSSVConfigDomainsManager domainEnvironment];
//    if ([OSSVConfigDomainsManager isDistributionOnlineRelease] || [OSSVConfigDomainsManager isPreRelease] || type == DomainType_Release) {
//
//        if (![STLWebsitesGroupManager hasWebsitesData]) {
//            [APPDELEGATE onlineAddressInfo:^{
//
//                if ([STLWebsitesGroupManager hasWebsitesData]) {
//                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_OnlineAddressUpdate object:nil];
//                }
//            }];
//        }
//    }
    
    //因为国家站关系，都用后台的
    if (![STLWebsitesGroupManager hasWebsitesData]) {
        [APPDELEGATE onlineAddressInfo:^{
            
            if ([STLWebsitesGroupManager hasWebsitesData]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_OnlineAddressUpdate object:nil];
            }
        }];
    }
}
@end
