//
//  ZFBTSManager.m
//  ZZZZZ
//
//  Created by YW on 2019/3/1.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFBTSManager.h"
#import "ZFRequestModel.h"
#import "YWCFunctionTool.h"
#import "Constants.h"
#import "ZFMergeRequest.h"
#import "YWLocalHostManager.h"
#import <AppsFlyerLib/AppsFlyerTracker.h>
#import "AFNetworking.h"
#import "YWLocalHostManager.h"
#import "ZFBTSDataSets.h"
#import "ZFLocalizationString.h"
#import <GGAppsflyerAnalyticsSDK/GGAppsflyerAnalytics.h>

@interface ZFBTSManager ()
@property (nonatomic, strong) NSMutableDictionary *btsDictionary;
@end

@implementation ZFBTSManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static ZFBTSManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[ZFBTSManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.btsDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

/**
 * 异步从网络获取BTS实验数据
 */
+ (NSURLSessionDataTask *)asynGetBtsModel:(NSString *)plancode
                            defaultPolicy:(NSString *)defaultPolicy
                          timeoutInterval:(NSTimeInterval)timeoutInterval
                        completionHandler:(void (^)(ZFBTSModel *model, NSError *error))completionHandler
{
    ZFBTSModel *model = [[ZFBTSManager sharedInstance].btsDictionary objectForKey:ZFToString(plancode)];
    if ([model isKindOfClass:[ZFBTSModel class]]) { //App生命周期内只请求一次
        if (completionHandler) {
            completionHandler(model, nil);
        }
        return nil;
    }
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.url = [YWLocalHostManager appBtsSingleUrl];
    requestModel.forbidEncrypt = YES;//禁止加密时底层不做任何处理,走AFNetwork原生请求
    requestModel.forbidAddPublicArgument = YES; //bts请求不加公共参数
    requestModel.timeOut = timeoutInterval;
    requestModel.pageName = @"BTS";
    requestModel.eventName = ZFToString(plancode);
    requestModel.parmaters = @{@"appkey"    : @"ZF",
                               @"cookie"    : ZFToString([[AppsFlyerTracker sharedTracker] getAppsFlyerUID]),
                               @"cookieNew"    : ZFToString([GGAppsflyerAnalytics getAppsflyerDeviceId]),
                               @"plancode"  : ZFToString(plancode),
//                               @"params"    : [self fetchBtsOtherParams],
                               };
    return [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        
        ZFBTSModel *btsModel = [ZFBTSManager defaultBtsModel];
        btsModel.policy = ZFToString(defaultPolicy);
        btsModel.plancode = plancode;
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:404 userInfo:nil];
        
        if ([responseObject[@"code"] integerValue] == 200) {
            NSDictionary *result = responseObject[@"result"];
            if (ZFJudgeNSDictionary(result) && result.count>0) {
                btsModel = [ZFBTSModel yy_modelWithJSON:result];
                [[ZFBTSManager sharedInstance].btsDictionary setObject:btsModel forKey:ZFToString(plancode)];
                //把获取到的BTS数据，加入到队列中
                [[ZFBTSDataSets sharedInstance] addObject:btsModel];
                error = nil;
            }
        }
        if (error) {
            [[ZFBTSManager sharedInstance].btsDictionary setObject:btsModel forKey:ZFToString(btsModel.plancode)];
        }
        if (completionHandler) {
            completionHandler(btsModel, error);
        }
    } failure:^(NSError *error) {
        if (completionHandler) {
            ZFBTSModel *btsModel = [ZFBTSManager defaultBtsModel];
            btsModel.policy = ZFToString(defaultPolicy);
            btsModel.plancode = plancode;
            [[ZFBTSManager sharedInstance].btsDictionary setObject:btsModel forKey:ZFToString(btsModel.plancode)];
            completionHandler(btsModel, error);
        }
    }];
}

/**
 * 请求Bts的公共参数
 */
+ (NSDictionary *)fetchBtsOtherParams
{
    ZFAddressCountryModel *accountModel = [AccountManager sharedManager].accountCountryModel;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"nation"] = ZFToString(accountModel.region_name);//国家名称
    params[@"terminal"] = @"IOS";//端平台
    params[@"productlinecode"] = @"ZZZZZ";//产品线
    params[@"nationstation"] = ZFToString(GetUserDefault(kLocationInfoPipeline));//国家站
    params[@"languagestation"] = ZFToString([[ZFLocalizationString shareLocalizable] currentLanguageName]);//语言全称
    
    BOOL isNewUser = [[AccountManager sharedManager].af_user_type isEqualToString:@"1"];
    params[@"userflag"] = isNewUser ? @"新用户" : @"老用户"; //不要怀疑:bts大佬要我们传中文
    return params;
}

/**
 *  异步从网络获取BTS一组实验数据(数组方式)
 *  @params  plancodeInfo: @{plancode: DefaultPolicy}
 *  @params timeoutInterval 接口超时时间
 *  @params completionHandler 回调函数，主线程回调
 */
+ (NSURLSessionDataTask *)requestBtsModelList:(NSDictionary *)requestPlancodeInfo
                              timeoutInterval:(NSTimeInterval)timeoutInterval
                            completionHandler:(void (^)(NSArray <ZFBTSModel *> *modelArray, NSError *error))completionHandler
{
    NSMutableArray *hasReqBtsModelArray = [NSMutableArray array];
    NSMutableArray *needReqBtsKeyArray = [NSMutableArray array];
    NSMutableDictionary *realRequrequestPlancodeInfoDict = [NSMutableDictionary dictionaryWithDictionary:requestPlancodeInfo];
    
    for (NSString *plancode in requestPlancodeInfo.allKeys) {
        if (ZFIsEmptyString(plancode)) continue;
        ZFBTSModel *model = [self containsBtsForKey:plancode];
        if ([model isKindOfClass:[ZFBTSModel class]]) {
            [hasReqBtsModelArray addObject:model];
            [realRequrequestPlancodeInfoDict removeObjectForKey:ZFToString(model.plancode)];
        } else {
            [needReqBtsKeyArray addObject:plancode];
        }
    }
    if (needReqBtsKeyArray.count == 0) {
        if (completionHandler) {
            completionHandler(hasReqBtsModelArray, nil);
        }
        return nil;
    }
    NSString *appsFlyerId = [[AppsFlyerTracker sharedTracker] getAppsFlyerUID];
    NSMutableArray *paramsArray = [NSMutableArray array];
    
    for (NSString *plancode in needReqBtsKeyArray) {
        if (ZFIsEmptyString(plancode)) continue;
        [paramsArray addObject:@{
            @"appkey"    : @"ZF",
            @"cookie"    : ZFToString(appsFlyerId),
            @"plancode"  : ZFToString(plancode),
            @"cookieNew"    : ZFToString([GGAppsflyerAnalytics getAppsflyerDeviceId]),
        }];
    }
    // 同一个BTS在App生命周期内只请求一次
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.url = [YWLocalHostManager appBtsListUrl];
    requestModel.forbidEncrypt = YES;//禁止加密时底层不做任何处理,走AFNetwork原生请求
    requestModel.forbidAddPublicArgument = YES; //bts请求不加公共参数
    requestModel.timeOut = timeoutInterval;
    requestModel.pageName = @"BTS";
    requestModel.eventName = @"shuntList";
    requestModel.parmaters = @{@"engineShuntParams" : paramsArray};

    return [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:404 userInfo:nil];
        NSMutableArray *btsModelArray = [NSMutableArray array];
        NSMutableDictionary *comparePlancodeInfo = [NSMutableDictionary dictionaryWithDictionary:realRequrequestPlancodeInfoDict];
        
        if ([responseObject[@"code"] integerValue] == 200) {
            NSArray *resultList = responseObject[@"result"];
            if (ZFJudgeNSArray(resultList) && resultList.count>0) {
                error = nil;
                for (NSDictionary *btsInfoDict in resultList) {
                    if (!ZFJudgeNSDictionary(btsInfoDict)) continue;
                    ZFBTSModel *btsModel = [ZFBTSModel yy_modelWithJSON:btsInfoDict];
                    [[ZFBTSManager sharedInstance].btsDictionary setObject:btsModel forKey:ZFToString(btsModel.plancode)];
                    [btsModelArray addObject:btsModel];
                    [comparePlancodeInfo removeObjectForKey:ZFToString(btsModel.plancode)];
                }
                // 防止服务端返回的plancode个数不一致
                if (comparePlancodeInfo.allKeys.count != 0) {
                    NSArray *leaveBtsArray = [self fetchBtsModelArray:comparePlancodeInfo];
                    [btsModelArray addObjectsFromArray:leaveBtsArray];
                    
                    for (ZFBTSModel *btsModel in leaveBtsArray) {
                        [[ZFBTSManager sharedInstance].btsDictionary setObject:btsModel forKey:ZFToString(btsModel.plancode)];
                    }
                }
            }
        }
        if (error) {
            btsModelArray = [NSMutableArray arrayWithArray:[self saveDefalutBtsFromFail:realRequrequestPlancodeInfoDict]];
        }
        if (completionHandler) {
            completionHandler(btsModelArray, error);
        }
    } failure:^(NSError *error) {
        NSArray *defaultBtsArray = [self saveDefalutBtsFromFail:realRequrequestPlancodeInfoDict];
        if (completionHandler) {
            completionHandler(defaultBtsArray, error);
        }
    }];
}

+ (NSArray *)saveDefalutBtsFromFail:(NSDictionary *)requestPlancodeInfo {
    NSArray *defaultBtsArray = [self fetchBtsModelArray:requestPlancodeInfo];
    for (ZFBTSModel *btsModel in defaultBtsArray) {
        [[ZFBTSManager sharedInstance].btsDictionary setObject:btsModel forKey:ZFToString(btsModel.plancode)];
    }
    return defaultBtsArray;
}

+ (NSArray *)fetchBtsModelArray:(NSDictionary *)plancodeInfo {
    NSMutableArray *btsModelArray = [NSMutableArray array];
    for (NSString *plancode in plancodeInfo.allKeys) {
        if (ZFIsEmptyString(plancode)) continue;
        ZFBTSModel *btsModel = [ZFBTSManager defaultBtsModel];
        btsModel.plancode = plancode;
        btsModel.policy = plancodeInfo[plancode];
        [btsModelArray addObject:btsModel];
    }
    return btsModelArray;
}

+ (NSString *)getBtsPolicyWithCode:(NSString *)plancode defaultPolicy:(NSString *)defaultPolicy {
    ZFBTSModel *btsModel = [ZFBTSManager getBtsModel:plancode defaultPolicy:defaultPolicy];
    return btsModel.policy;
}

/**
 * 清除Bts数据
 * @param plancodArray 支持清除指定plancode的bts,传空清除所有
 */
+ (void)clearBTSWithPlancodeArray:(NSArray<NSString *> *)plancodArray {
    if (plancodArray && !ZFJudgeNSArray(plancodArray)) return;
    
    if (plancodArray.count > 0) {
        NSDictionary *tmpDict = [NSDictionary dictionaryWithDictionary:[ZFBTSManager sharedInstance].btsDictionary];
        for (NSString *plancod in plancodArray) {
            if (ZFIsEmptyString(plancod)) continue;
            
            for (ZFBTSModel *model in tmpDict.allKeys) {
                if (![model isKindOfClass:[ZFBTSModel class]]) continue;
                if ([model.policy isEqualToString:plancod]) {
                    [[ZFBTSManager sharedInstance].btsDictionary removeObjectForKey:plancod];
                }
            }
        }
    } else {
        [[ZFBTSManager sharedInstance].btsDictionary removeAllObjects];
    }
}

+ (ZFBTSModel *)getBtsModel:(NSString *)plancode defaultPolicy:(NSString *)defaultPolicy {
    if (ZFIsEmptyString(plancode)) {
        return [self defaultBtsModel];
    }
    ZFBTSManager *manaer = [ZFBTSManager sharedInstance];
    if ([manaer.btsDictionary objectForKey:plancode]) {
        id model = manaer.btsDictionary[plancode];
        if ([model isKindOfClass:[ZFBTSModel class]]) {
            return model;
        }
    }
    if (!ZFIsEmptyString(defaultPolicy)) {
        ZFBTSModel *defaultModel = [self defaultBtsModel];
        defaultModel.policy = defaultPolicy;
        return defaultModel;
    }
    return [self defaultBtsModel];
}

/// App生命周期内是否已经请求保存过
+ (ZFBTSModel *)containsBtsForKey:(NSString *)plancode {
    ZFBTSModel *model = [[ZFBTSManager sharedInstance].btsDictionary objectForKey:ZFToString(plancode)];
    if ([model isKindOfClass:[ZFBTSModel class]]) {
        return model;
    } else {
        return nil;
    }
}

#pragma mark - private method

+ (ZFBTSModel *)defaultBtsModel {
    ZFBTSModel *model = [[ZFBTSModel alloc] init];
    model.bucketid = @"-1";
    model.planid = @"-1";
    model.plancode = @"-1";
    model.policy = @"";
    model.versionid = @"-1";
    return model;
}

@end
