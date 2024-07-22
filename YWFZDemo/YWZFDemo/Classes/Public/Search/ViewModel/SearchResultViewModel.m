//
//  SearchResultViewModel.m
//  Dezzal
//
//  Created by YW on 18/8/10.
//  Copyright © 2016年 7FD75. All rights reserved.
//

#import "SearchResultViewModel.h"
#import "SearchResultApi.h"
#import "ZFSearchResultModel.h"
#import "SearchResultViewController.h"
#import "ZFGoodsDetailViewController.h"
#import "NSString+Extended.h"
#import "ZFAppsflyerAnalytics.h"
#import "NSStringUtils.h"
#import "ZFAnalyticsTimeManager.h"
#import "YWCFunctionTool.h"
#import "ZFRequestModel.h"
#import "Constants.h"
#import "ZFGoodsModel.h"
#import "ZFTimerManager.h"
#import "YWLocalHostManager.h"
#import "ZFBTSManager.h"
#import <GGAppsflyerAnalyticsSDK/GGAppsflyerAnalytics.h>

@interface SearchResultViewModel ()
@property (nonatomic, strong) ZFSearchResultModel   *searchResultModel;
@property (nonatomic, strong) NSMutableArray        *dataArray;
@property (nonatomic, assign) NSInteger             selectSortIndex;//记录当前页面选择的排序方式的行数
@property (nonatomic, copy)   NSString              *orderby;//排序方式
@end

@implementation SearchResultViewModel

/// 废弃 v5.4.0 occ
- (void)requestNetwork:(id)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure {
    
    @weakify(self)
    NSArray * array = (NSArray *)parmaters;
    NSInteger page = 1;
    self.orderby = parmaters[2];
    if (self.orderby == nil) {
        self.orderby = @"";
    }
    
    if ([array[0] integerValue] == 0) {
        // 假如最后一页的时候
        if (self.searchResultModel.cur_page  == self.searchResultModel.total_page ) {
            if (completion) {
                completion(NoMoreToLoad);
            }
            return; // 直接返回
        }
        page = self.searchResultModel.cur_page  + 1;
    }
    
    SearchResultApi *api = [[SearchResultApi alloc] initSearchResultApiWithSearchString:array[1] withPage:page withSize:10 withOrderby:self.orderby featuring:array[3]];
    api.taget = self.controller;
    [[ZFAnalyticsTimeManager sharedManager] requestSuccessTimeWithRequestAction:@"search/get_list" requestTime:ZFRequestTimeBegin];
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        @strongify(self)
        
        [[ZFAnalyticsTimeManager sharedManager] requestSuccessTimeWithRequestAction:@"search/get_list" requestTime:ZFRequestTimeEnd];
        
        id requestJSON = [NSStringUtils desEncrypt:request api:NSStringFromClass(api.class)];
        self.searchResultModel = [self dataAnalysisFromJson:requestJSON request:request];
        if (page == 1) {
            [self.dataArray removeAllObjects];
            [self statisticsEventSearch:ZFToString(array[1])];
        }
        // 谷歌统计
        [self analyticsSearchWithModel:self.searchResultModel];
        [self.dataArray addObjectsFromArray:self.searchResultModel.goodsArray];
        self.searchResultModel.goodsArray = self.dataArray;
        if (!self.dataArray.count) {
            self.loadingViewShowType = LoadingViewNoDataType;
        }
        for (ZFGoodsModel *goodsModel in self.searchResultModel.goodsArray) {
            // 倒计时开启，根据商品属性判断
            if ([goodsModel.countDownTime integerValue] > 0) {
                [[ZFTimerManager shareInstance] startTimer:[NSString stringWithFormat:@"GoodsList_%@", goodsModel.goods_id]];
            }
            // 巴西分期付款
            ZFAddressCountryModel *accountModel = [AccountManager sharedManager].accountCountryModel;
            NSString *region_code = ZFToString(accountModel.region_code);
            if ([region_code isEqualToString:@"BR"] && ![NSStringUtils isEmptyString:goodsModel.instalMentModel.instalments]) {
                goodsModel.isInstallment = YES;
                goodsModel.tagsArray = @[[ZFGoodsTagModel new]];
            }
        }
        if (completion) {
            completion(self.searchResultModel);
        }
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        @strongify(self)
        self.loadingViewShowType = LoadingViewNoNetType;
        if (failure) {
            failure(nil);
        }
    }];
    
}

- (void)requestSearchNetwork:(NSDictionary *)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure {
    
    NSInteger page = 1;

    BOOL isRefresh = [parmaters[@"refresh"] boolValue];
    if (isRefresh) {
        
    } else {
        // 假如最后一页的时候
        if (self.searchResultModel.cur_page  == self.searchResultModel.total_page ) {
            if (completion) {
                completion(NoMoreToLoad);
            }
            return; // 直接返回
        }
        page = self.searchResultModel.cur_page  + 1;
    }
    
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.url = API(@"search/get_list");
    requestModel.eventName = @"get_attr_list";
    requestModel.taget = self.controller;
    requestModel.parmaters = @{@"keyword"   : ZFToString(parmaters[@"keyword"]),
                               @"page"      : @(page),
                               @"page_size" : parmaters[@"page_size"],
                               @"order_by"  : ZFToString(parmaters[@"order_by"]),
                               @"price_min" : ZFToString(parmaters[@"price_min"]),
                               @"price_max" : ZFToString(parmaters[@"price_max"]),
                               @"selected_attr_list" : ZFToString(parmaters[@"selected_attr_list"]),
                               @"is_enc"    : @"0",
                               @"appsFlyerUID" : ZFToString([[AppsFlyerTracker sharedTracker] getAppsFlyerUID]),
                               ZFApiBtsUniqueID : ZFToString([GGAppsflyerAnalytics getAppsflyerDeviceId]),
                               @"featuring" : ZFToString(parmaters[@"featuring"]),
                               @"bts_test"  : ZFJudgeNSArray(parmaters[@"bts_test"]) ? parmaters[@"bts_test"] : @[]
                               };
    
    @weakify(self)

    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        @strongify(self)

        [[ZFAnalyticsTimeManager sharedManager] requestSuccessTimeWithRequestAction:@"search/get_list" requestTime:ZFRequestTimeEnd];
        
        self.searchResultModel = nil;
        if ([responseObject[@"statusCode"] integerValue] == 200) {
            self.searchResultModel = [ZFSearchResultModel yy_modelWithJSON:responseObject[ZFResultKey]];
        }
        
        if (page == 1) {
            [self.dataArray removeAllObjects];
            [self statisticsEventSearch:ZFToString(parmaters[@"keyword"])];
        }
        // 谷歌统计
        [self analyticsSearchWithModel:self.searchResultModel];
        [self.dataArray addObjectsFromArray:self.searchResultModel.goodsArray];
        self.searchResultModel.goodsArray = self.dataArray;
        if (!self.dataArray.count) {
            self.loadingViewShowType = LoadingViewNoDataType;
        }
        for (ZFGoodsModel *goodsModel in self.searchResultModel.goodsArray) {
            // 倒计时开启，根据商品属性判断
            if ([goodsModel.countDownTime integerValue] > 0) {
                [[ZFTimerManager shareInstance] startTimer:[NSString stringWithFormat:@"GoodsList_%@", goodsModel.goods_id]];
            }
            // 巴西分期付款
            ZFAddressCountryModel *accountModel = [AccountManager sharedManager].accountCountryModel;
            NSString *region_code = ZFToString(accountModel.region_code);
            if ([region_code isEqualToString:@"BR"] && ![NSStringUtils isEmptyString:goodsModel.instalMentModel.instalments]) {
                goodsModel.isInstallment = YES;
                goodsModel.tagsArray = @[[ZFGoodsTagModel new]];
            }
        }
        if (completion) {
            completion(self.searchResultModel);
        }
    } failure:^(NSError *error) {
        @strongify(self)
        self.loadingViewShowType = LoadingViewNoNetType;
        if (failure) {
            failure(nil);
        }
    }];
    
}

- (void)requestSearchRefineData:(NSDictionary *)params completion:(void (^)(id))completion failure:(void (^)(id))failure {
    
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.url = API(@"search/get_attr_list");
    requestModel.eventName = @"get_attr_list";
    requestModel.taget = self.controller;
    requestModel.parmaters = @{@"keyword"  : ZFToString(params[@"keyword"]),
                        @"attr_version"    : ZFToString(params[@"attr_version"]) };
    
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        
        CategoryRefineSectionModel *refineModel = [CategoryRefineSectionModel yy_modelWithJSON:responseObject[ZFResultKey]];
        if (completion) {
            completion(refineModel);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(nil);
        }
    }];
}

/**
 * 添加统计代码
 */
- (void)statisticsEventSearch:(NSString *)searchKey
{
    NSMutableArray *screenNames = [NSMutableArray array];
    NSMutableDictionary *banner = [NSMutableDictionary dictionary];
    banner[@"name"] = @"impression_search";
    banner[@"position"] = @"1";
    [screenNames addObject:banner];
    [ZFAnalytics showAdvertisementWithBanners:screenNames position:@"1" screenName:@"Search_result"];
    
    // 谷歌统计
    NSString *GABannerId   = searchKey;
    NSString *GABannerName = @"impression_search";
    NSString *position     = @"1";
    [ZFAnalytics clickAdvertisementWithId:GABannerId name:GABannerName position:position];
}

- (id)dataAnalysisFromJson:(id)json request:(SYBaseRequest *)request {
    if ([request isKindOfClass:[SearchResultApi class]]) {
        if ([json[@"statusCode"] integerValue] == 200) {
            return  [ZFSearchResultModel yy_modelWithJSON:json[ZFResultKey]];
        }
    }
    return nil;
}

-(NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

#pragma mark - 谷歌统计
- (void)analyticsSearchWithModel:(ZFSearchResultModel *)model {
    NSArray *goodsList = model.goodsArray;
    if (goodsList.count == 0) {
        return;
    }
    //occ v3.7.0hacker 添加 ok
    NSString *impression = [NSString stringWithFormat:@"%@_%@",ZFGASearchKeyList, self.searchTitle];
    self.analyticsProduceImpression = [ZFAnalyticsProduceImpression initAnalyticsProducePosition:1
                                                                                  impressionList:impression
                                                                                      screenName:@"keyword_search"
                                                                                           event:@"load"];
}
@end
