//
//  ZFGoodsShowsViewModel.m
//  ZZZZZ
//
//  Created by YW on 2019/3/5.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGoodsShowsViewModel.h"
#import "YWCFunctionTool.h"
#import "ZFPubilcKeyDefiner.h"
#import "ZFRequestModel.h"
#import "ZFNetwork.h"
#import "AccountManager.h"
#import "Constants.h"
#import "ZFProgressHUD.h"
#import "ZFApiDefiner.h"
#import "YWLocalHostManager.h"
#import "NSDictionary+SafeAccess.h"
#import "GoodsDetailModel.h"
#import "ZFGoodsShowsRelatedModel.h"
#import "ZFAnalytics.h"
#import <GGBrainKeeper/BrainKeeperManager.h>

@interface ZFGoodsShowsViewModel ()
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) NSInteger currentRelatedPage;
@end

@implementation ZFGoodsShowsViewModel

- (void)requestGoodsShowsData:(NSString *)goods_sku
                 isFirstPage:(BOOL)isFirstPage
                  completion:(void (^)(NSArray *showModelArr, NSDictionary *pageInfo))completion
                     failure:(void (^)(id))failure
{
    if (isFirstPage) {
        self.currentPage = 1;
    } else {
        self.currentPage += 1;
    }
    
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[@"simple"] = @"2";
    info[@"directory"] = @"65";
    info[@"type"] = @"9";
    info[@"sku"] = ZFToString(goods_sku);
    info[@"pageSize"] = @"10";
    info[@"loginUserId"] = USERID ?: @"0";
    info[@"site"] = @"ZZZZZcommunity";
    info[@"app_type"] = @"2";
    info[@"version"] = ZFToString(ZFSYSTEM_VERSION);
    info[@"page"] = @(self.currentPage);
    
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.isCommunityRequest = YES;
    requestModel.url = CommunityAPI;
    requestModel.parmaters = info;
    requestModel.eventName = @"show_goods";
    requestModel.pageName = @"goods_detail_show";
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        
        //没用到
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            responseObject = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        NSDictionary *dataDic = [responseObject ds_dictionaryForKey:ZFDataKey];
        NSArray *list = [dataDic ds_arrayForKey:ZFListKey];
        NSArray *showModelArr = [NSArray yy_modelArrayWithClass:[GoodsShowExploreModel class] json:list];
        if (completion) {
            NSNumber *totalPage = (showModelArr.count < 10) ? @(self.currentPage) : [dataDic ds_numberForKey:@"total"];
            NSDictionary *pageInfo = @{ kTotalPageKey  : totalPage,
                                        kCurrentPageKey: @(self.currentPage)};
            completion(showModelArr, pageInfo);
        }
    } failure:^(NSError *error) {
        self.currentPage --;
        if (failure) {
            failure(error);
        }
    }];
}

- (void)requestRelatedGoods:(NSString *)goods_sku
                isFirstPage:(BOOL)isFirstPage
                 completion:(void (^)(NSArray *relatedModelArr, NSDictionary *pageInfo))completion
                    failure:(void (^)(id))failure
{
    if (isFirstPage) {
        self.currentRelatedPage = 1;
    } else {
        self.currentRelatedPage += 1;
    }
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[@"simple"] = @"1";
    info[@"directory"] = @"77";
    info[@"type"] = @"9";
    info[@"sku"] = ZFToString(goods_sku);
    info[@"pageSize"] = @"10";
    info[@"loginUserId"] = USERID ?: @"0";
    info[@"site"] = @"ZZZZZcommunity";
    info[@"app_type"] = @"2";
    info[@"version"] = ZFToString(ZFSYSTEM_VERSION);
    info[@"page"] = @(self.currentRelatedPage);
    
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.isCommunityRequest = YES;
    requestModel.url = CommunityAPI;
    requestModel.parmaters = info;
    requestModel.eventName = @"related_goods";
    requestModel.pageName = @"goods_detail_show";
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        
        //没用到
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            responseObject = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        NSDictionary *dataDic = [responseObject ds_dictionaryForKey:ZFDataKey];
        NSArray *list = [dataDic ds_arrayForKey:ZFListKey];
        NSArray *relatedModelArr = [NSArray yy_modelArrayWithClass:[ZFGoodsShowsRelatedModel class] json:list];
        if (completion) {
            NSNumber *totalPage = (relatedModelArr.count < 10) ? @(self.currentRelatedPage) : [dataDic ds_numberForKey:@"total"];
            NSDictionary *pageInfo = @{ kTotalPageKey  : totalPage,
                                        kCurrentPageKey: @(self.currentRelatedPage)};
            completion(relatedModelArr, pageInfo);
        }
        // 统计show商品
        if (relatedModelArr.count > 0) {
            NSMutableArray *goodsn = [[NSMutableArray alloc] init];
            [relatedModelArr enumerateObjectsUsingBlock:^(ZFGoodsShowsRelatedModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [goodsn addObject:ZFToString(obj.goods_sn)];
            }];
            NSString *goodIds = [goodsn componentsJoinedByString:@","];
            NSDictionary *params = @{ @"af_content_type": @"view showpage",
                                      @"af_content_id" : ZFToString(goodIds),
                                      };
            [ZFAnalytics appsFlyerTrackEvent:@"af_view_showpage" withValues:params];
        }
        
    } failure:^(NSError *error) {
        self.currentRelatedPage --;
        if (failure) {
            failure(error);
        }
    }];
}


- (void)requestAddToCart:(NSString *)goodsId
             goodsNumber:(NSInteger)goodsNumber
              freeGiftId:(NSString *)freeGiftId
             loadingView:(UIView *)loadingView
              completion:(void (^)(id))completion
                 failure:(void (^)(id))failure
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"goods_id"] = ZFToString(goodsId);
    dict[@"num"] = @(goodsNumber);
    dict[@"token"] = ISLOGIN ? TOKEN : @"";
    dict[@"sess_id"] = ISLOGIN ? @"" : SESSIONID;
    dict[@"is_enc"] = @"0";
    if (ZFIsEmptyString(freeGiftId)) {
        dict[@"manzeng_id"] = ZFToString(freeGiftId);
    }
    
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.url = API(Port_addCart);
    requestModel.parmaters = dict;
    requestModel.eventName = @"add_to_bag";
    requestModel.taget = self.controller;
    
    ShowLoadingToView(loadingView);
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        HideLoadingFromView(loadingView);
        if (![responseObject[ZFResultKey][@"error"] boolValue]) {
            NSDictionary *resultDcit = responseObject[ZFResultKey];
            if (ZFJudgeNSDictionary(resultDcit)) {
                if (resultDcit[@"sess_id"]) {
                    SaveUserDefault(kSessionId, resultDcit[@"sess_id"]);
                }
                if (resultDcit[@"goods_count"]) {
                    SaveUserDefault(kCollectionBadgeKey, @([resultDcit[@"goods_count"] integerValue]));
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kCartNotification object:nil];
            if (completion) {
                completion(nil);
            }
            if (![dict[kSuccessNoShowToast] boolValue]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    ShowToastToViewWithText(loadingView, responseObject[ZFResultKey][@"msg"]);
                });
            }
        } else {
            id obj = responseObject[ZFResultKey];
            if (ZFJudgeNSDictionary(obj)) {
                NSString *tipMsg = ZFGetStringFromDict(obj, @"msg");
                if (!ZFIsEmptyString(tipMsg)) {
                    ShowToastToViewWithText(loadingView, tipMsg);
                }
            }
            if (failure) {
                failure(nil);
            }
        }
    } failure:^(NSError *error) {
        ShowToastToViewWithText(loadingView, error.domain);
        if (failure) {
            failure(nil);
        }
    }];
}

@end
