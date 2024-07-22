//
//  ZFCMSViewModel.m
//  ZZZZZ
//
//  Created by YW on 2018/12/8.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFCMSViewModel.h"
#import "ZFTimerManager.h"
#import "UIColor+ExTypeChange.h"
#import "ZFPiecingOrderViewModel.h"
#import "YWLocalHostManager.h"
#import "JumpModel.h"
#import "ZFThemeManager.h"
#import "AppDelegate.h"
#import <AppsFlyerLib/AppsFlyerTracker.h>
#import "NSStringUtils.h"
#import "ZFAnalytics.h"
#import "SystemConfigUtils.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "ZFRequestModel.h"
#import "ZFBannerModel.h"
#import "Constants.h"
#import "Configuration.h"
#import "ZFLocalizationString.h"
#import "NSDictionary+SafeAccess.h"
#import <GGBrainKeeper/BrainKeeperManager.h>
#import "NSDate+ZFExtension.h"
#import "GGDeviceInfoManager.h"
#import "ZFCMSSecKillSkuCell.h"
#import <GGAppsflyerAnalyticsSDK/GGAppsflyerAnalytics.h>

@interface ZFCMSViewModel ()

@end

@implementation ZFCMSViewModel

/**
 * 请求首页频道对应的列表广告接口
 * isCMSMainUrlType-> YES:请求cms主站接口(默认), NO:请求cms备份S3上的数据
 */
- (void)requestHomeListData:(NSString *)channelID
        isRequestCMSMainUrl:(BOOL)isRequestCMSMainUrl
                 completion:(void (^)(NSArray<ZFCMSSectionModel *> *, BOOL ))completion
{
    self.cmsModelArr = @[];
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.forbidEncrypt = YES;
    requestModel.needToCache = YES;
    self.currentPage = 0;//警告:一定要重置分页数
    
    if (isRequestCMSMainUrl) { // 请求的是cms主站接口
        requestModel.timeOut = [[AccountManager sharedManager].cmsTimeOutDuration integerValue];
        requestModel.url = CMS_API(Port_cms_getMenuPage);//CMS数据
        requestModel.taget = self.controller;
        requestModel.eventName = @"get_page";
        
        NSMutableDictionary *parmaters = [self baseParmatersDic];
        [parmaters addEntriesFromDictionary:@{@"menu_id":ZFToString(channelID),@"page_code":@"Homepage"}];

        parmaters[@"user_info"] = [[AccountManager sharedManager] userInfo];
        
        if (![YWLocalHostManager isOnlineRelease]){ //⚠️警告: 只供测试时使用,线上环境时不能传
            NSDictionary *siftDict = GetUserDefault(kTestCMSParmaterSiftKey);
            if (ZFJudgeNSDictionary(siftDict)) {
                [parmaters addEntriesFromDictionary:siftDict];
            }
        }
        requestModel.parmaters = parmaters;
        
    } else { // 请求cms备份在S3接口数据
        requestModel.type = ZFNetworkRequestTypeGET;
        requestModel.url = [YWLocalHostManager cmsHomePageJsonS3URL:channelID];
    }
    
    [ZFNetworkHttpRequest sendExtensionRequestWithParmaters:requestModel success:^(id responseObject) {
        
        NSString *cacheTime = responseObject[@"cacheTime"];
        if (!isRequestCMSMainUrl && requestModel.isCacheData && !ZFIsEmptyString(cacheTime)) {
            NSString *currentTimes = [NSStringUtils getCurrentTimestamp];
            if ([currentTimes integerValue] - [cacheTime integerValue] >= sec_per_day * 1) {
                YWLog(@"⚠️⚠️⚠️警告: 其他频道 此次返回的是S3备份接口的本地缓存数据,忽略此次超过一天的本地缓存数据");
                return;
            }
        }
        
        NSArray *reslutArr = responseObject[ZFDataKey];
        
        BOOL isCacheData = requestModel.isCacheData;
        if (isCacheData && [self.recommendResponseDict isEqualToDictionary:responseObject]
            && ZFJudgeNSArray(reslutArr) && reslutArr.count != 0) {
            YWLog(@"如果此次返回的是缓存数据,并且和当前列表数据相同则无需刷新");
            return;
        }
        self.recommendResponseDict = responseObject;
        
        NSArray<ZFCMSSectionModel *> *homeCMSModelArr = @[];
        if ([reslutArr isKindOfClass:[NSArray class]]) {
            homeCMSModelArr = [NSArray yy_modelArrayWithClass:[ZFCMSSectionModel class] json:reslutArr];
        }
        
        if (!isCacheData) {
            self.cmsModelArr = homeCMSModelArr;
        }
        
        // 当CMS数据为空当做失败处理, 尝试请求S3上的备份数据
        if (isRequestCMSMainUrl && homeCMSModelArr.count == 0) {
            if (!isCacheData) {
                [self requestHomeListData:channelID isRequestCMSMainUrl:NO completion:completion];
            }
        } else {
            if (completion) {
                NSArray<ZFCMSSectionModel *> *sectionModelArray = [self configCMSListData:homeCMSModelArr];
                completion(sectionModelArray, isCacheData);
            }
        }
        if (!isCacheData) {
            [ZFAnalytics logSpeedWithCategory:@"App_Cost_Time"
                                    eventName:@"CMSHomeLoadingTime"
                                     interval:requestModel.requestDuration
                                        label:Port_cms_getMenuPage];
            
            if (!isRequestCMSMainUrl) {
                NSString *serverTime = ZFToString(responseObject[@"serverTime"]);
                [ZFCMSViewModel analyticRequestS3:@"200"
                                        cmsResult:@"donot upload S3 MenuPage success response json"
                                       requestUrl:requestModel.url
                                       serverTime:serverTime];
            }
        }
    } failure:^(NSError *error) {
        // 请求失败尝试请求S3上的备份数据
        if (isRequestCMSMainUrl && self.cmsModelArr.count == 0) {
            [self requestHomeListData:channelID isRequestCMSMainUrl:NO completion:completion];
        } else {
            if (completion) {
                completion(nil, NO);
            }
        }
        [ZFCMSViewModel analyticRequestS3:ZFToString(error.userInfo[NSHelpAnchorErrorKey])
                                cmsResult:ZFToString(error.domain)
                               requestUrl:requestModel.url
                               serverTime:@"fail: no serverTime text"];
    }];
}

/// V5.4.0 增加统计触发S3的请求事件 (AF+公司统计SDK)
+ (void)analyticRequestS3:(NSString *)httpCode
                cmsResult:(NSString *)cmsResult
               requestUrl:(NSString *)url
               serverTime:(NSString *)serverTime
{
    NSMutableDictionary *afParams = [NSMutableDictionary dictionary];
    afParams[@"af_content_type"] = @"get s3 data";
    afParams[@"request_s3_time"] = [NSDate nowDate];
    afParams[@"serverTime"] = ZFToString(serverTime);
    afParams[@"device_id"] = ZFToString([GGDeviceInfoManager sharedManager].appsflyer_device_id);
    afParams[@"http_code"] = ZFToString(httpCode);
    afParams[@"http_error_result"] = ZFToString(cmsResult);
    afParams[@"platform"] = @"iOS";
    afParams[@"request_url"] = ZFToString(url);
    afParams[@"pipeline"] = ZFToString(GetUserDefault(kLocationInfoPipeline));
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_get_s3" withValues:afParams];
}

/**
 * 检索出fb广告链接带进来的商品数据 放到浏览历史记录中
 */
- (void)retrievalAFGoodsGoodsData:(nullable void(^)(void))completion  {
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    NSString *goodsIDS = [us objectForKey:AFADGroup];
    if (ZFIsEmptyString(goodsIDS)) return;
    
    //NSString *goodsIDS  = @"[API-7]-20181011,MPA,CH-NO,15-45,M,m,fb,262924605/260874012/260874013/260874013,ios,null";
    goodsIDS = [goodsIDS lowercaseString];
    YWLog(@"fb==goodsIDS==%@", goodsIDS);
    
    NSRange beiginRange = [goodsIDS rangeOfString:@"fb,"];
    if (beiginRange.location == NSNotFound) return;
    
    NSInteger localIndex = beiginRange.location + beiginRange.length;
    NSRange endRange     = [goodsIDS rangeOfString:@"," options:NSCaseInsensitiveSearch range:NSMakeRange(localIndex, goodsIDS.length - localIndex)];
    NSInteger length     = goodsIDS.length - localIndex;
    if (endRange.location != NSNotFound) {
        length = endRange.location - localIndex;
    }
    NSString *goodsStrings = [goodsIDS substringWithRange:NSMakeRange(localIndex, length)];
    NSString *goodsIdsString =[goodsStrings stringByReplacingOccurrencesOfString:@"/" withString:@","];
    if (goodsIdsString.length == 0) return;
    
    @weakify(self)
    [ZFPiecingOrderViewModel requestHandpickGoodsList:goodsIdsString completion:^(NSArray<ZFGoodsModel *> *goodsModelArr){
        @strongify(self)
        if (!goodsModelArr) return ;
        self.afGoodsModelArr = goodsModelArr;
        [us removeObjectForKey:AFADGroup];
        [us synchronize];
        if (goodsModelArr.count > 0 && completion) {
            completion();
        }
    }];
}

/**
 * 请求推荐商品数据接口
 * recommendType 推荐商品类型
 * 0:获取大数据推荐数据(其他则请求ZZZZZ商品列表)  1:实体分类数据  2:虚拟分类数据 3：固定页 4：商品运营平台选品
 */
- (void)requestCmsRecommendData:(BOOL)firstPage
                   sectionModel:(ZFCMSSectionModel *)sectionModel
                      channelID:(NSString *)channelID
                     completion:(void (^)(NSArray<ZFGoodsModel *> *array, NSDictionary *pageInfo))completion
                        failure:(void (^)(NSError *error))failure
{
    if (firstPage) {
        self.currentPage = 1;
    } else {
        self.currentPage++;
    }
    ZFRequestModel *requestModel = [ZFRequestModel new];
    BOOL isBigDataType = (ZFIsEmptyString(sectionModel.recommendType) || [sectionModel.recommendType isEqualToString:@"0"]);
    
    NSDictionary *parmaters = nil;
    NSString *evenName = @"";  // 链路事件名
    if (isBigDataType) {
        evenName = @"recommend_bigdata";
        requestModel.url = API(Port_bigData_homeRecommendGoods);//请求大数据
        parmaters = @{
            @"page"           : @(self.currentPage),
            @"policy"         : @(0),
            @"channel_id"     : ZFToString(channelID),
            @"appsFlyerUID"   : ZFToString([[AppsFlyerTracker sharedTracker] getAppsFlyerUID]),
            ZFApiBtsUniqueID  : ZFToString([GGAppsflyerAnalytics getAppsflyerDeviceId])
        };
        
    } else {//请求ZZZZZ后台
        evenName = @"recommend";
        requestModel.url = API(Port_zf_homeRecommendGoods);
        parmaters = @{
            @"page"         : @(self.currentPage),
            @"type"         : ZFToString(sectionModel.recommendType),
            @"sku_sort"     : ZFToString(sectionModel.sku_sort),
            @"sku_limit"    : ZFToString(sectionModel.sku_limit),
            @"sku_ruleId"   : ZFToString(sectionModel.sku_ruleId),
            @"content"      : ZFToString(sectionModel.recommendContent),
            @"channel_id"   : ZFToString(channelID),
            @"appsFlyerUID" : ZFToString([[AppsFlyerTracker sharedTracker] getAppsFlyerUID]),
            ZFApiBtsUniqueID : ZFToString([GGAppsflyerAnalytics getAppsflyerDeviceId])
        };
    }
    requestModel.eventName = evenName;
    requestModel.taget = self.controller;
    requestModel.parmaters = parmaters;
    self.recommendParmaters = parmaters; //每次下拉记住请求参数, 防止弱网数据返回时机错乱
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        
        if (failure && self.recommendParmaters != parmaters) {
            self.currentPage--;
            failure(nil) ;
            return ;
        }
        NSDictionary *resultDict = responseObject[ZFResultKey];
        if (completion && ZFJudgeNSDictionary(resultDict)) {
            NSArray *goodsArr = resultDict[@"goods_list"];
            if (ZFJudgeNSArray(goodsArr)) {
                NSArray *goodsModelArr = [NSArray yy_modelArrayWithClass:[ZFGoodsModel class] json:goodsArr];
                
                NSInteger total_page = [resultDict[@"total_page"] integerValue];
                NSInteger cur_page = [resultDict[@"cur_page"] integerValue];
                if (isBigDataType) { // 大数据的分页有问题,额外处理
                    if (goodsArr.count > 0) {
                        total_page = cur_page + 1;
                    } else {
                        total_page = cur_page;
                    }
                }
                if (isBigDataType) { // 标识主页推荐位数据来源于大数据:用于统计
                    for (ZFGoodsModel *goodModel in goodsModelArr) {
                        if (![goodModel isKindOfClass:[ZFGoodsModel class]])return;
                        goodModel.isBigCommendDataType = YES;
                    }
                }
                NSDictionary *pageInfo = @{
                    kTotalPageKey   : @(total_page),
                    kCurrentPageKey : @(cur_page),
                    @"af_params"    : [resultDict ds_dictionaryForKey:@"af_params"], //实验id
                };
                completion(goodsModelArr, pageInfo);
                return ;
            }
        }
        self.currentPage--;
        failure(nil);
        
    } failure:^(NSError *error) {
        self.currentPage--;
        if (failure) {
            failure(error);
        }
    }];
}

- (void)requestCMSCouponData:(NSString *)couponsStrng completion:(void (^)(NSArray<ZFCMSCouponModel *> *array))completion failure:(void (^)(NSError *error))failure {
    
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.taget = self.controller;
    requestModel.url = API(Port_cms_getCmsCouponList);
    requestModel.parmaters = @{@"coupon":ZFToString(couponsStrng)};
    
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        NSArray *results = @[];
        if (ZFJudgeNSArray(responseObject[ZFResultKey])) {
            results = [NSArray yy_modelArrayWithClass:[ZFCMSCouponModel class] json:responseObject[ZFResultKey]];
        }
        if (completion) {
            completion(results);
        }
        
    } failure:^(NSError *error) {
        if (failure) {
            failure(nil);
        }
    }];
}

/**
 * 如果滑动SKU组件没有返回数据时再请求商品运营平台的接口
 * recommendType 推荐商品类型
 * 0:获取大数据推荐数据(其他则请求ZZZZZ商品列表)  1:实体分类数据  2:虚拟分类数据 3：固定页 4：商品运营平台选品
 */
- (void)requestSlidSkuModuleData:(ZFCMSSectionModel *)sectionModel
                       channelID:(NSString *)channelID
                      completion:(void (^)(NSArray<ZFGoodsModel *> *array))completion
                         failure:(void (^)(NSError *error))failure
{
    if (![sectionModel isKindOfClass:[ZFCMSSectionModel class]]) return;
    
    NSString *type = sectionModel.recommendType;
    if (ZFIsEmptyString(type)) {
        type = @"4";
    }
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.url = API(Port_zf_homeRecommendGoods);
    NSDictionary *parmaters = @{
        @"type"         : ZFToString(type),
        @"sku_sort"     : ZFToString(sectionModel.sku_sort),
        @"page_size"    : ZFToString(sectionModel.sku_limit),
        @"sku_limit"    : ZFToString(sectionModel.sku_limit),
        @"sku_ruleId"   : ZFToString(sectionModel.sku_ruleId),
        @"content"      : ZFToString(sectionModel.recommendContent),
        @"channel_id"   : ZFToString(channelID),
        @"appsFlyerUID" : ZFToString([[AppsFlyerTracker sharedTracker] getAppsFlyerUID]),
        ZFApiBtsUniqueID : ZFToString([GGAppsflyerAnalytics getAppsflyerDeviceId])
    };
    requestModel.eventName = @"Slid_Sku_Module";
    requestModel.taget = self.controller;
    requestModel.parmaters = parmaters;
    self.sliderModuleParmaters = parmaters; //每次下拉记住请求参数, 防止弱网数据返回时机错乱
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        
        if (failure && self.sliderModuleParmaters != parmaters) {
            failure(nil) ;
            return ;
        }
        NSDictionary *resultDict = responseObject[ZFResultKey];
        if (completion && ZFJudgeNSDictionary(resultDict)) {
            NSArray *goodsArr = resultDict[@"goods_list"];
            if (ZFJudgeNSArray(goodsArr)) {
                NSArray *goodsModelArr = [NSArray yy_modelArrayWithClass:[ZFGoodsModel class] json:goodsArr];
                completion(goodsModelArr);
                return;
            }
        }
        if (failure) {
            failure(nil);
        }
        
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

@end
