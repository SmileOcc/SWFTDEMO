
//
//  CategoryListPageViewModel.m
//  ListPageViewController
//
//  Created by YW on 16/6/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "CategoryListPageViewModel.h"
#import "CategoryListPageApi.h"
#import "CategoryNewRefineApi.h"
#import "ZFGoodsListItemCell.h"
#import "ZFListGoodsNumberHeaderView.h"
#import "CategoryRefineSectionModel.h"
#import "CategoryPriceListModel.h"
#import "ZFCellHeightManager.h"
#import "ZFAppsflyerAnalytics.h"
#import "NSStringUtils.h"
#import "ZFProgressHUD.h"
#import "UIView+LayoutMethods.h"
#import "ZFLocalizationString.h"
#import "ZFAnalytics.h"
#import "ZFAnalyticsTimeManager.h"
#import "CategoryDataManager.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "ZF3DTouchHeader.h"
#import "ZFFrameDefiner.h"
#import "ZFRequestModel.h"
#import "Constants.h"
#import "YWCFunctionTool.h"
#import "ZFAppsflyerAnalytics.h"
#import "ZFBTSDataSets.h"
#import "ZFTimerManager.h"
#import "ZFApiDefiner.h"
#import "YWLocalHostManager.h"
#import "ZFGrowingIOAnalytics.h"
#import "ZFBTSManager.h"

@interface CategoryListPageViewModel ()

@property (nonatomic, assign) CGFloat lastOffsetY;
@property (nonatomic, assign) BOOL hideTopOperateView;
@property (nonatomic, weak)   CategoryListPageApi     *listPageApi;//防止频繁筛选点击请求,数据刷新处理异常
@property (nonatomic, weak) ZFRequestModel *listRequest;//防止频繁筛选点击请求,数据刷新处理异常
@property (nonatomic, strong) ZFCategoryListAnalyticsAOP *categoryAnalyticsManager;
//@property (nonatomic, assign) NSInteger ABTestPolicy;

@end

@implementation CategoryListPageViewModel

- (void)dealloc {
    for (ZFGoodsModel *obj in self.goodsArray) {
        // 倒计时开启，根据商品属性判断
        if ([obj.countDownTime integerValue] > 0) {
            [[ZFTimerManager shareInstance] stopTimer:[NSString stringWithFormat:@"GoodsList_%@", obj.goods_id]];
        }
    }
    self.listPageApi.taget = nil;
    self.listPageApi.spanModel = nil;
    [self.listPageApi stop];
    self.listPageApi = nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[AnalyticsInjectManager shareInstance] analyticsInject:self injectObject:self.categoryAnalyticsManager];
    }
    return self;
}

#pragma mark - Public Methods
- (void)requestCategoryListDataWithParams:(NSDictionary *)parmaters
                              loadingView:(UIView *)loadingView
                               completion:(void (^)(CategoryListPageModel *loadingModel, NSInteger nextPageIndex,id pageData, BOOL isSucess))completion
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:parmaters];

    if (self.goodsArray.count == 0) {
        ShowLoadingToView(loadingView);
    }
    NSInteger curPage = 1;
    BOOL firstPage = [dict[@"page"] isEqualToString:Refresh];
    if (firstPage) {
        curPage = 1;
    } else {
        curPage = [self.model.cur_page integerValue];
        ++curPage;
    }
    dict[@"page"] = [@(curPage) stringValue];
    
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.taget = self.controller;
    requestModel.url = API(Port_categoryList);
    requestModel.parmaters = dict;
    self.listRequest = requestModel;
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        HideLoadingFromView(loadingView);
        NSDictionary *resultDict = responseObject[ZFResultKey];
        if (![resultDict isKindOfClass:[NSDictionary class]]) {
            if (completion) {
                self.model.goods_list = nil;
                completion(self.model,self.goodsArray.count,nil, NO);
            }
            return;
        }
        // 分类数据处理
        if (firstPage && [dict[@"is_first_cate"] isEqualToString:@"1"]) {
            self.categoryModelList = [NSArray yy_modelArrayWithClass:[CategoryNewModel class] json:resultDict[@"child_nav"]];
        }
        // 列表数据处理
        if (![self.listRequest isEqual:requestModel]) return ;
        
        [[ZFAnalyticsTimeManager sharedManager] requestSuccessTimeWithRequestAction:@"category/get_list" requestTime:ZFRequestTimeEnd];
        if (![self.lastCategoryID isEqualToString:dict[@"cat_id"]] || firstPage) {
            [self.goodsArray removeAllObjects];
        }
        
//        id requestJSON = [NSStringUtils desEncrypt:request api:NSStringFromClass(api.class)];
//        self.model = [self dataAnalysisFromJson:requestJSON request:request];
        self.model = [CategoryListPageModel yy_modelWithJSON:resultDict];
        if (firstPage) {
            [self.categoryAnalyticsManager refreshDataSource];
        }
        self.categoryAnalyticsManager.afParams = self.model.af_params;
        
        NSArray *currentPageArray = self.model.goods_list;
        
//        if (self.isVirtual && firstPage) {
//            [CategoryDataManager shareManager].isVirtualCategory = YES;
//            [[CategoryDataManager shareManager] parseCategoryData:self.model.virtualCategorys];
//            NSArray<CategoryNewModel *> *virtualArray = [[CategoryDataManager shareManager] queryRootCategoryData];
//            self.model.virtualCategorys = virtualArray;
//        }
        
        NSInteger newPageCount = 0;
        
        //防止添加空对象
        if (self.model && currentPageArray > 0) {
            [self.goodsArray addObjectsFromArray:currentPageArray];
            newPageCount = firstPage ? currentPageArray.count : self.goodsArray.count - currentPageArray.count;
            
            // 谷歌统计
            [self addAnalysicsWithModelArray:currentPageArray];
        }
        
        if (completion) {
            // 此blcok是请求成功的状态,不管有没有数据都应该返回一个字典到底层去显示空白页
            NSDictionary *pageData = @{ kTotalPageKey  :self.model.total_page,
                                        kCurrentPageKey:self.model.cur_page,
                                        };
            completion(self.model,newPageCount,pageData, YES);
        }
    } failure:^(NSError *error) {
        HideLoadingFromView(loadingView);
        if (![self.listRequest isEqual:requestModel]) return ;
        if (completion) {
            self.model.goods_list = nil;
            completion(self.model,self.goodsArray.count,nil, NO);
        }
    }];
}

- (void)requestCategoryListData:(id)parmaters
                     completion:(void (^)(CategoryListPageModel *loadingModel, NSInteger nextPageIndex,id pageData))completion {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:parmaters];

    if (self.goodsArray.count == 0) {
        ShowLoadingToView(parmaters);
    }
    NSInteger curPage = 1;
    BOOL firstPage = [dict[@"page"] isEqualToString:Refresh];
    if (firstPage) {
        curPage = 1;
    } else {
        curPage = [self.model.cur_page integerValue];
        ++curPage;
    }
    dict[@"page"] = [@(curPage) stringValue];
    
    CategoryListPageApi *api = [[CategoryListPageApi alloc] initListPageApiWithParameter:dict virtual:self.isVirtual];
    api.taget = self.controller;
    self.listPageApi = api;
    
    [[ZFAnalyticsTimeManager sharedManager] requestSuccessTimeWithRequestAction:@"category/get_list" requestTime:ZFRequestTimeBegin];
    
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        HideLoadingFromView(parmaters);
        if (![self.listPageApi isEqual:api]) return ;
        
        [[ZFAnalyticsTimeManager sharedManager] requestSuccessTimeWithRequestAction:@"category/get_list" requestTime:ZFRequestTimeEnd];
        if (![self.lastCategoryID isEqualToString:dict[@"cat_id"]] || firstPage) {
            [self.goodsArray removeAllObjects];
        }
        
        id requestJSON = [NSStringUtils desEncrypt:request api:NSStringFromClass(api.class)];
        self.model = [self dataAnalysisFromJson:requestJSON request:request];
        if (firstPage) {
            [self.categoryAnalyticsManager refreshDataSource];
        }
        self.categoryAnalyticsManager.afParams = self.model.af_params;
        
        NSArray *currentPageArray = self.model.goods_list;
        
        if (self.isVirtual && firstPage) {
            [CategoryDataManager shareManager].isVirtualCategory = YES;
            [[CategoryDataManager shareManager] parseCategoryData:self.model.virtualCategorys];
            NSArray<CategoryNewModel *> *virtualArray = [[CategoryDataManager shareManager] queryRootCategoryData];
            self.model.virtualCategorys = virtualArray;
        }
        
        NSInteger newPageCount = 0;
        
        //防止添加空对象
        if (self.model && currentPageArray > 0) {
            [self.goodsArray addObjectsFromArray:currentPageArray];
            newPageCount = firstPage ? currentPageArray.count : self.goodsArray.count - currentPageArray.count;
            
            // 谷歌统计
            [self addAnalysicsWithModelArray:currentPageArray];
        }
        
        if (completion) {
            // 此blcok是请求成功的状态,不管有没有数据都应该返回一个字典到底层去显示空白页
            NSDictionary *pageData = @{ kTotalPageKey  :self.model.total_page,
                                        kCurrentPageKey:self.model.cur_page,
                                        };
            completion(self.model,newPageCount,pageData);
        }
        
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        HideLoadingFromView(parmaters);
        if (![self.listPageApi isEqual:api]) return ;
        if (completion) {
            self.model.goods_list = nil;
            completion(self.model,self.goodsArray.count,nil);
        }
    }];
}

- (void)requestRefineDataWithCatID:(NSDictionary *)params completion:(void (^)(id))completion failure:(void (^)(id))failure {
    CategoryNewRefineApi *api = [[CategoryNewRefineApi alloc] initWithCategoryRefineApiCat_id:ZFToString(params[@"cat_id"]) attr_version:ZFToString(params[@"attr_version"])];
    api.eventName = @"attr_list";
    api.taget = self.controller;
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

- (CGFloat)queryCellHeightWithModel:(NSInteger)index {
    CGFloat cellHeight = 0.0f;
    
    // 获取模型数据˛¸
    ZFGoodsModel *model = self.goodsArray[index];
    // v4.4.0 AB: 不显示标签
//    if ([self isRealCategoryAB] && model.tagsArray.count > 0) {
//        model.tagsArray = @[];
//    }
    
    [ZFCellHeightManager shareManager].isRecomendCell = NO;
    // 获取缓存高度
    cellHeight = [[ZFCellHeightManager shareManager] queryHeightWithModelHash:model.goods_id.hash];
    
    if (cellHeight < 0) { // 没有缓存高度
        // 计算并保存高度
        cellHeight = [[ZFCellHeightManager shareManager] calculateCellHeightWithTagsArrayModel:model];
    }
    
    // 色块高度
    if (model.groupGoodsList.count > 1) {
        CGFloat cellWidth = (KScreenWidth - 36) * 0.5;
        CGFloat colorBlockCellheight = (cellWidth-12*4-15) / 4.5;
        cellHeight += colorBlockCellheight;
    }
    
    return cellHeight;
}

- (void)addAnalysicsWithModelArray:(NSArray<ZFGoodsModel *> *)goodsArray {
    // 查看分类下的商品列表、查看某个营销活动的商品列表统计
    NSMutableDictionary *valuesDic = [NSMutableDictionary dictionary];
    valuesDic[AFEventParamContentType] = [NSString stringWithFormat:@"Category/%@", self.cateName];
    [ZFAnalytics appsFlyerTrackEvent:@"af_view_list" withValues:valuesDic];
//    [ZFAppsflyerAnalytics trackGoodsList:goodsArray inSourceType:ZFAppsflyerInSourceTypeCategoryList sourceID:self.cateName];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y < 90) return;
    CGFloat offsetY = scrollView.contentOffset.y - self.lastOffsetY;
    BOOL hideTop = offsetY>0;
//    YWLog(@"%@",hideTop ? @"分类向------上------滑动" : @"分类向------下------滑动");
    
    if (self.hideTopOperateView != hideTop) {
        self.hideTopOperateView = hideTop;
        if (self.scrollListViewBlock) {
            self.scrollListViewBlock(hideTop);
        }
    }
    self.lastOffsetY = scrollView.contentOffset.y;
}

#pragma mark - UICollectionViewDelegateFlowLayout - UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.goodsArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFGoodsListItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kZFCollectionMultipleColumnCellIdentifier forIndexPath:indexPath];
//    cell.isNewABText = [self isRealCategoryAB];
    cell.af_inner_mediasource = [ZFAppsflyerAnalytics sourceStringWithType:(self.isVirtual ? ZFAppsflyerInSourceTypeVirtualCategoryList : ZFAppsflyerInSourceTypeCategoryList) sourceID:ZFToString(self.cateName)];
    cell.sort = self.analyticsSort;
    
    if (indexPath.row <= self.goodsArray.count - 1) {
        ZFGoodsModel *model = self.goodsArray[indexPath.row];
        cell.goodsModel = model;
        //判断更加3DTouch事件
        [self.controller register3DTouchAlertWithDelegate:collectionView sourceView:cell goodsModel:model];
    }
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    ZFGoodsModel *model = self.goodsArray[indexPath.row];
    ZFGoodsListItemCell *cell = (ZFGoodsListItemCell *)[collectionView cellForItemAtIndexPath:indexPath];
    ZFGoodsModel *model = cell.selectedGoodsModel;
    if (!model) {
        model = cell.goodsModel;
    }
    model.af_rank = cell.goodsModel.af_rank;
    if (self.handler) {
        NSNumber *from3DTouchFlag = objc_getAssociatedObject(indexPath, k3DTouchRelationCellComeFrom);
        //标记是从3DTouch进来不传动画视图进入商详
        UIImageView *sourceView = [from3DTouchFlag boolValue] ? nil : cell.goodsImageView;
        self.handler(model, sourceView);
    }
    
    // appflyer统计
    NSDictionary *appsflyerParams = @{@"af_content_id" : ZFToString(model.goods_sn),
                                      @"af_spu_id" : ZFToString(model.goods_spu),
                                      @"af_user_type" : ZFToString([AccountManager  sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                      @"af_page_name" : [NSString stringWithFormat:@"category_%@", ZFToString(self.cateName)],    // 当前页面名称
                                      };
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:appsflyerParams];
    if (![NSStringUtils isEmptyString:self.coupon]) {  // 优惠券商品列表
        params[@"af_page_name"] = @"mycoupon_page";
        params[@"af_coupon_code"] = ZFToString(self.coupon);
    }
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_sku_click" withValues:params];
    
    NSString *cateType = @"category";
    if (self.isVirtual) {
        cateType = @"virtual_category";
    }
    [ZFGrowingIOAnalytics ZFGrowingIOProductClick:model page:@"分类列表" sourceParams:@{
        GIOGoodsTypeEvar : self.isVirtual ? GIOGoodsTypeVirtual : GIOGoodsTypeRecommend,
        GIOGoodsNameEvar : [NSString stringWithFormat:@"%@_%@", cateType, ZFToString(self.cateName)]
    }];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.goodsArray.count <= indexPath.section || self.goodsArray.count <= indexPath.item) {
        YWLog(@"error:数组越界; selector:%@", NSStringFromSelector(_cmd));
        CGFloat width = (KScreenWidth - 36) * 0.5;
        return  CGSizeMake(width, (width / KImage_SCALE) + 58);// 默认size
    }
    
    static CGFloat cellHeight = 0.0f;
    
    if (indexPath.item % 2 == 0) {
        // 获取当前cell高度
        CGFloat currentCellHeight = [self queryCellHeightWithModel:indexPath.item];
        cellHeight = currentCellHeight;
        if (indexPath.item + 1 < self.goodsArray.count) {
            // 获取下一个cell高度
            CGFloat nextCellHeight = [self queryCellHeightWithModel:indexPath.item + 1];
            cellHeight = currentCellHeight > nextCellHeight ? currentCellHeight : nextCellHeight;
        }
    }
    return CGSizeMake((KScreenWidth - 36) * 0.5, cellHeight);
}

//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
//    ZFListGoodsNumberHeaderView *headView = [ZFListGoodsNumberHeaderView headWithCollectionView:collectionView Kind:kind IndexPath:indexPath];
//    headView.y = self.model.guideWords.count > 0 ? -6.0 : 0.0;
//    if ([kind isEqualToString:UICollectionElementKindSectionHeader] ) {
//        headView.item = [NSString stringWithFormat:ZFLocalizedString(@"list_item", nil),self.model.result_num];
//    }
//    return headView;
//}
//
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
//    CGFloat height = self.model.guideWords.count > 0 ? 24.0 : 36.0;
//    return  self.isFromHome || [self.model.result_num isEqualToString:@"0"] || [NSStringUtils isEmptyString:self.model.result_num] ? CGSizeZero : CGSizeMake(KScreenWidth, 36);
    return CGSizeMake(KScreenWidth, 12);
}

#pragma mark - Getter

-(void)setAnalyticsSort:(NSString *)analyticsSort
{
    _analyticsSort = analyticsSort;
    self.categoryAnalyticsManager.sort = _analyticsSort;
}

-(void)setCateName:(NSString *)cateName
{
    _cateName = cateName;
    self.categoryAnalyticsManager.cateName = self.cateName;
}

-(NSMutableArray *)goodsArray {
    if (!_goodsArray) {
        _goodsArray = [NSMutableArray array];
    }
    return _goodsArray;
}

-(ZFCategoryListAnalyticsAOP *)categoryAnalyticsManager
{
    if (!_categoryAnalyticsManager) {
        _categoryAnalyticsManager = [[ZFCategoryListAnalyticsAOP alloc] init];
    }
    return _categoryAnalyticsManager;
}

@end
