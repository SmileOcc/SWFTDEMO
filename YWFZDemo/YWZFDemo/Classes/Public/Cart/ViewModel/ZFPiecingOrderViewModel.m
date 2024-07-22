//
//  ZFPiecingOrderViewModel.m
//  ZZZZZ
//
//  Created by YW on 2018/9/15.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFPiecingOrderViewModel.h"
#import "ZFPiecingOrderPriceModel.h"
#import "YWLocalHostManager.h"
#import "ZFProgressHUD.h"
#import "NSDictionary+SafeAccess.h"
#import "YWCFunctionTool.h"
#import "ZFRequestModel.h"
#import "AccountManager.h"
#import "Constants.h"

@implementation ZFPiecingOrderViewModel

/**
 * 购物车-凑单商品列表标签页
 */
+ (void)requestPiecingOrderData:(NSString *)price_index
                 finishedHandle:(void (^)(NSDictionary *resultDict))finishedHandle {
    
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.url = API(Port_getShippingGoods);
    requestModel.parmaters = @{@"price_index": ZFToString(price_index),
                               @"sess_id"  :  [AccountManager sharedManager].isSignIn ? @"" : SESSIONID,
                               };;
    
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        if (finishedHandle) {
            NSDictionary *resultDict = [responseObject ds_dictionaryForKey:ZFResultKey];
            finishedHandle(resultDict);
        }
    } failure:^(NSError *error) {
        if (finishedHandle) {
            finishedHandle(nil);
        }
    }];
}

/**
 * 请求精选商品列表 (从deeplink进来)
 */
+ (void)requestHandpickGoodsList:(NSString *)goodsIDs
                      completion:(void (^)(NSArray<ZFGoodsModel *> *goodsModelArray))completion {
    
    ZFRequestModel *model = [[ZFRequestModel alloc] init];
    model.url = API(Port_categorySearch);
    model.parmaters = @{@"goods_sn" : ZFToString(goodsIDs)};
    
    [ZFNetworkHttpRequest sendRequestWithParmaters:model success:^(id responseObject) {
        HideLoadingFromView(nil);
        NSArray<ZFGoodsModel *> *goodsModelArray = @[];
        
        NSDictionary *resultDict = responseObject[ZFResultKey];
        if (ZFJudgeNSDictionary(resultDict)) {
            NSArray *goodsListArr = resultDict[@"goods_list"];
            if (ZFJudgeNSArray(goodsListArr)) {
                goodsModelArray = [NSArray yy_modelArrayWithClass:[ZFGoodsModel class] json:goodsListArr];
                if (completion) {
                    completion(goodsModelArray);
                    return ;
                }
            }
        }
        if (completion) {
            YWLog(@"从deeplink进来====%@", goodsModelArray);
            completion(goodsModelArray);
        }
    } failure:^(NSError *error) {
        HideLoadingFromView(nil);
        if (completion) {
            completion(nil);
        }
    }];
}

@end
