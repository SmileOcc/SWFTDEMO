//
//  OSSVCommonnRequestsManager.h
// XStarlinkProject
//
//  Created by odd on 2020/7/15.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "STLTabbarManager.h"

#import "OSSVItuneAppAip.h"
#import "UpdateUserApi.h"
#import "CountryApi.h"
#import "ExchangeApi.h"
#import "AdvertApi.h"
#import "OSSVCountrysCheckAip.h"

#import "CountryListModel.h"
#import "RateModel.h"
#import "OSSVAdvsEventsModel.h"

@interface OSSVCommonnRequestsManager : NSObject

+ (CGFloat)randomSecondsForMaxMillisecond:(NSInteger)maxMillisecond;

/**
* 国家列表
*/

+ (void)supportGountryList:(void(^)(BOOL success))completeHandler;


/**
 * 启动时异步请求必要接口数据 (在App启动时,首页从无网络到有网络时调用)
 */
+ (void)requestNecessaryData;


/**
* 放在首页请求其他接口
* 广告启动图
*/
+ (void)asyncRequestOtherApi;

/**
 * 检查App版本更新
 */
+ (void)checkUpadeApp:(void(^)(BOOL hasNoNewVersion))finishBlock  reuqestState:(void(^)(BOOL requestState))requestStateBlock;

+ (void)checkPushTime:(void(^)(NSString *status, NSString *content, NSString *hours))completeHandler;

/**
* 更新用户信息
*/
+ (void)checkUpdateUserInfo:(void(^)(BOOL success))completeHandler;

+ (void)onlyGetUserInfo:(void(^)(BOOL success))completeHandler;

/**
 * 请求汇率接口
 */
//+ (void)requestExchangeData:(void(^)(BOOL success))completeHandler;


/**
* 启动广告页
*/
+ (void)requestLaunchAdvData:(void(^)(BOOL success))completeHandler;


/**
* 检查是否欧盟
*/
+ (void)requestCountryCheck:(void(^)(BOOL success))completeHandler;


/**
* 上传FCMToken
*/
+ (void)saveFCMUserInfo:(NSString *)paid_order_number pushPower:(BOOL)pushPower fcmToken:(NSString *)fcmToken;

+ (void)getOnlineAddress:(NSInteger)index complete:(void(^)(BOOL success))completeHandler;
//获取APP文案
+ (void)getAppCopywriting;

+ (void)getOnlineDomainComplete:(void(^)(BOOL success))completeHandler;

+ (void)refreshAppOnLineDomain;
@end
