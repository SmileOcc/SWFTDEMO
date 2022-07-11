//
//  OSSVHomeMainVC.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/3.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVHomeMainVC.h"
#import "OSSVDiscoveyViewModel.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "OSSVThemesMainLayout.h"
#import "OSSVAsinglesAdvCCell.h"
#import "OSSVPrGoodsSPecialCCell.h"
#import "OSSVHomeCCellBanneModel.h"
#import "OSSVScrollCCellModel.h"
#import "OSSVTimeDownCCellModel.h"
#import "OSSVCountsDownCCell.h"
#import "OSSVTopicCCellModel.h"
#import "OSSVHomeTopiicCCell.h"
#import "OSSVAsinglADCellModel.h"
#import "OSSVAPPNewThemeMultiCCellModel.h"
#import "OSSVHomeRecommendToYouCCell.h"
#import "OSSVScrollCCTitleViewModel.h"
#import "OSSVScrollTitlesCCell.h"
#import "OSSVHomeCartsCCellModel.h"
#import "OSSVHomeCartCCell.h"
#import "OSSVThemesChannelsCCell.h"

#import "OSSVScrollAdvBannerCCell.h"
#import "OSSVScrollAdvCCellModel.h"
#import "OSSVSevenAdvBannerCCell.h"
#import "OSSVSevenAdvCCellModel.h"

#import "OSSVCycleSysCCellModel.h"
#import "OSSVHomeCycleSysTipCCell.h"
#import "OSSVFlasttSaleCellModel.h"
#import "OSSVFastSalesCCell.h"
#import "OSSVScrolllGoodsCCell.h"
#import "STLHomeSkeletonView.h"

@interface OSSVHomeMainVC ()<DiscoveryViewModelDataSource,DiscoveryViewModelDelegate>

@property (nonatomic, strong) UICollectionView                      *collectionView;
@property (nonatomic, strong) CHTCollectionViewWaterfallLayout      *waterFallLayout;
@property (nonatomic, strong) UIScrollView                          *emptyBackView;

@property (nonatomic, strong) OSSVDiscoveyViewModel                    *viewModel;

@property (nonatomic, strong) OSSVThemesMainLayout *customerLayout;

@property (nonatomic, copy) NSString *currentTime;//当前时间戳

@property (nonatomic, strong) STLHomeSkeletonView                   *homeSkeletonView; //骨架图
@end

@implementation OSSVHomeMainVC

#pragma mark - Life Cycle

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotif_Currency object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentPageCode = STLToString(self.channelName);
    [self initView];
    //occ阿语适配 阿语时: 外部容器控制器已翻转, 自控制器需要再次翻转显示才正确
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        self.view.transform = CGAffineTransformMakeScale(-1.0,1.0);
    }
    self.viewModel.channelName = STLToString(self.channelName);
    self.viewModel.channelName_en = STLToString(self.channelName_en);
    self.viewModel.channel_id = STLToString(self.channel_id);
    self.viewModel.analyticsDic = @{kAnalyticsAOPSourceKey:STLToString(self.channelName), kAnalyticsAOPSourceID: STLToString(self.channel_id),kHomeDiscoverSubTabIndex:@(0)}.mutableCopy;
        
    [self requestDataWithSkeleton];
    
    [self requestData];

    [self createEmptyViews];

    
    // 汇率改变的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCurrency:) name:kNotif_Currency object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshNoCacheData) name:kNotif_HomeDataRefresh object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //停留时长埋点
    
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a = [date timeIntervalSince1970];
    self.currentTime = [NSString stringWithFormat:@"%0.f", a];//转为字符型
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a = [date timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%0.f", a];//转为字符型
    double time  = timeString.doubleValue - self.currentTime.doubleValue;
    
}
#pragma mark - MakeUI
- (void)initView {

    self.view.backgroundColor = [OSSVThemesColors col_F5F5F5];
    [self.view addSubview:self.collectionView];
    [self.collectionView addSubview:self.homeSkeletonView];

    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [self.homeSkeletonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.mas_equalTo(self.collectionView);
        make.width.equalTo(SCREEN_WIDTH);
        make.height.equalTo(SCREEN_HEIGHT);
    }];
}

#pragma mark - Request
- (void)requestData {

    @weakify(self)
    self.collectionView.mj_footer = [OSSVRefreshsAutosNormalFooter footerWithRefreshingBlock:^{
        @strongify(self)
        [self.viewModel loadMenuData:NO];
    }];
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        @weakify(self)
        [self.viewModel requestBannerDatas:STLRefresh completion:^(id result, BOOL isCache) {
            @strongify(self)
            
            [self.collectionView reloadData];
            [self.collectionView.mj_header endRefreshing];

            self.collectionView.mj_footer.hidden = NO;
            [self.collectionView.mj_footer resetNoMoreData];
            self.emptyBackView.hidden = YES;
            if (result && [result isKindOfClass:[NSNumber class]]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.emptyBackView.hidden = [result boolValue] ? YES : NO;

                    if (self.viewModel.dataSourceList.count > 0) {
                        self.emptyBackView.hidden = YES;
                    } else {
                        self.emptyBackView.hidden = NO;
                        [self.emptyBackView showRequestTip:@{}];

                    }
                });
            } else {
                [self.emptyBackView showRequestTip:@{}];
            }

            if (!isCache) {//不是缓存数据，请求底部推荐商品数据
                [self.viewModel loadMenuData:YES];
            }
            if (self.requestCompleteBlock) {
                self.requestCompleteBlock(YES);
            }

        } failure:^(id obj) {
            @strongify(self)

            self.emptyBackView.hidden = NO;
            if (obj && [obj isKindOfClass:[NSNumber class]]) {
                self.emptyBackView.hidden = [obj boolValue] ? YES : NO;
            }

            if (self.viewModel.dataSourceList.count > 0) {
                self.emptyBackView.hidden = YES;
            }
            [self.collectionView reloadData];
            [self.collectionView.mj_header endRefreshing];

            [self.emptyBackView showRequestTip:nil];


            if (self.requestCompleteBlock) {
                self.requestCompleteBlock(YES);
            }
        }];

    }];
    
    // 隐藏时间
    header.lastUpdatedTimeLabel.hidden = YES;

    // 隐藏状态
    header.stateLabel.hidden = YES;
    
    self.collectionView.mj_header = header;
    //        [self.collectionView.mj_header beginRefreshing];
}
//首次进入请求数据---带入骨架图
- (void)requestDataWithSkeleton {
        @weakify(self)
        [self.viewModel requestBannerDatas:STLRefresh completion:^(id result, BOOL isCache) {
            @strongify(self)
            self.homeSkeletonView.hidden = YES;
            [self.collectionView reloadData];
            self.collectionView.mj_footer.hidden = NO;
            self.emptyBackView.hidden = YES;
            if (result && [result isKindOfClass:[NSNumber class]]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.emptyBackView.hidden = [result boolValue] ? YES : NO;

                    if (self.viewModel.dataSourceList.count > 0) {
                        self.emptyBackView.hidden = YES;

                    } else {
                        self.emptyBackView.hidden = NO;
                        [self.emptyBackView showRequestTip:@{}];

                    }
                });
            } else {
                [self.emptyBackView showRequestTip:@{}];
            }

            if (!isCache) {//不是缓存数据，请求底部推荐商品数据
                [self.viewModel loadMenuData:YES];
            }
            if (self.requestCompleteBlock) {
                self.requestCompleteBlock(YES);
            }

        } failure:^(id obj) {
            @strongify(self)
            self.homeSkeletonView.hidden = YES;

            self.emptyBackView.hidden = NO;
            if (obj && [obj isKindOfClass:[NSNumber class]]) {
                self.emptyBackView.hidden = [obj boolValue] ? YES : NO;
            }

            if (self.viewModel.dataSourceList.count > 0) {
                self.emptyBackView.hidden = YES;
            }
            [self.collectionView reloadData];
            [self.emptyBackView showRequestTip:nil];
            if (self.requestCompleteBlock) {
                self.requestCompleteBlock(YES);
            }
        }];

}

#pragma mark - Notification
//货币改变通知
- (void)changeCurrency:(NSNotification *)notify {
    [self.collectionView reloadData];
}

- (void)refreshNoCacheData {
    self.isCache = NO;
    //取消进入页面就下拉加载
//    if (self.index == 0) {
//        [self.collectionView.mj_header beginRefreshing];
//    }
}

#pragma mark - Action
//重新加载
- (void)emptyOperationTouch {
    self.isCache = NO;
    self.emptyBackView.hidden = YES;
    [self.collectionView.mj_header beginRefreshing];
}


#pragma mark - DiscoveryViewModelDelegate

- (UICollectionView *)stl_DiscoveryCollectionView {
    return self.collectionView;
}

- (OSSVThemesMainLayout *)stl_DiscoveryLayout {
    return self.customerLayout;
}

- (void)stl_DiscoveryScrollViewDidScroll:(UIScrollView *)scrollView {
    
}

- (void)stl_DiscoveryScrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.showFloatBannerBlock) {
        self.showFloatBannerBlock(YES);
    }
}

- (void)stl_DiscoveryScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([scrollView isEqual:self.collectionView]) {
        if (!decelerate && self.showFloatBannerBlock) {
            self.showFloatBannerBlock(YES);
        }
    }
}

- (void)stl_DiscoveryScrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.collectionView]) {
        if (self.showFloatBannerBlock) {
            self.showFloatBannerBlock(NO);
        }
    }
}

- (void)stl_DiscoveryScrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
}

#pragma mark - LazyLoad

- (void)setIsCache:(BOOL)isCache {
    _isCache = isCache;
    self.viewModel.isCache = isCache;
}
- (OSSVDiscoveyViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[OSSVDiscoveyViewModel alloc] init];
        _viewModel.controller = self;
        _viewModel.dataDelegate = self;
        _viewModel.discoverDelegate = self;
        @weakify(self)
        _viewModel.emptyOperationBlock = ^{
            @strongify(self)
            [self.collectionView.mj_header beginRefreshing];
        };
        _viewModel.updateHeaderHeightBlock = ^(CGFloat height) {
            @strongify(self)
            self.waterFallLayout.headerHeight = height;
        };
    }
    return _viewModel;
}

- (UIScrollView *)emptyBackView {
    if (!_emptyBackView) {
        _emptyBackView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _emptyBackView.hidden = YES;
    }
    return _emptyBackView;
}

// 骨架图
- (STLHomeSkeletonView *)homeSkeletonView {
    if (!_homeSkeletonView) {
        _homeSkeletonView = [[STLHomeSkeletonView alloc] init];
        _homeSkeletonView.backgroundColor = [UIColor whiteColor];
    }
    return _homeSkeletonView;
}

- (CHTCollectionViewWaterfallLayout *)waterFallLayout {
    if (!_waterFallLayout) {
        _waterFallLayout = [[CHTCollectionViewWaterfallLayout alloc] init];
        _waterFallLayout.columnCount = 2;
        _waterFallLayout.minimumColumnSpacing = 12;
        _waterFallLayout.minimumInteritemSpacing = 12;
        _waterFallLayout.headerHeight = 0;
    }
    return _waterFallLayout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        self.customerLayout = [[OSSVThemesMainLayout alloc] init];
        self.customerLayout.dataSource = self.viewModel;
        self.customerLayout.delegate = self.viewModel;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.customerLayout];
        
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.dataSource = self.viewModel;
        _collectionView.delegate = self.viewModel;
        _collectionView.backgroundColor = [OSSVThemesColors stlClearColor];
        if (APP_TYPE == 3) {
            _collectionView.backgroundColor = [OSSVThemesColors stlWhiteColor];
        }

        [_collectionView registerClass:[OSSVAsinglesAdvCCell class] forCellWithReuseIdentifier:[OSSVAsingleCCellModel reuseIdentifier]];
        [_collectionView registerClass:[OSSVPrGoodsSPecialCCell class] forCellWithReuseIdentifier:[OSSVProGoodsCCellModel reuseIdentifier]];
        [_collectionView registerClass:[OSSVHomeAdvBannerCCell class] forCellWithReuseIdentifier:[OSSVHomeCCellBanneModel reuseIdentifier]];
        [_collectionView registerClass:[OSSVScrollCCell class] forCellWithReuseIdentifier:[OSSVScrollCCellModel reuseIdentifier]];
        [_collectionView registerClass:[OSSVCountsDownCCell class] forCellWithReuseIdentifier:[OSSVTimeDownCCellModel reuseIdentifier]];
        [_collectionView registerClass:[OSSVHomeTopiicCCell class] forCellWithReuseIdentifier:[OSSVTopicCCellModel reuseIdentifier]];
        [_collectionView registerClass:[OSSVAsinglesAdvCCell class] forCellWithReuseIdentifier:[OSSVAPPNewThemeMultiCCellModel reuseIdentifier]];
        [_collectionView registerClass:[OSSVAsinglesAdvCCell class] forCellWithReuseIdentifier:[OSSVAsinglADCellModel reuseIdentifier]];

        [_collectionView registerClass:[OSSVHomeRecommendToYouCCell class] forCellWithReuseIdentifier:[STLJustForYouCellModel reuseIdentifier]];
        [_collectionView registerClass:[OSSVScrollTitlesCCell class] forCellWithReuseIdentifier:[OSSVScrollCCTitleViewModel reuseIdentifier]];
        [_collectionView registerClass:[OSSVHomeCartCCell class] forCellWithReuseIdentifier:[OSSVHomeCartsCCellModel reuseIdentifier]];
        [_collectionView registerClass:[OSSVThemesChannelsCCell class] forCellWithReuseIdentifier:[OSSVHomeChannelCCellModel reuseIdentifier]];
        [_collectionView registerClass:[OSSVHomeCycleSysTipCCell class] forCellWithReuseIdentifier:[OSSVCycleSysCCellModel reuseIdentifier]];
        
        [_collectionView registerClass:[OSSVScrollAdvBannerCCell class] forCellWithReuseIdentifier:[OSSVScrollAdvCCellModel reuseIdentifier]];
        [_collectionView registerClass:[OSSVSevenAdvBannerCCell class] forCellWithReuseIdentifier:[OSSVSevenAdvCCellModel reuseIdentifier]];
        [_collectionView registerClass:[OSSVFastSalesCCell class] forCellWithReuseIdentifier:[OSSVFlasttSaleCellModel reuseIdentifier]];
        [_collectionView registerClass:[OSSVScrolllGoodsCCell class] forCellWithReuseIdentifier:[OSSVScrollGoodsItesCCellModel reuseIdentifier]];
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass(UICollectionViewCell.class)];


    }
    return _collectionView;
}


#pragma mark - 空白View
- (void)createEmptyViews {
    
    [self.view addSubview:self.emptyBackView];
    self.emptyBackView.blankPageImageViewTopDistance = 40;
    self.emptyBackView.emptyDataImage = [UIImage imageNamed:@"error_bank"];
    if (APP_TYPE == 3) {
        self.emptyBackView.emptyDataBtnTitle = STLLocalizedString_(@"retry", nil);
    } else {
        self.emptyBackView.emptyDataBtnTitle = STLLocalizedString_(@"retry", nil).uppercaseString;
    }
    
    @weakify(self)
    self.emptyBackView.blankPageViewActionBlcok = ^(STLBlankPageViewStatus status) {
        @strongify(self)
        [self.collectionView.mj_header beginRefreshing];
    };
}

@end
