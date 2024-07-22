//
//  CategoryVirtualViewController.m
//  ListPageViewController
//
//  Created by YW on 6/7/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "CategoryVirtualViewController.h"
#import "CategoryDropDownMenu.h"
#import "CategorySelectView.h"
#import "ZFGoodsListItemCell.h"
#import "CategoryListPageViewModel.h"
#import "CategoryRefineContainerView.h"
#import "CategoryRefineSectionModel.h"
#import "CategoryNewModel.h"
#import "ZFGoodsDetailViewController.h"
#import "ZFCartViewController.h"
#import "NSArray+SafeAccess.h"
#import "ZFThemeManager.h"
#import "NSStringUtils.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "UIView+LayoutMethods.h"
#import "ZFLocalizationString.h"
#import "ZFFireBaseAnalytics.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFPopDownAnimation.h"
#import "ZFTimerManager.h"
#import "ZFCommonRequestManager.h"
#import "ZFBTSManager.h"

static CGFloat const KMenuHeight = 44.0f;

@interface CategoryVirtualViewController ()

@property (nonatomic, assign) BOOL                        isFromHome;
@property (nonatomic, copy) NSString                      *currentCategory;
@property (nonatomic, copy) NSString                      *currentSort;
@property (nonatomic, strong) CategoryDropDownMenu        *topMenuView;
@property (nonatomic, strong) CategorySelectView          *selectView;
@property (nonatomic, strong) CategoryListPageViewModel   *viewModel;
@property (nonatomic, strong) UICollectionView            *listPageView;
@property (nonatomic, strong) NSMutableArray              *menuTitles;
@property (nonatomic, strong) NSArray<NSString *>         *sortRequests;
@property (nonatomic, strong) NSArray<CategoryNewModel *>    *virtualArray;
@property (nonatomic, strong) NSArray<CategoryPriceListModel *>  *priceListArray;
@property (nonatomic, copy)   NSString                    *navTitle;
@property (nonatomic, strong) UIView                      *againRequestView;
@property (nonatomic, strong) CategoryPriceListModel      *virtualPriceModel;
@property (nonatomic, copy)   NSString                    *categoryID;
@property (nonatomic, copy)   NSString                    *virtualType;
@property (nonatomic, copy)   NSString                    *sortType;
@property (nonatomic, copy)   NSString                    *price_id;
@property (nonatomic, copy)   NSString                    *tabType;// 配合WMPageViewController使用的（必须的）
@property (nonatomic, strong) UIButton                    *shoppingCarBtn;
@property (nonatomic, strong) ZFAnalyticsProduceImpression    *analyticsProduceImpression;//统计
@property (nonatomic, strong) UILabel                     *titleLabel;
@end

@implementation CategoryVirtualViewController

#pragma mark - Life Cycle
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = ZFCOLOR_WHITE;
    self.navigationItem.titleView = self.titleLabel;
    
    self.currentCategory = ZFLocalizedString(@"TopicHead_Cell_ViewAll", nil);
    self.currentSort = ZFLocalizedString(@"Category_Item_Segmented_Sort", nil);
    [self configureNavgationItem];
    [self configureSubViews];
    [self autoLayoutSubViews];
    [self loadAllData];
    [self addObNotification];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    //刷新购物车数量
    [self refreshShppingCarBag];
}

#pragma mark - Init Methods
- (void)configureSubViews{
    [self.view addSubview:self.listPageView];
    if (!_isFromHome) {
        [self.view addSubview:self.selectView];
        [self.view addSubview:self.topMenuView];
        self.topMenuView.hidden = NO;
    } else {
        self.topMenuView.height = 0.0;
        self.topMenuView.hidden = YES;
    }
}

- (void)autoLayoutSubViews {
    if (!_isFromHome) {
        [self.selectView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.topMenuView.mas_bottom);
            make.leading.trailing.bottom.equalTo(self.view);
        }];
        
        [self.listPageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.topMenuView.mas_bottom);
            make.leading.trailing.bottom.equalTo(self.view);
        }];
    } else {
        [self.listPageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top);
            make.leading.trailing.bottom.equalTo(self.view);
        }];
    }
}

- (void)configureNavgationItem {
    self.shoppingCarBtn = [self showNavigationRightCarBtn:ZF_CategoryVirtual_Cars_type];
}

- (void)changeCurrency {
    [self loadAllData];
}

- (void)addObNotification {
    // 汇率改变的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCurrency) name:kCurrencyNotification object:nil];
    //添加购物车需要刷新bag
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshVirtualCategoryCartCount) name:kCartNotification object:nil];
}

- (void)refreshVirtualCategoryCartCount {
    [self refreshShppingCarBag];
    [ZFPopDownAnimation popDownRotationAnimation:self.shoppingCarBtn];
}

/**
 * 刷新购物车数量
 */
- (void)refreshShppingCarBag {
    NSNumber *badgeNum = [[NSUserDefaults standardUserDefaults] valueForKey:kCollectionBadgeKey];
    [self.shoppingCarBtn showShoppingCarsBageValue:[badgeNum integerValue]];
}

#pragma mark - Private Methods
- (void)loadAllData{
    [self requestListPageData];
    self.navTitle = self.virtualTitle;
    if (!ZFIsEmptyString(self.navTitle)) {
        self.titleLabel.text = self.navTitle;
    }
//    self.title = self.navTitle;
    [self updateTopMenu];
}

- (void)updateTopMenu {
    self.topMenuView.titles = self.menuTitles;
}

- (void)requestPageData:(NSDictionary *)parmaters {
    @weakify(self);
    [self.viewModel requestCategoryListData:parmaters completion:^(CategoryListPageModel *loadingModel, NSInteger nextPageIndex, id pageData) {
        @strongify(self);
        self.view.tag = isLoaded;
        // 当前加载页的商品个数
        NSInteger loadingPageSize = loadingModel.goods_list.count;
        BOOL firstPage = [loadingModel.cur_page integerValue] == 1;
        if (firstPage) {
            self.virtualArray = loadingModel.virtualCategorys;
            self.priceListArray = loadingModel.price_list;
            
            // 标题
            if (!ZFIsEmptyString(self.navTitle) && [self.viewModel.model.result_num integerValue] > 0) {
                NSString *itemNumStr = [NSString stringWithFormat:ZFLocalizedString(@"list_item", nil),self.viewModel.model.result_num];
                NSString *title = [NSString stringWithFormat:@"%@\n%@", self.navTitle, itemNumStr];
                
                UIColor *numColor = ZFCOLOR(153, 153, 153, 1);
                if ([AccountManager sharedManager].needChangeAppSkin) {
                    numColor = [AccountManager sharedManager].appNavFontColor;
                }
                
                NSRange range = [title rangeOfString:itemNumStr];
                NSMutableAttributedString *attriTitle = [[NSMutableAttributedString alloc] initWithString:title];
                NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
                paragraph.alignment = NSTextAlignmentCenter;
                [attriTitle addAttribute:NSParagraphStyleAttributeName value:paragraph range:range];
                [attriTitle addAttributes:@{NSFontAttributeName : ZFFontSystemSize(12), NSForegroundColorAttributeName : numColor} range:range];
                self.titleLabel.attributedText = attriTitle;
            }
        }
        if (!loadingModel || loadingPageSize >= 0) { // 第一页可能没有数据情况也需要处理
            if (firstPage) {
                [UIView performWithoutAnimation:^{
                   [self.listPageView reloadData];
                }];
            } else { // 增量刷新数据
                NSMutableArray *nextPageArray = [NSMutableArray arrayWithCapacity:loadingPageSize];
                for (int i = 0; i < loadingPageSize; i++) { // 每次只增加 loadingPageSize
                    [nextPageArray addObject:[NSIndexPath indexPathForItem:(nextPageIndex+i) inSection:0]];
                }
                //警告:第一页不能用此方法刷新, 因为预加载的cell都没清空了
                [self.listPageView performBatchUpdates:^{
                    [self.listPageView insertItemsAtIndexPaths:nextPageArray];
                } completion:nil];
            }
        }
        
        [self.listPageView showRequestTip:pageData];
        
        for (ZFGoodsModel *goodsModel in loadingModel.goods_list) {
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
        
        // 统计代码
        NSString *impression = [NSString stringWithFormat:@"%@_%@", ZFGACategoryList, ZFToString(self.virtualTitle)];
        NSString *screenName = [NSString stringWithFormat:@"category_%@", ZFToString(self.virtualTitle)];
        [ZFAnalytics showProductsWithProducts:loadingModel.goods_list
                                     position:1
                               impressionList:impression
                                   screenName:screenName
                                        event:@"load"];
        //occ v3.7.0hacker 添加 ok
        self.analyticsProduceImpression = [ZFAnalyticsProduceImpression initAnalyticsProducePosition:1
                                                                                      impressionList:impression
                                                                                          screenName:screenName
                                                                                               event:@"load"];
        
        [ZFFireBaseAnalytics scanGoodsListWithCategory:(self.categoryID == nil ? @"" : self.categoryID)];
        NSString *impressName = [NSString stringWithFormat:@"%@_%@", ZFGACategoryList, self.virtualTitle];
        [ZFAnalytics showProductsWithProducts:loadingModel.goods_list position:(int)nextPageIndex impressionList:impressName screenName:@"VirtualPage" event:@"load"];
    }];
}

- (void)loadFirstPageDataWithFirstEnter:(BOOL)firstEnter {
    NSDictionary *parmaters = @{
                                @"page"      : Refresh,
                                @"cat_id"    : self.categoryID == nil ? @"" : self.categoryID,
                                @"order_by"  : firstEnter ? [self queryNormalSort] : self.sortType ?: @"",
                                @"type"      : self.virtualType == nil ? @"" : self.virtualType,
                                @"price_min" : self.virtualPriceModel ? [@(self.virtualPriceModel.price_min) stringValue] : @"",
                                @"price_max" : self.virtualPriceModel ? [@(self.virtualPriceModel.price_max) stringValue] : @"",
                                @"price_id"  : ZFToString(self.price_id),
                                kLoadingView : self.view
                                };
    self.viewModel.analyticsSort = ZFToString(self.sortType).length ? self.sortType : @"recommend";
    [self requestPageData:parmaters];
}

- (void)loadNextPageData {
    NSDictionary *parmaters = @{
                                @"page"         : LoadMore,
                                @"cat_id"       : self.categoryID == nil ? @"" : self.categoryID,
                                @"order_by"     : self.sortType == nil ? @"" : self.sortType,
                                @"type"         : self.virtualType == nil ? @"" : self.virtualType,
                                @"price_min"    : self.virtualPriceModel ? [@(self.virtualPriceModel.price_min) stringValue] : @"",
                                @"price_max"    : self.virtualPriceModel ? [@(self.virtualPriceModel.price_max) stringValue] : @"",
                                @"price_id"     : ZFToString(self.price_id),
                                 kLoadingView   : self.view
                                };
    [self requestPageData:parmaters];
}

- (void)requestListPageData {
    __block BOOL isFirstEnter = YES;
    @weakify(self);
    [self.listPageView addHeaderRefreshBlock:^{
        @strongify(self);
        [self loadFirstPageDataWithFirstEnter:isFirstEnter];
        isFirstEnter = NO;
        
    } footerRefreshBlock:^{
        @strongify(self);
        [self loadNextPageData];
        if ([NSStringUtils isEmptyString:self.categoryID]) {
            self.viewModel.lastCategoryID = @"";
        }else{
            self.viewModel.lastCategoryID = self.categoryID;
        }
        isFirstEnter = NO;
    } startRefreshing:NO];
    
    [ZFCommonRequestManager requestProductPhotoBts:^(ZFBTSModel *btsModel) {
        // 不带动画直接加载数据
        [self.listPageView headerRefreshingByAnimation:NO];
    }];
    
}

- (NSArray *)loadCategoryData {
    NSArray *categoryArray;
    if ([self.virtualType isEqualToString:@"deals"]) {
        categoryArray = self.priceListArray;
        self.selectView.isPriceList = YES;
    }else{
        categoryArray = self.virtualArray;
    }
    return categoryArray;
}

- (NSString *)queryNormalSort {
    NSString *sortType = @"";
    if ([self.virtualType isEqualToString:@"deals"]) {
        sortType = @"price_low_to_high";
        self.sortType = @"price_low_to_high";
        self.selectView.currentSortType = ZFLocalizedString(@"GoodsSortViewController_Type_LowToHigh", nil);
        
    } else if ([self.virtualType isEqualToString:@"newarrivals"] || [self.virtualType isEqualToString:@"new"]) {
        sortType = @"new_arrivals";
        self.sortType = @"new_arrivals";
        self.selectView.currentSortType = ZFLocalizedString(@"GoodsSortViewController_Type_New", nil);
    }
    return sortType;
}

- (void)configureSelectDataType:(NSInteger)dataType select:(BOOL)isSelect {
    if (!isSelect) {
        [self.selectView dismiss];
        return;
    }
    self.selectView.dataType = dataType;
    if (dataType == SelectViewDataTypeCategory) {
        self.selectView.currentCategory = self.selectView.currentCategory ? self.selectView.currentCategory : @"";
        self.selectView.currentCateId = self.selectView.currentCateId ? self.selectView.currentCateId : @"";
        self.selectView.categoryArray = [self loadCategoryData];
        self.selectView.currentPriceType = self.virtualPriceModel ? self.virtualPriceModel.price_range : @"";
    }else{
        BOOL isNew = ([self.virtualType isEqualToString:@"newarrivals"] || [self.virtualType isEqualToString:@"new"]);
        
        NSString *defaultSort = isNew ? ZFLocalizedString(@"GoodsSortViewController_Type_New", nil) : [self.virtualType isEqualToString:@"deals"] ? ZFLocalizedString(@"GoodsSortViewController_Type_LowToHigh", nil) : ZFLocalizedString(@"GoodsSortViewController_Type_Recommend", nil);
        
        self.selectView.currentSortType = self.selectView.currentSortType.length > 0 ? self.selectView.currentSortType : defaultSort;
        self.selectView.sortArray = @[
                                      ZFLocalizedString(@"GoodsSortViewController_Type_Recommend", nil),
                                      ZFLocalizedString(@"GoodsSortViewController_Type_New", nil),
                                      ZFLocalizedString(@"GoodsSortViewController_Type_LowToHigh", nil),
                                      ZFLocalizedString(@"GoodsSortViewController_Type_HighToLow", nil)
                                      ];
    }
    
    [self.selectView showCompletion:nil];
}

// 筛选数据统计
- (void)analyticsRefine {
    NSDictionary *afParams = @{@"af_content_type" : @"",
                             @"af_sort" : ZFToString(self.sortType),
                             @"af_category" : ZFToString(self.categoryID),
                             @"af_filter" : @{},
                             @"af_keyword" : @"",
                             @"af_inner_mediasource" : [ZFAppsflyerAnalytics sourceStringWithType:ZFAppsflyerInSourceTypeVirtualCategoryList sourceID:self.categoryID]
    };
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_filter_choice" withValues:afParams];
}

#pragma mark - Setter
- (void)setArgument:(NSString *)argument {
    _argument = argument;
    
    NSArray  *info = [argument componentsSeparatedByString:@","];
    if (info.count > 1) {
        self.virtualType = [info stringWithIndex:0];
        if ([self.virtualType isEqualToString:@"deals"]) {
            self.price_id = [info stringWithIndex:1];
        }else{
            self.categoryID  = [info stringWithIndex:1];
        }
    }else{
        self.virtualType = info.firstObject;
        if ([self.virtualType isEqualToString:@"deals"]) {
            // 传空,第一次默认不选中
            self.price_id = @"";
        }
    }
}

#pragma mark - Getter
- (CategoryDropDownMenu *)topMenuView {
    if (!_topMenuView) {
        _topMenuView = [[CategoryDropDownMenu alloc] initWithOrigin:CGPointMake(0, 0) andHeight:KMenuHeight];
        @weakify(self)
        _topMenuView.chooseCompletionHandler = ^(NSInteger tapIndex, BOOL isSelect) {
            @strongify(self)
            [self.againRequestView removeFromSuperview];
            NSString *title = self.topMenuView.titles[tapIndex];
            if ([title isEqualToString:self.currentCategory]) {
                [self configureSelectDataType:SelectViewDataTypeCategory select:isSelect];
            } else if ([title isEqualToString:self.currentSort]) {
                [self configureSelectDataType:SelectViewDataTypeSort select:isSelect];
            }
        };
    }
    return _topMenuView;
}

- (CategorySelectView *)selectView {
    if (!_selectView) {
        _selectView = [[CategorySelectView alloc] init];
        _selectView.isVirtual = YES;
        _selectView.currentCateId = self.categoryID;
        @weakify(self);
        _selectView.selectCompletionHandler = ^(NSInteger tag, SelectViewDataType type) {
            @strongify(self);
            [self.topMenuView restoreIndicator:type];
            
            if (type == SelectViewDataTypeCategory) {
                if ([self.virtualType isEqualToString:@"deals"]) {
                    self.virtualPriceModel = self.priceListArray[tag];
                    self.selectView.currentPriceType = self.virtualPriceModel.price_range;
                    self.price_id = @"";
                    [self loadFirstPageDataWithFirstEnter:NO];
                }else{
                    CategoryNewModel *model = self.selectView.categoryArray[tag];
                    self.categoryID = model.cat_id;
                    self.viewModel.lastCategoryID = @"";
                    self.selectView.currentSortType = @"";
                    self.currentSort = ZFLocalizedString(@"Category_Item_Segmented_Sort", nil);
                    self.selectView.currentCategory = model.cat_name;
                    self.selectView.currentCateId = model.cat_id;
                    self.navTitle = model.cat_name;
                    self.menuTitles[0] = model.cat_name;
                    self.menuTitles[1] = self.currentSort;
                    [self updateTopMenu];
                    
                    self.currentCategory = model.cat_name;
                    [self loadFirstPageDataWithFirstEnter:YES];
//                    self.title = self.navTitle;
                    if (!ZFIsEmptyString(self.navTitle)) {
                        self.titleLabel.text = self.navTitle;
                    }
                }
            }else if (type == SelectViewDataTypeSort) {
                self.sortType = self.sortRequests[tag];
                self.viewModel.lastCategoryID = @"1-s";
                self.menuTitles[1] = self.selectView.sortArray[tag];
                [self updateTopMenu];
                
                self.currentSort = self.selectView.sortArray[tag];
                self.selectView.currentSortType = self.currentSort;
                [self loadFirstPageDataWithFirstEnter:NO];
            }
            
            [self.listPageView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        };
        
        _selectView.maskTapCompletionHandler = ^(NSInteger index) {
            @strongify(self)
            [self.topMenuView restoreIndicator:index];
        };
        
        _selectView.selectSubCellHandler = ^(CategoryNewModel *model, SelectViewDataType type) {
            @strongify(self)
            [self.topMenuView restoreIndicator:SelectViewDataTypeCategory];
            // 这个属性是用来清空原有数据的,只要前后两个 ID 不一样即可,所以这里传空
            self.categoryID = model.cat_id;
            self.viewModel.lastCategoryID = @"";
            self.selectView.currentSortType = @"";
            self.selectView.currentCategory = model.cat_name;
            self.selectView.currentCateId = model.cat_id;
            self.navTitle = model.cat_name;
            self.currentSort = ZFLocalizedString(@"Category_Item_Segmented_Sort", nil);
            self.menuTitles[0] = ZFToString(model.cat_name);
            self.menuTitles[1] = ZFToString(self.currentSort);
            [self updateTopMenu];
            
            self.currentCategory = model.cat_name;
            self.sortType = @"recommend";//选择商品分类重置sort
            [self loadFirstPageDataWithFirstEnter:YES];
//            self.title = self.navTitle;
            if (!ZFIsEmptyString(self.navTitle)) {
                self.titleLabel.text = self.navTitle;
            }
            [self.listPageView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        };
        
        _selectView.selectAnimationStopCompletionHandler = ^{
            @strongify(self);
            self.topMenuView.isDropAnimation = NO;
        };
    }
    return _selectView;
}

- (UICollectionView *)listPageView {
    if (!_listPageView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0.0f;
        layout.minimumInteritemSpacing = 12.0f;
        layout.sectionInset = UIEdgeInsetsMake(0, 12, 12, 12);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        _listPageView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _listPageView.backgroundColor = ZFCOLOR(255, 255, 255, 1);
        [_listPageView registerClass:[ZFGoodsListItemCell class] forCellWithReuseIdentifier:kZFCollectionMultipleColumnCellIdentifier];
        _listPageView.delegate = self.viewModel;
        _listPageView.dataSource = self.viewModel;
        _listPageView.emptyDataImage = ZFImageWithName(@"blankPage_noCart");
        _listPageView.emptyDataTitle = [NSString stringWithFormat:ZFLocalizedString(@"CategoryNoDate",nil),ZFToString(self.virtualTitle)];
        
        if (@available(iOS 11.0, *)) {
            _listPageView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _listPageView;
}

- (CategoryListPageViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[CategoryListPageViewModel alloc] init];
        _viewModel.controller = self;
        _viewModel.cateName = NullFilter(self.virtualType);
        _viewModel.isVirtual = YES;
        _viewModel.isFromHome = self.isFromHome;
        _viewModel.analyticsSort = @"Recommended";//默认
        _viewModel.coupon = self.coupon;
        @weakify(self)
        _viewModel.handler = ^(ZFGoodsModel *model, UIImageView *imageView) {
            @strongify(self)
            [ZFFireBaseAnalytics selectContentWithItemId:[NSString stringWithFormat:@"Click_Virtual_Category_%@_Goods_%@", [self.virtualTitle length] > 0 ? self.virtualTitle : model.cat_name, model.goods_id] itemName:model.goods_title ContentType:@"Goods" itemCategory:@"Category_Goods"];
            
            ZFGoodsDetailViewController *detailVC = [[ZFGoodsDetailViewController alloc] init];
            detailVC.goodsId = model.goods_id;
            detailVC.sourceID = self.virtualType;
            //occ v3.7.0hacker 添加 ok
            detailVC.analyticsProduceImpression = self.analyticsProduceImpression;
            detailVC.transformSourceImageView = imageView;
            detailVC.analyticsSort = self.viewModel.analyticsSort;
            detailVC.sourceType = ZFAppsflyerInSourceTypeVirtualCategoryList;
            detailVC.isNeedProductPhotoBts = YES;
            detailVC.af_rank = model.af_rank;
            self.navigationController.delegate = detailVC;
            [self.navigationController pushViewController:detailVC animated:YES];
        };
        
        // 上下滚动控制顶部条是否隐藏
        [_viewModel setScrollListViewBlock:^(BOOL hide) {
            @strongify(self)
            CGFloat operaterY = hide ? (-self.topMenuView.height) : 0;
            YWLog(@"上下滚动控制顶部条是否隐藏===%d===%.2f", hide, operaterY);
            //if (self.topMenuView.y == operaterY || operaterY > 0) return ;
            [UIView animateWithDuration:0.5 animations:^{
                self.topMenuView.y = operaterY;
            }];
        }];
    }
    return _viewModel;
}

- (NSMutableArray *)menuTitles {
    if (!_menuTitles) {
        _menuTitles = [NSMutableArray arrayWithObjects:
                       ZFLocalizedString(@"TopicHead_Cell_ViewAll", nil),
                       ZFLocalizedString(@"Category_Item_Segmented_Sort", nil),
                       nil];
    }
    return _menuTitles;
}

- (NSArray *)virtualArray {
    if (!_virtualArray) {
        _virtualArray = [NSArray array];
    }
    return _virtualArray;
}

- (NSArray *)priceListArray {
    if (!_priceListArray) {
        _priceListArray = [NSArray array];
    }
    return _priceListArray;
}

- (NSArray<NSString *> *)sortRequests {
    if (!_sortRequests) {
        _sortRequests = [NSArray arrayWithObjects:@"recommend", @"new_arrivals",@"price_low_to_high",@"price_high_to_low",nil];
    }
    return _sortRequests;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth - 200, 40)];
        _titleLabel.font = ZFFontBoldSize(18);
        UIColor *titleColor = ZFC0x2D2D2D();
        if ([AccountManager sharedManager].needChangeAppSkin) {
        titleColor = [AccountManager sharedManager].appNavFontColor;
        }
        _titleLabel.textColor = titleColor;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 2;
    }
    return _titleLabel;
}

@end

