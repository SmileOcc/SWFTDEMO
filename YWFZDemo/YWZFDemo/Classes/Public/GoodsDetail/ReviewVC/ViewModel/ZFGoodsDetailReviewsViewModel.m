//
//  ZFGoodsDetailReviewsViewModel.m
//  ZZZZZ
//
//  Created by YW on 2017/11/25.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFGoodsDetailReviewsViewModel.h"
#import "GoodsDetailsReviewsModel.h"
#import "YWLocalHostManager.h"
#import "YWCFunctionTool.h"
#import "ZFRequestModel.h"
#import "Constants.h"
#import "GoodsDetailsReviewsListModel.h"
#import "ZFBTSManager.h"
#import "ZFAnalytics.h"

@implementation ZFGoodsDetailReviewsViewModel

+ (void)requestReviewsData:(id)parmaters
                completion:(void (^)(id))completion
                   failure:(void (^)(id))failure
{
    if (!ZFJudgeNSDictionary(parmaters)) {
        parmaters = @{};
    }
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.url = API(Port_GoodsReviews);
    requestModel.parmaters = @{
        @"goods_id"    : ZFToString(parmaters[@"goods_id"]),
        @"goods_sn"    : ZFToString(parmaters[@"goods_sn"]),
        @"page"        : parmaters[@"page"] ? parmaters[@"page"] : @(1),
        @"page_size"   : parmaters[@"page_size"] ? parmaters[@"page_size"] : @(10),
        @"sort"        : ZFToString(parmaters[@"sort"]),
        @"is_enc"      : @"0"
    };
    //刷新时，就统计一次
    if ([requestModel.parmaters[@"page"] integerValue] == 1) {
        NSDictionary *params = @{ @"af_content_type": @"view reviepage" };
        [ZFAnalytics appsFlyerTrackEvent:@"af_view_reviewpage" withValues:params];
    }
    
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        
        GoodsDetailsReviewsModel *reviewsModel = [GoodsDetailsReviewsModel yy_modelWithJSON:responseObject[ZFResultKey]];
        
        if (completion) {
            completion(reviewsModel);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(nil);
        }
    }];
}

@end
