//
//  OSSVCategoryListsViewModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/4.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//


#import "OSSVCategoryListsAip.h"
#import "OSSVCategorysFilterAip.h"

#import "OSSVCategoryListsViewModel.h"
#import "OSSVDetailsVC.h"
#import "OSSVCategoriyDetailsGoodListsModel.h"
#import "OSSVDetailsBaseInfoModel.h"

@interface OSSVCategoryListsViewModel ()

@property (nonatomic,assign) NSInteger overTimeCount; // 记录已被销毁的cell的个数
@property (nonatomic,assign) NSInteger indexCount;

@property (nonatomic,weak) OSSVCategoryListsAip *api;
@property (nonatomic,weak) OSSVCategorysFilterAip *filterApi;


@end

@implementation OSSVCategoryListsViewModel

#pragma mark - life cycle

- (void)dealloc
{

}

- (void)requestNetwork:(id)parmaters
            completion:(void (^)(id))completion
               failure:(void (^)(id))failure
{
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        NSDictionary *paramtersDic = (NSDictionary *)parmaters;
        NSInteger page = 1;
        
        if ([paramtersDic[@"loadState"] intValue] == 0){
            // 假如最后一页的时候
            if (self.detailListModel.page == self.detailListModel.pageCount){
                if (completion)
                {
                    completion(STLNoMoreToLoad);
                }
                return;
            }
            page = self.detailListModel.page + 1;
        }
        
        @strongify(self)
        OSSVCategoryListsAip *api = [[OSSVCategoryListsAip alloc] initWithCategoriesListCatId:paramtersDic[@"cat_id"]
                                                                                   page:page
                                                                               pageSize:kSTLPageSize
                                                                                orderBy:[paramtersDic[@"order_by"] integerValue]
                                                                              filterIDs:paramtersDic[@"filter"]
                                                                            filterPrice:paramtersDic[@"price"]
                                                                             deepLinkId:paramtersDic[@"deep_link_id"]
                                                                                    isNew:paramtersDic[@"is_new_in"]];
        self.api = api;
        
        // 取缓存数据
        if (api.cacheJSONObject) {
            id requestJSON = api.cacheJSONObject;
            self.detailListModel = [self dataAnalysisFromJson: requestJSON request:api];
            
            if (page == 1) {
                _overTimeCount = 0;
                self.dataArray = [NSMutableArray arrayWithArray:self.detailListModel.goodList];
                
                if (self.dataArray.count > 0)  {
                    self.indexCount = 1;
                    if (self.dataArray.count > 1) {
                        self.indexCount = 2;
                    }
                    
//                    self.tempArray = [NSMutableArray array];
//                    __weak __typeof(self) weakSelf= self;
//                    for (int i = 0; i < self.indexCount; i++) {
//                        OSSVCategoriyDetailsGoodListsModel *model = self.dataArray[i];
//                        model.countDownIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
//                        if (model.isDailyDeal) {
//                            [self.timer countDownWithCompleteBlock:^{
//                                [weakSelf refreshLessTime];
//                            }];
//                        }
//                        [self.tempArray addObject:model];
//
//                    }
                }
            }
            if (completion) {
                completion(nil);
            }
        }
        
        @weakify(self)
        [api startWithBlockSuccess:^(__kindof STLBaseRequest *request) {
            @strongify(self)
            id requestJSON = [NSStringTool desEncrypt:request];
            self.detailListModel = [self dataAnalysisFromJson: requestJSON request:api];
            
            if (page == 1){
                _overTimeCount = 0;
                self.dataArray = [NSMutableArray arrayWithArray:self.detailListModel.goodList];
                
                if (self.dataArray.count > 0){
                    self.indexCount = 1;
                    
                    if (self.dataArray.count > 1){
                        self.indexCount = 2;
                    }
//                    self.tempArray = [NSMutableArray array];
//                    __weak __typeof(self) weakSelf= self;
//
//                    for (int i = 0; i < self.indexCount; i++){
//                        OSSVCategoriyDetailsGoodListsModel *model = self.dataArray[i];
//                        model.countDownIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
//                        if (model.isDailyDeal){
//                            [self.timer countDownWithCompleteBlock:^{
//                                [weakSelf refreshLessTime];
//                            }];
//                        }
//                        [self.tempArray addObject:model];
//                    }
                }
                
                if (completion){
                    completion(nil);
                }
            } else {
                if (self.detailListModel.goodList.count > 0) {
                    [self.dataArray addObjectsFromArray:self.detailListModel.goodList];
                    if (completion) {
                        completion(nil);
                    }
                    return;
                } else {
                    //为防万一，APP上拉加载的判断逻辑调整，由之前判定返回的数量<请求的数量即认为无更多商品，改为判断返回的数量=0。
                    if (completion) {
                        completion(STLNoMoreToLoad);
                    }
                }
            }
            
        }
                           failure:^(__kindof STLBaseRequest *request, NSError *error) {
                               if (failure){
                                   failure(nil);
                               }
                           }];
    }
                                              exception:^{
                                                  if (failure){
                                                      failure(nil);
                                                  }
                                              }];
}

- (void)requestFilterNetwork:(id)parmaters
            completion:(void (^)(id))completion
               failure:(void (^)(id))failure
{

        NSDictionary *paramtersDic = (NSDictionary *)parmaters;
        OSSVCategorysFilterAip *api = [[OSSVCategorysFilterAip alloc] initWithCategoriesFilterCatId:paramtersDic[@"cat_id"]];
        self.filterApi = api;

        @weakify(self)
        [api startWithBlockSuccess:^(__kindof STLBaseRequest *request) {
            @strongify(self)
            id requestJSON = [NSStringTool desEncrypt:request];
            self.categoryFilterDatas = [self dataAnalysisFromJson: requestJSON request:api];
            
            if (completion){
                completion(self.categoryFilterDatas);
            }
            
        } failure:^(__kindof STLBaseRequest *request, NSError *error) {
            if (failure){
                failure(nil);
            }
        }];
}

- (void)freesource {
    [[STLRequestManager sharedInstance] removeRequest:self.api completion:nil];
}

#pragma mark - private methods

- (id)dataAnalysisFromJson:(id)json request:(STLBaseRequest *)request {
    if ([request isKindOfClass:[OSSVCategoryListsAip class]]) {
        if ([json[kStatusCode] integerValue] == kStatusCode_200 || [json[kStatusCode] integerValue] == 202) {
            return [OSSVCategoryListsModel yy_modelWithJSON:json[kResult]];
        }
    } else if([request isKindOfClass:[OSSVCategorysFilterAip class]]) {
        if ([json[kStatusCode] integerValue] == kStatusCode_200) {
            
            return [NSArray yy_modelArrayWithClass:[OSSVCategorysFiltersNewModel class] json:json[kResult]];
        }
    }
    return nil;
}



#pragma mark - setters and getters

//- (NSArray *)filterItems
//{
//    return self.detailListModel.filteItemArray;
//}

@end
