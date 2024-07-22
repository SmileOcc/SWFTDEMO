//
//  ZFHomePageMenuViewModel.m
//  ZZZZZ
//
//  Created by YW on 2018/11/10.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFHomePageMenuViewModel.h"
#import "YWLocalHostManager.h"
#import "ZFProgressHUD.h"
#import "NSDictionary+SafeAccess.h"
#import "YWCFunctionTool.h"
#import "ZFRequestModel.h"
#import "Constants.h"
#import "ZFLocalizationString.h"
#import "ZFCMSSectionModel.h"
#import "AFNetworking.h"
#import "NSStringUtils.h"
#import "ZFCMSViewModel.h"

@interface ZFHomePageMenuViewModel ()
@property (nonatomic, assign) BOOL isCMSDataType;
// 主页列表数据源
@property (nonatomic, strong) NSArray<ZFCMSSectionModel *> *homeSectionModelArr;
@property (nonatomic, strong) NSMutableArray<ZFHomePageMenuModel *> *tabMenuModels;
@property (nonatomic, strong) NSDictionary *pageMenuResponseDict;
@end

@implementation ZFHomePageMenuViewModel

/**
 * 重置菜单接口数据
 */
- (void)shouldResetMenuData {
    self.pageMenuResponseDict = nil;
}

/**
 * 请求cms列表数据
 * isCMSMainUrlType-> YES:请求cms主站接口, NO:请求cms备份S3上的数据
 */
- (void)requestHomePageMenuData:(BOOL)isRequestCMSMainUrl completeHandler:(void (^)(BOOL isSucceess))completeHandler
{
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.needToCache = YES;
    requestModel.forbidEncrypt = YES;
    requestModel.taget = self.controller;
    
    if (isRequestCMSMainUrl) { // 请求的是cms主站接口
        requestModel.type = ZFNetworkRequestTypePOST;
        requestModel.url = CMS_API(Port_cms_getMenuList);//cms频道接口
        requestModel.timeOut = [[AccountManager sharedManager].cmsTimeOutDuration integerValue];
        
        ZFAddressCountryModel *accountModel = [AccountManager sharedManager].accountCountryModel;
        NSString *new_customer = [AccountManager sharedManager].af_user_type;
        
        NSMutableDictionary *parmaters = [NSMutableDictionary  dictionary];
        parmaters[@"website"] = @"ZF";
        parmaters[@"platform"] = @"ios";
        parmaters[@"page_code"] = @"Homepage";
        parmaters[@"country_code"] = ZFIsEmptyString(accountModel.region_code) ? @"US" : accountModel.region_code;   
        parmaters[@"language_code"] = ZFToString([[ZFLocalizationString shareLocalizable] currentLanguageMR]);
        parmaters[@"is_new_customer"] = ZFIsEmptyString(new_customer ) ? @"1" : new_customer;
        parmaters[@"mid"] = ZFToString([AccountManager sharedManager].device_id);
        parmaters[@"app_version"] = ZFToString(ZFSYSTEM_VERSION);
        parmaters[@"api_version"] = @"2";//CMS版本号（ZF ios 4.5.4以后版本必须传）
        parmaters[@"user_info"] = [[AccountManager sharedManager] userInfo];
        
        if (![YWLocalHostManager isOnlineRelease]){ //⚠️警告: 只供测试时使用,线上环境时不能传
            NSDictionary *siftDict = GetUserDefault(kTestCMSParmaterSiftKey);
            if (ZFJudgeNSDictionary(siftDict)) {
                [parmaters addEntriesFromDictionary:siftDict];
            }
        }
        requestModel.parmaters = parmaters;
        
    } else { //CMS备份在S3服务器上的缓存数据接口
        requestModel.type = ZFNetworkRequestTypeGET;
        requestModel.url = [YWLocalHostManager cmsHomePageJsonS3URL:nil];
        requestModel.eventName = @"CMS_S3";
    }
    
    [ZFNetworkHttpRequest sendExtensionRequestWithParmaters:requestModel success:^(id responseObject) {        
        NSString *cacheTime = responseObject[@"cacheTime"];
        if (!isRequestCMSMainUrl && requestModel.isCacheData && !ZFIsEmptyString(cacheTime)) {
            NSString *currentTimes = [NSStringUtils getCurrentTimestamp];
            if ([currentTimes integerValue] - [cacheTime integerValue] >= sec_per_day * 1) {
                
                if (self.homeSectionModelArr.count != 0) {
                    YWLog(@"⚠️⚠️⚠️警告:此次返回的是S3备份接口的本地缓存数据,忽略此次超过一天的本地缓存数据");
                    return;
                }
            }
        }
        [AccountManager sharedManager].homeDateIsCMSType = isRequestCMSMainUrl;// 是否是cms数据
        NSArray *dataArray = responseObject[ZFDataKey];
        
        if ([self.pageMenuResponseDict isEqualToDictionary:responseObject]
            && ZFJudgeNSArray(dataArray) && dataArray.count != 0) {
            YWLog(@"⚠️⚠️⚠️ 因为主页MenuData请求有缓存会回调两次,这里判断是否为重复数据,来避免过多重复绘制初始化主页");
            return ;
        }
        self.pageMenuResponseDict = responseObject;
        
        if (ZFJudgeNSArray(dataArray)) {
            [self.tabMenuModels removeAllObjects];
            self.homeBtsModel = nil;
            
            NSMutableArray<ZFHomePageMenuModel *> *targetList = [NSMutableArray array];
            for (NSInteger i=0; i<dataArray.count; i++ ) {
                NSDictionary *menuDict = dataArray[i];
                if (!ZFJudgeNSDictionary(menuDict)) continue;
                
                if (i == 0) { //CMS频道接口会返回第一个频道下对应的列表数据
                    NSArray *menuDataList = menuDict[@"menu_data"];
                    if (ZFJudgeNSArray(menuDataList)) {
                        self.homeSectionModelArr = [NSArray yy_modelArrayWithClass:[ZFCMSSectionModel class] json:menuDataList];
                    }
                    
                    NSDictionary *btsDict = menuDict[@"bts_data"];
                    if (ZFJudgeNSDictionary(btsDict)) {
                        self.homeBtsModel = [ZFBTSModel yy_modelWithJSON:btsDict];
                    }
                    
                    // 推送延时曝光
                    if ([AccountManager sharedManager].isFilterAnalytics) {
                        [AccountManager sharedManager].channelId = [menuDict ds_stringForKey:@"menu_id"];
                        [AccountManager sharedManager].channelName = [menuDict ds_stringForKey:@"menu_name"];
                    }
                }
                ZFHomePageMenuModel *menuModel = [[ZFHomePageMenuModel alloc] init];
                menuModel.tabTitle = [menuDict ds_stringForKey:@"menu_name"];
                menuModel.channel_id = [menuDict ds_stringForKey:@"menu_id"];
                [targetList addObject:menuModel];
            }
            [self.tabMenuModels addObjectsFromArray:targetList];
        }
        
        //数据为空当CMS为失败处理 ,尝试请求网站后台备份数据接口
        if (isRequestCMSMainUrl && self.tabMenuModels.count == 0) {
            [self requestHomePageMenuData:NO completeHandler:completeHandler];
            
        } else {
            if (completeHandler) {
                completeHandler((self.tabMenuModels.count > 0));
            }
        }
        if (!requestModel.isCacheData && !isRequestCMSMainUrl) {
            NSString *serverTime = ZFToString(responseObject[@"serverTime"]);
            [ZFCMSViewModel analyticRequestS3:@"200"
                                    cmsResult:@"donot upload S3 get-menu success response json"
                                   requestUrl:requestModel.url
                                   serverTime:serverTime];
        }
    } failure:^(NSError *error) {
        [AccountManager sharedManager].homeDateIsCMSType = isRequestCMSMainUrl;// 是否是cms主站数据
        
        if (isRequestCMSMainUrl && self.tabMenuModels.count == 0) {
            // CMS请求失败时,尝试请求网站后台接口
            [self requestHomePageMenuData:NO completeHandler:completeHandler];
            
        } else {            
            if (completeHandler) {
                completeHandler((self.tabMenuModels.count > 0));
            }
            // ShowToastToViewWithText(nil, error.domain); V4.6.0不需要提示
        }
        [ZFCMSViewModel analyticRequestS3:ZFToString(error.userInfo[NSHelpAnchorErrorKey])
                                cmsResult:ZFToString(error.domain)
                               requestUrl:requestModel.url
                               serverTime:@"fail: no serverTime text"];
    }];
}

- (NSMutableArray<ZFHomePageMenuModel *> *)tabMenuModels {
    if (!_tabMenuModels) {
        _tabMenuModels = [NSMutableArray array];
    }
    return _tabMenuModels;
}

- (NSArray <NSString *> *)values {
    NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:self.tabMenuModels.count];
    for (ZFHomePageMenuModel *model in self.tabMenuModels) {
        [values addObject:[NSString stringWithFormat:@"%@", model.channel_id]];
    }
    return values;
}

- (NSArray <NSString *> *)keys {
    NSMutableArray *keys = [[NSMutableArray alloc] initWithCapacity:self.tabMenuModels.count];
    for (NSInteger i = 0; i < self.tabMenuModels.count; i++) {
        [keys addObject:@"tabType"];
    }
    return keys;
}

- (NSArray *)tabMenuTitles {
    NSMutableArray *tabMenuTitles = [[NSMutableArray alloc] initWithCapacity:self.tabMenuModels.count];
    for (ZFHomePageMenuModel *model in self.tabMenuModels) {
        [tabMenuTitles addObject:model.tabTitle];
    }
    return tabMenuTitles;
}

@end
