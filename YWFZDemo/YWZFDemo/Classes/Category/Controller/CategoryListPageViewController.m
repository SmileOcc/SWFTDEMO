//
//  CategoryListPageViewController.m
//  ListPageViewController
//
//  Created by YW on 1/6/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "CategoryListPageViewController.h"
#import "CategorySelectView.h"
#import "ZFGoodsListItemCell.h"
#import "ZFGoodsModel.h"
#import "CategoryListPageViewModel.h"
#import "ZFGoodsDetailViewController.h"
#import "CategoryRefineContainerView.h"
#import "CategoryRefineSectionModel.h"
#import "ZFCartViewController.h"
#import "ZFSearchViewController.h"
#import "ZFGoodsKeyWordsHeaderView.h"
#import "ZFSearchViewController.h"
#import "CategoryParentViewModel.h"
#import "ZFCategoryTopOperateView.h"
#import "ZFThemeManager.h"
#import "NSStringUtils.h"
#import "ZFProgressHUD.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "UIView+LayoutMethods.h"
#import "ZFLocalizationString.h"
#import "ZFFireBaseAnalytics.h"
#import "ZFStatistics.h"
#import "ZFGrowingIOAnalytics.h"
#import "CategoryDataManager.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "ZFRefreshHeader.h"
#import "ZFRefreshFooter.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFPopDownAnimation.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "ZFTimerManager.h"
#import "ZFCommonRequestManager.h"
#import "ZFBTSManager.h"
#import "ZFAppsflyerAnalytics.h"

#import "ZFCategoryRefineNewView.h"
#import <GGAppsflyerAnalyticsSDK/GGAppsflyerAnalytics.h>

@interface CategoryListPageViewController ()
@property (nonatomic, copy) NSString                      *currentCategory;
@property (nonatomic, strong) ZFCategoryTopOperateView    *operaterContentView;
@property (nonatomic, strong) CategorySelectView          *selectView;
@property (nonatomic, strong) CategoryRefineContainerView *refineView;
@property (nonatomic, strong) ZFCategoryRefineNewView     *newRefineView;

@property (nonatomic, strong) CategoryListPageViewModel   *viewModel;
@property (nonatomic, strong) UICollectionView            *listPageView;
@property (nonatomic, strong) NSMutableArray              *menuTitles;
@property (nonatomic, strong) UIView                      *againRequestView;
@property (nonatomic, copy)   NSString                    *navTitle;
@property (nonatomic, strong) NSArray<NSString *>         *sortRequests;
@property (nonatomic, strong) NSArray<NSString *>         *sortArray;
@property (nonatomic, copy)   NSString                    *categoryID;
@property (nonatomic, strong) CategoryParentViewModel     *parentViewModel;
@property (nonatomic, copy)   NSString                    *sortType; // 接口 排序的请求参数
@property (nonatomic, copy)   NSString                    *keyword;
@property (nonatomic, strong) UIButton                    *shoppingCarBtn;
@property (nonatomic, strong) ZFAnalyticsProduceImpression    *analyticsProduceImpression;//统计
@property (nonatomic, assign) BOOL                        isFirstCate;// 首次进入分类列表，用于区分是否返回分类数组
@property (nonatomic, strong) ZFBTSModel                 *listfilterBtsModel;
@property (nonatomic, strong) NSDictionary               *afRefineDic;
@property (nonatomic, strong) NSURLSessionDataTask       *goodsDetailBtsTask;
@property (nonatomic, strong) UILabel                    *titleLabel;
@end

@implementation CategoryListPageViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = ZFCOLOR_WHITE;
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    self.navigationItem.titleView = self.titleLabel;

    self.isFirstCate = YES;
    
    self.currentCategory = ZFLocalizedString(@"Category_Item_Segmented_Category", nil);
    if (ZFIsEmptyString(self.currentSort)) {
        self.currentSort = ZFLocalizedString(@"Category_Item_Segmented_Sort", nil);
    }
    [self configureNavgationItem];
    [self configureSubViews];
    [self autoLayoutSubViews];
    
    // 处理选中，及请求参数
    if (!ZFIsEmptyString(self.currentSort)) {
        NSInteger index = [self.sortRequests indexOfObject:self.currentSort];
        if (index < self.sortArray.count) {
            self.currentSort = self.sortArray[index];

            //V4.5.5修改deeplink进来没有带参数请求的bug
            if (index < self.sortRequests.count) {
                self.sortType = self.sortRequests[index];
            }
            if (self.model.is_child) {
                self.menuTitles[[self.model.is_child boolValue]] = ZFToString(self.currentSort);
                self.operaterContentView.menuView.titles = self.menuTitles;
            }
            self.selectView.currentSortType = self.currentSort;
        }
    }
    
    [self loadAllData];
    [self requestListPageData];
    [self addObNotification];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    //刷新购物车数量
    [self refreshShppingCarBag];
    //谷歌统计
    [ZFAnalytics screenViewQuantityWithScreenName:[NSString stringWithFormat:@"Cate - %@",_model.cat_name]];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self.model.cat_name isEqualToString:ZFLocalizedString(@"TopicDetailView_ViewAll", nil)]) {
        for (CategoryNewModel *model in self.selectView.categoryArray) {
            model.isOpen = NO;
        }
    }
    if (_newRefineView) {
        [self.newRefineView hideRefineInfoViewViewWithAnimation:NO];
    }
}

#pragma mark - Init Methods
- (void)configureSubViews{
    self.view.backgroundColor = ZFCOLOR_WHITE;
    [self.view addSubview:self.listPageView];
    [self.view addSubview:self.selectView];
    [self.view addSubview:self.operaterContentView];
}

- (void)autoLayoutSubViews{
    [self.selectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.view);
        make.top.equalTo(self.view).offset(KMenuHeight);
    }];

//    [self.listPageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.leading.trailing.equalTo(self.view);
//        make.bottom.mas_equalTo(self.view).offset(IPHONE_X_5_15 ? -34 : 0);
//    }];
}

- (void)configureNavgationItem {
    UIButton *bagBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [bagBtn setFrame:CGRectMake(0, 0, NavBarButtonSize, NavBarButtonSize)];
    [bagBtn setImage:ZFImageWithName(@"public_bag") forState:UIControlStateNormal];
    [bagBtn addTarget:self action:@selector(rightBagBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.shoppingCarBtn = bagBtn;
    bagBtn.contentEdgeInsets = UIEdgeInsetsMake(0.0, 8.0, 0.0, -8.0);
    UIBarButtonItem *bagItem = [[UIBarButtonItem alloc] initWithCustomView:bagBtn];
    
    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchButton setFrame:CGRectMake(0, 0, NavBarButtonSize, NavBarButtonSize)];
    [searchButton setImage:ZFImageWithName(@"category_goodslist_search") forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(rightSearchBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    searchButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 12.0, 0.0, -12.0);
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    
    self.navigationItem.rightBarButtonItems = @[bagItem, searchItem];
}

/**
 * 添加购物车需要刷新bag
 */
- (void)addObNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCategoryListCartCount) name:kCartNotification object:nil];
}

- (void)refreshCategoryListCartCount {
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

- (void)rightBagBtnClick:(id)sender {
    [ZFStatistics eventType:ZF_CategoryList_Cars_type];
    ZFCartViewController *cartViewController = [[ZFCartViewController alloc] init];
    [self.navigationController pushViewController:cartViewController animated:YES];
}

- (void)rightSearchBtnClick:(id)sender {
    ZFSearchViewController *searchViewController = [[ZFSearchViewController alloc] init];
    searchViewController.cateId = self.categoryID;
    [self.navigationController pushViewController:searchViewController animated:YES];
}

#pragma mark - Private Methods
- (void)loadAllData{
    self.categoryID = self.model.cat_id;
    self.navTitle = self.model.cat_name;
    if (!ZFIsEmptyString(self.navTitle)) {
        self.titleLabel.text = self.navTitle;
    }
//    [self loadRefineData:self.categoryID];
//    self.title = self.navTitle;
}

/// 请求列表商品数据
- (void)requestPageData:(BOOL)isFirstPage {
    ZFBTSModel *productPhotoBtsModel = [ZFBTSManager getBtsModel:kZFBtsProductPhoto defaultPolicy:kZFBts_A];
    NSMutableArray *bts_test = [NSMutableArray array];
    [bts_test addObject:[productPhotoBtsModel getBtsParams]];
    NSDictionary *parmaters = @{
                                @"page"      : isFirstPage ? Refresh : LoadMore,
                                @"cat_id"    : ZFToString(self.categoryID),
                                @"order_by"  : ZFToString(self.sortType),
                                @"price_min" : ZFToString(self.price_min),
                                @"price_max" : ZFToString(self.price_max),
                                @"selected_attr_list" : ZFToString(self.selectedAttrsString),
                                @"keyword"   : ZFToString(self.keyword),
                                @"featuring" : ZFToString(self.model.cat_featuring),
                                @"page_size" : @(20),
                                @"is_enc"    : @"0",
                                @"appsFlyerUID" : ZFToString([[AppsFlyerTracker sharedTracker] getAppsFlyerUID]),
                                ZFApiBtsUniqueID : ZFToString([GGAppsflyerAnalytics getAppsflyerDeviceId]),
                                @"bts_test"  : bts_test,
                                @"is_first_cate" : self.isFirstCate ? @"1" : @"0"
                                };
    
    if (isFirstPage) {
        self.viewModel.analyticsSort = ZFToString(self.sortType).length ? self.sortType : @"recommend";
    }
    
    [self.viewModel requestCategoryListDataWithParams:parmaters
                                          loadingView:self.listPageView
                                           completion:^(CategoryListPageModel *loadingModel, NSInteger nextPageIndex, id pageData, BOOL isSucess)
    {
        HideLoadingFromView(self.listPageView);
        // ====================分类数据处理====================
        if (isFirstPage && self.isFirstCate && isSucess) {
            self.isFirstCate = NO;
            NSArray<CategoryNewModel *> *childs = self.viewModel.categoryModelList;
            if (childs.count > 0) {
                self.model.is_child = @"1";
            } else {
                [self configureMenuTitleArray];
            }
            
            if (!ZFIsEmptyString(self.currentSort)) {
                NSInteger index = [self.sortRequests indexOfObject:self.currentSort];
                if (index < self.sortArray.count) {
                    self.currentSort = self.sortArray[index];
                    
                    //V4.5.5修改deeplink进来没有带参数请求的bug
                    if (index < self.sortRequests.count) {
                        self.sortType = self.sortRequests[index];
                    }
                }
                self.menuTitles[[self.model.is_child boolValue]] = ZFToString(self.currentSort);
                self.operaterContentView.menuView.titles = self.menuTitles;
                self.selectView.currentSortType = self.currentSort;
            }
        }
        
        // ====================列表数据处理====================
        //更新热词数据源
        self.operaterContentView.hidden = NO;
        if (isFirstPage) {
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
            
            [self.operaterContentView updateKeyworkData:loadingModel.guideWords];
        }
        CGFloat offsetY = (self.operaterContentView.keyworkHeaderView.kerwordArray.count > 0) ? (KMenuHeight + kKeywordHeight) : KMenuHeight;
        
        //如果请求的数据中从有热词到无热词时operaterContentView会变化,列表的顶部偏移量也要变化, 因此需要再次设置列表的contentInset和contentOffset
        if (self.operaterContentView.height != offsetY) {
            
            [self.selectView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view).offset(offsetY);
            }];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (self.listPageView.contentInset.top != offsetY) {
                    self.listPageView.contentInset = UIEdgeInsetsMake(offsetY, 0, offsetY, 0);
                }
                if (self.listPageView.contentOffset.y != -offsetY) {
                    self.listPageView.contentOffset = CGPointMake(0, -offsetY);
                }
            });
        } else {
            
        }
        self.operaterContentView.height = offsetY;
        
        [loadingModel.goods_list enumerateObjectsUsingBlock:^(ZFGoodsModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *pageName = [NSString stringWithFormat:@"GIOCategoryList_%@", self.model.cat_name];
            [ZFGrowingIOAnalytics ZFGrowingIOProductShow:obj page:pageName];

            // 巴西分期付款
            ZFAddressCountryModel *accountModel = [AccountManager sharedManager].accountCountryModel;
            NSString *region_code = ZFToString(accountModel.region_code);
            if ([region_code isEqualToString:@"BR"] && ![NSStringUtils isEmptyString:obj.instalMentModel.instalments]) {
                obj.isInstallment = YES;
                obj.tagsArray = @[[ZFGoodsTagModel new]];
            }

            // 倒计时开启，根据商品属性判断
            if ([obj.countDownTime integerValue] > 0) {
                [[ZFTimerManager shareInstance] startTimer:[NSString stringWithFormat:@"GoodsList_%@", obj.goods_id]];
            }
        }];
        
        [self.listPageView reloadData];
        [self.listPageView showRequestTip:pageData];
        
        // 统计代码
        NSString *impression = [NSString stringWithFormat:@"%@_%@", ZFGACategoryList, self.model.cat_name];
        NSString *screenName = [NSString stringWithFormat:@"category_%@", self.model.cat_name];
        //occ v3.7.0hacker 添加 ok
        self.analyticsProduceImpression = [ZFAnalyticsProduceImpression initAnalyticsProducePosition:1
                                                                                      impressionList:impression
                                                                                          screenName:screenName
                                                                                               event:@"load"];
        // 统计代码 (此处的统计暂时不要了, 在addAnalyticsShowProducts中已用新的方式统计, modify by: YW)
        // NSString *impression = [NSString stringWithFormat:@"%@_%@", ZFGACategoryList, self.model.cat_name];
        // NSString *screenName = [NSString stringWithFormat:@"category_%@", self.model.cat_name];
        // [ZFAnalytics showProductsWithProducts:loadingModel.goods_list position:1 impressionList:impression screenName:screenName event:@"load"];
        
        [ZFFireBaseAnalytics scanGoodsListWithCategory:(self.model.cat_name == nil ? @"" : self.model.cat_name)];
    }];
}

- (void)requestListPageData {
    @weakify(self);
    self.listPageView.mj_header = [ZFRefreshHeader headerWithRefreshingBlock:^{
        @strongify(self);
        
        //没有请求筛选数据
        if (!self.refineView.model && !self.newRefineView.model) {
            [self loadRefineData:self.categoryID];
        }
        [self requestPageData:YES];
    }];

    self.listPageView.mj_footer = [ZFRefreshFooter footerWithRefreshingBlock:^{
        @strongify(self);
        [self requestPageData:NO];
        self.viewModel.lastCategoryID = self.categoryID;
    }];
    self.listPageView.mj_footer.hidden = YES;
    
    NSMutableDictionary *btsDict = [NSMutableDictionary dictionary];
    btsDict[kZFBtsProductPhoto] = kZFBts_A;
    
    //V5.7.0:@产品说不请求保留默认版本
//    btsDict[kZFBtsIOSListfilter] = kZFBts_A;
    
    ShowLoadingToView(self.listPageView);
    self.goodsDetailBtsTask = [ZFBTSManager requestBtsModelList:btsDict timeoutInterval:2 completionHandler:^(NSArray<ZFBTSModel *> * _Nonnull modelArray, NSError * _Nonnull error) {
        @strongify(self);
        
        for (ZFBTSModel *obj in modelArray) {
            if ([obj.plancode isEqualToString:kZFBtsIOSListfilter]) {
                self.listfilterBtsModel = obj;
            }
        }
        
        [self loadRefineData:self.categoryID];
        // 请求列表数据
        [self requestPageData:YES];
    }];
}

/**
 * 如果是没有子类或者直接三级进入的,不展示Category
 */
- (void)configureMenuTitleArray {
    BOOL ifNeedRemove = ![self.model.is_child boolValue];
    if (ifNeedRemove) {
        [self.menuTitles removeObjectAtIndex:0];
    }
    self.operaterContentView.menuView.titles = self.menuTitles;
}

- (void)loadRefineData:(NSString *)catID {
    self.listfilterBtsModel = [ZFBTSManager getBtsModel:kZFBtsIOSListfilter defaultPolicy:kZFBts_A];
    NSString *attrVersion = [self attVersionIosListfilter:self.listfilterBtsModel.policy];
    NSDictionary *paramsDic = @{@"attr_version":ZFToString(attrVersion),
                                @"cat_id":ZFToString(catID)};
    @weakify(self)
    [self.viewModel requestRefineDataWithCatID:paramsDic completion:^(CategoryRefineSectionModel *refineModel) {
        @strongify(self)
        if ([self.listfilterBtsModel.policy isEqualToString:kZFBts_B]) {
            self.newRefineView.categoryRefineDataArray = refineModel.refine_list;
            self.newRefineView.model = refineModel;
            self.newRefineView.hidden = NO;
            self.refineView.hidden = YES;
        } else {
            self.refineView.model = refineModel;
            self.refineView.hidden = NO;
            self.newRefineView.hidden = YES;
        }
        
        //如果是从Deeplink进来需要选中指定的refine
        [self shouldSelectedRefineFromDeeplink];
        
    } failure:^(id obj) {
        YWLog(@"怼后台!!!");
    }];
    
}

- (NSString *)attVersionIosListfilter:(NSString *)policy {
    if (!ZFIsEmptyString(policy) && [policy isEqualToString:kZFBts_B]) {
        return @"1";
    }
    return @"0";
}

/**
 * 如果是从Deeplink进来需要选中指定的refine
 */
- (void)shouldSelectedRefineFromDeeplink {
    
    if (self.isFromDeepLink) {
        
        if (!self.refineView.isHidden) {
            // 选中传进来的deeplink标签
            @weakify(self)
            [self.refineView selectedCustomRefineByDeeplink:self.selectedAttrsString
                                                   priceMax:self.price_max
                                                   priceMin:self.price_min
                                                   hasCheck:^{
                @strongify(self)
                // 改变选中的refine标题颜色
                [self.operaterContentView.menuView updateSelectInfoOptionWithApply:YES];
            }];
        } else if(!self.newRefineView.isHidden) {

            // 选中传进来的deeplink标签
            [self.newRefineView selectedCustomRefineByDeeplink:self.selectedAttrsString
                                                   priceMax:self.price_max
                                                   priceMin:self.price_min
                                                   hasCheck:^{
        
            }];
        }
    }
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
        NSMutableArray *categoryArray = [NSMutableArray array];
        NSArray<CategoryNewModel *> *array = self.viewModel.categoryModelList;//[[CategoryDataManager shareManager] querySubCategoryDataWithParentID:self.model.cat_id];
        
        if ([self.model.cat_name isEqualToString:ZFLocalizedString(@"TopicDetailView_ViewAll", nil)]
            || self.isViewAll) {
            CategoryNewModel *viewAllModel = [[CategoryNewModel alloc] init];
            viewAllModel.cat_name = ZFLocalizedString(@"TopicDetailView_ViewAll", nil);
            viewAllModel.cat_id = array.firstObject.parent_id;
            viewAllModel.parent_id = @"0";
            viewAllModel.is_child = @"0"; // 1 有子级 0 没有
            [categoryArray addObjectsFromArray:array];
            [categoryArray insertObject:viewAllModel atIndex:0];
            self.selectView.categoryArray = [categoryArray copy];
        }else{
            self.selectView.categoryArray = array;
        }
    }else{
        self.selectView.currentSortType = self.selectView.currentSortType.length > 0 ? self.selectView.currentSortType : @"Recommend";
        self.selectView.sortArray = self.sortArray;
    }
    
    [self.selectView showCompletion:^{
    }];
}

- (void)showRefineView {
    
    if ([ZFToString(self.listfilterBtsModel.policy) isEqualToString:kZFBts_B]) {
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window addSubview:self.newRefineView];
        self.newRefineView.hidden = NO;
        self.refineView.hidden = YES;
        
        self.newRefineView.af_page_name = [NSString stringWithFormat:@"category_%@", self.model.cat_name];
        [self.newRefineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        [self.newRefineView showRefineInfoViewWithAnimation:YES];
        
    } else {
    
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window addSubview:self.refineView];
        self.newRefineView.hidden = YES;
        self.refineView.hidden = NO;
        [self.refineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        [self.refineView showRefineInfoViewWithAnimation:YES];
    }
}

- (void)resetRequestParmas  {
    self.price_max = @"";
    self.price_min = @"";
    self.sortType = @"";
    self.selectedAttrsString = @"";
    self.afRefineDic = @{};
    
    // 重置选中
    if (_newRefineView) {
        [self.newRefineView.categoryRefineDataArray enumerateObjectsUsingBlock:^(CategoryRefineDetailModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj.childArray enumerateObjectsUsingBlock:^(CategoryRefineCellModel * _Nonnull subObj, NSUInteger idx, BOOL * _Nonnull stop) {
                subObj.isSelect = NO;
                subObj.editMax = @"";
                subObj.editMin = @"";
                subObj.localCurrencyMin = @"";
                subObj.localCurrencyMax = @"";
            }];
        }];
        [self.newRefineView.collectView reloadData];
        [self updateTopMenu:@""];
    }
    
    // 分类改变，重置筛选条件
    [self loadRefineData:self.categoryID];
}

- (void)updateTopMenu:(NSString *)counts {
    [self.operaterContentView.menuView updateIndex:(self.operaterContentView.menuView.titles.count - 1) counts:counts];
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
                             @"af_sort" : ZFToString(self.sortType),
                             @"af_category" : ZFToString(self.categoryID),
                               @"af_filter" : ZFJudgeNSDictionary(self.afRefineDic) ? self.afRefineDic : @{},
                             @"af_keyword" : ZFToString(self.keyword),
                             @"af_inner_mediasource" : [ZFAppsflyerAnalytics sourceStringWithType:ZFAppsflyerInSourceTypeCategoryList sourceID:self.model.cat_id]
    };
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_filter_choice" withValues:afParams];
}

#pragma mark - Setter
- (void)setSortIndex:(NSString *)sortIndex {
    _sortIndex = sortIndex;
}

#pragma mark - Getter Block

- (void (^)(NSInteger, BOOL))fetchSelectedMenuBlock {
    @weakify(self)
    return ^(NSInteger tapIndex, BOOL isSelect) {
        @strongify(self);
        NSString *title = self.operaterContentView.menuView.titles[tapIndex];
        if ([title isEqualToString:self.currentCategory]) {
            [self configureSelectDataType:SelectViewDataTypeCategory select:isSelect];
            
        } else if ([title isEqualToString:self.currentSort]) {
            [self configureSelectDataType:SelectViewDataTypeSort select:isSelect];
            
        } else if ([title isEqualToString:ZFLocalizedString(@"Category_Item_Segmented_Refine", nil)]) {
            [self.selectView dismiss];
            [self showRefineView];
        }
    };
}

- (void (^)(NSString *))fetchSelectedKeywordBlock {
    @weakify(self)
    return ^(NSString *keyword) {
        @strongify(self)
        self.keyword = keyword;
        ShowLoadingToView(self.listPageView);
        [self requestPageData:YES];
        // 统计
        [self analyticsRefine:SelectViewDataTypeWord];
    };
}

- (ZFCategoryTopOperateView *)operaterContentView {
    if (!_operaterContentView) {
        CGRect topViewRect = CGRectMake(0.0, 0.0, KScreenWidth, KMenuHeight);
        _operaterContentView = [[ZFCategoryTopOperateView alloc] initWithFrame:topViewRect
                                                               selectMenuBlock:[self fetchSelectedMenuBlock]
                                                          selectedKeywordBlock:[self fetchSelectedKeywordBlock]];
        _operaterContentView.backgroundColor = [UIColor whiteColor];
        _operaterContentView.clipsToBounds = YES;
        _operaterContentView.hidden = YES;
        _operaterContentView.menuView.isLastFilter = YES;
    }
    return _operaterContentView;
}

- (CategorySelectView *)selectView {
    if (!_selectView) {
        _selectView = [[CategorySelectView alloc] init];
        @weakify(self)
        _selectView.selectCompletionHandler = ^(NSInteger tag, SelectViewDataType type) {
            @strongify(self);
            [self.operaterContentView.menuView restoreIndicator:[self.model.is_child boolValue] ? type : type - 1];
            if (type == SelectViewDataTypeCategory) {
                // 这个属性是用来清空原有数据的,只要前后两个 ID 不一样即可,所以这里传空
                CategoryNewModel *model = self.selectView.categoryArray[tag];

                if (![self.categoryID isEqualToString:model.cat_id]) {
                    
                    self.categoryID = model.cat_id;
                    self.viewModel.lastCategoryID = @"";
                    self.viewModel.cateName = self.categoryID;  //统计代码分类id赋值
                    self.selectView.currentSortType = @"";
                    self.currentSort = ZFLocalizedString(@"Category_Item_Segmented_Sort", nil);
                    self.selectView.currentCategory = model.cat_name;
                    self.selectView.currentCateId = model.cat_id;
                    [self resetRequestParmas];
                    [self.listPageView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
                    [self requestPageData:YES];
                    self.menuTitles[0] = ZFToString(model.cat_name);
                    self.menuTitles[1] = ZFToString(self.currentSort);
                    self.operaterContentView.menuView.titles = self.menuTitles;
                    self.currentCategory = model.cat_name;
                    [self.refineView clearRefineInfoViewData];
                    
                    [self analyticsRefine:type];
                }
                
            } else if (type == SelectViewDataTypeSort) {
                if (![self.sortType isEqualToString:self.sortRequests[tag]]) {
                    
                    self.sortType = self.sortRequests[tag];
                    self.menuTitles[[self.model.is_child boolValue]] = self.selectView.sortArray[tag];
                    self.operaterContentView.menuView.titles = self.menuTitles;
                    self.currentSort = self.selectView.sortArray[tag];
                    self.selectView.currentSortType = self.currentSort;
                    self.viewModel.lastCategoryID = @"";
                    [self.listPageView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
                    [self requestPageData:YES];
                    
                    [self analyticsRefine:type];
                }
            }
        };
        
        _selectView.maskTapCompletionHandler = ^(NSInteger index) {
            @strongify(self);
            [self.operaterContentView.menuView restoreIndicator:[self.model.is_child boolValue] ? index : index - 1];
        };

        _selectView.selectSubCellHandler = ^(CategoryNewModel *model, SelectViewDataType type) {
            @strongify(self);
            
            [self.operaterContentView.menuView restoreIndicator:SelectViewDataTypeCategory];
            if (![self.categoryID isEqualToString:model.cat_id]) {
                
                // 这个属性是用来清空原有数据的,只要前后两个 ID 不一样即可,所以这里传空
                self.categoryID = model.cat_id;
                self.viewModel.lastCategoryID = @"";
                self.selectView.currentSortType = @"";
                self.selectView.currentCategory = model.cat_name;
                self.selectView.currentCateId = model.cat_id;
                self.currentSort = ZFLocalizedString(@"Category_Item_Segmented_Sort", nil);
                self.menuTitles[0] = ZFToString(model.cat_name);
                self.menuTitles[1] = ZFToString(self.currentSort);
                self.operaterContentView.menuView.titles = self.menuTitles;
                self.keyword = @"";
                [self.operaterContentView.keyworkHeaderView reset];
                self.currentCategory = model.cat_name;
                [self resetRequestParmas];
                [self requestPageData:YES];
                
                [self analyticsRefine:type];
            }
        };
        _selectView.selectAnimationStopCompletionHandler = ^{
            @strongify(self);
            self.operaterContentView.menuView.isDropAnimation = NO;
        };
    }
    return _selectView;
}

- (UICollectionView *)listPageView {
    if (!_listPageView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 12;
        layout.sectionInset = UIEdgeInsetsMake(0, 12, 12, 12);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        CGRect rect = CGRectMake(0, 0, KScreenWidth, self.view.height-(IPHONE_X_5_15 ? 34 : 0));
        _listPageView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
        _listPageView.backgroundColor = ZFCOLOR(255, 255, 255, 1);
        [_listPageView registerClass:[ZFGoodsListItemCell class] forCellWithReuseIdentifier:kZFCollectionMultipleColumnCellIdentifier];
        _listPageView.delegate = self.viewModel;
        _listPageView.dataSource = self.viewModel;
        _listPageView.emptyDataImage = ZFImageWithName(@"blankPage_noCart");
        _listPageView.emptyDataTitle = [NSString stringWithFormat:ZFLocalizedString(@"CategoryNoDate",nil),ZFToString(self.model.cat_name)];
        //下面这两个偏移量需要设置,否则会影响快速滑动流畅度
        CGFloat offsetY = KMenuHeight;// + kKeywordHeight;
        _listPageView.contentInset = UIEdgeInsetsMake(offsetY, 0, 0, 0);
        _listPageView.contentOffset = CGPointMake(0, -offsetY);

        if (@available(iOS 11.0, *)) {
            _listPageView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _listPageView;
}

- (CategoryRefineContainerView *)refineView {
    if (!_refineView) {
        _refineView = [[CategoryRefineContainerView alloc] init];
        _refineView.hidden = YES;
        @weakify(self);
        _refineView.hideRefineViewCompletionHandler = ^{
            @strongify(self);
            [self.refineView removeFromSuperview];
            // 此处 index 只是避免数组越界
            NSInteger index = [self.model.is_child boolValue] ? SelectViewDataTypeRefine : SelectViewDataTypeSort;
            [self.operaterContentView.menuView restoreIndicator:index];
        };
        
        _refineView.applyRefineContainerViewInfoCompletionHandler = ^(NSDictionary *parms,NSDictionary *afParams) {
            @strongify(self);
            [self.refineView hideRefineInfoViewViewWithAnimation:YES];
            self.price_max = parms[@"price_max"];
            self.price_min = parms[@"price_min"];
            self.selectedAttrsString = parms[@"selected_attr_list"];
            self.viewModel.lastCategoryID = @"Reccommand";
            [self.listPageView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
            [self requestPageData:YES];
            self.afRefineDic = afParams;
            
            [self analyticsRefine:SelectViewDataTypeRefine];
        };
        
        _refineView.categoryRefineSelectIconCompletionHandler = ^(BOOL selelct) {
            @strongify(self);
            [self.operaterContentView.menuView updateSelectInfoOptionWithApply:selelct];
        };
    }
    return _refineView;
}

- (ZFCategoryRefineNewView *)newRefineView {
    if (!_newRefineView) {
        _newRefineView = [[ZFCategoryRefineNewView alloc] initWithFrame:CGRectZero];
        _newRefineView.hidden = YES;
        
        @weakify(self);
        _newRefineView.hideCategoryRefineBlock = ^{
            @strongify(self);
            
            [self.newRefineView removeFromSuperview];
            // 此处 index 只是避免数组越界
            NSInteger index = [self.model.is_child boolValue] ? SelectViewDataTypeRefine : SelectViewDataTypeSort;
            [self.operaterContentView.menuView restoreIndicator:index];
        };
        
        _newRefineView.confirmBlock = ^(NSArray<ZFGeshopSiftItemModel *> *nativeResults, NSArray<CategoryRefineCellModel *> *categoryResults, NSDictionary *afParams) {
            @strongify(self);

            [self.newRefineView hideRefineInfoViewViewWithAnimation:YES];
            
            self.price_min = @"";
            self.price_max = @"";
            self.selectedAttrsString = @"";
            self.afRefineDic = @{};
            
            __block NSInteger selectCount = categoryResults.count;
            
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
                
                self.afRefineDic = afParams;
                self.selectedAttrsString = [allSelectAttrs componentsJoinedByString:@"~"];
                self.viewModel.lastCategoryID = @"Reccommand";
                [self.listPageView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
                [self requestPageData:YES];
                
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
            self.price_max = @"";
            self.price_min = @"";
        };
        
    }
    return _newRefineView;
}

- (CategoryListPageViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[CategoryListPageViewModel alloc] init];
        _viewModel.controller = self;
        _viewModel.cateName = NullFilter(self.model.cat_id);
        _viewModel.isVirtual = NO;
        _viewModel.analyticsSort = self.sortType;
        @weakify(self)
        _viewModel.handler = ^(ZFGoodsModel *model, UIImageView *imageView) {
            @strongify(self)
            [ZFFireBaseAnalytics selectContentWithItemId:[NSString stringWithFormat:@"Click_Category_%@_Goods_%@", self.model.cat_name, model.goods_id] itemName:model.goods_title ContentType:@"Goods" itemCategory:@"Category_Goods"];
            
            ZFGoodsDetailViewController *detailVC = [[ZFGoodsDetailViewController alloc] init];
            detailVC.goodsId    = model.goods_id;
            detailVC.sourceID   = self.model.cat_id;
            detailVC.sourceType = ZFAppsflyerInSourceTypeCategoryList;
            //occ v3.7.0hacker 添加 ok
            detailVC.analyticsProduceImpression = self.analyticsProduceImpression;
            detailVC.transformSourceImageView = imageView;
            detailVC.afParams = self.viewModel.model.af_params;
            detailVC.analyticsSort = self.viewModel.analyticsSort;
            detailVC.isNeedProductPhotoBts = YES;
            detailVC.af_rank = model.af_rank;
            self.navigationController.delegate = detailVC;
            [self.navigationController pushViewController:detailVC animated:YES];
        };
        
        // 上下滚动控制顶部条是否隐藏
        [_viewModel setScrollListViewBlock:^(BOOL hide) {
            @strongify(self)
            CGFloat operaterY = hide ? (-self.operaterContentView.height) : 0;
            YWLog(@"上下滚动控制顶部条是否隐藏===%d===%.2f", hide, operaterY);
            //if (self.operaterContentView.y == operaterY || operaterY > 0) return ;
            [UIView animateWithDuration:0.5 animations:^{
                self.operaterContentView.y = operaterY;
            }];
        }];
    }
    return _viewModel;
}

- (NSMutableArray *)menuTitles {
    if (!_menuTitles) {
        _menuTitles = [NSMutableArray arrayWithObjects:
                       ZFLocalizedString(@"Category_Item_Segmented_Category", nil),
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

- (UIView *)againRequestView {
    if (!_againRequestView) {
        _againRequestView = [[UIView alloc] initWithFrame:CGRectZero];
        _againRequestView.backgroundColor = ZFCOLOR(245, 245, 245, 1.f);
    }
    return _againRequestView;
}

- (CategoryParentViewModel *)parentViewModel {
    if (!_parentViewModel) {
        _parentViewModel = [[CategoryParentViewModel alloc] init];
    }
    return _parentViewModel;
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    HideLoadingFromView(self.view);
    HideLoadingFromView(_listPageView);
    HideLoadingFromView(nil);
    
    if (_goodsDetailBtsTask) {
        [_goodsDetailBtsTask cancel];
        _goodsDetailBtsTask = nil;
    }
    if (_newRefineView) {
        [self.newRefineView removeFromSuperview];
    }
}

@end

