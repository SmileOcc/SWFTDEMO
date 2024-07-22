//
//  ZFCMSRecommendViewModel.m
//  ZZZZZ
//
//  Created by YW on 2019/6/13.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCMSRecommendViewModel.h"
#import "ZFRequestModel.h"
#import "ZFPubilcKeyDefiner.h"
#import "YWCFunctionTool.h"
#import "NSDictionary+SafeAccess.h"
#import "ZFApiDefiner.h"
#import "YWLocalHostManager.h"
#import <GGAppsflyerAnalyticsSDK/GGAppsflyerAnalytics.h>

@interface ZFCMSRecommendViewModel()

@property (nonatomic, strong) NSDictionary *recommendParmaters;
@property (nonatomic, assign) NSInteger currentPage;

@end

@implementation ZFCMSRecommendViewModel

- (void)requestCmsRecommendData:(BOOL)firstPage
                      parmaters:(NSDictionary *)parmaters
                     completion:(void (^)(NSArray<ZFGoodsModel *> *array, NSDictionary *pageInfo))completion
                        failure:(void (^)(NSError *error))failure {
    if (!ZFJudgeNSDictionary(parmaters)) {
        if (failure) {
            failure(nil);
        }
        return;
    }
    
    if (firstPage) {
        self.currentPage = 1;
    } else {
        self.currentPage++;
    }
    
    ZFRequestModel *requestModel = [ZFRequestModel new];
    NSString *evenName = @"recommend_bigdata";  // 链路事件名
    if (!ZFIsEmptyString(parmaters[@"evenName"])) {
        evenName = parmaters[@"evenName"];
    }
    //若后期调整，请求链接都可以传入
    requestModel.url = API(Port_bigData_homeRecommendGoods);//请求大数据
    parmaters = @{@"page"           : @(self.currentPage),
                  @"policy"         : parmaters[@"policy"],
                  @"channel_id"     : parmaters[@"channel_id"],
                  @"appsFlyerUID"   : parmaters[@"appsFlyerUID"],
                  ZFApiBtsUniqueID : ZFToString([GGAppsflyerAnalytics getAppsflyerDeviceId]),
    };
    
    requestModel.eventName = evenName;
    requestModel.taget = self.controller;
    requestModel.parmaters = parmaters;
    requestModel.needToCache = NO;
    self.recommendParmaters = parmaters; //每次下拉记住请求参数, 防止弱网数据返回时机错乱
    
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        
        if (!failure || self.recommendParmaters != parmaters) {
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
                if (goodsArr.count > 0) {
                    total_page = cur_page + 1;
                } else {
                    total_page = cur_page;
                }
                NSDictionary *pageInfo = @{ kTotalPageKey   : @(total_page),
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
@end
