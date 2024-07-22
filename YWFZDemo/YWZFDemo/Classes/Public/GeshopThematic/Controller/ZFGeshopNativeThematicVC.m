//
//  ZFGeshopNativeThematicVC.m
//  ZZZZZ
//
//  Created by YW on 2019/12/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGeshopNativeThematicVC.h"
#import "ZFGeshopViewModel.h"
#import "ZFGeshopCollectionView.h"

#import "ZFGeshopSectionModel.h"
#import "ZFInitViewProtocol.h"
#import "ZFCMSCycleBannerCell.h"
#import "ZFCMSTextModuleCell.h"
#import "YWCFunctionTool.h"
#import "ZFColorDefiner.h"
#import "UIColor+ExTypeChange.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "ZFFrameDefiner.h"
#import "ZFProgressHUD.h"
#import "BannerManager.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "ZFGoodsDetailViewController.h"
#import "ZFWebViewViewController.h"
#import "AnalyticsInjectManager.h"
#import "ZFGeshopNavtiveAOP.h"
#import "ZFGeshopSiftPopListView.h"
#import "ZFCategoryRefineNewView.h"
#import "ZFAnalyticsExposureSet.h"
#import "ZFGeshopFlowLayout.h"

@interface ZFGeshopNativeThematicVC ()<ZFGeshopThematicProtocol>

@property (nonatomic, strong) ZFGeshopNavtiveAOP            *nativeThemeAop;
@property (nonatomic, strong) ZFGeshopViewModel             *viewModel;
@property (nonatomic, strong) ZFGeshopCollectionView        *geshopCollectionView;
@property (nonatomic, strong) ZFGeshopSiftPopListView       *siftPopListView;
@property (nonatomic, strong) ZFCategoryRefineNewView       *refineNewView;
@property (nonatomic, strong) NSDictionary                  *afRefineAnalyticDic;
@property (nonatomic, strong) NSDictionary                  *siftRefineIds;
@property (nonatomic, strong) NSDictionary                  *asyncRequestParmaters;
@property (nonatomic, copy  ) NSString                      *lastSiftCategoryId;
@property (nonatomic, copy  ) NSString                      *sift_price_min;
@property (nonatomic, copy  ) NSString                      *sift_price_max;
@property (nonatomic, assign) BOOL                          hasSiftData;
@property (nonatomic, strong) NSArray                       *siftCategoryList;
@property (nonatomic, strong) ZFGeshopSiftItemModel         *checkedCategorySiftModel;
@property (nonatomic, strong) ZFGeshopSiftItemModel         *checkedSortSiftModel;
@end

@implementation ZFGeshopNativeThematicVC

- (void)dealloc {
    if (_refineNewView) {
        [self.refineNewView removeFromSuperview];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[AnalyticsInjectManager shareInstance] analyticsInject:self injectObject:self.nativeThemeAop];
    [self zfInitView];
    [self zfAutoLayoutView];
    
    ShowLoadingToView(self.view);
    [self requestGeshopListData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_refineNewView) {
        [self.refineNewView hideRefineInfoViewViewWithAnimation:NO];
    }
}

- (void)requestGeshopListData {
    @weakify(self)
    self.asyncRequestParmaters = nil;
    NSDictionary *parmater = @{@"page_id" : ZFToString(self.nativeThemeId)};
    [self.viewModel requestGeshopPageData:parmater
                               completion:^(NSArray<ZFGeshopSectionModel *> *modelArray, NSDictionary *pageDict) {
        @strongify(self)
        [self clearSiftParmater];
        HideLoadingFromView(self.view);
        [self.geshopCollectionView dealWithListData:modelArray
                                           pageDict:pageDict];
    }];
}

- (void)requestGeshopMorePageData {
    @weakify(self)
    self.asyncRequestParmaters = nil;
    NSString *component_ids = [self.viewModel fetchMorePageComponent_ids];
    NSDictionary *parmater = [self configParmater:component_ids];
    [self.viewModel requestGeshopMoreData:parmater
                               completion:^(NSArray<ZFGeshopSectionListModel *> *modelArray, NSDictionary *pageDict) {
        @strongify(self)
        HideLoadingFromView(self.view);
        if (self.hasSiftData) {
            [self refresCategorySortSiftData];
        }
        [self.geshopCollectionView dealWithMorePageData:modelArray
                                               pageDict:pageDict
                                             isFromSift:self.hasSiftData];
    }];
}

- (void)requestGeshopAsyncData:(NSString *)component_ids {
    if (ZFIsEmptyString(component_ids)) return;
    @weakify(self)
    NSDictionary *requestInfo = [self configParmater:component_ids];
    if ([self.asyncRequestParmaters isEqualToDictionary:requestInfo]) {
        return;// 防止异步筛选时点击相同条件来请求
    } else {
        self.asyncRequestParmaters = requestInfo;
    }
    ShowLoadingToView(self.view);
    [self.viewModel requestGeshopAsyncData:requestInfo
                           pageModelArrray:self.geshopCollectionView.sectionModelArr
                               completion:^(NSArray<ZFGeshopSectionModel *> *modelArray, NSDictionary *pageDict) {
        @strongify(self)
        HideLoadingFromView(self.view);
        if (self.hasSiftData) {
            [self refresCategorySortSiftData];
        }
        [self.geshopCollectionView dealWithAsyncReloadData:modelArray
                                                  pageDict:pageDict
                                                isFromSift:self.hasSiftData];
    }];
}

- (void)clearSiftParmater {
    self.checkedCategorySiftModel = nil;
    self.checkedSortSiftModel = nil;
    self.siftRefineIds = nil;
    self.sift_price_min = nil;
    self.sift_price_max = nil;
    self.hasSiftData = NO;
}

- (NSDictionary *)configParmater:(NSString *)component_ids {
    NSMutableDictionary *parmater = [NSMutableDictionary dictionary];
    parmater[@"page_id"]     = ZFToString(self.nativeThemeId);
    parmater[@"component_id"] = ZFToString(component_ids);
    parmater[@"category_id"] = ZFToString(self.checkedCategorySiftModel.item_id);
    parmater[@"sort_id"]     = ZFToString(self.checkedSortSiftModel.item_id);
    parmater[@"refine_id"]   = self.siftRefineIds ? self.siftRefineIds : @{};
    parmater[@"price_min"]   = ZFToString(self.sift_price_min);
    parmater[@"price_max"]   = ZFToString(self.sift_price_max);
    parmater[@"page_no"]     = @(self.viewModel.curPage);
    parmater[@"page_size"]   = @(self.viewModel.page_size);
    return parmater;
}

/// 每次筛选完之后需要把分类和排序的小列表数据恢复成之前的老数据
- (void)refresCategorySortSiftData {
    NSString *siftCategoryId = self.checkedCategorySiftModel.item_id;
    if (_refineNewView &&
        ![self.lastSiftCategoryId isEqualToString:ZFToString(siftCategoryId)]) {
        self.refineNewView.nativeRefineDataArray = @[];
    }
    self.lastSiftCategoryId = ZFToString(siftCategoryId);
    
    for (ZFGeshopSectionModel *sectionModel in self.geshopCollectionView.sectionModelArr) {
        if (sectionModel.component_type != ZFGeshopSiftGoodsCellType) continue;
        
        sectionModel.checkedCategorySiftModel = self.checkedCategorySiftModel;
        sectionModel.checkedSortSiftModel = self.checkedSortSiftModel;
        ///在每次重新筛选后保持之前的分类数据不做替换
        if (self.siftCategoryList.count > 0) {
            sectionModel.component_data.category_list = self.siftCategoryList;
        }
        for (ZFGeshopSiftItemModel *itemModel in sectionModel.component_data.sort_list) {
            if ([self.checkedSortSiftModel.item_title isEqualToString:itemModel.item_title]) {
                itemModel.isCurrentSelected = YES;
            } else {
                itemModel.isCurrentSelected = NO;
            }
        }
    }
}

#pragma mark - 点击悬浮操作栏

/// 处理点击筛选组件回调
- (void)handleSiftGoodsAction:(ZFGeshopSectionModel *)siftSectionModel
                 dataType:(NSInteger)dataType
                     openList:(BOOL)openListFlag
{
    ///打开商品筛选组件
    if (dataType == ZFCategoryColumn_RefineType) {
        if (self->_siftPopListView) {
            [self.siftPopListView dismissCategoryListView];
        }
        if (self.refineNewView.nativeRefineDataArray.count == 0) {
            self.refineNewView.nativeRefineDataArray = siftSectionModel.component_data.refine_list;
        }
        [WINDOW addSubview:self.refineNewView];
        [self.refineNewView showRefineInfoViewWithAnimation:YES];
    } else {
        if (openListFlag) {
            [self.siftPopListView setCategoryData:siftSectionModel dataType:dataType];
            [self.siftPopListView openCategoryListView];
        } else {
            [self.siftPopListView dismissCategoryListView];
        }
    }
}

#pragma mark - <处理筛选操作栏>

/// 刷新选中的条件
- (void)configSiftCategoryModel:(ZFGeshopSiftItemModel *)siftModel
{
    if (self.siftPopListView.dataType == ZFCategoryColumn_CategoryType) {
        self.checkedCategorySiftModel = siftModel;
        // 每次切换分类后,都要清空Rfine的筛选条件
        self.siftRefineIds = nil;
        self.sift_price_min = nil;
        self.sift_price_max = nil;
        
    } else if (self.siftPopListView.dataType == ZFCategoryColumn_SortType) {
        self.checkedSortSiftModel = siftModel;
        self.nativeThemeAop.selectedSort = siftModel.item_id;
    }
    
    [self analyticsRefine:self.siftPopListView.dataType];
    
    @weakify(self)/// 刷新表格中的筛选栏Cell筛选标题
    [self.geshopCollectionView dealwithSiftCategoryModel:siftModel
                                        categoryDataType:self.siftPopListView.dataType
                                         siftModelHandle:^(ZFGeshopComponentDataModel *siftComponent) {
        @strongify(self)
        self.siftCategoryList = siftComponent.category_list;
        
    } loadNewDataHandle:^{
        @strongify(self)
        ///请求(Categoty, Sort)条件筛选数据
        [self startRequestAsyncData];
    }];
}

/// 刷新Refine请求数据
- (void)configSiftRefineIdDict:(NSArray *)nativeResults {
    [self.refineNewView hideRefineInfoViewViewWithAnimation:YES];
    
    NSMutableDictionary *refineIdsDict = [NSMutableDictionary dictionary];
    
    for (ZFGeshopSiftItemModel *itemModel in nativeResults) {
        if (![itemModel isKindOfClass:[ZFGeshopSiftItemModel class]]) continue;
        if (itemModel.typePrice) {
            if (!ZFIsEmptyString(itemModel.editMin)) {
                self.sift_price_min = ZFToString(itemModel.editMin);
            } else {
                self.sift_price_min = ZFToString(itemModel.price_min);
            }
            if (!ZFIsEmptyString(itemModel.editMax)) {
                self.sift_price_max = ZFToString(itemModel.editMax);
            } else {
                self.sift_price_max = ZFToString(itemModel.price_max);
            }
        } else {
            if (ZFIsEmptyString(itemModel.item_id)) continue;
            // 每一栏选择的子级id
            NSMutableArray *childIdsArray = [NSMutableArray array];
            for (ZFGeshopSiftItemModel *tmpModel in itemModel.selectItems) {
                if (![tmpModel isKindOfClass:[ZFGeshopSiftItemModel class]]) continue;
                if (ZFIsEmptyString(itemModel.item_id))continue;
                [childIdsArray addObject:ZFToString(tmpModel.item_id)];
            }
            // 每栏选择的id -> dict[superId] = @[childId1, childId2]
            refineIdsDict[itemModel.item_id] = childIdsArray;
        }
    }
    self.siftRefineIds = [NSDictionary dictionaryWithDictionary:refineIdsDict];
    
    //请求Refine筛选数据
    [self startRequestAsyncData];
    
    [self analyticsRefine:ZFCategoryColumn_RefineType];
}

/// 请求异步数据
- (void)startRequestAsyncData {
    self.hasSiftData = YES;
    NSString *component_ids = [self.viewModel fetchSiftComponent_ids];
    [self requestGeshopAsyncData:component_ids];
}

// 筛选数据统计
- (void)analyticsRefine:(ZFCategoryColumnDataType )seletType{
    NSString *type = @"";
    if (seletType == ZFCategoryColumn_CategoryType) {
        type = @"category_choice";
    } else if(seletType == ZFCategoryColumn_SortType) {
        type = @"sort_choice";

    } else if(seletType == ZFCategoryColumn_RefineType) {
        type = @"filter_choice";
    }
    NSString *categoryId = ZFToString(self.checkedCategorySiftModel.item_id);
    NSString *sortId = ZFToString(self.checkedSortSiftModel.item_id);
    if (ZFIsEmptyString(sortId)) {
        sortId = @"recommend";
    }
    NSDictionary *af_filter = ZFJudgeNSDictionary(self.afRefineAnalyticDic) ? self.afRefineAnalyticDic : @{};
    NSDictionary *afParams = @{
        @"af_content_type"      : ZFToString(type),
        @"af_sort"              : ZFToString(sortId),
        @"af_category"          : ZFToString(categoryId),
        @"af_filter"            : af_filter,
        @"af_inner_mediasource" : [ZFAppsflyerAnalytics sourceStringWithType:ZFAppsflyerInSourceTypeNativeTopic sourceID:self.nativeThemeId]
    };
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_filter_choice" withValues:afParams];
}

#pragma mark - <DeepLink Action>
- (void)clickListItemWithSectionModel:(ZFGeshopSectionModel *)sectionModel indexPath:(NSIndexPath *)indexPath
{
    if (sectionModel.component_type == ZFGeshopNavigationCellType ||
        sectionModel.component_type == ZFGeshopCycleBannerCellType) return;
    
    // 商品平铺列表组件跳转
    if (sectionModel.component_type == ZFGeshopGridGoodsCellType) {
        ZFGoodsDetailViewController *goodsDetailVC = [[ZFGoodsDetailViewController alloc] init];
        ZFGeshopSectionListModel *listModel = sectionModel.component_data.list[indexPath.item];
        goodsDetailVC.goodsId = ZFToString(listModel.goods_id);
        goodsDetailVC.sourceID = self.nativeThemeId;
        goodsDetailVC.sourceType = ZFAppsflyerInSourceTypeNativeTopic;
        goodsDetailVC.analyticsSort = self.nativeThemeAop.selectedSort;
        goodsDetailVC.af_rank = indexPath.item + 1;
        [self.navigationController pushViewController:goodsDetailVC animated:YES];
        
    } else { //Deeplink: 其他组件栏跳转
        [self jumpDeeplinkAction:sectionModel.component_data.jump_link];
    }
}

- (void)jumpDeeplinkAction:(NSString *)jump_link {
    if (ZFIsEmptyString(jump_link)) return;
    
    // 去除首尾空格和换行：
    jump_link = [jump_link stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([jump_link hasPrefix:@"http"]) {
        ZFWebViewViewController *webVC = [[ZFWebViewViewController alloc] init];
        webVC.link_url = jump_link;
        [self.navigationController pushViewController:webVC animated:YES];
        
    } else if ([jump_link hasPrefix:@"ZZZZZ"]) {
        NSMutableDictionary *paramDict = [BannerManager parseDeeplinkParamDicWithURL:[NSURL URLWithString:jump_link]];
        
        NSString *actiontype = ZFToString(paramDict[@"actiontype"]);
        if (actiontype.integerValue == -2) {
            
            NSString *customDeeplink = ZFToString(ZFEscapeString(ZFToString(paramDict[@"url"]), YES));
            if (ZFIsEmptyString(customDeeplink)) return;
            paramDict = [BannerManager parseDeeplinkParamDicWithURL:[NSURL URLWithString:customDeeplink]];
        }
        [BannerManager jumpDeeplinkTarget:self deeplinkParam:paramDict];
    }
}

#pragma mark - InitView

- (void)zfInitView {
    [self.view addSubview:self.geshopCollectionView];
}

- (void)zfAutoLayoutView {
    [self.geshopCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

- (ZFGeshopCollectionView *)geshopCollectionView {
    if (!_geshopCollectionView) {
        _geshopCollectionView = [[ZFGeshopCollectionView alloc] initWithGeshopProtocol:self];
        _geshopCollectionView.backgroundColor = [UIColor whiteColor];
    }
    return _geshopCollectionView;
}

/// 分类条件筛选下拉框
- (ZFGeshopSiftPopListView *)siftPopListView {
    if (!_siftPopListView) {
        _siftPopListView = [[ZFGeshopSiftPopListView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:_siftPopListView];
        
        @weakify(self)
        _siftPopListView.categoryCompletionAnimation = ^(BOOL isShow) {
            @strongify(self)
            //显示筛选时是否禁止点击状态栏滚到顶部
            [self.geshopCollectionView setListViewCanScrollsToTop:!isShow];
            if (!isShow) {
                ZFPostNotification(kNativeThemeRecoverArrowNotification, nil);
            }
        };
        _siftPopListView.selectedCategoryBlock = ^(ZFGeshopSiftItemModel *siftModel) {
            @strongify(self)
            [self configSiftCategoryModel:siftModel];
        };
        
        CGFloat siftBarCellHeight = 44;//固定高度
        [_siftPopListView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.view.mas_top).offset(siftBarCellHeight);
            make.leading.trailing.bottom.mas_equalTo(self.view);
        }];
    }
    [self.view bringSubviewToFront:_siftPopListView];
    return _siftPopListView;
}

/// 颜色/数量/尺码筛选 -> 右侧滑动操作视图
- (ZFCategoryRefineNewView *)refineNewView {
    if (!_refineNewView) {
        CGRect rect = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
        _refineNewView = [[ZFCategoryRefineNewView alloc] initWithFrame:rect];
        [WINDOW addSubview:_refineNewView];
        
        @weakify(self)
        _refineNewView.confirmBlock = ^(NSArray<ZFGeshopSiftItemModel *> *nativeResults, NSArray<CategoryRefineCellModel *> *categoryResults,NSDictionary *afParams) {
            @strongify(self)
            self.afRefineAnalyticDic = afParams;
            [self configSiftRefineIdDict:nativeResults];
        };
        _refineNewView.clearConditionBlock = ^{
            @strongify(self)
            self.siftRefineIds = nil;
            self.sift_price_min = nil;
            self.sift_price_max = nil;
            self.afRefineAnalyticDic = @{};
        };
        _refineNewView.hideCategoryRefineBlock = ^{
            @strongify(self)
            [self.refineNewView removeFromSuperview];
            [self.geshopCollectionView setListViewCanScrollsToTop:YES];
        };
    }
    return _refineNewView;
}

- (ZFGeshopViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFGeshopViewModel alloc] init];
        _viewModel.nativeThemeId          = ZFToString(self.nativeThemeId);
        _viewModel.nativeThemeTitle       = ZFToString(self.title);
        _viewModel.listViewCellBlockArray = [self.geshopCollectionView configAllClickCellBlockArray];
    }
    return _viewModel;
}

- (ZFGeshopNavtiveAOP *)nativeThemeAop {
    if (!_nativeThemeAop) {
        _nativeThemeAop = [[ZFGeshopNavtiveAOP alloc] init];
        _nativeThemeAop.nativeThemeId = self.nativeThemeId;
        _nativeThemeAop.nativeThemeName = self.title;
    }
    return _nativeThemeAop;
}

@end
