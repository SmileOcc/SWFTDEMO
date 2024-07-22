//
//  ZFCartViewModel.m
//  ZZZZZ
//
//  Created by YW on 2017/8/29.
//  Copyright © 2018年 YW. All rights reserved.
//
#import "ZFCartViewModel.h"
#import "ZFCartListModel.h"
#import "ZFCartListResultModel.h"
#import "ZFCartGoodsListModel.h"
#import "ZFCartGoodsModel.h"
#import "ZFOrderManager.h"
#import "ZFOrderCheckInfoModel.h"
#import "ZFOrderCheckInfoDetailModel.h"
#import <AVOSCloud/AVOSCloud.h>
#import "FastSettleApi.h"
#import "YWLocalHostManager.h"
#import "NSStringUtils.h"
#import "ZFProgressHUD.h"
#import "NSDictionary+SafeAccess.h"
#import "ZFAnalytics.h"
#import "ZFAnalyticsTimeManager.h"
#import "ExchangeManager.h"
#import "ZFRequestModel.h"
#import "AccountManager.h"
#import "Constants.h"
#import "YWCFunctionTool.h"
#import <GGAppsflyerAnalyticsSDK/GGAppsflyerAnalytics.h>
#import "ZFBranchAnalytics.h"
#import <GGBrainKeeper/BrainKeeperManager.h>
#import "GoodsDetailModel.h"
#import "ZFAppsflyerAnalytics.h"
#import "ZFBTSManager.h"

@implementation ZFCartViewModel

#pragma mark - 购物车所有请求操作
/**
 * 请求购物车列表数据
 * addGiftFlag: 是否需要自动在赠品列表中增加一个商品(V4.5.7版本)
 * ABTest: ab_cart: 0:旧版本(有选中) 1:新版本
 */
- (void)requestCartListWithGiftFlag:(NSString *)addGiftFlag
                         completion:(void (^)(ZFCartListResultModel *cartListModel))completion
                            failure:(void (^)(NSError *))failure
{
    NSNumber *ab_cartNum = [NSNumber numberWithInt:0];
    //V4.5.3以后
    ab_cartNum = [NSNumber numberWithInt:1]; //有优化时ab_cart传1, 其他传0
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.taget = self.controller;
    requestModel.url = API(Port_getCartList);
    
    requestModel.parmaters = @{@"token"    :  ISLOGIN ? TOKEN : @"",
                               @"sess_id"  :  ISLOGIN ? @"" : SESSIONID,
                               @"auto_add_gift" : ZFToString(addGiftFlag),
                               @"is_enc"   :  @"0",
                               @"ab_cart"  :  ab_cartNum,
                               @"bizhong"  : ZFToString([ExchangeManager localCurrencyName])
                               };
    
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        ZFCartListModel *cartListModel = [ZFCartListModel yy_modelWithJSON:responseObject];
        if (cartListModel.statusCode == 200){
            if (completion) {
                completion(cartListModel.result);
            }
        } else {
            if (failure) {
                failure(nil);
            }
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(nil);
        }
    }];
}

/**
 * 购物车切换商品规格
 */
+ (void)requestCartSizeColorData:(NSString *)goods_id
                      completion:(void (^)(GoodsDetailModel *goodsModel))completion
                         failure:(void (^)(NSError *))failure
{
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.url = API(Port_GoodsDetail);
    requestModel.parmaters = @{@"goods_id"      :  ZFToString(goods_id),
                               @"token"         :  ISLOGIN ? TOKEN : @"",
                               @"sess_id"       :  ISLOGIN ? @"" : SESSIONID,
                               @"appsFlyerUID"  :  ZFToString([[AppsFlyerTracker sharedTracker] getAppsFlyerUID]),
                               ZFApiBtsUniqueID : ZFToString([GGAppsflyerAnalytics getAppsflyerDeviceId]),
                               @"size_tips_bts" :  @(1), };
    
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        
        NSDictionary *resultDict = responseObject[ZFResultKey];
        if (ZFJudgeNSDictionary(resultDict) && [resultDict[@"error"] integerValue] == 0) {
            if (completion) {
                GoodsDetailModel *detailModel = [GoodsDetailModel yy_modelWithJSON:resultDict];
                completion(detailModel);
            }
        } else {
            //ShowErrorToastToViewWithResult(dict[kLoadingView], resultDict);
            if (failure) {
                NSError *error = [NSError errorWithDomain:ZFToString(resultDict[ZFMsgKey]) code:444 userInfo:nil];
                failure(error);
            }
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

/**
 * 生成订单
 */
- (void)requestCartCheckOutNetwork:(NSDictionary *)parmater
                        completion:(void (^)(id obj))completion
                           failure:(void (^)(NSError *error))failure
{
    ZFBTSModel *deliverytimeBtsModel = [ZFBTSManager getBtsModel:kZFBtsIosdeliverytime defaultPolicy:@"0"];
    NSString *auto_coupon = @"0";
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.eventName = @"checkout_info";
    requestModel.taget = self.controller;
    requestModel.url = API(Port_checkout);
    requestModel.parmaters = @{@"token"         :   TOKEN,
                               @"is_enc"        :   @"0",
                               @"auto_coupon"   :   auto_coupon,
                               @"ab_test_ship_desc"  :   ZFToString(deliverytimeBtsModel.policy)
    };
    
    [ZFAnalyticsTimeManager recordRequestStartTime:Port_checkout];
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        [ZFAnalyticsTimeManager recordRequestEndTime:Port_checkout];
        
        ZFOrderCheckInfoModel *InfoModel = [ZFOrderCheckInfoModel yy_modelWithJSON:responseObject[ZFResultKey]];
        InfoModel.order_info = [ZFOrderCheckInfoDetailModel yy_modelWithJSON:responseObject[ZFResultKey]];
        
        // 谷歌统计
        [[ZFAnalyticsTimeManager sharedManager] logTimeWithEventName:kFinishLoadingOrderDetail];
        if (InfoModel && [InfoModel isKindOfClass:[ZFOrderCheckInfoModel class]]) {
            if (completion) {
                completion(InfoModel);
            }
        }else{
            if (failure) {
                failure(nil);
            }
        }
    } failure:^(NSError *error) {
        // 谷歌统计
        [[ZFAnalyticsTimeManager sharedManager] logTimeWithEventName:kFinishLoadingOrderDetail];
        if (failure) {
            failure(error);
        }
    }];
}

/**
 * 快捷支付
 */
- (void)requestCartFastPayNetwork:(NSDictionary *)parmaters
                       completion:(void (^)(BOOL hasAddress, id obj))completion
                          failure:(void (^)(id obj))failure
{
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.eventName = @"quick_checkout";
    requestModel.taget = self.controller;
    requestModel.url = API(Port_fastPayCart);
    requestModel.parmaters = @{
                               @"sess_id"    : SESSIONID,
                               @"token"      : TOKEN,
                               @"payertoken" : ZFToString(parmaters[@"payertoken"]),
                               @"payerId"    : ZFToString(parmaters[@"payerId"]),
                               @"is_enc"     : @"0",
                               @"auto_coupon": @"0",//V5.4.0版本改成不自动使用最优coupon
                               @"device_id"  : ZFToString([AccountManager sharedManager].device_id)
                               };
    
    ShowLoadingToView(parmaters);
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        HideLoadingFromView(parmaters);
        if ([responseObject[ZFResultKey][@"error"] integerValue] == 0) {
            switch ([responseObject[ZFResultKey][@"data"][@"flag"] integerValue]) {
                case FastPaypalCheckTypeNoLoginAndNoRegiste:
                case FastPaypalCheckTypeNoLoginAndRegistedAndNoAddress: {
                    //自动登录
                    AccountModel *userModel = [AccountModel yy_modelWithJSON:responseObject[ZFResultKey][@"data"][@"user"]];
                    [self fastCheckOutAutoLogin:userModel];
                    if (completion) {
                        completion(NO, [ZFAddressInfoModel yy_modelWithJSON:responseObject[ZFResultKey][@"data"][@"address"]]);
                    }
                }
                    break;
                case FastPaypalCheckTypeNoLoginAndRegistedAndHasAddress: {
                    //自动登录
                    AccountModel *userModel = [AccountModel yy_modelWithJSON:responseObject[ZFResultKey][@"data"][@"user"]];
                    [self fastCheckOutAutoLogin:userModel];
                    if (completion) {
                        completion(YES, [ZFOrderCheckInfoDetailModel yy_modelWithJSON:responseObject[ZFResultKey][@"data"][@"check"]]);
                    }
                }
                    break;
                case FastPaypalCheckTypeLoginAndNoAddress: {
                    if (completion) {
                        completion(NO, [ZFAddressInfoModel yy_modelWithJSON:responseObject[ZFResultKey][@"data"][@"address"]]);
                    }
                }
                    break;
                case FastPaypalCheckTypeLoginAndHasAddress: {
                    //根据返回的状态来确定
                    if (completion) {
                        completion(YES, [ZFOrderCheckInfoDetailModel yy_modelWithJSON:responseObject[ZFResultKey][@"data"][@"check"]]);
                    }
                }
                    break;
            }
        }else  if ([responseObject[ZFResultKey][@"error"] integerValue] == 6) { // 添加的商品库存没了,返回购物车
            ShowToastToViewWithText(parmaters, responseObject[ZFResultKey][@"msg"]);
            if (completion) {
                completion(NO,@(YES));
            }
        }else{
            ShowToastToViewWithText(parmaters, responseObject[@"msg"]);
        }
    } failure:^(NSError *error) {
        ShowToastToViewWithText(parmaters, error.domain);
    }];
}

/**
 * 选择支付流程
 */
- (void)requestPaymentProcessCompletion:(void (^)(NSInteger state, NSString *msg))completion
                                failure:(void (^)(NSError *error))failure
{
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.eventName = @"get_checkout_flow";
    requestModel.taget = self.controller;
    requestModel.url = API(Port_GetCheckoutFlow);
    requestModel.parmaters = @{@"token" :   TOKEN,
                               @"is_enc":   @"0"};
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        NSDictionary *stateDict = [responseObject ds_dictionaryForKey:ZFResultKey];
        NSInteger state = [stateDict ds_integerForKey:@"checkout_flow"];
        NSString *message = [stateDict ds_stringForKey:@"msg"] ?: @"";
        if (completion) {
            completion(state, message);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

/**
 * 新增获取SOA快捷支付链接
 */
- (void)requestPayPaylProcessCompletion:(void (^)(NSInteger state, NSString *msg, NSString *url))completion
                                failure:(void (^)(id obj))failure
{
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.eventName = @"exp_check_cart";
    requestModel.taget = self.controller;
    requestModel.url = API(Port_NewGetCheckoutFlow);//API(Port_GetCheckoutFlow);
    requestModel.parmaters = @{@"token"     :   TOKEN,
                               @"is_enc"    :   @"0",
                               @"bizhong"   :   [ExchangeManager localCurrencyName],
                               @"sess_id"   :   ISLOGIN ? @"" : SESSIONID,
                               };
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        NSDictionary *stateDict = [responseObject ds_dictionaryForKey:ZFResultKey];
        NSInteger state = [stateDict ds_integerForKey:@"checkout_flow"];
        NSString *message = [stateDict ds_stringForKey:@"msg"] ?: @"";
        NSString *url = [stateDict ds_stringForKey:@"url"];
        if (completion) {
            completion(state, message, url);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

#pragma mark - private methods
//自动登录
- (void)fastCheckOutAutoLogin:(AccountModel *)userModel {
    [[AccountManager sharedManager] updateUserInfo:userModel];
    [[NSUserDefaults standardUserDefaults] setValue:userModel.email forKey:kUserEmail];
    
    // 保存LeandCloud数据
    [AccountManager saveLeandCloudData];
    
    [AppsFlyerTracker sharedTracker].customerUserID = [NSStringUtils isEmptyString:USERID] ? @"0" : USERID;
    
    // Branch
    [[ZFBranchAnalytics sharedManager] branchLoginWithUserId:[NSStringUtils isEmptyString:USERID] ? @"0" : USERID];
    
    //注册大数据统计用户id
    [GGAppsflyerAnalytics registerBigDataWithUserId:[NSStringUtils isEmptyString:USERID] ? @"0" : USERID];
    
    //登录通知
    [[NSNotificationCenter defaultCenter] postNotificationName:kLoginNotification object:nil];
}

@end

