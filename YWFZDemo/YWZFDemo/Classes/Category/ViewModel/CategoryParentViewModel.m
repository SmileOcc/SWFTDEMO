//
//  CategoryParentViewModel.m
//  ListPageViewController
//
//  Created by YW on 26/6/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "CategoryParentViewModel.h"
#import "CategoryDataApi.h"
#import "ZFSubCategoryModel.h"
#import "ZFBannerModel.h"
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
#import "ZFAppsflyerAnalytics.h"

@interface CategoryParentViewModel ()
@property (nonatomic, strong) NSMutableArray        *parentsArray;
@property (nonatomic, strong) NSArray               *elfParentModelArray;
@property (nonatomic, strong) NSMutableArray        *superCateArray;
@property (nonatomic, strong) ZFSubCategoryModel    *subCateModel;
@property (nonatomic, assign) NSInteger             selectedSuperCateIndex;
@property (nonatomic, strong) NSMutableDictionary   *subCateCachDic;
@property (nonatomic, strong) NSMutableArray        *showSubCateIndexArray;
@end

@implementation CategoryParentViewModel
#pragma mark - Public Methods
-(void)requestParentsData:(void (^)(void))completion failure:(void (^)(id))failure{
    
    CategoryDataApi *api = [[CategoryDataApi alloc] initCategoryDataApi];
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        
        id requestJSON = [NSStringUtils desEncrypt:request api:NSStringFromClass(api.class)];
        NSArray<CategoryNewModel *> *categorysArray = [self dataAnalysisFromJson:requestJSON request:request];
        [self parseRequestJSON:categorysArray];
        [self analyticsCateBannerWithCateArray:self.parentsArray];
    
        if (completion) {
            completion();
        }
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        if (failure) {
            failure(nil);
        }
    }];
}

/**
 * Elf新分类导航接口
 */
- (void)requestParentsCategoryData:(id)parmaters
                        completion:(void (^)(NSArray *parentModelArray))completion
                           failure:(void (^)(NSError *error))failure
{
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.url = API(Port_get_elf_nav);
    requestModel.needToCache = YES;
    requestModel.taget = self.controller;
    
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[@"clientType"] = @"APP";
    requestModel.parmaters = info;
    
    [ZFNetworkHttpRequest sendExtensionRequestWithParmaters:requestModel success:^(id responseObject) {
        NSArray *parentModelArray = @[];
        
        NSArray *resultArray = [responseObject ds_arrayForKey:@"result"];
        if (ZFJudgeNSArray(resultArray)) {
            parentModelArray = [NSArray yy_modelArrayWithClass:[ZFCategoryParentModel class] json:resultArray];
            
            self.elfParentModelArray = parentModelArray;
            [self.superCateArray removeAllObjects];
            
            for (NSInteger i=0; i<parentModelArray.count; i++) {
                ZFCategoryParentModel *parentModel = parentModelArray[i];
                [self.superCateArray addObject:parentModel.TabNav];
                if (parentModel.TabNav.isActive) {
                    self.selectedSuperCateIndex = i;
                    // 包装子视图数据模型
                    [self convertSubCategoryData:parentModel];
                }
            }
            [self showSuperCateAnalytics:self.superCateArray];
        }
        if (completion) {
            completion(parentModelArray);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

#pragma mark - Private Methods
- (void)parseRequestJSON:(NSArray<CategoryNewModel *> *)categorysArray {
    [CategoryDataManager shareManager].isVirtualCategory = NO;
    [[CategoryDataManager shareManager] parseCategoryData:categorysArray];
    NSArray *array = [[CategoryDataManager shareManager] queryRootCategoryData];
    [self.parentsArray removeAllObjects];
    
    for (CategoryNewModel *model in array) {
        if (![NSStringUtils isEmptyString:model.cat_pic]) {
            [self.parentsArray addObject:model];
        }
    }
}

- (id)dataAnalysisFromJson:(id)requestJSON request:(SYBaseRequest *)request {
    id result;
    if (![request isKindOfClass:[CategoryDataApi class]]) {
        result = nil;
    }
    if (request.responseStatusCode == 200) {
        result = [NSArray  yy_modelArrayWithClass:[CategoryNewModel class] json:requestJSON[ZFResultKey]];
    }
    
    return result;
}

#pragma mark ---------- public method
#pragma mark - 父分类
- (NSInteger)superCateCount {
    return self.superCateArray.count;
}

- (NSString *)superCateNameWithIndex:(NSInteger)index {
    ZFCategoryTabNav *TabNav = [self.superCateArray objectAtIndex:index];
    return TabNav.text;
}

- (ZFCategoryTabNav *)superCateWithIndex:(NSInteger)index {
    ZFCategoryTabNav *TabNav = [self.superCateArray objectAtIndex:index];
    return TabNav;
}

- (ZFCategoryTabNav *)getSlectedCategoryTabNav {
    ZFCategoryTabNav *TabNav = nil;
    if (self.selectedSuperCateIndex < self.superCateArray.count) {
        TabNav = [self.superCateArray objectAtIndex:self.selectedSuperCateIndex];
    }
    return TabNav;
}

- (NSInteger)selectedCateIndex {
    return self.selectedSuperCateIndex;
}

- (void)setselectedCateIndex:(NSInteger)index {
    if (self.superCateArray.count <= index) return;
    if (self.elfParentModelArray.count <= index) return;
    
    // 包装子视图数据模型
    self.selectedSuperCateIndex = index;
    ZFCategoryParentModel *parentModel = self.elfParentModelArray[index];
    [self convertSubCategoryData:parentModel];
}

/**
 * 包装子视图数据模型
 */
- (void)convertSubCategoryData:(ZFCategoryParentModel *)parentModel
{
    [self.subCateSectionModelArray removeAllObjects];
    ZFSubCategorySectionModel *lastSectionModel = nil;
    
    CGFloat collectionViewWidth = KScreenWidth - kSuperCategoryTableWidth;
    CGFloat bannerWidth = (collectionViewWidth - kCollectionViewMargin * 2);
    CGFloat goodsWidth = (collectionViewWidth - (kCollectionViewMargin + kImageMarginSpace) * 2) / 3;
    
    for (NSInteger i=0; i<parentModel.TabContainer.count; i++) {
        ZFCategoryTabContainer *tabContainer = parentModel.TabContainer[i];
        
        /// 203:通栏Banner高度
        CGFloat bannerHeight = tabContainer.imgHeight.floatValue * bannerWidth / tabContainer.imgWidth.floatValue;
        
        /// 201:商品Item高度
        CGFloat goodsHeight = tabContainer.imgHeight.floatValue * goodsWidth / tabContainer.imgWidth.floatValue + kImageTitleHeight;
        
        
        /// 遍历逻辑: 相同类型的数据放到同一Section组中显示
        if (!lastSectionModel || lastSectionModel.sectionType != tabContainer.type
            || tabContainer.type == ZFSubCategoryModel_BannerType) {

            ZFSubCategorySectionModel *sectionModel = [[ZFSubCategorySectionModel alloc] init];
            sectionModel.sectionType = tabContainer.type;
            sectionModel.sectionModelarray = [NSMutableArray arrayWithObject:tabContainer];
            
            if (sectionModel.sectionType == ZFSubCategoryModel_BannerType) {
                sectionModel.sectionItemSize = CGSizeMake(bannerWidth, bannerHeight);
            } else {
                sectionModel.sectionItemSize = CGSizeMake(goodsWidth, goodsHeight);
            }
            [self.subCateSectionModelArray addObject:sectionModel];
            lastSectionModel = sectionModel;
            
        } else {
            if (tabContainer.type == ZFSubCategoryModel_BannerType) {
                lastSectionModel.sectionItemSize = CGSizeMake(bannerWidth, bannerHeight);
            } else {
                lastSectionModel.sectionItemSize = CGSizeMake(goodsWidth, goodsHeight);
            }
            [lastSectionModel.sectionModelarray addObject:tabContainer];
        }
    }
    // GA
    [self showSubCateAnalytics:self.subCateSectionModelArray];
}

#pragma mark - 子分类

- (CategoryNewModel *)subCateModelWidthIndex:(NSInteger)index {
    if (self.subCateModel.cateModelArray.count > index) {
        CategoryNewModel *model = self.subCateModel.cateModelArray[index];
        return model;
    }
    return nil;
}

#pragma mark - Getter
-(NSMutableArray *)parentsArray {
    if (!_parentsArray) {
        _parentsArray = [NSMutableArray array];
    }
    return _parentsArray;
}

- (NSMutableArray *)superCateArray {
    if (!_superCateArray) {
        _superCateArray = [NSMutableArray new];
    }
    return _superCateArray;
}

- (NSMutableArray *)subCateSectionModelArray {
    if (!_subCateSectionModelArray) {
        _subCateSectionModelArray = [NSMutableArray new];
    }
    return _subCateSectionModelArray;
}

- (NSMutableDictionary *)subCateCachDic {
    if (!_subCateCachDic) {
        _subCateCachDic = [NSMutableDictionary new];
    }
    return _subCateCachDic;
}

- (NSMutableArray *)showSubCateIndexArray {
    if (!_showSubCateIndexArray) {
        _showSubCateIndexArray = [NSMutableArray new];
    }
    return _showSubCateIndexArray;
}

#pragma mark - 谷歌统计
-(void)showSuperCateAnalytics:(NSArray<ZFCategoryTabNav *> *)cateArray {
    NSMutableArray *screenNames = [NSMutableArray array];
    for (int i = 0; i < cateArray.count; i ++) {
        ZFCategoryTabNav *model = cateArray[i];
        if (![model isKindOfClass:[ZFCategoryTabNav class]]) continue;
        
        NSString *screenName = [NSString stringWithFormat:@"%@_%@",ZFGACategoryInternalPromotion, model.text];
        [screenNames addObject:@{@"name":screenName,@"position": @""}];
        // AF
        if (i == 0) {
            NSDictionary *appsflyerParams = @{@"af_content_type"    : @"Vitural_Catentrance_click",
                                              @"af_cat_id"          : @"",
                                              @"af_cat_name"        : @"",
                                              @"af_cat_level"       : @"1",
                                              @"af_text"            : ZFToString(model.text),
                                              @"af_first_entrance"  : @"category"
            };

            [ZFAppsflyerAnalytics zfTrackEvent:@"af_Catentrance_click" withValues:appsflyerParams];
        }
    }
    [ZFAnalytics showAdvertisementWithBanners:screenNames position:nil screenName:@"Category"];
}

-(void)showSubCateAnalytics:(NSArray<ZFSubCategorySectionModel *> *)subCateArray
{
    if (![self.showSubCateIndexArray containsObject:@(self.selectedSuperCateIndex)]) {
        [self.showSubCateIndexArray addObject:@(self.selectedSuperCateIndex)];
    } else {
        return;
    }
    NSMutableArray *screenNames = [NSMutableArray array];
    for (ZFSubCategorySectionModel *subModel in subCateArray) {
        if (![subModel isKindOfClass:[ZFSubCategorySectionModel class]]) continue;
        
        for (ZFCategoryTabContainer *tabContainer in subModel.sectionModelarray) {
            if (![tabContainer isKindOfClass:[ZFCategoryTabContainer class]]) continue;
            
            NSString *screenName = [NSString stringWithFormat:@"%@_%@",ZFGACategoryInternalPromotion, tabContainer.text];
            [screenNames addObject:@{@"name":screenName,@"position": @""}];
        }
    }
    [ZFAnalytics showAdvertisementWithBanners:screenNames position:nil screenName:@"Category"];
}


- (void)clickBannerAdvertisementWithIndex:(ZFCategoryTabContainer *)bannerModel
                              bannerIndex:(NSInteger)bannerIndex
{
    NSString *GABannerId    = bannerModel.tabContainerId;
    NSString *GABannerName  = [NSString stringWithFormat:@"%@_%ld_%@",ZFGACategoryBannerBranch, bannerIndex, bannerModel.text];
    NSString *position      = @"";
    [ZFAnalytics clickAdvertisementWithId:GABannerId name:GABannerName position:position];
}



-(void)analyticsCateBannerWithCateArray:(NSArray<CategoryNewModel *> *)cateArray {
    NSMutableArray *screenNames = [NSMutableArray array];
    for (int i = 0; i < cateArray.count; i++) {
        CategoryNewModel * model = cateArray[i];
        NSString *screenName = [NSString stringWithFormat:@"%@_%@",ZFGACategoryInternalPromotion, model.cat_name];
        [screenNames addObject:@{@"name":screenName,@"position": @""}];
    }
    [ZFAnalytics showAdvertisementWithBanners:screenNames position:nil screenName:@"Category"];
}

- (void)clickCateAdvertisementWithIndex:(NSInteger)index {
    CategoryNewModel *model = self.subCateModel.cateModelArray[index];
    NSString *GABannerId    = model.cat_id;
    NSString *GABannerName  = [NSString stringWithFormat:@"%@_%@",ZFGACategoryInternalPromotion, model.cat_name];
    NSString *position      = @"";
    [ZFAnalytics clickAdvertisementWithId:GABannerId name:GABannerName position:position];
}

-(void)analyticsCateBannerWithBannerArray:(NSArray<ZFCateBranchBanner *> *)branchBannerArray {
    NSMutableArray *screenNames = [NSMutableArray array];
    for (int i = 0; i < branchBannerArray.count; i++) {
        ZFCateBranchBanner *branchBanner = branchBannerArray[i];
        for (int j = 0; j < branchBanner.bannerArray.count; j++) {
            ZFCateBanner *banner = branchBanner.bannerArray[j];
            NSString *screenName = [NSString stringWithFormat:@"%@_%ld_%d_%@",ZFGACategoryBannerBranch, branchBanner.branch, j, banner.name];
            [screenNames addObject:@{@"name":screenName,@"position": @""}];
        }
    }
    [ZFAnalytics showAdvertisementWithBanners:screenNames position:nil screenName:@"Category"];
}

@end

