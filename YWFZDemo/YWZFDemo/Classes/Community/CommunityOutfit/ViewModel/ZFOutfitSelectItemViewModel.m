//
//  ZFOutfitSelectItemViewModel.m
//  Zaful
//
//  Created by QianHan on 2018/5/23.
//  Copyright © 2018年 Y001. All rights reserved.
//

#import "ZFCommunityOutfitSelectItemViewModel.h"
#import "CategoryRefineSectionModel.h"

#import "CategoryListPageApi.h"
#import "CategoryNewRefineApi.h"

#import "ZFAppsflyerAnalytics.h"


@interface ZFCommunityOutfitSelectItemViewModel ()

@property (nonatomic, assign) NSInteger allItemCount;


///////////////////////
@property (nonatomic, strong) CategoryListPageApi     *listPageApi;//防止频繁筛选点击请求,数据刷新处理异常

@end

@implementation ZFCommunityOutfitSelectItemViewModel

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (NSMutableArray *)goodsList {
    if (!_goodsList) {
        _goodsList = [[NSMutableArray alloc] init];
    }
    return _goodsList;
}



- (void)requestSelectCategoryListData:(id)parmaters
                           completion:(void (^)(CategoryListPageModel *loadingModel,id pageData, BOOL requestState))completion {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:parmaters];
    NSInteger curPage = 1;
    BOOL firstPage = [dict[@"page"] isEqualToString:Refresh];
    if (firstPage) {
        curPage = 1;
    } else {
        curPage = [self.model.cur_page integerValue];
        ++curPage;
    }
    dict[@"page"] = [@(curPage) stringValue];
    // 1：返回图片组，2：不返回图片组
    dict[@"outfit"] = @"1";
    
    CategoryListPageApi *api = [[CategoryListPageApi alloc] initListPageApiWithParameter:dict virtual:self.isVirtual];
    self.listPageApi = api;
    
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        
        if (![self.listPageApi isEqual:api]) return ;
        
        if (firstPage) {
            [self.goodsList removeAllObjects];
        }
        
        id requestJSON = [NSStringUtils desEncrypt:request api:NSStringFromClass(api.class)];
        self.model = [self dataAnalysisFromJson:requestJSON request:request];
        NSMutableArray *currentPageArray = [[NSMutableArray alloc] init];
        
        if (self.isVirtual && firstPage) {
            [CategoryDataManager shareManager].isVirtualCategory = YES;
            [[CategoryDataManager shareManager] parseCategoryData:self.model.virtualCategorys];
            NSArray<CategoryNewModel *> *virtualArray = [[CategoryDataManager shareManager] queryRootCategoryData];
            self.model.virtualCategorys = virtualArray;
        }
        
        NSInteger newPageCount = 0;
        
        //防止添加空对象
        if (self.model && self.model.goods_list > 0) {
            [self.model.goods_list enumerateObjectsUsingBlock:^(ZFGoodsModel * _Nonnull goodsObj, NSUInteger idx, BOOL * _Nonnull goodsStop) {
                if (ZFJudgeNSArray(goodsObj.pictures)) {
                    NSArray *pictures = goodsObj.pictures;
                    
                    
                    [pictures enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        //.png的图片为纯背景图片,
                        if ([obj hasSuffix:@".png"]) {
                            goodsObj.pureImageName = obj;
                            *stop = YES;
                            // 过滤无纯背景的商品数据
                            [currentPageArray addObject:goodsObj];
                        }
                    }];
                }
            }];
            
            [self.goodsList addObjectsFromArray:currentPageArray];
            newPageCount = firstPage ? currentPageArray.count : self.goodsList.count - currentPageArray.count;
            
            // 谷歌统计
//            [self addAnalysicsWithModelArray:currentPageArray];
        }
        
        if (completion) {
            // 此blcok是请求成功的状态,不管有没有数据都应该返回一个字典到底层去显示空白页
            NSDictionary *pageData = @{ kTotalPageKey  :self.model.total_page,
                                        kCurrentPageKey:self.model.cur_page };
            completion(self.model,pageData,YES);
        }
        
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        HideLoadingFromView(parmaters);
        if (![self.listPageApi isEqual:api]) return ;
        if (completion) {
            self.model.goods_list = nil;
            completion(self.model,nil,NO);
        }
    }];
}


- (void)requestRefineDataWithCatID:(NSString *)cat_id completion:(void (^)(id))completion failure:(void (^)(id))failure {
    CategoryNewRefineApi *api = [[CategoryNewRefineApi alloc] initWithCategoryRefineApiCat_id:cat_id];
    
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        id requestJSON = [NSStringUtils desEncrypt:request api:NSStringFromClass(api.class)];
        CategoryRefineSectionModel *refineModel = [CategoryRefineSectionModel yy_modelWithJSON:requestJSON[ZFResultKey]];
        if (completion) {
            completion(refineModel);
        }
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        if (failure) {
            failure(nil);
        }
    }];
}


#pragma mark - Private Methods
- (id)dataAnalysisFromJson:(id)requestJSON request:(SYBaseRequest *)request {
    id result;
    if (!requestJSON) {
        return nil;
    }
    if (request.responseStatusCode == 200) {
        if ([request isKindOfClass:[CategoryListPageApi class]] ) {
            result = [CategoryListPageModel yy_modelWithJSON:requestJSON[ZFResultKey]];
        }
    }
    return result;
}


- (void)addAnalysicsWithModelArray:(NSArray<ZFGoodsModel *> *)goodsArray {
    // 查看分类下的商品列表、查看某个营销活动的商品列表统计
    NSMutableDictionary *valuesDic = [NSMutableDictionary dictionary];
    valuesDic[AFEventParamContentType] = [NSString stringWithFormat:@"Category/%@", self.cateName];
    [ZFAnalytics appsFlyerTrackEvent:@"af_view_list" withValues:valuesDic];
    [ZFAppsflyerAnalytics trackGoodsList:goodsArray inSourceType:ZFAppsflyerInSourceTypeCategoryList sourceID:self.cateName];
    
    // ABTest
//    for (NSInteger i=0; i<goodsArray.count; i++) {
//        if (self.isVirtual) {
//            // 新品商品浏览总次数
//            [ZFABTestManager categoryPromotionGoodsViews];
//        } else {
//            // 分类结果接口:商品浏览总次数
//            [ZFABTestManager categoryListGoodsViews];
//        }
//    }
}
@end
