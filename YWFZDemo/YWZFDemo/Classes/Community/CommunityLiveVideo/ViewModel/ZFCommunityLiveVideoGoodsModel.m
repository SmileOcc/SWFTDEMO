//
//  ZFCommunityLiveVideoGoodsModel.m
//  ZZZZZ
//
//  Created by YW on 2019/4/2.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityLiveVideoGoodsModel.h"
#import "YWLocalHostManager.h"
#import "NSStringUtils.h"
#import "ZFProgressHUD.h"
#import "NSDictionary+SafeAccess.h"
#import "NSUserDefaults+SafeAccess.h"
#import "ZFAnalytics.h"
#import "ZFFrameDefiner.h"
#import "ZFRequestModel.h"
#import "Configuration.h"
#import "YWCFunctionTool.h"


@interface ZFCommunityLiveVideoGoodsModel()

@end

@implementation ZFCommunityLiveVideoGoodsModel

- (NSMutableArray<ZFGoodsModel *> *)goodsArray {
    if (!_goodsArray) {
        _goodsArray = [[NSMutableArray alloc] init];
    }
    return _goodsArray;
}

- (NSMutableArray<ZFGoodsDetailCouponModel *> *)couponsArray {
    if (!_couponsArray) {
        _couponsArray = [[NSMutableArray alloc] init];
    }
    return _couponsArray;
}

-(void)requestLiveVideoGoodsData:(BOOL)firstPage videoCoupon:(NSString *)coupon skus:(NSString *)skus completion:(void (^)(NSArray<ZFGoodsModel*> *postModel,NSDictionary *goodsArray))completion failure:(void (^)(id obj))failure {
    
    if (firstPage) {
        [self.goodsArray removeAllObjects];
    }
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.url = API(Port_GoodsGet_coupon_goods);
    requestModel.needToCache = NO;
    
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[@"g_coupon_id"] = ZFToString(coupon);
    info[@"skus"] = ZFToString(skus);
    requestModel.parmaters = info;
    
    [ZFNetworkHttpRequest sendExtensionRequestWithParmaters:requestModel success:^(id responseObject) {
        NSArray *parentModelArray = @[];
        
        NSDictionary *resultDic = [responseObject ds_dictionaryForKey:@"result"];
        NSArray *goodsArray = [resultDic ds_arrayForKey:@"goods"];
        NSDictionary *couponDic = [resultDic ds_dictionaryForKey:@"coupon"];
        
        if (ZFJudgeNSArray(goodsArray)) {
            parentModelArray = [NSArray yy_modelArrayWithClass:[ZFGoodsModel class] json:goodsArray];
            [self.goodsArray addObjectsFromArray:parentModelArray];
        }
        if (ZFJudgeNSDictionary(couponDic)) {
            self.couponModel = [ZFGoodsDetailCouponModel yy_modelWithJSON:couponDic];
        }
        
        if (completion) {
            
            NSDictionary *pageInfo = @{ kTotalPageKey  : @(1),
                                        kCurrentPageKey: @(1) };
            
            completion(parentModelArray,pageInfo);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

-(void)requestLiveVideoCouponsData:(BOOL)firstPage coupon:(NSString *)coupons completion:(void (^)(NSArray<ZFGoodsDetailCouponModel*> *couponsArray,NSDictionary *pageInfo))completion failure:(void (^)(id obj))failure {
    
    if (firstPage) {
        [self.couponsArray removeAllObjects];
    }
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.url = API(Port_GoodsGet_coupon_lists);
    requestModel.needToCache = NO;
    
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[@"coupon_id_str"] = ZFToString(coupons);
    requestModel.parmaters = info;
    
    [ZFNetworkHttpRequest sendExtensionRequestWithParmaters:requestModel success:^(id responseObject) {
        NSArray *parentModelArray = @[];
        NSArray *couponsArray = [responseObject ds_arrayForKey:@"result"];
        
        if (ZFJudgeNSArray(couponsArray)) {
            parentModelArray = [NSArray yy_modelArrayWithClass:[ZFGoodsDetailCouponModel class] json:couponsArray];
            [self.couponsArray addObjectsFromArray:parentModelArray];
        }

        if (completion) {
            
            NSDictionary *pageInfo = @{ kTotalPageKey  : @(1),
                                        kCurrentPageKey: @(1) };
            
            completion(parentModelArray,pageInfo);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}
/**
 * 详情页面领取coupon
 */
+ (void)requestGetGoodsCoupon:(NSString *)couponId
                   completion:(void (^)(BOOL success, NSInteger couponStatus))completion
{
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.url = API(Port_GoodsDetailGetCoupon);
    requestModel.parmaters = @{
                               @"couponId" : ZFToString(couponId),
                               @"user_id"  : ZFToString([[AccountManager sharedManager] userId])
                               };
    
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        if (completion) {
            NSDictionary *dataDic = [responseObject ds_dictionaryForKey:ZFResultKey];
            // couponStatus 1:可领取;2:领券Coupon不存在;3:已领券;4:没到领取时间;5:已过期;6:coupon 已领取完;7:赠送coupon 失败
            NSInteger couponStatus = [dataDic ds_integerForKey:@"couponStatus"];
            completion(YES, couponStatus);
        }
    } failure:^(NSError *error) {
        if (completion) {
            completion(NO, 0);
        }
    }];
}


@end
