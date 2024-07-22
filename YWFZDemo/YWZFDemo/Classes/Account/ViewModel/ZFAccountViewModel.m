
//
//  ZFAccountViewModel.m
//  ZZZZZ
//
//  Created by YW on 2018/4/28.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFAccountViewModel.h"
#import "ZFBannerModel.h"
#import "YWLocalHostManager.h"
#import "ZFAnalytics.h"
#import "YWCFunctionTool.h"
#import "ZFRequestModel.h"
#import "AccountModel.h"
#import "Constants.h"
#import "ZFCommonRequestManager.h"
#import "NSDictionary+SafeAccess.h"
#import <AppsFlyerLib/AppsFlyerTracker.h>
#import "ZFLocalizationString.h"
#import "RSA.h"
#import <GGAppsflyerAnalyticsSDK/GGAppsflyerAnalytics.h>

@interface ZFAccountViewModel ()
@property (nonatomic, strong) NSMutableArray *recommendProductList;
@end

@implementation ZFAccountViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.pageIndex = 1;
        self.recommendProductList = [[NSMutableArray alloc] init];
    }
    return self;
}

/**
 * 获取用户信息
 */
- (void)requestUserInfoData:(void (^)(AccountModel *))completion
                    failure:(void (^)(NSError *error))failure
{
    ZFAddressCountryModel *accountModel = [AccountManager sharedManager].accountCountryModel;
    NSString *device_id = [AccountManager sharedManager].device_id;
    NSString *lang = [ZFLocalizationString shareLocalizable].nomarLocalizable;
    
    NSDictionary *dataDict = @{ZFApiCountryIdKey    : ZFToString(accountModel.region_id),
                               ZFApiCountryCodeKey  : ZFToString(accountModel.region_code),
                               ZFApiDeviceId        : ZFToString(device_id),
                               ZFApiLangKey         : ZFToString(lang),
                               ZFApiTokenKey        : ZFToString(TOKEN) };
    
    NSString *dataJson = [dataDict yy_modelToJSONString];
    NSString *encryptString = [RSA encryptString:dataJson publicKey:kEncryptPublicKey];
    
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.url = API(Port_userInfo);
    requestModel.forbidAddPublicArgument = YES; // 用户信息接口需要加密,不添加公共参数
    requestModel.eventName = @"get_user_info";
    requestModel.taget = self.controller;
    requestModel.parmaters = @{@"is_enc"  : @"2",
                               @"data"    : ZFToString(encryptString) };
    
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        AccountModel *userModel = [self dealwithUserInfoData:responseObject];
        //更新单例数据
        if (userModel) {
            [[AccountManager sharedManager] updateUserInfo:userModel];
            // 保存LeandCloud数据
            [AccountManager saveLeandCloudData];
        } else {
            [[AccountManager sharedManager] clearUserInfo];
        }
        if (completion) {
            completion(userModel);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

/**
 * 合并处理用户信息
 */
- (AccountModel *)dealwithUserInfoData:(NSDictionary *)responseObject
{
    NSDictionary *resultDict = responseObject[ZFResultKey];
    if (ZFJudgeNSDictionary(resultDict) && [resultDict[@"error"] integerValue] == 0) {
        
        NSDictionary *userInfoDict = resultDict[ZFDataKey];
        NSString *encryptString = resultDict[@"encryptData"];
        
        if (ZFJudgeNSDictionary(userInfoDict) && !ZFIsEmptyString(encryptString)) {
            // 重要敏感信息放在加密字段里面
            NSString *decryptJson = [RSA decryptString:encryptString publicKey:kEncryptPublicKey];
            
            if (!ZFIsEmptyString(decryptJson)) {
                NSData *jsonData = [decryptJson dataUsingEncoding:NSUTF8StringEncoding];
                if (jsonData) {
                    NSDictionary *encryptDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                                options:NSJSONReadingMutableContainers
                                                                                  error:nil];
                    if (ZFJudgeNSDictionary(encryptDict)) {
                        NSMutableDictionary *fullResultDict = [NSMutableDictionary dictionaryWithDictionary:userInfoDict];
                        
                        YWLog(@"用户信息接口: 合并普通信息和加密的敏感信息===%@", encryptDict)
                        [fullResultDict addEntriesFromDictionary:encryptDict];
                        
                        AccountModel *userModel = [AccountModel yy_modelWithJSON:fullResultDict];
                        return userModel;
                    }
                }
            }
        }
    }
    return nil;
}


/**
 * 获取个人中心banner接口
 */
- (void)requestUserCoreBannerData:(void (^)(NSArray *banners))completion
                          failure:(void (^)(id obj))failure {
    
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.url = API(Port_userCoreBanner);
    
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        NSArray *resultArr = responseObject[ZFResultKey];
        
        NSArray<ZFNewBannerModel *> *banners = nil;
        if (ZFJudgeNSArray(resultArr)) {
            banners = [NSArray yy_modelArrayWithClass:[ZFNewBannerModel class] json:resultArr];
        }
        if (completion) {
            completion(banners);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(nil);
        }
    }];
}

/**
 * 获取个人中心显示的Banner广告
 */
- (void)requestUserCoreCMSBanner:(void (^)(NSArray<ZFNewBannerModel *> *))completion
{
    [ZFCommonRequestManager requestCMSAppAdvertsWithTpye:(ZFCMSAppAdvertsType_UserCenter) otherId:nil completion:^(NSDictionary *responseObject) {
        
        NSArray *resultArray = responseObject[ZFDataKey];
        if (!ZFJudgeNSArray(resultArray)) {
            if (completion) {
                completion(nil);
            }
            return;
        }
        NSMutableArray<ZFNewBannerModel *> *newBannerArray = [NSMutableArray array];
        
        for (NSDictionary *resultDic in resultArray) {
            if(!ZFJudgeNSDictionary(resultDic)) continue;
            
            NSMutableArray *bannerArr = [NSMutableArray array];
            NSArray *banners = [resultDic ds_arrayForKey:@"list"];
            
            for (NSDictionary *listDic in banners) {
                ZFBannerModel *bannerModel = [[ZFBannerModel alloc] init];
                bannerModel.name = [listDic ds_stringForKey:@"name"];
                bannerModel.image = [listDic ds_stringForKey:@"img"];
                bannerModel.banner_width = [listDic ds_stringForKey:@"width"];
                bannerModel.banner_height = [listDic ds_stringForKey:@"height"];
                bannerModel.colid = [listDic ds_stringForKey:@"colId"];
                bannerModel.componentId = [listDic ds_stringForKey:@"componentId"];
                bannerModel.banner_id = [listDic ds_stringForKey:@"advertsId"];
                bannerModel.menuid = [listDic ds_stringForKey:@"menuId"];
                NSString *actionType = [listDic ds_stringForKey:@"actionType"];
                NSString *url = [listDic ds_stringForKey:@"url"];
                
                //如果actionType=-2,则特殊处理自定义完整ddeplink
                if (actionType.integerValue == -2) {
                    bannerModel.deeplink_uri = ZFToString(ZFEscapeString(url, YES));
                } else {
                    bannerModel.deeplink_uri = [NSString stringWithFormat:ZFCMSConvertDeepLinkString, actionType, url, bannerModel.name];
                }
                [bannerArr addObject:bannerModel];
            }
            
            if (bannerArr.count > 0) {
                ZFNewBannerModel *newBannerModel = [[ZFNewBannerModel alloc] init];
                newBannerModel.banners = bannerArr;
                newBannerModel.branch = [NSString stringWithFormat:@"%ld", bannerArr.count];
                [newBannerArray addObject:newBannerModel];
            }
        }
        if (completion) {
            completion(newBannerArray);
        }
    } target:self.controller];
}

/**
 * 统计个人中心banner内推广告
 */
- (void)analyticsGABanner:(NSArray<ZFNewBannerModel *> *)bannersArr {
    NSMutableArray *screenNames = [NSMutableArray array];
    for (ZFNewBannerModel *bannerModel in bannersArr) {
        NSMutableDictionary *banner = [NSMutableDictionary dictionary];
        for (ZFBannerModel *model in bannerModel.banners) {
            banner[@"name"] = [NSString stringWithFormat:@"%@_%@",ZFGAAccountInternalPromotion, model.name];
            [screenNames addObject:banner];
        }
    }
    if (screenNames.count > 0) {
        [ZFAnalytics showAdvertisementWithBanners:screenNames position:nil screenName:@"Account"];
    }
}

/**
 *  在requestAccountRecommendProduct接口前调用,重新获取第一页推荐商品数据,用于页面下拉刷新请求
 */
- (void)requestFirstPageRecommendProduct
{
    self.pageIndex = 1;
    [self.recommendProductList removeAllObjects];
}

/**
 *  获取个人中心推荐位商品
 */
- (void)requestAccountRecommendProduct:(void (^)(NSDictionary *object, NSError *error))completion
{
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.url = API(Port_GetAccountProduct);
    requestModel.taget = self.controller;
    requestModel.parmaters = @{
                               @"appsFlyerUID" : ZFToString([[AppsFlyerTracker sharedTracker] getAppsFlyerUID]),
                               ZFApiBtsUniqueID : ZFToString([GGAppsflyerAnalytics getAppsflyerDeviceId]),
                               @"page" : @(self.pageIndex),
                               };
    
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        NSDictionary *result = responseObject[ZFResultKey];
        if ([result isKindOfClass:[NSDictionary class]]) {
            NSArray *goodsList = result[@"goods_list"];
            
            if ([goodsList isKindOfClass:[NSArray class]]) {
                NSArray <ZFGoodsModel *> *resultList = [NSArray yy_modelArrayWithClass:[ZFGoodsModel class] json:goodsList];
                if (completion) {
                    NSInteger total_page = 1;
                    NSInteger cur_page = self.pageIndex;
                    
                    if ([goodsList count]) {
                        total_page = self.pageIndex + 1;
                    } else {
                        total_page = cur_page;
                    }
                    
                    NSDictionary *pageInfo = @{
                                               kTotalPageKey  : @(total_page),
                                               kCurrentPageKey: @(cur_page),
                                               };
                    
                    NSDictionary *afParams = result[@"af_params"];
                    NSDictionary *blockResult = @{
                                                  @"af_params" : afParams,
                                                  @"goods_list" : resultList,
                                                  @"pageInfo" : pageInfo
                                                  };
                    self.pageIndex += 1;
                    completion(blockResult, nil);
                    return;
                }
            }
        }
        if (completion) {
            completion(nil, [NSError errorWithDomain:NSURLErrorDomain code:404 userInfo:nil]);
        }
    } failure:^(NSError *error) {
        self.pageIndex--;
        if (completion) {
            completion(nil, error);
        }
    }];
}

/**
 *  获取个人中心推荐位商品
 */
- (void)requestAccountRecommend:(BOOL)isFirstPage
                     completion:(void (^)(NSDictionary *object, NSError *error))completion
{
    if (isFirstPage) {
        self.pageIndex = 1;
    } else {
        self.pageIndex += 1;
    }
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.url = API(Port_GetAccountProduct);
    requestModel.taget = self.controller;
    requestModel.parmaters = @{
                               @"appsFlyerUID" : ZFToString([[AppsFlyerTracker sharedTracker] getAppsFlyerUID]),
                               ZFApiBtsUniqueID : ZFToString([GGAppsflyerAnalytics getAppsflyerDeviceId]),
                               @"page" : @(self.pageIndex),
                               };    
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        NSDictionary *result = responseObject[ZFResultKey];
        if ([result isKindOfClass:[NSDictionary class]]) {
            NSArray *goodsList = result[@"goods_list"];
            
            if ([goodsList isKindOfClass:[NSArray class]]) {
                NSArray <ZFGoodsModel *> *resultList = [NSArray yy_modelArrayWithClass:[ZFGoodsModel class] json:goodsList];
                if (completion) {
                    NSInteger total_page = 1;
                    NSInteger cur_page = self.pageIndex;
                    if ([goodsList count]) {
                        total_page = self.pageIndex + 1;
                    } else {
                        total_page = cur_page;
                    }
                    NSDictionary *pageInfo = @{kTotalPageKey  : @(total_page),
                                               kCurrentPageKey: @(cur_page) };
                    
                    NSDictionary *afParams = result[@"af_params"];
                    NSDictionary *blockResult = @{@"af_params" : afParams,
                                                  @"goods_list" : resultList,
                                                  @"pageInfo" : pageInfo };
                    completion(blockResult, nil);
                    return;
                }
            }
        }
        self.pageIndex--;
        if (completion) {
            completion(nil, [NSError errorWithDomain:NSURLErrorDomain code:404 userInfo:nil]);
        }
    } failure:^(NSError *error) {
        self.pageIndex--;
        if (completion) {
            completion(nil, error);
        }
    }];
}

@end
