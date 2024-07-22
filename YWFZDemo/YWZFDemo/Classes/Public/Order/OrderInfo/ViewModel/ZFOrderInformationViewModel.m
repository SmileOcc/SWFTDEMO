//
//  ZFOrderInformationViewModel.m
//  ZZZZZ
//
//  Created by YW on 2018/11/12.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFOrderInformationViewModel.h"
#import "ZFOrderManager.h"
#import "ZFOrderCheckDoneModel.h"
#import "ZFOrderCheckDoneDetailModel.h"
#import "ZFOrderCheckInfoModel.h"
#import "ZFOrderCheckInfoDetailModel.h"
#import "UserCouponModel.h"
#import "ZFAddressInfoModel.h"
#import "YWLocalHostManager.h"
#import "NSStringUtils.h"
#import "ZFProgressHUD.h"
#import "ZFLocalizationString.h"
#import "NSDictionary+SafeAccess.h"
#import "ZFAnalyticsTimeManager.h"
#import "YWCFunctionTool.h"
#import "ZFRequestModel.h"
#import <GGBrainKeeper/BrainKeeperManager.h>
#import "ZFBTSManager.h"

@implementation ZFOrderInformationViewModel

- (NSDictionary *)queryCheckoutInfoPublicParmas:(ZFOrderManager *)manager {
    return @{
             @"address_id"              :   [NSStringUtils emptyStringReplaceNSNull:manager.addressId],
             @"shipping"                :   [NSStringUtils emptyStringReplaceNSNull:manager.shippingId],
             @"insurance"               :   [NSStringUtils emptyStringReplaceNSNull:manager.insurance],
             @"currentPoint"            :   [NSStringUtils emptyStringReplaceNSNull:manager.currentPoint],
             @"payment"                 :   [NSStringUtils emptyStringReplaceNSNull:manager.paymentCode],
             //用于快速支付
             @"payertoken"              :   [NSStringUtils emptyStringReplaceNSNull:manager.payertoken],
             @"payerId"                 :   [NSStringUtils emptyStringReplaceNSNull:manager.payerId],
             @"node"                    :   NullFilter(manager.node),
             @"auto_coupon"             :   manager.autoCoupon,
             @"coupon"                  :   [NSStringUtils emptyStringReplaceNSNull:manager.couponCode],
             };
}

- (NSDictionary *)queryCheckDonePublicParmas:(ZFOrderManager *)manager {
    NSString *usePoint = manager.currentPoint;
    //如果用户选择了不使用积分，就传0
    if (!manager.isUsePoint) {
        usePoint = @"0";
    }

    NSDictionary *params = @{
                             @"coupon"                  :   [NSStringUtils emptyStringReplaceNSNull:manager.couponCode],
                             @"address_id"              :   [NSStringUtils emptyStringReplaceNSNull:manager.addressId],
                             @"shipping"                :   [NSStringUtils emptyStringReplaceNSNull:manager.shippingId],
                             @"need_traking_number"     :   [NSStringUtils emptyStringReplaceNSNull:manager.need_traking_number],
                             @"insurance"               :   [NSStringUtils emptyStringReplaceNSNull:manager.insurance],
                             @"point"                   :   [NSStringUtils emptyStringReplaceNSNull:usePoint],
                             @"payment"                 :   [NSStringUtils emptyStringReplaceNSNull:manager.paymentCode],
                             @"verifyCode"              :   [NSStringUtils emptyStringReplaceNSNull:manager.verifyCode],
                             @"bizhong"                 :   [NSStringUtils emptyStringReplaceNSNull:manager.bizhong],
                             @"node"                    :   NullFilter(manager.node),
                             @"order_id"                :   NullFilter(manager.orderID),
                             //用于快速支付
                             @"payertoken"              :   [NSStringUtils emptyStringReplaceNSNull:manager.payertoken],
                             @"payerId"                 :   [NSStringUtils emptyStringReplaceNSNull:manager.payerId],
                             //appflyer
                             @"media_source"            :   [NSStringUtils getAppsflyerParamsWithKey:MEDIA_SOURCE],
                             @"campaign"                :   [NSStringUtils getAppsflyerParamsWithKey:CAMPAIGN],
                             @"wj_linkid"               :   [NSStringUtils getLkid],
                             @"ad_id"                   :   [NSStringUtils getAdId], // 增加从appsflyer获取归因参数 并储存至网站后台
                             //用于催付
                             @"pid"                     : [NSStringUtils getPid],
                             @"c"                       : [NSStringUtils getC],
                             @"is_retargeting"          : [NSStringUtils getIsRetargeting],
                             @"appsflyer_params"        : [self appflyerParamsString],
                             //税号
                             @"customer_pcc"                  : ZFToString(manager.taxString),
                             @"aff_utm_source"          : [NSStringUtils getBranchParamsWithKey:UTM_SOURCE],
                             @"aff_utm_campaign"        : [NSStringUtils getBranchParamsWithKey:UTM_CAMPAIGN],
                             @"aff_utm_medium"          : [NSStringUtils getBranchParamsWithKey:UTM_MEDIUM],
                             @"aff_postback_id"         : [NSStringUtils getBranchParamsWithKey:POSTBACK_ID],
                             @"aff_mss_info"            : [NSStringUtils getBranchParamsWithKey:AFF_MSS_INFO]
                             };
    
    return params;
}

- (NSArray *)queryCheckInfoRequestParmasWithPayCode:(NSInteger)paycode managerArray:(NSArray *)managerArray {
    NSMutableArray *array = [NSMutableArray array];
    ZFOrderManager *manager = managerArray.firstObject;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self queryCheckoutInfoPublicParmas:manager]];
    [dict setObject: @(paycode) forKey:@"node"];
    [array addObject:dict];
    return array;
}

- (NSArray *)queryCheckDoneRequestParmasWithPayCode:(NSInteger)paycode managerArray:(NSArray *)managerArray {
    NSMutableArray *array = [NSMutableArray array];
    ZFOrderManager *manager = managerArray.firstObject;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self queryCheckDonePublicParmas:manager]];
    [dict setObject: @(paycode) forKey:@"node"];
    BOOL is_cod = [manager.paymentCode isEqualToString:@"Cod"] ? 1 : 0;
    [dict setObject:@(is_cod) forKey:@"isCod"];
    [array addObject:dict];
    return array;
}

- (void)requestCheckDoneOrder:(NSDictionary *)parmaters completion:(void (^)(NSArray<ZFOrderCheckDoneModel *> *dataArray))completion failure:(void (^)(id))failure
{
    ZFRequestModel *checkDoneModel = [[ZFRequestModel alloc] init];
    checkDoneModel.url = API(Prot_CartDone);
    checkDoneModel.parmaters = parmaters;
    checkDoneModel.eventName = @"create_order";
    checkDoneModel.taget = self.controller;
    [[ZFAnalyticsTimeManager sharedManager] requestSuccessTimeWithRequestAction:Prot_CartDone requestTime:ZFRequestTimeBegin];
    
    [ZFNetworkHttpRequest sendRequestWithParmaters:checkDoneModel success:^(id responseObject) {
        [[ZFAnalyticsTimeManager sharedManager] requestSuccessTimeWithRequestAction:Prot_CartDone requestTime:ZFRequestTimeEnd];
        id result = responseObject[ZFResultKey];
        if ([result isKindOfClass:[NSDictionary class]]) {
            ZFOrderCheckDoneModel *doneModel = [ZFOrderCheckDoneModel yy_modelWithJSON:result];
            doneModel.order_info = [ZFOrderCheckDoneDetailModel yy_modelWithJSON:result];
            NSInteger errorCode = [result[@"error"] integerValue];
            ShowErrorToastToViewWithResult(nil, result);
            if (errorCode == 6) {
                // 添加的商品库存没了,返回购物车
                doneModel.isBackToCart = YES;
            }
            if (completion && doneModel) {
                if (errorCode == 0 || errorCode == 6) {
                    completion(@[doneModel]);
                } else {
                    if (failure) {
                        failure(ZFToString(result[@"msg"]));
                    }
                }
            } else {
                if (failure) {
                    failure(nil);
                }
            }
        }else{
            if (failure) {
                failure(nil);
            }
        }
    } failure:^(NSError *error) {
        HideLoadingFromView(nil);
        if (failure) {
            failure(nil);
        }
    }];
}

- (void)requestCheckInfoNetwork:(NSDictionary *)parmaters completion:(void (^)(NSArray<ZFOrderCheckInfoModel *>* dataArray))completion failure:(void (^)(id))failure {
    
    ShowLoadingToView(parmaters);
    ZFRequestModel *checkInfoModel = [[ZFRequestModel alloc] init];
    checkInfoModel.url = API(Port_checkout);
    
    ZFBTSModel *deliverytimeBtsModel = [ZFBTSManager getBtsModel:kZFBtsIosdeliverytime defaultPolicy:@"0"];
    
    NSMutableDictionary *parmaterInfo = [NSMutableDictionary dictionaryWithDictionary:parmaters[@"order_info"]];
    parmaterInfo[@"ab_test_ship_desc"] = ZFToString(deliverytimeBtsModel.policy);
    // 从商详一键(快速)购买过来时,需要带入相应参数
    if (ZFJudgeNSDictionary(self.detailFastBuyInfo)) {
        [parmaterInfo addEntriesFromDictionary:self.detailFastBuyInfo];
    }
    checkInfoModel.parmaters = parmaterInfo;
    checkInfoModel.eventName = @"checkout_info";
    checkInfoModel.taget = self.controller;
    
    [[ZFAnalyticsTimeManager sharedManager] requestSuccessTimeWithRequestAction:Port_checkout requestTime:ZFRequestTimeBegin];
    [ZFNetworkHttpRequest sendRequestWithParmaters:checkInfoModel success:^(id responseObject) {
        
        HideLoadingFromView(parmaters);
        [[ZFAnalyticsTimeManager sharedManager] requestSuccessTimeWithRequestAction:Port_checkout requestTime:ZFRequestTimeEnd];
        
        id result = responseObject[ZFResultKey];
        if ([result isKindOfClass:[NSDictionary class]]) {
            ZFOrderCheckInfoModel *model = [ZFOrderCheckInfoModel yy_modelWithJSON:result];
            model.order_info = [ZFOrderCheckInfoDetailModel yy_modelWithJSON:result];
            NSInteger errorCode = [result[@"error"] integerValue];
            ShowErrorToastToViewWithResult(nil, result);
            if (errorCode == 6) {
                // 添加的商品库存没了,返回购物车
                model.isBackToCart = YES;
            }
            if (completion && model) {
                if (errorCode == 0 || errorCode == 6) {
                    completion(@[model]);
                }
            }
        }else{
            YWLog(@"数据格式返回错误");
        }
    } failure:^(NSError *error) {
        HideLoadingFromView(parmaters);
        ShowToastToViewWithText(nil, error.domain);
        if (failure) {
            failure(nil);
        }
    }];
}

- (void)requestPaymentProcess:(id)parmaters  Completion:(void (^)(NSInteger state))completion failure:(void (^)(id obj))failure {
    NSDictionary *dict = parmaters;
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.url = API(Port_GetCheckoutFlow);
    requestModel.eventName = @"get_checkout_flow";
    requestModel.taget = self.controller;
    ShowLoadingToView(dict);
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        HideLoadingFromView(dict);
        NSDictionary *stateDict = [responseObject ds_dictionaryForKey:ZFResultKey];
        NSInteger state = [stateDict ds_integerForKey:@"checkout_flow"];
        NSInteger errorCode = [stateDict[@"error"] integerValue];
        NSString *message = [stateDict ds_stringForKey:@"msg"] ?: @"";
        ShowToastToViewWithText(dict, message);
        if (completion && errorCode == 0) {
            completion(state);
        }
    } failure:^(NSError *error) {
        HideLoadingFromView(dict);
        ShowToastToViewWithText(nil, error.domain);
        if (failure) {
            failure(error);
        }
    }];
}

- (void)sendPhoneCod:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    NSDictionary *dict = parmaters;
    ZFRequestModel *sendPhoneCodModel = [[ZFRequestModel alloc] init];
    sendPhoneCodModel.eventName = @"cod_verify";
    sendPhoneCodModel.taget = self.controller;
    sendPhoneCodModel.url = API(@"cart/checkout_verify");
    sendPhoneCodModel.parmaters = @{@"address_id" :
                                    dict[@"address_id"]};
    ShowLoadingToView(nil);
    [ZFNetworkHttpRequest sendRequestWithParmaters:sendPhoneCodModel success:^(id responseObject) {
        HideLoadingFromView(nil);
        id result = responseObject[ZFResultKey];
        if ([result isKindOfClass:[NSDictionary class]]) {
            NSInteger errorCode = [result[@"error"] integerValue];
            if (errorCode == 0) {// 成功收到验证码
                if (completion) {
                    completion(nil);
                }
            }else{
                // 显示错误消息
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    ShowErrorToastToViewWithResult(parmaters[kLoadingView], result);
                });
            }
        }else{
            ShowToastToViewWithText(nil, ZFLocalizedString(@"EmptyCustomViewManager_titleLabel",nil));
        }
    } failure:^(NSError *error) {
        HideLoadingFromView(nil);
        ShowToastToViewWithText(nil, ZFLocalizedString(@"EmptyCustomViewManager_titleLabel",nil));
    }];
}

- (void)requestCartBadgeNum {
    ZFRequestModel *cartNumModel = [[ZFRequestModel alloc] init];
    cartNumModel.url = API(@"cart/get_cart_num");
    cartNumModel.eventName = @"get_cart_num";
    cartNumModel.taget = self.controller;
    [[ZFAnalyticsTimeManager sharedManager] requestSuccessTimeWithRequestAction:@"cart/get_cart_num" requestTime:ZFRequestTimeBegin];
    [ZFNetworkHttpRequest sendRequestWithParmaters:cartNumModel success:^(id responseObject) {
        [[NSUserDefaults standardUserDefaults] setValue:@([responseObject[ZFResultKey] integerValue]) forKey:kCollectionBadgeKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[ZFAnalyticsTimeManager sharedManager] requestSuccessTimeWithRequestAction:@"cart/get_cart_num" requestTime:ZFRequestTimeEnd];
    } failure:^(NSError *error) {
        
    }];
}

+ (void)requestPayTag:(NSString *)orderSN step:(NSString *)step {
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.url = API(Port_orderPayTag);
    requestModel.parmaters = @{
                               @"order_sn" : ZFToString(orderSN),
                               @"step"     : step,
                               @"click_time" : [NSStringUtils getCurrentMSimestamp]
                               };
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
    } failure:^(NSError *error) {
    }];
}

- (NSString *)appflyerParamsString {
    NSMutableString *params = [NSMutableString new];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appflyerDict   = [userDefaults objectForKey:APPFLYER_ALL_PARAMS];
    for (NSString *key in appflyerDict.allKeys) {
        NSString *value = [appflyerDict ds_stringForKey:key];
        [params appendFormat:@"%@=%@", key, value];
        if (![key isEqualToString:appflyerDict.allKeys.lastObject]) {
            [params appendString:@"##"];
        }
    }
    return params;
}



@end
