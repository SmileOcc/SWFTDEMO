
//
//  STLCategoryListCtrl.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/4.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//  分类列表页面


#import "OSSVSortsBarView.h"
#import "OSSVSortsOptionalView.h"
//#import "OSSVCategoryFiltersView.h"
#import "OSSVCategoryListsViewModel.h"
#import "OSSVDetailsVC.h"
#import "OSSVCatagoryListsCollectionView.h"
#import "OSSVCategorysListVC.h"
#import "OSSVCategoriyDetailsGoodListsModel.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "OSSVSearchVC.h"
#import "STLActivityWWebCtrl.h"
#import "UINavigationController+FDFullscreenPopGesture.h"

#import "OSSVCategoryRefinesNewView.h"
#import "OSSVCartVC.h"
#import "JSBadgeView.h"
#import "STLProductListSkeletonView.h"
#import "OSSVCategoryListNavBar.h"
#import "STLPreference.h"
#import "Adorawe-Swift.h"

typedef NS_ENUM(NSInteger,CategorySortType){
    /** 0-Most Popular：按照当前排序规则（默认）*/
    CategorySortTypeMost = 0,
    /** 1-New Arrivals：根据sku的上架时间排序*/
    CategorySortTypeNew,
    /** 价格从高到低*/
    CategorySortTypeHighToLow,
    /** 价格从低到高*/
    CategorySortTypeLowToHigh
};

@interface OSSVCategorysListVC ()<STLSortOptionalViewDataSource,STLSortOptionalViewDelegate,STLCatagoryListCollectionViewDelegate>

@property (nonatomic, strong) OSSVCategoryListsViewModel             *viewModel;
@property (nonatomic, strong) OSSVSortsBarView                       *topSortView;
@property (nonatomic, strong) OSSVSortsOptionalView                  *sortOptionView;
//@property (nonatomic, strong) OSSVCategoryFiltersView                *filterView;
@property (nonatomic, strong) OSSVCategoryRefinesNewView             *newRefineView;

@property (nonatomic, strong) OSSVCatagoryListsCollectionView        *collectionView;
@property (nonatomic, strong) UIButton                            *backToTopButton;

@property (nonatomic, strong) NSArray                             *sortArrays;
@property (nonatomic, assign) CategorySortType                    sortType;

@property (nonatomic, strong) STLProductListSkeletonView          *productSkeletonView; //骨架图
@property (nonatomic, strong) OSSVCategoryListNavBar        *customNavigationBar;

@property (nonatomic,strong) PrivacySheet              *privacySheet;
@end
 
@implementation OSSVCategorysListVC

#pragma mark - Life Cycle

- (void)dealloc
{
    if (_collectionView) {
        [self.collectionView removeObserver:self forKeyPath:kColletionContentOffsetName];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotif_Currency object:nil];
    [self.viewModel freesource];
    
    if (_newRefineView) {
        [_newRefineView removeFromSuperview];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.firstEnter)
    {
        self.firstEnter = YES;
    }
    
    [self.customNavigationBar showCartCount];
    
    if (![[STLPreference objectForKey:@"noNeedShowPrivacy"] boolValue] && [OSSVAccountsManager sharedManager].sysIniModel.is_show_privacy) {
        [self.privacySheet showInParentView:self.view bottomAncher:nil offset:@20];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.title = self.childDetailTitle;
    self.fd_prefersNavigationBarHidden = YES;

    self.sortArrays = @[STLLocalizedString_(@"Most_popular", nil),
                        STLLocalizedString_(@"New_arrivals", nil),
                        STLLocalizedString_(@"Price_high_to_low", nil),
                        STLLocalizedString_(@"Price_low_to_high", nil)];
    self.view.backgroundColor = [OSSVThemesColors col_F5F5F5];
   
    
    self.currentPageCode = self.childId;
    
    [self setupView];
    [self requestFilter];
    [self requestData];
   
    // 汇率改变的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCurrency:) name:kNotif_Currency object:nil];
    [self.collectionView addObserver:self forKeyPath:kColletionContentOffsetName options:NSKeyValueObservingOptionNew context:nil];
    [self.collectionView viewDidShow];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (_newRefineView) {
        [self.newRefineView hideRefineInfoViewViewWithAnimation:NO];
    }
}


#pragma mark - private methods

- (void)showRefineView {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.newRefineView];
    self.newRefineView.hidden = NO;
    [self.newRefineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [self.newRefineView showRefineInfoViewWithAnimation:YES];
}

#pragma mark --Action ---
- (void)toBagButtonAction:(id)sender {
    OSSVCartVC *cartVC = [[OSSVCartVC alloc] init];
    [self.navigationController pushViewController:cartVC animated:YES];
}


- (void)setupView {
    
    [self.view addSubview:self.customNavigationBar];
    [self.view addSubview:self.topSortView];
    [self.view addSubview:self.collectionView];
    [self.collectionView addSubview:self.productSkeletonView];
    [self.view addSubview:self.backToTopButton];
    [self.view bringSubviewToFront:self.backToTopButton];
    [self.view addSubview:self.sortOptionView];
    [self makeContraints];
}

- (OSSVCategoryListNavBar *)customNavigationBar {
    if (!_customNavigationBar) {
        _customNavigationBar = [[OSSVCategoryListNavBar alloc] init];
        if (STLIsEmptyString(self.childDetailTitle)) {
            _customNavigationBar.searchKey = STLLocalizedString_(@"search", nil);

        } else {
            _customNavigationBar.searchKey = self.childDetailTitle;
        }
          @weakify(self)
        _customNavigationBar.searchInputCancelCompletionHandler = ^{
            @strongify(self)
            [self.navigationController popViewControllerAnimated:YES];
        };
        
        _customNavigationBar.tapBagButtonCompletionHandler = ^{
            @strongify(self)
            //进入购物车
            OSSVCartVC *cartVC = [[OSSVCartVC alloc] init];
            [self.navigationController pushViewController:cartVC animated:YES];
            
            [OSSVAnalyticsTool analyticsGAEventWithName:@"top_function" parameters:@{
                   @"screen_group":[NSString stringWithFormat:@"ProductList_%@",STLToString(self.title)],
                   @"button_name":@"Cart"}];
        };
        
        
        _customNavigationBar.tapContentbgViewCompletionHandler = ^(NSString *searchKey) {
            @strongify(self)
            OSSVSearchVC * searchVC = [[OSSVSearchVC alloc] init];
            searchVC.searchTitle = searchKey;
            searchVC.searchNavbar.inputPlaceHolder = searchKey;
            searchVC.catId = self.childId;
            [self.navigationController pushViewController:searchVC animated:NO];
            
            [OSSVAnalyticsTool analyticsGAEventWithName:@"top_function" parameters:@{
                   @"screen_group":[NSString stringWithFormat:@"ProductList_%@",STLToString(self.title)],
                   @"button_name":@"Search_box"}];
        };
        
        _customNavigationBar.tapSerachBgViewCompletionHandler = ^(NSString *searchKey) {
            @strongify(self)
            OSSVSearchVC * searchVC = [[OSSVSearchVC alloc] init];
//            searchVC.searchTitle = searchKey;
            searchVC.searchNavbar.searchKey = searchKey;
            searchVC.catId = self.childId;
            [self.navigationController pushViewController:searchVC animated:NO];
            [OSSVAnalyticsTool analyticsGAEventWithName:@"top_function" parameters:@{
                   @"screen_group":[NSString stringWithFormat:@"ProductList_%@",STLToString(self.title)],
                   @"button_name":@"Search_box"}];

        };
    }
    return _customNavigationBar;
}


- (void)makeContraints
{
    [self.customNavigationBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view.mas_top);
        make.height.mas_equalTo(kNavHeight);
    }];

    [self.topSortView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.view);
        make.top.mas_equalTo(self.customNavigationBar.mas_bottom).offset(0);
        make.height.mas_equalTo(44);
    }];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(self.topSortView.mas_bottom).mas_offset(0);
    }];
    [self.productSkeletonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.bottom.mas_equalTo(self.collectionView);
        make.width.equalTo(SCREEN_WIDTH);
    }];
    [self.backToTopButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(@(50));
        make.trailing.equalTo(@(-10));
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    [self.sortOptionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(self.topSortView.mas_bottom);
    }];
}

#pragma mark ---弹出搜索框
- (void)categoriesSearchBtnClick {
    OSSVSearchVC * searchVC = [[OSSVSearchVC alloc] init];
    searchVC.enterName = self.childDetailTitle;
    searchVC.catId = self.childId;
    [self.navigationController pushViewController:searchVC animated:YES];

}

// 骨架图
- (STLProductListSkeletonView *)productSkeletonView {
    if (!_productSkeletonView) {
        _productSkeletonView = [[STLProductListSkeletonView alloc] init];
        _productSkeletonView.hidden = YES;
    }
    return _productSkeletonView;
}

- (void)resetRequestParmas  {
    self.price_max = @"";
    self.price_min = @"";
    self.sortType = 0;
    self.selectedAttrsString = @"";
    
    // 重置选中
    if (_newRefineView) {
        [self.newRefineView.categoryRefineDataArray enumerateObjectsUsingBlock:^(OSSVCategorysFiltersNewModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            [obj.subItemValues enumerateObjectsUsingBlock:^(OSSVCategorysFiltersNewModel * _Nonnull subObj, NSUInteger idx, BOOL * _Nonnull stop) {
//                subObj.isSelected = NO;
//            }];
        }];
        [self.newRefineView.collectView reloadData];
//        [self updateTopMenu:@""];
    }
    
    // 分类改变，重置筛选条件
//    [self loadRefineData:self.childId];
}
#pragma mark ---首次进入请求数据，带入骨架图
- (void)requestDataWithproductSkeleton {
    @weakify(self)
    self.productSkeletonView.hidden = NO;
    NSString *price = [self.newRefineView filterPriceCondition];
    NSDictionary *parmaters = @{@"cat_id"     : STLToString(self.childId),
                                @"order_by"   : @(self.sortType),
                                @"loadState"  : STLRefresh,
                                @"filter"     : [self.newRefineView filterItemIDs],
                                @"price"      : STLToString(price),
                                @"deep_link_id" : STLToString(self.deepLinkId),
                                @"is_new_in" : STLToString(self.is_new_in),
                                };

    [self.viewModel requestNetwork:parmaters
                        completion:^(id obj) {
                            @strongify(self)
                            self.collectionView.dataArray = self.viewModel.dataArray;
                            [self.collectionView refreshDataView:YES];
                            self.productSkeletonView.hidden = YES;

                            if (self.collectionView.mj_footer.state == MJRefreshStateNoMoreData)
                            {
                                // 此处是对应 mj_footer.state == 不能加载更多后的重置
                                [self.collectionView showRequestTip:@{kTotalPageKey  : @(1),
                                                                     kCurrentPageKey: @(1)}];
                            } else {
                                [self.collectionView showRequestTip:@{kTotalPageKey  : @(1),
                                                                     kCurrentPageKey: @(0)}];
                            }
        

                        }
                           failure:^(id obj) {
                               @strongify(self)
                               self.collectionView.dataArray = self.viewModel.dataArray;
                               [self.collectionView refreshDataView:YES];
                               self.productSkeletonView.hidden = YES;
                                [self.collectionView showRequestTip:nil];


                           }];
}
#pragma mark -----数据请求以及分页
- (void)requestData{
    @weakify(self)
    self.collectionView.mj_footer = [OSSVRefreshsAutosNormalFooter footerWithRefreshingBlock:^{
        @strongify(self)
        @weakify(self)
        if (self.childId == nil) {
            return ;
        }
        
        
        NSString *price = [self.newRefineView filterPriceCondition];
        NSDictionary *parmaters = @{@"cat_id"     : STLToString(self.childId),
                                    @"order_by"   : @(self.sortType),
                                    @"loadState"  : STLLoadMore,
                                    @"filter"     : [self.newRefineView filterItemIDs],
                                    @"price"      : STLToString(price),
                                    @"deep_link_id" : STLToString(self.deepLinkId),
                                    @"is_new_in" : STLToString(self.is_new_in),
                                    };
        
        [self.viewModel requestNetwork:parmaters
                            completion:^(id obj) {
                                @strongify(self)
                                self.collectionView.dataArray = self.viewModel.dataArray;
                                [self.collectionView refreshDataView:NO];

                                if([obj isEqual: STLNoMoreToLoad])
                                {
                                    // 无法加载更多的时候
                                    [self.collectionView.mj_footer endRefreshingWithNoMoreData];
                                    self.collectionView.mj_footer.hidden = YES;
                                }
                                else
                                {
                                    self.collectionView.dataArray = self.viewModel.dataArray;
                                    [self.collectionView.mj_footer endRefreshing];
                                }


                                
                            }
                               failure:^(id obj) {
                                   @strongify(self)
                                   self.collectionView.dataArray = self.viewModel.dataArray;
                                   [self.collectionView refreshDataView:NO];
                                   [self.collectionView.mj_footer endRefreshing];

                               }];
    }];
    
    MJRefreshNormalHeader* header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        @weakify(self)

        NSString *price = [self.newRefineView filterPriceCondition];
        NSDictionary *parmaters = @{@"cat_id"     : STLToString(self.childId),
                                    @"order_by"   : @(self.sortType),
                                    @"loadState"  : STLRefresh,
                                    @"filter"     : [self.newRefineView filterItemIDs],
                                    @"price"      : STLToString(price),
                                    @"deep_link_id" : STLToString(self.deepLinkId),
                                    @"is_new_in" : STLToString(self.is_new_in),
                                    };

        [self.viewModel requestNetwork:parmaters
                            completion:^(id obj) {
                                @strongify(self)
                                
                                self.collectionView.dataArray = self.viewModel.dataArray;
                                [self.collectionView refreshDataView:YES];
                                [self.collectionView.mj_header endRefreshing];
//                                if (!self.newRefineView.model) {
//                                    OSSVCategorysSectionsModel *refineModel = [[OSSVCategorysSectionsModel alloc] init];
//                                    refineModel.child_item = [self.viewModel filterItems];
//                                    self.newRefineView.model = refineModel;
//                                }
//                                self.newRefineView.categoryRefineDataArray = [self.viewModel filterItems];
            
                                if (self.collectionView.mj_footer.state == MJRefreshStateNoMoreData)
                                {
                                    // 此处是对应 mj_footer.state == 不能加载更多后的重置
                                    [self.collectionView showRequestTip:@{kTotalPageKey  : @(1),
                                                                         kCurrentPageKey: @(1)}];
                                } else {
                                    [self.collectionView showRequestTip:@{kTotalPageKey  : @(1),
                                                                         kCurrentPageKey: @(0)}];
                                }

                            }
                               failure:^(id obj) {
                                   @strongify(self)
                                   self.collectionView.dataArray = self.viewModel.dataArray;
                                   [self.collectionView refreshDataView:YES];
                                    [self.collectionView showRequestTip:nil];

                               }];
    }];
    
    // 隐藏时间
    header.lastUpdatedTimeLabel.hidden = YES;

    // 隐藏状态
    header.stateLabel.hidden = YES;
    self.collectionView.mj_header = header;
//        [self.collectionView.mj_header beginRefreshing];
   
}


- (void)requestFilter {
    
    @weakify(self)
    [self.viewModel requestFilterNetwork:@{@"cat_id":STLToString(self.childId)} completion:^(id obj) {
        @strongify(self)
        if (STLJudgeNSArray(obj)) {
            self.newRefineView.categoryRefineDataArray = obj;
        } else {
            self.newRefineView.categoryRefineDataArray = @[];
        }
        //首次进入用骨架图
        [self requestDataWithproductSkeleton];
    } failure:^(id obj) {
        @strongify(self)
        self.newRefineView.categoryRefineDataArray = @[];
        [self requestDataWithproductSkeleton];
    }];
}

#pragma mark - KVO set


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:kColletionContentOffsetName]) {
        CGFloat offset = self.collectionView.contentOffset.y;
        if (offset > STL_COLLECTION_MOVECONTENT_HEIGHT) {
            
            [UIView animateWithDuration: 0.8 delay: 0.4 options: UIViewAnimationOptionCurveEaseInOut animations: ^{
                [self.backToTopButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    if (kIS_IPHONEX) {
                        make.bottom.equalTo(@(-10-STL_TABBAR_IPHONEX_H));
                    } else {
                        make.bottom.equalTo(@(-10));
                    }
                }];
            } completion: ^(BOOL finished) {
                [UIView animateWithDuration: 0.4 animations: ^{
                    self.backToTopButton.alpha = 1.0;
                }];
            }];
        } else {
            [UIView animateWithDuration: 0.8 delay: 0.4 options: UIViewAnimationOptionCurveEaseInOut animations: ^{
                [self.backToTopButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.bottom.equalTo(@(50));
                }];
            } completion: ^(BOOL finished) {
                [UIView animateWithDuration: 0.4 animations: ^{
                    self.backToTopButton.alpha = 0;
                }];
            }];
        }
    }
}

#pragma mark - user Action
//显示筛选弹窗
- (void)showOptionView:(NSInteger)index state:(BOOL)flag {
    [self.sortOptionView show:flag];
}

- (void)clickBackToTopButtonAction {
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                          atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
}

#pragma mark - kNotif_Currency 货币改变通知


- (void)changeCurrency:(NSNotification *)notify {
    if (self.collectionView) {
        [self.collectionView reloadData];
    }
}

#pragma mark - STLCatagoryListCollectionViewDelegate

- (void)didDeselectGoodListModel:(OSSVCategoriyDetailsGoodListsModel *)model {
    
    STLAppsflyerGoodsSourceType sourceType = self.isSimilar ? STLAppsflyerGoodsSourceDetailSimilar : STLAppsflyerGoodsSourceCategoryList;
    
    OSSVDetailsVC *goodsDetailsVC = [OSSVDetailsVC new];
    goodsDetailsVC.goodsId = model.goodsId;
    goodsDetailsVC.wid = model.wid;
    goodsDetailsVC.coverImageUrl = model.goodsImageUrl;
    goodsDetailsVC.sourceType = sourceType;
    goodsDetailsVC.reviewsId = self.childDetailTitle;
    goodsDetailsVC.coverImageUrl = STLToString(model.goodsImageUrl);
    NSInteger index = 0;
    if (self.viewModel.dataArray) {
        index = [self.viewModel.dataArray indexOfObject:model];
    }
    
    
    NSDictionary *dic = @{kAnalyticsAction:[OSSVAnalyticsTool sensorsSourceStringWithType:sourceType sourceID:@""],
                          kAnalyticsUrl:STLToString(self.childId),
                          kAnalyticsKeyWord:@"",
                          kAnalyticsPositionNumber:@(index + 1),
    };
    [goodsDetailsVC.transmitMutDic addEntriesFromDictionary:dic];
    [self.navigationController pushViewController:goodsDetailsVC animated:YES];
}

#pragma mark - STLSortOptionalViewDataSource


- (NSArray *)datasYSSortOptionalView {
    return self.sortArrays;
}

- (void)sortOptinalView:(OSSVSortsOptionalView *)optionView selectIndex:(NSInteger)index {
    
    [self.topSortView cancelSelectState];
    if (self.sortType == index) {
        return;
    }
    self.topSortView.sortItem.titleLabel.text = self.sortArrays[index];
    self.sortType = index;
    NSString *pageName = [UIViewController currentTopViewControllerPageName];
    /**GA埋点*/
    [OSSVAnalyticsTool analyticsGAEventWithName:@"product_filter" parameters:@{
        @"screen_group" : [NSString stringWithFormat:@"ProductList_%@", STLToString(pageName)],
        @"filter" : [NSString stringWithFormat:@"Sort_%@", STLToString(self.sortArrays[index])]
    }];
    
    [self.collectionView.mj_header beginRefreshing];
}

#pragma mark - LazyLoad setters and getters
- (OSSVCategoryListsViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [OSSVCategoryListsViewModel new];
        _viewModel.childDetailTitle = _childDetailTitle;
    }
    return _viewModel;
}

- (OSSVSortsBarView *)topSortView {
    if (!_topSortView) {
        _topSortView = [[OSSVSortsBarView alloc] initWithFrame:CGRectZero];
        @weakify(self)
        _topSortView.sortItemBlock = ^(NSInteger index, BOOL flag) {
            @strongify(self)
            [self showOptionView:index state:flag];
        };
        _topSortView.filterItemBlock = ^{
            @strongify(self)
            [self.sortOptionView dismiss];
//            [self.filterView configFilterItems:[self.viewModel filterItems]];
//            [self.filterView show];
            [self showRefineView];
        };
    }
    return _topSortView;
}

- (OSSVSortsOptionalView *)sortOptionView {
    if (!_sortOptionView) {
        _sortOptionView = [[OSSVSortsOptionalView alloc] initWithFrame:CGRectZero];
        _sortOptionView.dataSource = self;
        _sortOptionView.delegate = self;
    }
    return _sortOptionView;
}

//- (OSSVCategoryFiltersView *)filterView {
//    if (!_filterView) {
//        _filterView = [[OSSVCategoryFiltersView alloc] initWithFrame:CGRectMake(0.0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
//        @weakify(self)
//        _filterView.resetFilter = ^{
//            @strongify(self)
//            [self requestData];
//            self.topSortView.filterItem.selected = [self.filterView isFiltered];
//        };
//        _filterView.applyFilter = ^{
//            @strongify(self)
//            [self requestData];
//            self.topSortView.filterItem.selected = [self.filterView isFiltered];
//        };
//    }
//    return _filterView;
//}

- (OSSVCatagoryListsCollectionView *)collectionView {
    if (!_collectionView) {
        CHTCollectionViewWaterfallLayout *waterFallLayout = [[CHTCollectionViewWaterfallLayout alloc] init];
        waterFallLayout.columnCount = 2;
        waterFallLayout.minimumColumnSpacing = 12;
        waterFallLayout.minimumInteritemSpacing = 12;
        waterFallLayout.sectionInset = UIEdgeInsetsMake(12, 12, 0, 12);
        
        _collectionView = [[OSSVCatagoryListsCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:waterFallLayout];
        _collectionView.frame = self.view.bounds;
        _collectionView.showsVerticalScrollIndicator = YES;
        if (APP_TYPE == 3) {
            _collectionView.backgroundColor = [OSSVThemesColors stlWhiteColor];
        } else {
            _collectionView.backgroundColor = [OSSVThemesColors col_F5F5F5];
        }
        _collectionView.myDelegate = self;
        _collectionView.emptyDataTitle    = STLLocalizedString_(@"category_filter_nodate_tip",nil);
        _collectionView.emptyDataImage = [UIImage imageNamed:@"search_bank"];
        _collectionView.blankPageImageViewTopDistance = 40;
        _collectionView.currentTitle = STLToString(self.title);
        _collectionView.analyticDic = @{kAnalyticsAOPSourceKey:STLToString(self.childDetailTitle),kAnalyticsAOPSourceID:STLToString(self.childId),@"isSimilar":@(self.isSimilar)}.mutableCopy;
    }
    return _collectionView;
}

- (UIButton *)backToTopButton {
    if (!_backToTopButton) {
        _backToTopButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backToTopButton setImage:[UIImage imageNamed:@"back_icon"] forState:UIControlStateNormal];
        [_backToTopButton addTarget:self action:@selector(clickBackToTopButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _backToTopButton.alpha = 0;
    }
    return _backToTopButton;
}


- (OSSVCategoryRefinesNewView *)newRefineView {
    if (!_newRefineView) {
        _newRefineView = [[OSSVCategoryRefinesNewView alloc] initWithFrame:CGRectZero];
        _newRefineView.hidden = YES;
        _newRefineView.categoryRefineDataArray = @[];
        _newRefineView.sourceKey = self.childId;
        
        @weakify(self);
        _newRefineView.hideCategoryRefineBlock = ^{
            @strongify(self);
            
            [self.newRefineView removeFromSuperview];
        };
        
        _newRefineView.confirmBlock = ^(NSArray<OSSVCategroySubsFilterModel *> *nativeResults, NSArray<STLCategoryFilterValueModel *> *categoryResults, NSDictionary *afParams) {
            @strongify(self);
            
            self.price_min = @"";
            self.price_max = @"";
            self.selectedAttrsString = @"";
            
            
            if (STLJudgeNSArray(categoryResults)) {
                
                [categoryResults enumerateObjectsUsingBlock:^(STLCategoryFilterValueModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj.supKey isEqualToString:@"price"]) {
                                                
                        self.price_min = STLToString(obj.editMinPrice);
                        self.price_max = STLToString(obj.editMaxPrice);
                    }
                }];
                
//                self.selectedAttrsString = [allSelectAttrs componentsJoinedByString:@"~"];
//                self.viewModel.lastCategoryID = @"Reccommand";
//                [self.listPageView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
                [self.collectionView.mj_header beginRefreshing];
                
            }
        };
        
        _newRefineView.clearConditionBlock = ^{
            @strongify(self);
            self.selectedAttrsString = @"";
            self.price_max = @"";
            self.price_min = @"";
        };
        
    }
    return _newRefineView;
}

- (PrivacySheet *)privacySheet{
    if (!_privacySheet) {
        _privacySheet = [[PrivacySheet alloc] initWithFrame:CGRectZero];
    }
    return _privacySheet;
}


@end
