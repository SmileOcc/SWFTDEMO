//
//  SearchResultViewController.m
//  Dezzal
//
//  Created by YW on 18/8/10.
//  Copyright © 2016年 7FD75. All rights reserved.
//

#import "SearchResultViewController.h"
#import "ZFInitViewProtocol.h"
#import "ZFCartViewController.h"
#import "ZFGoodsDetailViewController.h"
#import "ZFSearchResultNavigationView.h"
#import "ZFSearchResultSortView.h"
#import "ZFSearchResultModel.h"
#import "ZFSearchMatchResultView.h"
#import "ZFListGoodsNumberHeaderView.h"
#import "ZFGoodsListItemCell.h"
#import "ZFGoodsKeyWordsHeaderView.h"
#import "ZFSearchResultErrorHeaderView.h"
#import "ZFSearchResultErrorTitleView.h"
#import "SearchResultViewModel.h"
#import "ZFSearchMatchViewModel.h"
#import "ZFGoodsModel.h"
#import "ZFSearchResultMoreCollectionViewCell.h"
#import "ZFAppsflyerAnalytics.h"
#import "ZFCellHeightManager.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "ZFSearchMapResultAnalyticsAOP.h"
#import "AnalyticsInjectManager.h"
#import "ZFThemeManager.h"
#import "NSStringUtils.h"
#import "ZFProgressHUD.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "UIView+LayoutMethods.h"
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"
#import "NSUserDefaults+SafeAccess.h"
#import "ZFFireBaseAnalytics.h"
#import "ZFAnalyticsTimeManager.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "ZF3DTouchHeader.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "ZFRefreshHeader.h"
#import "ZFRefreshFooter.h"
#import "UINavigationItem+ZFChangeSkin.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFTimerManager.h"
#import "ZFAppsflyerAnalytics.h"
#import "ZFCommonRequestManager.h"
#import "ZFBTSManager.h"
#import "ZFSearchHistoryInfoModel.h"
#import "CategoryListPageViewModel.h"

#import "CategoryDropDownMenu.h"
#import "CategorySelectView.h"
#import "ZFCategoryRefineNewView.h"

static const CGFloat kKeywordHeight = 54.0;
@interface SearchResultViewController () <ZFInitViewProtocol, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ZFSearchMapResultAnalyticsDatasource>

/// 当前排序
@property (nonatomic, copy) NSString                                *currentSortType;
@property (nonatomic, assign) BOOL                                  cancelNormal;
@property (nonatomic, strong) SearchResultViewModel                 *viewModel;
@property (nonatomic, strong) ZFSearchMatchViewModel                *matchViewModel;
@property (nonatomic, strong) ZFSearchResultNavigationView          *navigationView;
@property (nonatomic, strong) ZFSearchResultSortView                *sortView;
@property (nonatomic, strong) ZFGoodsKeyWordsHeaderView             *keyworkHeaderView;
@property (nonatomic, strong) ZFSearchMatchResultView               *matchView;
@property (nonatomic, strong) UICollectionViewFlowLayout            *waterFallLayout;
@property (nonatomic, strong) UICollectionView                      *collectionView;

@property (nonatomic, strong) UIView                                *topView;


/// 筛选弹窗
@property (nonatomic, strong) ZFCategoryRefineNewView               *newRefineView;
/// 菜单选项栏
@property (nonatomic, strong) CategoryDropDownMenu                  *downMenuView;
@property (nonatomic, strong) CategorySelectView                    *sortListView;


@property (nonatomic, strong) NSArray<NSString *>                   *sortRequests;
@property (nonatomic, strong) NSArray<NSString *>                   *sortArray;
@property (nonatomic, strong) NSMutableArray                        *menuTitles;
/// 排序选中的标题
@property (nonatomic, copy) NSString                                *currentSortTitle;
@property (nonatomic, copy)   NSString                              *price_max;
@property (nonatomic, copy)   NSString                              *price_min;
/// 选择的属性ID
@property (nonatomic, copy)   NSString                              *selectedAttrsString;
@property (nonatomic, strong) NSDictionary                          *afRefineDic;


@property (nonatomic, strong) ZFSearchResultModel                   *model;
@property (nonatomic, copy) NSString                                *keyword;
//统计代码AOP，跟该页面相关的统计代码移到这个类
@property (nonatomic, strong) ZFSearchMapResultAnalyticsAOP         *searchAnalytics;

@property (nonatomic, strong) NSURLSessionDataTask       *goodsDetailBtsTask;

@end

@implementation SearchResultViewController

-(instancetype)init
{
    self = [super init];
    
    if (self) {
        self.featuring = @"";
        ///注入代码
        [[AnalyticsInjectManager shareInstance] analyticsInject:self injectObject:self.searchAnalytics];
    }
    return self;
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = YES;
    [self zfInitView];
    [self zfAutoLayoutView];
 
    self.currentSortType = @"recommend"; //默认的请求排序方式
    self.currentSortTitle = ZFLocalizedString(@"Category_Item_Segmented_Sort", nil);
    self.sortView.selectType = ZFSearchResultSortTypeRecommend;
    self.cancelNormal = NO;
    
    // 配置选择栏
//    [self configuratSortView];
    
    NSMutableDictionary *btsDict = [NSMutableDictionary dictionary];
    btsDict[kZFBtsProductPhoto] = kZFBts_A;
    
    //V5.7.0:@产品说不请求保留默认版本
//    btsDict[kZFBtsIOSListfilter] = kZFBts_A;
    
    @weakify(self)
    self.goodsDetailBtsTask = [ZFBTSManager requestBtsModelList:btsDict timeoutInterval:3 completionHandler:^(NSArray<ZFBTSModel *> * _Nonnull modelArray, NSError * _Nonnull error) {
        @strongify(self);
        
        for (ZFBTSModel *obj in modelArray) {
            if ([obj.plancode isEqualToString:kZFBtsIOSListfilter]) {
                if ([obj.policy isEqualToString:kZFBts_B]) {
                    // 筛选数据
                    [self requestRefineData];
                }
            }
        }
        
        [self configuratSortView];
        
        // 请求列表数据
        [self.collectionView.mj_header beginRefreshing];
    }];
    
//    [ZFCommonRequestManager requestProductPhotoBts:^(ZFBTSModel *btsModel) {
//        [self.collectionView.mj_header beginRefreshing];
//    }];
    // 3D Touch添加购物车刷新
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCartCountByAnimation) name:kCartNotification object:nil];
    [self getSearchHistoryWords];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_newRefineView) {
        [self.newRefineView hideRefineInfoViewViewWithAnimation:NO];
    }
}

- (void)dealloc {
    for (ZFGoodsModel *obj in self.model.goodsArray) {
        // 倒计时开启，根据商品属性判断
        if ([obj.countDownTime integerValue] > 0) {
            [[ZFTimerManager shareInstance] stopTimer:[NSString stringWithFormat:@"GoodsList_%@", obj.goods_id]];
        }
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (_goodsDetailBtsTask) {
        [_goodsDetailBtsTask cancel];
        _goodsDetailBtsTask = nil;
    }
    if (_newRefineView) {
        [self.newRefineView removeFromSuperview];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [ZFAnalytics screenViewQuantityWithScreenName:[NSString stringWithFormat:@"Search - %@",self.searchString]];
    //刷新Bag
    [self refreshBadge];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark - private methods

- (void)refreshCartCountByAnimation
{
    [self refreshBadge];
    [self.navigationView refreshCartCountAnimation];
}

/// 顶部选择栏 AB: A 原始，B 试验
- (void)configuratSortView {
    
    // 每次都调，防止有界面，没数据
    ZFBTSModel *btsModel = [ZFBTSManager getBtsModel:kZFBtsIOSListfilter defaultPolicy:kZFBts_A];
    if ([btsModel.policy isEqualToString:kZFBts_B]) {
        self.sortView.hidden = YES;
        self.downMenuView.hidden = NO;
        self.downMenuView.alpha = 0;
    } else {
        self.sortView.hidden = NO;
        self.downMenuView.hidden = YES;
        self.sortView.alpha = 0;
    }
    [UIView animateWithDuration:0.25 animations:^{
        self.sortView.alpha = 1.0;
        self.downMenuView.alpha = 1.0;
        [self.sortView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(40);
        }];
    } completion:^(BOOL finished) {
    }];
}
/**
 * 刷新Bag
 */
- (void)refreshBadge
{
    NSNumber *badgeNum = [[NSUserDefaults standardUserDefaults] valueForKey:kCollectionBadgeKey];
    NSString * numberIndex = @"";
    if ([badgeNum integerValue] == 0) {
        self.navigationView.badgeCount = @"";
        return;
    }
    if ([badgeNum integerValue] > 99) {
        numberIndex = @"99+";
    } else {
        numberIndex = [NSString stringWithFormat:@"%ld",(long)[badgeNum integerValue]];
    }
    self.navigationView.badgeCount = numberIndex;
}

- (void)requestSearchResultMatchInfoWithKey:(NSString *)searchKey {
    if (searchKey.length <= 0) {
        self.matchView.hidden = YES;
        return ;
    }
    @weakify(self)
    [self.matchViewModel requestNetwork:searchKey completion:^(id obj) {
        @strongify(self)
        NSArray *searchResult = obj;
        if (!self.cancelNormal) {
            self.matchView.matchResult = searchResult;
            self.matchView.hidden = NO;
        }
    } failure:^(id obj) {
        
    }];
}

- (void)requestSearchRefresh {
    
    if (!self.newRefineView.model) {
        [self requestRefineData];
    }
    
    ZFBTSModel *productPhotoBtsModel = [ZFBTSManager getBtsModel:kZFBtsProductPhoto defaultPolicy:kZFBts_A];
    NSMutableArray *bts_test = [NSMutableArray array];
    [bts_test addObject:[productPhotoBtsModel getBtsParams]];
    
    // 谷歌统计
    [[ZFAnalyticsTimeManager sharedManager] logTimeWithEventName:kStartLoadingSearchList];
    NSString *searchString = [self.keyword length] > 0 ? self.keyword : _searchString;
    
    NSDictionary *paramsDic = @{@"keyword"   : ZFToString(searchString),
                                @"refresh"   : Refresh,
                                @"page_size" : @(10),
                                @"order_by"  : ZFToString(_currentSortType),
                                @"price_min" : ZFToString(self.price_min),
                                @"price_max" : ZFToString(self.price_max),
                                @"selected_attr_list" : ZFToString(self.selectedAttrsString),
                                @"is_enc"    : @"0",
                                @"featuring" : ZFToString(self.featuring),
                                @"bts_test"  : bts_test
                                };
    @weakify(self)
    [self.viewModel requestSearchNetwork:paramsDic completion:^(id obj) {
        @strongify(self)
        // 谷歌统计
        [[ZFAnalyticsTimeManager sharedManager] logTimeWithEventName:kFinishLoadingSearchList];
        self.model = obj;
        HideLoadingFromView(self.view);
        [self.collectionView setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
        if (self.model.result_num <= 0) {

        
            self.topView.hidden = YES;

            [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.bottom.mas_equalTo(self.view);
                make.top.mas_equalTo(self.navigationView.mas_bottom);
            }];
            [self.collectionView showRequestTip:@{}];
            self.collectionView.mj_footer.hidden = YES;
            self.collectionView.mj_header.hidden = YES;
            [self.collectionView reloadData];
        } else {
            self.topView.hidden = NO;
            self.keyworkHeaderView.kerwordArray = self.model.guideWords;
            [self.collectionView showRequestTip:@{}];
            HideLoadingFromView(self.view);
            [self.collectionView reloadData];
            [self.collectionView.mj_header endRefreshing];
            self.collectionView.mj_footer.hidden = self.model.result_num <= 0 || self.model.cur_page == self.model.total_page;
            self.collectionView.mj_header.hidden = self.model.result_num <= 0 || self.model.cur_page == self.model.total_page;
            
            if (self.model.spellKeywords.count > 0) {
                [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.leading.trailing.bottom.mas_equalTo(self.view);
                    make.top.mas_equalTo(self.navigationView.mas_bottom);
                }];
                self.collectionView.mj_header.hidden = YES;
                self.collectionView.mj_footer.hidden = YES;
            } else if (self.model.guideWords.count > 0) {
                [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.leading.trailing.bottom.mas_equalTo(self.view);
                    make.top.mas_equalTo(self.keyworkHeaderView.mas_bottom);
                }];
            } else {
                [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.leading.trailing.bottom.mas_equalTo(self.view);
                    make.top.mas_equalTo(self.topView.mas_bottom);
                }];
            }
            // 防止首次进来刷新数据动画异常
            [self.view layoutIfNeeded];
        }
        self.searchAnalytics.totalCount = self.model.result_num;
    } failure:^(id obj) {
        @strongify(self)
        // 谷歌统计
        [[ZFAnalyticsTimeManager sharedManager] logTimeWithEventName:kFinishLoadingSearchList];
        [self.collectionView reloadData];
        [self.collectionView.mj_header endRefreshing];
        self.collectionView.mj_footer.hidden = self.model.result_num <= 0;
        self.collectionView.mj_header.hidden = self.model.result_num <= 0;
        [self.collectionView showRequestTip:nil];
        HideLoadingFromView(self.view);
    }];
}

- (void)requestSearchLoadMore {
    // 谷歌统计
    [[ZFAnalyticsTimeManager sharedManager] logTimeWithEventName:kStartLoadingSearchList];
    
    ZFBTSModel *productPhotoBtsModel = [ZFBTSManager getBtsModel:kZFBtsProductPhoto defaultPolicy:kZFBts_A];
    NSMutableArray *bts_test = [NSMutableArray array];
    [bts_test addObject:[productPhotoBtsModel getBtsParams]];
    
    NSString *searchString = [self.keyword length] > 0 ? self.keyword : _searchString;
    
    NSDictionary *paramsDic = @{@"keyword"   : ZFToString(searchString),
                                @"refresh"   : LoadMore,
                                @"page_size" : @(10),
                                @"order_by"  : ZFToString(_currentSortType),
                                @"price_min" : ZFToString(self.price_min),
                                @"price_max" : ZFToString(self.price_max),
                                @"selected_attr_list" : ZFToString(self.selectedAttrsString),
                                @"is_enc"    : @"0",
                                @"featuring" : ZFToString(self.featuring),
                                @"bts_test"  : bts_test
                                };
    @weakify(self)
    [self.viewModel requestSearchNetwork:paramsDic  completion:^(id obj) {
        @strongify(self)
        // 谷歌统计
        [[ZFAnalyticsTimeManager sharedManager] logTimeWithEventName:kFinishLoadingSearchList];
        if([obj isEqual: NoMoreToLoad]) {
            // 无法加载更多的时候
            [self.collectionView.mj_footer endRefreshingWithNoMoreData];
            self.collectionView.mj_footer.hidden = YES;
        } else {
            self.model = obj;
            [self.collectionView reloadData];
            [self.collectionView.mj_footer endRefreshing];
            self.collectionView.mj_footer.hidden = self.model.result_num <= 0 || self.model.cur_page == self.model.total_page;
        }
    } failure:^(id obj) {
        @strongify(self)
        // 谷歌统计
        [[ZFAnalyticsTimeManager sharedManager] logTimeWithEventName:kFinishLoadingSearchList];
        [self.collectionView.mj_footer endRefreshing];
    }];
}

// 获取历史搜索词
- (void)getSearchHistoryWords {
    NSMutableDictionary *historyInfo = (NSMutableDictionary *)[[[NSUserDefaults standardUserDefaults] valueForKey:kSearchHistoryKey] mutableCopy];
    NSMutableArray<ZFSearchHistoryInfoModel *> *sortArray = [NSMutableArray array];
    
    [historyInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        ZFSearchHistoryInfoModel *model = [[ZFSearchHistoryInfoModel alloc] init];
        model.addTime = [obj doubleValue];
        model.searchKey = key;
        [sortArray addObject:model];
    }];
    
    [sortArray sortUsingComparator:^NSComparisonResult(ZFSearchHistoryInfoModel *obj1, ZFSearchHistoryInfoModel *obj2) {
        return obj1.addTime < obj2.addTime;
    }];
    
    NSMutableArray *searchHistoryArray = [NSMutableArray array];
    [sortArray enumerateObjectsUsingBlock:^(ZFSearchHistoryInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (searchHistoryArray.count < 10) {
            [searchHistoryArray addObject:obj.searchKey];
        }
    }];
    
    self.matchView.historyArray = searchHistoryArray;
}


/// 试验版本为B才用这个数据 请求写死
- (void)requestRefineData{
    
    ZFBTSModel *btsModel = [ZFBTSManager getBtsModel:kZFBtsIOSListfilter defaultPolicy:kZFBts_A];
    if ([btsModel.policy isEqualToString:kZFBts_B]) {
        
        NSString *searchString = [self.keyword length] > 0 ? self.keyword : _searchString;
        NSString *attrVersion = [self attVersionIosListfilter:btsModel.policy];
        NSDictionary *paramsDic = @{@"attr_version":ZFToString(attrVersion),
                                    @"keyword":ZFToString(searchString)};
        @weakify(self)
        [self.viewModel requestSearchRefineData:paramsDic completion:^(CategoryRefineSectionModel *refineModel) {
            @strongify(self)
            self.newRefineView.model = refineModel;
            self.newRefineView.categoryRefineDataArray = refineModel.refine_list;
            
        } failure:^(id obj) {
            YWLog(@"怼后台!!!");
        }];
    }
}

- (NSString *)attVersionIosListfilter:(NSString *)policy {
    if (!ZFIsEmptyString(policy) && [policy isEqualToString:kZFBts_B]) {
        return @"1";
    }
    return @"0";
}

- (void)updateTopMenu:(NSString *)counts {
    [self.downMenuView updateIndex:(self.downMenuView.titles.count - 1) counts:counts];
}

// 筛选数据统计
- (void)analyticsRefine:(SelectViewDataType )seletType{
    NSString *type = @"";
    if (seletType == SelectViewDataTypeCategory) {
        type = @"category_choice";
    } else if(seletType == SelectViewDataTypeSort) {
        type = @"sort_choice";

    } else if(seletType == SelectViewDataTypeRefine) {
        type = @"filter_choice";
    } else if (seletType == SelectViewDataTypeWord) {
        type = @"word_choice";
    }
    
    NSDictionary *afParams = @{@"af_content_type" : ZFToString(type),
                             @"af_sort" : ZFToString(self.currentSortType),
                             @"af_filter" : ZFJudgeNSDictionary(self.afRefineDic) ? self.afRefineDic : @{},
                             @"af_keyword" : ZFToString(self.keyword),
                             @"af_inner_mediasource" : [ZFAppsflyerAnalytics sourceStringWithType:self.sourceType sourceID:self.searchString]
    };
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_filter_choice" withValues:afParams];
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.model.spellKeywords.count > 0 ? 2 : 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.model.spellKeywords.count > 0
        && section == 0) {
        return 0;
    }
    return (self.model.spellKeywords.count > 0 && self.model.goodsArray.count > 6) ? 7 : self.model.goodsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.model.spellKeywords.count > 0 && self.model.goodsArray.count > 6 && indexPath.item == 6) {
        ZFSearchResultMoreCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ZFSearchResultMoreCollectionViewCell class]) forIndexPath:indexPath];
        return cell;
    }
    
    ZFGoodsListItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kZFCollectionMultipleColumnCellIdentifier forIndexPath:indexPath];
    cell.af_inner_mediasource = [ZFAppsflyerAnalytics sourceStringWithType:ZFAppsflyerInSourceTypeSearchResult sourceID:[self ZFSearchMapResultAnalyticsSearchKey]];
    cell.sort = self.currentSortType;
    ZFGoodsModel *model = self.model.goodsArray[indexPath.item];
    cell.goodsModel = model;
    //关联3DTouch数据
    [self register3DTouchAlertWithDelegate:collectionView sourceView:cell goodsModel:model];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.model.spellKeywords.count > 0 && self.model.goodsArray.count > 6 && indexPath.item == 6) {
        _searchString = self.model.spellKeywords[0];
        ShowLoadingToView(self.view);
        self.navigationView.searchTitle = _searchString;
        [self requestSearchRefresh];
        return;
    }
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    ZFGoodsListItemCell *cell = (ZFGoodsListItemCell *)[collectionView cellForItemAtIndexPath:indexPath];
    ZFGoodsModel *goodModel = cell.selectedGoodsModel;
    if (!goodModel) {
        goodModel = cell.goodsModel;
    }
    goodModel.af_rank = cell.goodsModel.af_rank;
//    ZFGoodsModel *goodModel = self.model.goodsArray[indexPath.item];
    ZFGoodsDetailViewController * goodsVC = [[ZFGoodsDetailViewController alloc]init];
    goodsVC.goodsId = goodModel.goods_id;
    goodsVC.sourceID = self.searchString;
    goodsVC.sourceType = self.sourceType;
    //occ v3.7.0hacker 添加 ok
    goodsVC.analyticsProduceImpression = self.viewModel.analyticsProduceImpression;
    goodsVC.analyticsSort = self.currentSortType;
    goodsVC.af_rank = goodModel.af_rank;
    goodsVC.isNeedProductPhotoBts = YES;

    NSNumber *from3DTouchFlag = objc_getAssociatedObject(indexPath, k3DTouchRelationCellComeFrom);
    //标记是从3DTouch进来不传动画视图进入商详
    if ([from3DTouchFlag boolValue]) {
        self.navigationController.delegate = nil;
    } else {
        ZFGoodsListItemCell *cell = (ZFGoodsListItemCell *)[collectionView cellForItemAtIndexPath:indexPath];
        goodsVC.transformSourceImageView = cell.goodsImageView;
        self.navigationController.delegate = goodsVC;
    }
    goodsVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:goodsVC animated:YES];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.model.goodsArray.count <= indexPath.section || self.model.goodsArray.count <= indexPath.item) {
        YWLog(@"error:数组越界; selector:%@", NSStringFromSelector(_cmd));
        CGFloat width = (KScreenWidth - 36) * 0.5;
        return  CGSizeMake(width, (width / KImage_SCALE) + 58);// 默认size
    }
    
    static CGFloat cellHeight = 0.0f;
    
    if (indexPath.item % 2 == 0) {
        // 获取当前cell高度
        CGFloat currentCellHeight = [self queryCellHeightWithModel:indexPath.item];
        cellHeight = currentCellHeight;
        
        if (indexPath.item + 1 < self.model.goodsArray.count) {
            // 获取下一个cell高度
            CGFloat nextCellHeight = [self queryCellHeightWithModel:indexPath.item + 1];
            cellHeight = currentCellHeight > nextCellHeight ? currentCellHeight : nextCellHeight;
        }
    }
    
    return CGSizeMake((KScreenWidth - 36) * 0.5, cellHeight);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (self.model.spellKeywords.count > 0
            && [kind isEqualToString: UICollectionElementKindSectionHeader]) {
            ZFSearchResultErrorHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([ZFSearchResultErrorHeaderView class]) forIndexPath:indexPath];
            NSString *keywordString = self.keyword.length > 0 ? self.keyword : _searchString;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [headerView configWithSearchword:keywordString errorKeyword:self.model.spellKeywords];
            });
            
            @weakify(self)
            headerView.clickKeywordHandle = ^(NSString *keyword) {
                @strongify(self)
                self.searchString = keyword;
                ShowLoadingToView(self.view);
                self.navigationView.searchTitle = self.searchString;
                self.sourceType = ZFAppsflyerInSourceTypeSearchFix;
                [self requestSearchRefresh];
            };
            
            return headerView;
        } else if ([kind isEqualToString: UICollectionElementKindSectionHeader]) {
            ZFListGoodsNumberHeaderView *headView = [ZFListGoodsNumberHeaderView headWithCollectionView:collectionView Kind:kind IndexPath:indexPath];
            headView.y = self.model.guideWords.count > 0 ? -6.0 : 0.0;
            if ([kind isEqualToString: UICollectionElementKindSectionHeader]) {
                NSString *number = [NSString stringWithFormat:@"%lu", (long)self.model.result_num];
                headView.item = [NSString stringWithFormat:ZFLocalizedString(@"Public_items_Found", nil), number];
            }
            return headView;
        } else {
            UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([UICollectionReusableView class]) forIndexPath:indexPath];
            headerView.backgroundColor = ZFC0xF2F2F2();
            return headerView;
        }
    }
    
    if (indexPath.section == 1
        && [kind isEqualToString: UICollectionElementKindSectionHeader]) {
        ZFSearchResultErrorTitleView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([ZFSearchResultErrorTitleView class]) forIndexPath:indexPath];
        [headerView configWithGoodsNumber:[NSString stringWithFormat:@"%ld", self.model.result_num] keyword:self.model.spellKeywords[0]];
        return headerView;
    }
    
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([UICollectionReusableView class]) forIndexPath:indexPath];
    headerView.backgroundColor = ZFC0xF2F2F2();
    return headerView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (self.model.spellKeywords.count > 0 && section == 0) {
        CGFloat contentWidth = 12.0;
        NSString *titleString = ZFLocalizedString(@"search_result_matches_keyword", nil);
        CGSize titleSize = [titleString sizeWithAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:14.0] }];
        contentWidth += titleSize.width + 5.0;
        for (NSString *keyword in self.model.spellKeywords) {
            CGSize keySize = [keyword sizeWithAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:14.0] }];
            contentWidth += keySize.width + 16.0;
        }
        if (contentWidth > KScreenWidth) {
            return CGSizeMake(KScreenWidth, 90.0);
        } else {
            return CGSizeMake(KScreenWidth, 64.0);
        }
    } else {
        if (section == 1) {
            return CGSizeMake(KScreenWidth, 40.0f);
        } else {
            if (self.model.result_num <= 0) {
                return CGSizeZero;
            }
            CGFloat height = self.model.guideWords.count > 0 ? 24.0 : 36.0;
            return CGSizeMake(KScreenWidth, height);
        }
    }
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    if (self.model.spellKeywords.count > 0
        && section == 0) {
        return CGSizeMake(KScreenWidth, 8.0);
    }
    return CGSizeMake(KScreenWidth, 0.000001);
}

- (CGFloat)queryCellHeightWithModel:(NSInteger)index {
    CGFloat cellHeight = 0.0f;
    
    // 获取模型数据
    ZFGoodsModel *model = self.model.goodsArray[index];
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

#pragma mark - 搜索Aop需求数据

-(NSArray *)ZFSearchMapResultAnalyticsDataList
{
    return [self.model.goodsArray copy];
}

-(NSString *)ZFSearchMapResultAnalyticsSearchKey
{
    if (ZFToString(self.keyword).length) {
        return self.keyword;
    }
    return self.searchString;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.searchString = self.searchString == nil ? @"": self.searchString;
    self.navigationView.searchTitle = self.searchString;
    self.title = self.searchString;
    self.view.backgroundColor = ZFCOLOR(245, 245, 245, 1.0);
    self.topView.backgroundColor = ZFCOLOR(245, 245, 245, 1.0);
    [self.view addSubview:self.navigationView];
    [self.view addSubview:self.topView];
    [self.view addSubview:self.keyworkHeaderView];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.matchView];
    
    [self.topView addSubview:self.sortView];
    [self.topView addSubview:self.downMenuView];
    [self.view addSubview:self.sortListView];
}

- (void)zfAutoLayoutView {
    
    [self.navigationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.mas_equalTo(self.view);
        make.height.mas_equalTo((STATUSHEIGHT + 45.0));
    }];
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        make.leading.trailing.mas_equalTo(self.view);
        make.top.mas_equalTo(self.navigationView.mas_bottom);
    }];
    
    [self.sortView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0);
        make.leading.trailing.mas_equalTo(self.topView);
        make.top.mas_equalTo(self.topView.mas_top);
    }];
    
    [self.keyworkHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(kKeywordHeight);
        make.leading.trailing.mas_equalTo(self.view);
        make.top.mas_equalTo(self.sortView.mas_bottom);
    }];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(self.topView.mas_bottom);
    }];
    
    [self.view sendSubviewToBack:self.navigationView];
    
    [self.matchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(self.navigationView.mas_bottom);
        
    }];
    
    [self.downMenuView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.topView);
        make.top.mas_equalTo(self.topView.mas_top);
        make.height.mas_equalTo(self.sortView.mas_height);
    }];
    
    [self.sortListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.view);
        make.top.equalTo(self.topView.mas_bottom);
    }];
}


#pragma mark - setter
- (void)setSearchString:(NSString *)searchString {
    _searchString = searchString;
    NSMutableDictionary *historyInfo = (NSMutableDictionary *)[[[NSUserDefaults standardUserDefaults] valueForKey:kSearchHistoryKey] mutableCopy];
    if (historyInfo == nil ||
        ![historyInfo isKindOfClass:[NSMutableDictionary class]]) {
        historyInfo = [NSMutableDictionary dictionary];
    }
    NSTimeInterval addTime = [[NSDate date] timeIntervalSince1970];
    if (!ZFIsEmptyString(_searchString)) {
        [historyInfo setValue:@(addTime) forKey:_searchString];
    }
    [NSUserDefaults setZFObject:historyInfo forKey:kSearchHistoryKey];
    
    if (self.searchResultLoadHistoryCompletionHandler) {
        self.searchResultLoadHistoryCompletionHandler();
    }
}

- (void)setSourceType:(ZFAppsflyerInSourceType)sourceType {
    _sourceType = sourceType;
    self.searchAnalytics.sourceType = sourceType;
}

#pragma mark - 懒加载

- (NSMutableArray *)menuTitles {
    if (!_menuTitles) {
        _menuTitles = [NSMutableArray arrayWithObjects:
                       ZFLocalizedString(@"Category_Item_Segmented_Sort", nil),
                       ZFLocalizedString(@"Category_Item_Segmented_Refine", nil),
                       nil];
    }
    return _menuTitles;
}

- (NSArray<NSString *> *)sortRequests {
    if (!_sortRequests) {
        _sortRequests = @[@"recommend",
                         @"new_arrivals",
                         @"price_low_to_high",
                         @"price_high_to_low"];
    }
    return _sortRequests;
}


- (NSArray<NSString *> *)sortArray {
    if (!_sortArray) {
        _sortArray = @[ZFLocalizedString(@"GoodsSortViewController_Type_Recommend", nil),
                        ZFLocalizedString(@"GoodsSortViewController_Type_New", nil),
                        ZFLocalizedString(@"GoodsSortViewController_Type_LowToHigh", nil),
                        ZFLocalizedString(@"GoodsSortViewController_Type_HighToLow", nil)
                        ];
    }
    return _sortArray;
}

- (ZFGoodsKeyWordsHeaderView *)keyworkHeaderView {
    if (!_keyworkHeaderView) {
        _keyworkHeaderView = [[ZFGoodsKeyWordsHeaderView alloc] init];
        @weakify(self)
        _keyworkHeaderView.selectedKeywordHandle = ^(NSString *keyword) {
            @strongify(self)
            self.keyword = keyword;
            self.sourceType = ZFAppsflyerInSourceTypeSearchRecommend;
            ShowLoadingToView(self.view);
            [self requestSearchRefresh];
            // 统计
            [self analyticsRefine:SelectViewDataTypeWord];
        };
    }
    return _keyworkHeaderView;
}

- (ZFSearchResultNavigationView *)navigationView {
    if (!_navigationView) {
        _navigationView = [[ZFSearchResultNavigationView alloc] initWithFrame:CGRectZero];
        [_navigationView hideBottomSeparateLine];
        // 换肤: by maownagxin
        [_navigationView zfChangeSkinToCustomNavgationBar];
        
        @weakify(self);
        _navigationView.searchResultBackCompletionHandler = ^{
            @strongify(self);
            [self.navigationController popViewControllerAnimated:YES];
        };
        
        _navigationView.searchResultJumpCartCompletionHandler = ^{
            @strongify(self);
            [ZFFireBaseAnalytics selectContentWithItemId:@"Click_bag" itemName:@"SearchResult - bag" ContentType:@"Bag" itemCategory:@"Bag"];
            ZFCartViewController *cartVc = [[ZFCartViewController alloc] init];
            [self.navigationController pushViewController:cartVc animated:YES];
            self.cancelNormal = YES;
        };
        
        _navigationView.searchResultCancelSearchCompletionHandler = ^{
            @strongify(self);
            self.matchView.hidden = YES;
            [self.view endEditing:YES];
            self.navigationView.searchTitle = self.searchString;
            self.cancelNormal = YES;
        };
        
        _navigationView.searchResultReturnCompletionHandler = ^(NSString *searchKey) {
            @strongify(self);
            self.matchView.hidden = YES;
            [self.view endEditing:YES];
            self.cancelNormal = YES;
            if ([NSStringUtils isEmptyString:searchKey]) {
                //空实现
                self.navigationView.searchTitle = self.searchString;
            } else {
                self.searchString = searchKey;
                self.keyword = nil;
                [self.keyworkHeaderView reset];
                [ZFAnalytics clickButtonWithCategory:@"Search" actionName:@"Search - Perform the search" label:searchKey];
                [self.collectionView.mj_header beginRefreshing];
                [self getSearchHistoryWords];
            }
        };
        
        _navigationView.searchResultSearchKeyCompletionHandler = ^(NSString *searchKey) {
            @strongify(self);
            if ([NSStringUtils isEmptyString:searchKey]) {
                self.matchView.hidden = YES;
            } else {
                self.keyword = nil;
                [self.keyworkHeaderView reset];
                self.matchView.searchKey = searchKey;
                self.matchView.hidden = NO;
                [self requestSearchResultMatchInfoWithKey:searchKey];
                [ZFAnalytics clickButtonWithCategory:@"Search" actionName:@"Search - Perform the search" label:searchKey];
            }
        };
        
        _navigationView.searchResultCancelNormalCompletionHandler = ^{
            @strongify(self);
            self.cancelNormal = NO;
            self.matchView.hidden = NO;
        };
    }
    return _navigationView;
}

- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectZero];
        _topView.hidden = NO;
    }
    return _topView;
}
- (ZFSearchResultSortView *)sortView {
    if (!_sortView) {
        _sortView = [[ZFSearchResultSortView alloc] initWithFrame:CGRectZero];
        _sortView.hidden = YES;
        //根据排序方式重新请求数据，并刷新页面
        @weakify(self);
        _sortView.searchResultSortCompletionHandler = ^(ZFSearchResultSortType type) {
            @strongify(self);
            if (type == ZFSearchResultSortTypeRecommend) {
                self.currentSortType = @"recommend";
            } else if (type == ZFSearchResultSortTypeNewArrival) {
                self.currentSortType = @"new_arrivals";
            } else if (type == ZFSearchResultSortTypeHighToLow) {
                self.currentSortType = @"price_high_to_low";
            } else if (type == ZFSearchResultSortTypeLowToHigh) {
                self.currentSortType = @"price_low_to_high";
            }
            self.searchAnalytics.sort = self.currentSortType;
            if (self.model.goodsArray.count > 0) {
                [self.collectionView.mj_header beginRefreshing];
            }
        };
    }
    return _sortView;
}

- (CategoryDropDownMenu *)downMenuView {
    if (!_downMenuView) {
        _downMenuView = [[CategoryDropDownMenu alloc] initWithOrigin:CGPointMake(0, 0) andHeight:44];
        _downMenuView.hidden = YES;
        _downMenuView.isHideTopLine = YES;
        _downMenuView.isHideSpaceLine = YES;
        _downMenuView.isLastFilter = YES;
        _downMenuView.titles = self.menuTitles;
        @weakify(self)
        _downMenuView.chooseCompletionHandler = ^(NSInteger tapIndex, BOOL isSelect) {
            @strongify(self)
            
            NSString *title = self.downMenuView.titles[tapIndex];
            if ([title isEqualToString:self.currentSortTitle]) {
                [self configureSelectDataType:SelectViewDataTypeSort select:isSelect];
                
            } else if ([title isEqualToString:ZFLocalizedString(@"Category_Item_Segmented_Refine", nil)]) {
                [self.sortListView dismiss];
                [self showRefineView];
            }
        };
    }
    return _downMenuView;
}

- (void)showRefineView {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.newRefineView];
    self.newRefineView.hidden = NO;
    [self.newRefineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [self.newRefineView showRefineInfoViewWithAnimation:YES];
        
}

- (void)configureSelectDataType:(NSInteger)dataType select:(BOOL)isSelect {
    if (!isSelect) {
        [self.sortListView dismiss];
        return;
    }
    self.sortListView.dataType = dataType;
    
    self.sortListView.currentSortType = self.sortListView.currentSortType.length > 0 ? self.sortListView.currentSortType : @"Recommend";
    self.sortListView.sortArray = self.sortArray;
    
    [self.sortListView showCompletion:^{
    }];
}

- (CategorySelectView *)sortListView {
    if (!_sortListView) {
        _sortListView = [[CategorySelectView alloc] init];
        @weakify(self)
        _sortListView.selectCompletionHandler = ^(NSInteger tag, SelectViewDataType type) {
            @strongify(self);
            type = SelectViewDataTypeSort;
            [self.downMenuView restoreIndicator:type-1];
  
            self.currentSortType = self.sortRequests[tag];
            self.menuTitles[0] = self.sortListView.sortArray[tag];
            self.downMenuView.titles = self.menuTitles;
            self.currentSortTitle = self.sortListView.sortArray[tag];
            self.sortListView.currentSortType = self.currentSortTitle;
            [self.collectionView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
            [self requestSearchRefresh];
        };
        
        _sortListView.maskTapCompletionHandler = ^(NSInteger index) {
            @strongify(self);
            [self.downMenuView restoreIndicator:index - 1];
        };
        
        _sortListView.selectSubCellHandler = ^(CategoryNewModel *model, SelectViewDataType type) {
        };
        _sortListView.selectAnimationStopCompletionHandler = ^{
            @strongify(self);
            self.downMenuView.isDropAnimation = NO;
        };
    }
    return _sortListView;
}

- (ZFCategoryRefineNewView *)newRefineView {
    if (!_newRefineView) {
        _newRefineView = [[ZFCategoryRefineNewView alloc] initWithFrame:CGRectZero];
        _newRefineView.hidden = YES;
        _newRefineView.af_page_name = @"textSearch";
        
        @weakify(self);
        _newRefineView.hideCategoryRefineBlock = ^{
            @strongify(self);
            
            [self.newRefineView removeFromSuperview];
            // 此处 index 只是避免数组越界
            NSInteger index = SelectViewDataTypeRefine - 1;
            [self.downMenuView restoreIndicator:index];
        };
        
        _newRefineView.confirmBlock = ^(NSArray<ZFGeshopSiftItemModel *> *nativeResults, NSArray<CategoryRefineCellModel *> *categoryResults, NSDictionary *afParams) {
            @strongify(self);

            [self.newRefineView hideRefineInfoViewViewWithAnimation:YES];
            __block NSInteger selectCount = categoryResults.count;
            
            self.price_min = @"";
            self.price_max = @"";
            self.selectedAttrsString = @"";
            self.afRefineDic = @{};
            
            if (ZFJudgeNSArray(categoryResults)) {
                
                NSMutableArray *allSelectAttrs = [NSMutableArray array];
                [categoryResults enumerateObjectsUsingBlock:^(CategoryRefineCellModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (!ZFIsEmptyString(obj.attrID)) {
                        [allSelectAttrs addObject:obj.attrID];
                    }
                    if (obj.typePrice) {
                        self.price_min = !ZFIsEmptyString(obj.editMin) ? obj.editMin : [NSString stringWithFormat:@"%li",(long)obj.min];
                        self.price_max = !ZFIsEmptyString(obj.editMax) ? obj.editMax : [NSString stringWithFormat:@"%li",(long)obj.max];
                        selectCount -= 1;
                    }
                }];
                self.selectedAttrsString = [allSelectAttrs componentsJoinedByString:@"~"];
                self.afRefineDic = afParams;
                [self.collectionView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
                [self requestSearchRefresh];
                [self analyticsRefine:SelectViewDataTypeRefine];
            }
            
            if (selectCount <= 0) {
                [self updateTopMenu:@""];
            } else {
                [self updateTopMenu:[NSString stringWithFormat:@"%li",(long)selectCount]];
            }
        };
        _newRefineView.clearConditionBlock = ^{
            @strongify(self);
            self.selectedAttrsString = @"";
            self.afRefineDic = @{};
            self.price_min = @"";
            self.price_max = @"";
        };
        
    }
    return _newRefineView;
}

- (ZFSearchMatchResultView *)matchView {
    if (!_matchView) {
        _matchView = [[ZFSearchMatchResultView alloc] initWithFrame:CGRectZero];
        _matchView.hidden = YES;
        @weakify(self);
        _matchView.searchMatchCloseKeyboardCompletionHandler = ^{
            @strongify(self);
            [self.view endEditing:YES];
            self.cancelNormal = YES;
        };
        
        _matchView.searchMatchResultSelectCompletionHandler = ^(NSString *matchKey) {
            @strongify(self);
            self.searchString = matchKey;
            self.navigationView.searchTitle = matchKey;
            [self.navigationView cancelOptionRefreshLayout];
            [self.collectionView.mj_header beginRefreshing];
            self.matchView.hidden = YES;
            [self.view endEditing:YES];
            self.cancelNormal = YES;
        };
        
        _matchView.searchMatchHideMatchViewCompletionHandler = ^{
            @strongify(self);
            self.matchView.hidden = YES;
            [self.view endEditing:YES];
            self.navigationView.searchTitle = self.searchString;
            self.cancelNormal = YES;
        };
    }
    return _matchView;
}

- (UICollectionViewFlowLayout *)waterFallLayout {
    if (!_waterFallLayout) {
        _waterFallLayout = [[UICollectionViewFlowLayout alloc] init];
        _waterFallLayout.minimumLineSpacing = 0;
        _waterFallLayout.minimumInteritemSpacing = 12;
        _waterFallLayout.sectionInset = UIEdgeInsetsMake(0, 12, 0, 12);
    }
    return _waterFallLayout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.waterFallLayout];
        _collectionView.backgroundColor = ZFCOLOR(255, 255, 255, 1.0);
        _collectionView.showsVerticalScrollIndicator = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        
        [_collectionView registerClass:[ZFGoodsListItemCell class] forCellWithReuseIdentifier:kZFCollectionMultipleColumnCellIdentifier];
        
        [_collectionView registerClass:[ZFSearchResultMoreCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([ZFSearchResultMoreCollectionViewCell class])];
        
        [_collectionView registerClass:[UICollectionReusableView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                   withReuseIdentifier:NSStringFromClass([UICollectionReusableView class])];
        
        [_collectionView registerClass:[UICollectionReusableView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:NSStringFromClass([UICollectionReusableView class])];
        
        [_collectionView registerClass:[ZFSearchResultErrorHeaderView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:NSStringFromClass([ZFSearchResultErrorHeaderView class])];
        
        [_collectionView registerClass:[ZFSearchResultErrorTitleView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:NSStringFromClass([ZFSearchResultErrorTitleView class])];
        
        _collectionView.emptyDataImage = [UIImage imageNamed:@"blankPage_noSearchData"];
        _collectionView.emptyDataTitle = ZFLocalizedString(@"Search_ResultViewModel_Tip",nil);
        _collectionView.emptyDataSubTitle = ZFLocalizedString(@"Search_ResultViewModel_SubTip",nil);
        
        @weakify(self);
        ZFRefreshHeader *header = [ZFRefreshHeader headerWithRefreshingBlock:^{
            @strongify(self);
            self.collectionView.mj_header.hidden = NO;
            [self requestSearchRefresh];
        }];
        [_collectionView setMj_header:header];
        
        ZFRefreshFooter *footer = [ZFRefreshFooter footerWithRefreshingBlock:^{
            @strongify(self)
            [self requestSearchLoadMore];
        }];
        [_collectionView setMj_footer:footer];
        footer.hidden = YES;
    }
    return _collectionView;
}

- (SearchResultViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[SearchResultViewModel alloc]init];
        _viewModel.searchTitle = _searchString;
        _viewModel.controller = self;
    }
    return _viewModel;
}

- (ZFSearchResultModel *)model
{
    if (!_model) {
        _model = [[ZFSearchResultModel alloc] init];
    }
    return _model;
}

- (ZFSearchMatchViewModel *)matchViewModel {
    if (!_matchViewModel) {
        _matchViewModel = [[ZFSearchMatchViewModel alloc] init];
    }
    return _matchViewModel;
}

-(ZFSearchMapResultAnalyticsAOP *)searchAnalytics
{
    if (!_searchAnalytics) {
        _searchAnalytics = [[ZFSearchMapResultAnalyticsAOP alloc] init];
        _searchAnalytics.page = @"textSearchResultPage";
        _searchAnalytics.searchType = @"textSearch";
        _searchAnalytics.datasource = self;
        _searchAnalytics.sort = @"recommend"; //默认的
        _searchAnalytics.sourceType = ZFAppsflyerInSourceTypeSearchResult;
    }
    return _searchAnalytics;
}

@end
