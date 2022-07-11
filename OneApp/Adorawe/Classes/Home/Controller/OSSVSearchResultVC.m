
//
//  OSSVSearchResultVC.m
// OSSVSearchResultVC
//
//  Created by 10010 on 20/7/1.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVSearchResultVC.h"
#import "OSSVSeachsResultsViewModel.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "UIViewController+PopBackButtonAction.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "OSSVCartVC.h"
#import "OSSVSearchsRecommdHeader.h"
#import "STLProductListSkeletonView.h"
#import "Adorawe-Swift.h"
#import "STLPreference.h"

@interface OSSVSearchResultVC ()

@property (nonatomic, strong) UIButton                         *searchTitleButton;
@property (nonatomic, strong) UICollectionView                 *collectionView;
@property (nonatomic, strong) UIButton                         *backToTopButton;
@property (nonatomic, strong) OSSVSeachsResultsViewModel             *viewModel;
@property (nonatomic, strong) STLProductListSkeletonView       *productSkeletonView; //骨架图

@property (nonatomic,strong) PrivacySheet              *privacySheet;
@end

@implementation OSSVSearchResultVC

#pragma mark - Life Cycle

- (void)dealloc {
    [_searchTitleButton removeFromSuperview];
    _searchTitleButton = nil;
    [self.collectionView removeObserver:self forKeyPath:kColletionContentOffsetName];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotif_Currency object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.firstEnter) {
    }
    self.firstEnter = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_CartBadge object:nil];
    
    if (![[STLPreference objectForKey:@"noNeedShowPrivacy"] boolValue] && [OSSVAccountsManager sharedManager].sysIniModel.is_show_privacy) {
        [self.privacySheet showInParentView:self.view bottomAncher:nil offset:@20];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = YES;
//    if (! (self.keyword.length > 0)) return;
//    if (self.isFromSearchVC) {
//        // 此处是为了后期可能做的一个需求，预计做的
//        [self initCustomSearchNavBar];
//    }
//    else {
    if (STLIsEmptyString(self.title)) {
        self.title = self.keyword;
    }
//    }
    self.currentPageCode = self.keyword;
    // Appflyer统计搜索词
    [OSSVAnalyticsTool appsFlyerSearch:@{
                                    //@"af_content_list" : @"normal_search",
                                    @"af_search_string" : STLToString(self.keyword)
                                    }];
    
    [self initSearchBar];
    [self initView];
    [self requestDataWithproductSkeleton];
    [self requsetData];
    // 汇率改变的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCurrency:) name:kNotif_Currency object:nil];
    // KVO 添加观察 backToTopButton
    [self.collectionView addObserver:self forKeyPath:kColletionContentOffsetName options:NSKeyValueObservingOptionNew context:nil];
 
}

#pragma mark - MakeUI
- (void)initSearchBar {
    [self.view addSubview:self.searchNavbar];
    
    [self.searchNavbar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view.mas_top);
        make.height.mas_equalTo(kNavHeight);
    }];
}
- (void)initView {
    
    [self.view addSubview:self.collectionView];
    [self.collectionView addSubview:self.productSkeletonView];
    [self.view addSubview:self.backToTopButton];
    [self.view bringSubviewToFront:self.backToTopButton];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(self.searchNavbar.mas_bottom);
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
}


#pragma mark 暂时未用
- (void)initCustomSearchNavBar {
    
    /**
     *  此处有三种思路
     1、直接在 navigationItem setTitleView 但是不好控制位置
     2、通过 透明 titleView 设置，然后再增加,位置相对来说好改变一些
     3、直接在 navigationBar 添加，但是移除比较费事，还要考虑子ViewController 中的显示
     4、隐藏 NavigationBar，然后重新自定义 NavigationCustomBar
     */
    
    // 暂时选思路一 但位置可调整
    //    self.searchTitleButton.frame = CGRectMake(0, 0, SCREEN_WIDTH - 95, 32);
    //    self.navigationItem.titleView = self.searchTitleButton;
    
    // 思路二 暂时这样选，不过注意实际上 backNavTitleView width 是小于 SCREEN_WIDTH的
    UIView *backNavTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 32)];
    backNavTitleView.backgroundColor = [UIColor clearColor];
    [self.navigationItem setTitleView:backNavTitleView];
    
    [backNavTitleView addSubview:self.searchTitleButton];
    [self.searchTitleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.leading.equalTo(@0);
        make.trailing.mas_equalTo(@(-15));
    }];
    
    //思路三
    //    self.searchTitleButton.frame = CGRectMake(50, 6, SCREEN_WIDTH - 80, 32);
    //    [self.navigationController.navigationBar addSubview:self.searchTitleButton];
    
}
#pragma mark ---首次进入请求数据，带入骨架图
- (void)requestDataWithproductSkeleton {
    self.productSkeletonView.hidden = NO;
    @weakify(self)
    [self.viewModel requestNetwork: @[self.keyword,STLRefresh] completion:^(id obj) {
        @strongify(self)

        self.productSkeletonView.hidden = YES;
        [self.collectionView reloadData];
        [self.collectionView showRequestTip:@{kTotalPageKey  : @(1),
                                             kCurrentPageKey: @(0)}];

        OSSVAdvsEventsModel *advEventModel = [[OSSVAdvsEventsModel alloc] init];
        advEventModel.url = self.sourceDeeplinkUrl;
        NSDictionary *sensorsDic = @{@"key_word":STLToString(self.keyword),
                                         @"key_word_type":STLToString(self.keyWordType),
                                     @"url":STLToString([advEventModel advActionUrl]),
                                     @"result_number":@([self.viewModel currentPageGoodsCount]),
                                    kAnalyticsThirdPartId: STLToString(self.viewModel.searchModel.btm_sid) ,
                };
        [OSSVAnalyticsTool analyticsSensorsEventWithName:@"SearchRequest" parameters:sensorsDic];
        [ABTestTools.shared searchRequestWithKeyWord:STLToString(self.keyword) keyWordsType:STLToString(self.keyWordType) resultNumber:[self.viewModel currentPageGoodsCount]];
        
    } failure:^(id obj) {
         @strongify(self)
        self.productSkeletonView.hidden = YES;
        [self.collectionView reloadData];
        [self.collectionView showRequestTip:nil];
    }];
}

#pragma mark - Method
- (void)requsetData {
    
    @weakify(self)
    self.collectionView.mj_footer = [OSSVRefreshsAutosNormalFooter footerWithRefreshingBlock:^{
        @strongify(self)
        @weakify(self)
        NSString *keyword = [OSSVNSStringTool isEmptyString:self.keyword] ? @"" : self.keyword;
        [self.viewModel requestNetwork:@[keyword,STLLoadMore] completion:^(id obj) {
            @strongify(self)
             if([obj isEqual: STLNoMoreToLoad]) {
                  // 无法加载更多的时候
                 /*!
                     1、此处是为了 隐藏加载到最后不显示那个 NO More Data
                     2、hidden = YES 后，实际上是重复了上述的功能，后期可根据需求调整
                  */
              [self.collectionView.mj_footer endRefreshingWithNoMoreData];
               self.collectionView.mj_footer.hidden = YES;
             }
             else {
                 NSArray *indexPaths = (NSArray *)obj;
                 if (indexPaths){
                     [self.collectionView performBatchUpdates:^{
                         [self.collectionView insertItemsAtIndexPaths:indexPaths];
                     } completion:NULL];
                 }
                 [self.collectionView.mj_footer endRefreshing];
                 
                 OSSVAdvsEventsModel *advEventModel = [[OSSVAdvsEventsModel alloc] init];
                 advEventModel.url = self.sourceDeeplinkUrl;
                 NSDictionary *sensorsDic = @{@"key_word":STLToString(self.keyword),
                                                  @"key_word_type":STLToString(self.keyWordType),
                                              @"url":STLToString([advEventModel advActionUrl]),
                                              @"result_number":@([self.viewModel currentPageGoodsCount]),
                                              kAnalyticsThirdPartId: STLToString(self.viewModel.searchModel.btm_sid) ,
                         };
                 [OSSVAnalyticsTool analyticsSensorsEventWithName:@"SearchRequest" parameters:sensorsDic];
                 [ABTestTools.shared searchRequestWithKeyWord:STLToString(self.keyword) keyWordsType:STLToString(self.keyWordType) resultNumber:[self.viewModel currentPageGoodsCount]];
             }

         } failure:^(id obj) {
              @strongify(self)
             [self.collectionView reloadData];
             [self.collectionView.mj_footer endRefreshing];
         }];
    }];
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        @weakify(self)

        [self.viewModel requestNetwork: @[self.keyword,STLRefresh] completion:^(id obj) {
            @strongify(self)

            // 备注，在不足一页的情况下，在numberOfRowsInSection 做了判断
//            if (self.collectionView.mj_footer.state == MJRefreshStateNoMoreData) {
//                // 此处是对应 mj_footer.state == 不能加载更多后的重置,
//                [self.collectionView.mj_footer resetNoMoreData]; // 暂时是没用到的
//            }
            [self.collectionView reloadData];
            [self.collectionView showRequestTip:@{kTotalPageKey  : @(1),
                                                 kCurrentPageKey: @(0)}];
            OSSVAdvsEventsModel *advEventModel = [[OSSVAdvsEventsModel alloc] init];
            advEventModel.url = self.sourceDeeplinkUrl;
            NSDictionary *sensorsDic = @{@"key_word":STLToString(self.keyword),
                                             @"key_word_type":STLToString(self.keyWordType),
                                         @"url":STLToString([advEventModel advActionUrl]),
                                         @"result_number":@([self.viewModel currentPageGoodsCount]),
                                         kAnalyticsThirdPartId: STLToString(self.viewModel.searchModel.btm_sid) ,
                    };
            [OSSVAnalyticsTool analyticsSensorsEventWithName:@"SearchRequest" parameters:sensorsDic];
            [ABTestTools.shared searchRequestWithKeyWord:STLToString(self.keyword) keyWordsType:STLToString(self.keyWordType) resultNumber:[self.viewModel currentPageGoodsCount]];
            
        } failure:^(id obj) {
             @strongify(self)
            [self.collectionView reloadData];
            [self.collectionView showRequestTip:nil];
        }];
    }];
    
    // 隐藏时间
    header.lastUpdatedTimeLabel.hidden = YES;

    // 隐藏状态
    header.stateLabel.hidden = YES;
    
    self.collectionView.mj_header = header;

//    [self.collectionView.mj_header beginRefreshing];
    
}


#pragma mark - KVO Offset
- (void)scrollerBackToTopAction {
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:kColletionContentOffsetName]) {
        
        CGFloat offset = self.collectionView.contentOffset.y;
        if (offset > STL_COLLECTION_MOVECONTENT_HEIGHT) {
            
            [UIView animateWithDuration: 0.8 delay: 0.4 options: UIViewAnimationOptionCurveEaseInOut animations: ^{
                [self.backToTopButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.bottom.equalTo(@(-10));
                }];
            } completion: ^(BOOL finished) {
                [UIView animateWithDuration: 0.4 animations: ^{
                    self.backToTopButton.alpha = 1.0;
                }];
            }];
        }
        else {
            
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


#pragma mark Notification
//货币改变通知
- (void)changeCurrency:(NSNotification *)notify {
    [self.collectionView reloadData];
}

#pragma mark -
#pragma mark - Action
#pragma mark - 是否要直接返回 rootVC  (暂时储备中)
#pragma mark 监听点击返回
- (BOOL)navigationShouldPopOnBackButton {
    if (self.searchHistoryRefreshBlock) {
        self.searchHistoryRefreshBlock();
    }
    // 这是为了后期的一个效果
     NSArray *viewControlles = self.navigationController.viewControllers;
    if (self.isFromSearchVC && viewControlles.count > 2) {
        UIViewController *realyBackVC = viewControlles[viewControlles.count - 3];
        [self.navigationController popToViewController:realyBackVC animated:YES];
        return NO;
    }
    return YES;
}

#pragma mark 点击头部NavSearchBar Action
- (void)searchTitleButtonAction {
    if (self.isFromSearchVC) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - LazyLoad
- (OSSVSeachsResultsViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[OSSVSeachsResultsViewModel alloc] init];
        _viewModel.controller = self;
        _viewModel.keyword = _keyword;
        _viewModel.keyWordType = STLToString(self.keyWordType);
        _viewModel.deeplinkUrl = STLToString(self.sourceDeeplinkUrl);
        _viewModel.deeplinkId = self.deepLinkId;
        @weakify(self)
        _viewModel.emptyOperationBlock = ^{
            @strongify(self)
            [self.collectionView.mj_header beginRefreshing];
        };
    }
    return _viewModel;
}


- (UIButton *)searchTitleButton {
    if (!_searchTitleButton) {
        _searchTitleButton = [[UIButton alloc]initWithFrame:CGRectMake(25, 27, SCREEN_WIDTH - 50, 30)];
        [_searchTitleButton setTitle:self.keyword forState:UIControlStateNormal];
        [_searchTitleButton setImage:[UIImage imageNamed:@"search_n_icon"] forState:UIControlStateNormal];
        [_searchTitleButton setTitleColor:OSSVThemesColors.col_333333 forState:UIControlStateNormal];
        _searchTitleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_searchTitleButton setImageEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
        [_searchTitleButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
        _searchTitleButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _searchTitleButton.layer.masksToBounds = YES;
        _searchTitleButton.layer.cornerRadius = 2;
        _searchTitleButton.backgroundColor = OSSVThemesColors.col_FFFFFF;
        _searchTitleButton.layer.borderColor = OSSVThemesColors.col_FFFFFF.CGColor;
        _searchTitleButton.layer.borderWidth = 1.0f;
        [_searchTitleButton addTarget:self action:@selector(searchTitleButtonAction) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _searchTitleButton;
}

// 骨架图
- (STLProductListSkeletonView *)productSkeletonView {
    if (!_productSkeletonView) {
        _productSkeletonView = [[STLProductListSkeletonView alloc] init];
        _productSkeletonView.hidden = YES;
    }
    return _productSkeletonView;
}


- (UICollectionView *)collectionView {
    if (!_collectionView) {
        
        CHTCollectionViewWaterfallLayout *waterFallLayout = [[CHTCollectionViewWaterfallLayout alloc] init];
        waterFallLayout.columnCount = 2;
        waterFallLayout.minimumColumnSpacing = 12;
        waterFallLayout.minimumInteritemSpacing = 12;
        waterFallLayout.sectionInset = UIEdgeInsetsMake(12, 12, 0, 12);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:waterFallLayout];
        _collectionView.frame = self.view.bounds;
        _collectionView.showsVerticalScrollIndicator = YES;
        _collectionView.dataSource = self.viewModel;
        _collectionView.delegate = self.viewModel;
        
        _collectionView.emptyDataTitle    = STLLocalizedString_(@"search_blank",nil);
        _collectionView.blankPageImageViewTopDistance = 40;
        _collectionView.emptyDataImage = [UIImage imageNamed:@"search_bank"];
        
        if (APP_TYPE == 3) {
            _collectionView.backgroundColor = [OSSVThemesColors stlWhiteColor];
        } else {
            _collectionView.backgroundColor = [OSSVThemesColors col_F5F5F5];
        }
        [_collectionView registerClass:[OSSVSearchsRecommdHeader class]
                forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"STLSearchRecommendHeader"];

        [_collectionView registerClass:[UICollectionReusableView class]
                forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"UICollectionReusableView"];
    }
    return _collectionView;
}

- (UIButton *)backToTopButton {
    if (!_backToTopButton) {
        _backToTopButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backToTopButton setImage:[UIImage imageNamed:@"back_icon"] forState:UIControlStateNormal];
        [_backToTopButton addTarget:self action:@selector(scrollerBackToTopAction) forControlEvents:UIControlEventTouchUpInside];
        _backToTopButton.alpha = 0;
    }
    return _backToTopButton;
}

- (OSSVSearchResultNavBar *)searchNavbar {
    if (!_searchNavbar) {
        _searchNavbar = [[OSSVSearchResultNavBar alloc] init];
        _searchNavbar.searchKey = self.keyword;
        _searchNavbar.searchField.enabled = NO;
//        _searchNavbar.searchContenView.contentLabel.text = self.keyword;
        _searchNavbar.searchContenView.contentString = self.keyword;

        @weakify(self);
        _searchNavbar.searchInputCancelCompletionHandler = ^{
            @strongify(self);
            
            [self.navigationController popViewControllerAnimated:YES];
            if (self.popCompleteBlock) {
                self.popCompleteBlock();
            }
        };
        
        _searchNavbar.tapSerachBgViewCompletionHandler = ^(NSString *searchKey) {
            @strongify(self);
            if (self.popCompleteWithTextBlock) {
                self.popCompleteWithTextBlock(searchKey);
            }
            [self.navigationController popViewControllerAnimated:NO];
            [OSSVAnalyticsTool analyticsGAEventWithName:@"top_function" parameters:@{
                   @"screen_group":@"SearchResult",
                   @"button_name":@"Search_box"}];
            
        };
        _searchNavbar.searchInputSearchKeyCompletionHandler = ^(NSString *searchKey) {
            @strongify(self);
        };
        
        _searchNavbar.searchInputReturnCompletionHandler = ^(NSString *searchKey) {
            @strongify(self);
            //点击购物车Action
            OSSVCartVC *cartVC = [[OSSVCartVC alloc] init];
            [self.navigationController pushViewController:cartVC animated:YES];
            
            [OSSVAnalyticsTool analyticsGAEventWithName:@"top_function" parameters:@{
                   @"screen_group":@"SearchResult",
                   @"button_name":@"Cart"}];
        };
    }
    return _searchNavbar;
}

- (PrivacySheet *)privacySheet{
    if (!_privacySheet) {
        _privacySheet = [[PrivacySheet alloc] initWithFrame:CGRectZero];
    }
    return _privacySheet;
}


@end
