//
//  OSSAPPThemesMainView.m
// OSSAPPThemesMainView
//
//  Created by odd on 2021/3/25.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSAPPThemesMainView.h"
#import "OSSVThemesSpecialsAip.h"
#import "OSSVHomesCouponsAip.h"
#import "OSSVThemesSpecialActiviyAip.h"

#import "OSSVCartVC.h"
#import "OSSVDetailsVC.h"
#import "OSSVCategorysNewZeroListVC.h"
#import "OSSVAppNewThemeVC.h"

#import "OSSVAddCollectApi.h"
#import "OSSVDelCollectApi.h"
#import "OSSVThemesCouponsCCell.h"
@interface OSSAPPThemesMainView ()<STLThemeManagerViewProtocol>

//17表示单列分页商品，18表示双列分页商品
@property(nonatomic, assign) NSInteger             recommendType;
@property(nonatomic, assign) NSInteger             ranking;
@property (nonatomic, assign) NSInteger            page;
@property (nonatomic, strong) NSMutableArray       *recommedDatas;
@property (nonatomic, assign) BOOL                 hasFirtFlash;
@property (nonatomic, copy)  NSString              *titleName; //传入商品列表的标题
@property (nonatomic, assign) NSInteger          rankType;// 排行榜类型

// 跳到商品详情页的时候要暂时保留的数据 因为商品详情页里面有收藏
@property (nonatomic, strong) STLHomeCGoodsModel    *rankGoodsModel;
@property (nonatomic, strong) NSIndexPath           *rankIndexPath;
@end

@implementation OSSAPPThemesMainView


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidShow {
    self.rankGoodsModel = nil;
    self.rankIndexPath = nil;
}

- (instancetype)initWithFrame:(CGRect)frame
                 firstChannel:(NSString *)firstChannel
                      channel:(NSString *)channel
                        title:(NSString *)title {
    self = [super initWithFrame:frame];
    if (self) {
        self.page = 1;
        self.title = title;
        self.customId = channel;
        
        [[OSSVAnalyticInjectsManager shareInstance] analyticsInject:self injectObject:self.themeAnalyticsAOP];

        
        self.themeAnalyticsAOP.sourceKey = self.customId;
        self.themeAnalyticsAOP.sourecDic = @{kAnalyticsAOPSourceID: STLToString(self.customId)};
        
        [self stlInitView];
        [self stlAutoLayoutView];
        [self addNotification];
        self.viewModel.isShowLoad = YES;
        [self requestCustomData:NO];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
                 firstChannel:(NSString *)firstChannel
                      channel:(NSString *)channel
                     deeplink:(NSString *)deepLink
                        title:(NSString *)title {
    self = [super initWithFrame:frame];
    if (self) {
        self.page = 1;
        self.title = title;
        self.customId = channel;
        self.deepLinkId = deepLink;
        
        [[OSSVAnalyticInjectsManager shareInstance] analyticsInject:self injectObject:self.themeAnalyticsAOP];

        
        self.themeAnalyticsAOP.sourceKey = self.customId;
        self.themeAnalyticsAOP.sourecDic = @{kAnalyticsAOPSourceID: STLToString(self.customId)}.mutableCopy;
        
        [self stlInitView];
        [self stlAutoLayoutView];
        [self addNotification];
        self.viewModel.isShowLoad = YES;
        [self requestCustomData:NO];
    }
    return self;
}

#pragma mark - STLInitViewProtocol

- (void)stlInitView{
    [self addSubview:self.themeManagerView];
}

- (void)stlAutoLayoutView{
    [self.themeManagerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self).insets(UIEdgeInsetsZero);
    }];
}

- (void)addNotification {
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(insertGoodsToHistoryFromAdGroup) name:kAdGroupGoodsKey object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCurrency) name:kCurrencyNotification object:nil];
//    // 登录刷新通知
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loginChangeCollectionRefresh) name:kLoginNotification object:nil];
    // 收藏刷新的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFavoriteValues:) name:kNotif_Favorite object:nil];
}


#pragma mark ---原生专题数据请求
-(void)requestCustomData:(BOOL)isLoadMore
{
    
    @weakify(self)
//    [self.viewModel themeRequest:@{@"specialId":STLToString(self.customId)} completion:^(id  _Nonnull result, BOOL isCache, BOOL isEqualData) {
    NSDictionary *parm = nil;
    if (![OSSVNSStringTool isEmptyString:self.deepLinkId]) {
        parm = @{@"specialId":STLToString(self.customId), @"deep_link_id":STLToString(self.deepLinkId)};
    }else{
        parm = @{@"specialId":STLToString(self.customId)};
    }
    [self.viewModel themeOldRequest:parm completion:^(id  _Nonnull result, BOOL isCache, BOOL isEqualData) {

        @strongify(self)
        self.viewModel.isShowLoad = NO;
        [self.themeManagerView endHeaderOrFooterRefresh:!isLoadMore];
        self.recommendType = 0;
        self.ranking = 0;
        self.isChannel = NO;
        self.titleName = @"";
        [self.themeManagerView clearDatas];
        
        NSMutableArray *dataSourceList = [[NSMutableArray alloc] init];
        [self.recommedDatas removeAllObjects];
        if (result && [result isKindOfClass:[OSSVThemesMainsModel class]]) {
            
            OSSVThemesMainsModel *resultModel = (OSSVThemesMainsModel *)result;

            NSDictionary *pageProtogene = resultModel.pageProtogene;
            self.recommendType = [pageProtogene[@"type"] integerValue];
            self.ranking = [pageProtogene[@"ranking"] integerValue];
            NSArray *modellist = [NSArray yy_modelArrayWithClass:[OSSVHomeCThemeModel class] json:resultModel.mutiProtogene];
            NSString *specialName = STLToString(resultModel.specialName);
            self.viewController.title = specialName;
            self.titleName = specialName;
            
            NSString *specialColor = STLToString(resultModel.bg_color);
            if (!STLIsEmptyString(specialColor)) {
                self.themeManagerView.bgColor = [UIColor colorWithHexColorString:specialColor];
            }
            
            if ([modellist isKindOfClass:[NSArray class]]) {
                
                [modellist enumerateObjectsUsingBlock:^(OSSVHomeCThemeModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    OSSVHomeCThemeModel *themeModel = obj;
                    if (themeModel.type == 12) { //0元活动
                        OSSVAsinglViewMould *singleModule = [[OSSVAsinglViewMould alloc] init];
                        OSSVThemesZeroActivyCellModel *scrollerCellModel = [[OSSVThemesZeroActivyCellModel alloc] init];
                        scrollerCellModel.dataSource = themeModel.exchange;
                        scrollerCellModel.bg_color = themeModel.bg_color;
                        scrollerCellModel.size = [OSSVThemeZeorsActivyCCell itemSize:themeModel.exchange.count];

                        [singleModule.sectionDataList addObject:scrollerCellModel];
                        [dataSourceList addObject:singleModule];
                    }

                    if (themeModel.type == 1) {//商品类型
                        OSSVWaterrFallViewMould *waterModule = [[OSSVWaterrFallViewMould alloc] init];
                        [themeModel.goodsList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            OSSVProGoodsCCellModel *proCellModel = [[OSSVProGoodsCCellModel alloc] init];
                            proCellModel.dataSource = obj;
                            [waterModule.sectionDataList addObject:proCellModel];
                        }];
                        [dataSourceList addObject:waterModule];
                    }

                    if (themeModel.type == 14) {//三列商品
                        OSSVMultiColumnsGoodItemsViewMould *waterModule = [[OSSVMultiColumnsGoodItemsViewMould alloc] init];
                        [themeModel.goodsList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            OSSVMultProGoodsCCellModel *proCellModel = [[OSSVMultProGoodsCCellModel alloc] init];
                            proCellModel.dataSource = obj;
                            [waterModule.sectionDataList addObject:proCellModel];
                        }];
                        [dataSourceList addObject:waterModule];
                    }
                    if (themeModel.type == 2) {//图片类型
                        OSSVCustomThemeMultiMould *asingleCellModule = [[OSSVCustomThemeMultiMould alloc] init];
                        [themeModel.modeImg enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            OSSVAPPNewThemeMultiCCellModel *asingleCellModel = [[OSSVAPPNewThemeMultiCCellModel alloc] init];
                            asingleCellModel.dataSource = obj;
                            [asingleCellModule.sectionDataList addObject:asingleCellModel];
                        }];
                        [dataSourceList addObject:asingleCellModule];
                    }
                    if (themeModel.type == 6) {//商品滑动样式数据
                        
                        if (themeModel.slideList.count > 0) {

                            themeModel.imageScale = 3/4.0;
                            NSInteger imageScale = 0;
                            
                            // 宽高
                            for (int i=0; i<themeModel.slideList.count; i++) {
                                OSSVHomeGoodsListModel *objModel = themeModel.slideList[i];
                                objModel.specialId = STLToString(themeModel.specialId);
                                if (objModel.goods_img_w > 0 && objModel.goods_img_w == objModel.goods_img_h) {
                                    imageScale++;
                                } else {
                                    imageScale--;
                                }
                            }
                            if (imageScale > 0) {
                                themeModel.imageScale = 1.0;
                            }

                            OSSVAsinglViewMould *scrollGoodsModule = [[OSSVAsinglViewMould alloc] init];
                            OSSVScrollGoodsItesCCellModel *goodsItemCellModel = [[OSSVScrollGoodsItesCCellModel alloc] init];
                            goodsItemCellModel.size = [OSSVScrolllGoodsCCell itemSize:themeModel.imageScale];
                            goodsItemCellModel.subItemSize = [OSSVScrolllGoodsCCell subItemSize:themeModel.imageScale];
                            goodsItemCellModel.dataSource = themeModel;
                            [scrollGoodsModule.sectionDataList addObject:goodsItemCellModel];
                            [dataSourceList addObject:scrollGoodsModule];
                            
                        }
                        
                        
                        
                    }
                    if (themeModel.type == 8) {//优惠券类型
                        OSSVCustomThemeMultiMould *asingleCellModule = [[OSSVCustomThemeMultiMould alloc] init];
                        
                        for (STLAdvEventSpecialModel *obj in themeModel.modeImg) {
                            OSSVAPPNewThemeMultiCCellModel *asingleCellModel = [[OSSVAPPNewThemeMultiCCellModel alloc] init];
                            asingleCellModel.dataSource = obj;
                            [asingleCellModule.sectionDataList addObject:asingleCellModel];
                            [self.themeManagerView.allCoupons addObject:obj];
                        }
                        [dataSourceList addObject:asingleCellModule];
                    }

                    //新人页免费商品领取 11 已移除模块1.2.8
                    
                    if (themeModel.type == 13) {//一键领取
                        
                        OSSVDiscoverBlocksModel *discovBlockModel = [[OSSVDiscoverBlocksModel alloc] init];
                        discovBlockModel.specialModelBanner = themeModel.couponButton;
                        discovBlockModel.type = @"1";
                        OSSVMutilBranchMould *branchModule = [[OSSVMutilBranchMould alloc] init];
                        branchModule.isNewBranch = YES;
                        branchModule.discoverBlockModel = discovBlockModel;
                        
                        OSSVAsingleCCellModel *cellModel = [[OSSVAsingleCCellModel alloc] init];
                        cellModel.dataSource = discovBlockModel.specialModelBanner;
                        [branchModule.sectionDataList addObject:cellModel];
                        
                        [dataSourceList addObject:branchModule];

                    }
                    
                    if (themeModel.type == 16 && themeModel.goodsList.count > 0) {//商品排名模块
                        
                        OSSVAsinglViewMould *singleModule = [[OSSVAsinglViewMould alloc] init];
                        OSSVThemeItemGoodsRanksModuleModel *rankModuleModel = [[OSSVThemeItemGoodsRanksModuleModel alloc] init];
                        rankModuleModel.size = [OSSVThemeGoodsItesRankModuleCCell itemSize:themeModel.goodsList.count];
                        rankModuleModel.subItemSize = [OSSVThemeGoodsItesRankModuleCCell subItemSize];
                        rankModuleModel.dataSource = themeModel;
                        [singleModule.sectionDataList addObject:rankModuleModel];
                        [dataSourceList addObject:singleModule];

                    }
        
                    
                    if (themeModel.type == 7 && themeModel.channel.count > 0) {//频道页数据
                        OSSVAsinglViewMould *singleModule = [[OSSVAsinglViewMould alloc] init];
                        OSSVHomeChannelCCellModel *singleCellModel = [[OSSVHomeChannelCCellModel alloc] init];
                        singleCellModel.dataSource = themeModel;
                        [singleModule.sectionDataList addObject:singleCellModel];
                        [dataSourceList addObject:singleModule];
                        
                        ///频道页下面的商品列表
                        OSSVWaterrFallViewMould *module = [[OSSVWaterrFallViewMould alloc] init];
                        ///取第一个设置成显示的
                        STLHomeCThemeChannelModel *channelModel = [themeModel.channel firstObject];
                        for (int i = 0; i < [channelModel.goodsList count]; i++) {
                            OSSVProGoodsCCellModel *proCellModel = [[OSSVProGoodsCCellModel alloc] init];
                            proCellModel.dataSource = channelModel.goodsList[i];
                            [module.sectionDataList addObject:proCellModel];
                        }
                        //设置悬浮窗显示属性
                        self.isChannel = YES;
                        self.themeManagerView.isChannel = YES;
                        [dataSourceList addObject:module];
                        //把第一次获取的数据存储到cacheModel里
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            for (int i = 0; i < [themeModel.channel count]; i++) {
                                NSMutableArray *sectionDataList = [[NSMutableArray alloc] init];
                                STLHomeCThemeChannelModel *channel = themeModel.channel[i];
                                for (int j = 0; j < [channel.goodsList count]; j++) {
                                    OSSVProGoodsCCellModel *productCellModel = [[OSSVProGoodsCCellModel alloc] init];
                                    productCellModel.dataSource = channel.goodsList[j];
                                    [sectionDataList addObject:productCellModel];
                                }
                                [self.themeManagerView firstSaveProductList:i list:sectionDataList sort:channel.channelSort];
                            }
                        });
                    }
                    
                    // 1.4.0 新人礼页面 优惠券组件
                    if (themeModel.type == 20) {
                        OSSVAsinglViewMould *scrollCouponsModule = [[OSSVAsinglViewMould alloc] init];
                        OSSVThemeCouponCCellModel *couponsItemCellModel = [[OSSVThemeCouponCCellModel alloc] init];
                        couponsItemCellModel.size = [OSSVThemesCouponsCCell itemSize:themeModel.imageScale];
                        couponsItemCellModel.dataSource = themeModel;
                        [scrollCouponsModule.sectionDataList addObject:couponsItemCellModel];
                        [dataSourceList addObject:scrollCouponsModule];
                    }
                    
                    if (themeModel.type == 19) {
                        OSSVAsinglViewMould *singleModule = [[OSSVAsinglViewMould alloc] init];
                        OSSVThemeZeroActivyTwoCCellModel *scrollerCellModel = [[OSSVThemeZeroActivyTwoCCellModel alloc] init];
                        scrollerCellModel.cart_exits = themeModel.cart_exists;
                        scrollerCellModel.type = themeModel.type;
                        scrollerCellModel.dataSource = themeModel.exchange;
                        scrollerCellModel.bg_color = themeModel.bg_color;
                        scrollerCellModel.size = [OSSVZeroActivyDoulesLineCCell itemSize:themeModel.exchange.count];

                        [singleModule.sectionDataList addObject:scrollerCellModel];
                        [dataSourceList addObject:singleModule];
                    }
                }];
            }
            
            if (self.isChannel) {// 有商品分类导航 在里面控制 是否加载更多
                [self addFooterLoadingMore:YES];
            } else {
                // 设置是否上拉加载
                BOOL showFooter = self.recommendType > 0 ? YES : NO;
                [self addFooterLoadingMore:showFooter];
                
                if (showFooter) {
                    [self loadActivityGoods:NO];
                }
            }
        }
        
        self.themeManagerView.dataSourceList = [[NSMutableArray alloc] initWithArray:dataSourceList];
        if (!self.isChannel && self.recommendType > 0) {
            self.themeManagerView.emptyShowType = EmptyViewShowTypeHide;
        } else {
            self.themeManagerView.emptyShowType = dataSourceList.count > 0 ? EmptyViewShowTypeHide : EmptyViewShowTypeNoData;
        }
        [self.themeManagerView.themeCollectionView reloadData];
        
    } failure:^(id _Nonnull msg) {
        @strongify(self)
        
        if (self.themeManagerView.dataSourceList.count > 0) {
            
        } else {
            self.themeManagerView.emptyShowType = EmptyViewShowTypeNoNet;
        }
        
        [self.themeManagerView endHeaderOrFooterRefresh:!isLoadMore];
        [self.themeManagerView.themeCollectionView reloadData];

    }];

//    [self.operations addObject:api];
}

- (void)loadMenuGoods:(BOOL)isLoadMore {
    
    NSInteger currentIndex = self.themeManagerView.menuView.selectIndex;
    OSSVCustThemePrGoodsListCacheModel *cacheModel = [self.themeManagerView.customProductListCache objectForKey:@(currentIndex)];
    @weakify(self)
    [cacheModel pageOnThePullRequestCustomeId:self.customId complation:^(NSInteger index, NSArray *result) {
        @strongify(self)
        [self.themeManagerView endHeaderOrFooterRefresh:!isLoadMore];

        if (currentIndex == index) {
            ///当获取到数据后，用户切换了menu index，就不设置数据源
            id<CustomerLayoutSectionModuleProtocol>module = [self.themeManagerView.dataSourceList lastObject];
            [module.sectionDataList addObjectsFromArray:result];
            [self.themeManagerView.layout inserSection:[self.themeManagerView.dataSourceList count] - 1];
            [self.themeManagerView.themeCollectionView performBatchUpdates:^{
                [self.themeManagerView.themeCollectionView reloadSections:[NSIndexSet indexSetWithIndex:[self.themeManagerView.dataSourceList count] - 1]];
            } completion:NULL];
            [self.themeManagerView menuEndfootRefresh];
        }
    }];
}

- (void)loadActivityGoods:(BOOL)isLoadMore {// 没有导航分类处理
    
    NSInteger page = isLoadMore ? self.page+1 : 1;
//    self.recommendType = 18;
    @weakify(self)
//    [self.viewModel themeActivityGoodsRequest:@{@"specialId":STLToString(self.customId),
//                                                @"type":@(self.recommendType),
//                                                @"page":@(page),
//                                                }
//                                   completion:^(id  _Nonnull result, BOOL isRanking) {
    [self.viewModel themeOldActivityGoodsRequestWithType:@{@"specialId":STLToString(self.customId),
                                                @"type":@(self.recommendType),
                                                @"page":@(page),
                                                }
                                   completion:^(id  _Nonnull result, BOOL isRanking, NSInteger ranking_type) {
        @strongify(self)
        [self.themeManagerView endHeaderOrFooterRefresh:!isLoadMore];

        if (result && STLJudgeNSArray(result)) {
            self.page = page;
            NSArray *resultArr = (NSArray *)result;
            
            NSInteger count = self.recommedDatas.count;
            [self.recommedDatas addObjectsFromArray:result];
            
            self.rankType = ranking_type;
            if (self.recommendType == 17) {
                
                for (int i=0; i<resultArr.count; i++) {
                    id objModel = resultArr[i];
                    
                    if (self.ranking != 0 && [objModel isKindOfClass:[STLHomeCGoodsModel class]]) {
                        STLHomeCGoodsModel *goodsModel = (STLHomeCGoodsModel *)objModel;
//                        goodsModel.ranking = isRanking ? 1 : 0;
                        goodsModel.ranking = self.ranking;
                        goodsModel.rankIndex = count + i + 1;
                        goodsModel.rankType = self.rankType;
                    }
                    OSSVAsinglViewMould *goodsAsingleModule = [[OSSVAsinglViewMould alloc] init];
                    OSSVThemeItemsGoodsRanksCCellModel *rankCCellModel = [[OSSVThemeItemsGoodsRanksCCellModel alloc] init];
                    rankCCellModel.size = [OSSVThemeGoodsItesRankModuleCCell subItemSize];
                    rankCCellModel.dataSource = objModel;
                    [goodsAsingleModule.sectionDataList addObject:rankCCellModel];
                    [self.themeManagerView.dataSourceList addObject:goodsAsingleModule];
                }
            } else if(self.recommendType == 18) {
                
                if (isLoadMore) {
                    id<CustomerLayoutSectionModuleProtocol>module = [self.themeManagerView.dataSourceList lastObject];
                    
                    //防止最后一个不是瀑布流模块
                    if (![module isKindOfClass:[OSSVWaterrFallViewMould class]]) {
                        module = [[OSSVWaterrFallViewMould alloc] init];
                        for (int i=0; i<resultArr.count; i++) {
                            OSSVProGoodsCCellModel *proCellModel = [[OSSVProGoodsCCellModel alloc] init];
                            proCellModel.dataSource = resultArr[i];
                            [module.sectionDataList addObject:proCellModel];
                        }
                        [self.themeManagerView.dataSourceList addObject:module];
                    } else {

                        for (int i=0; i<resultArr.count; i++) {
                            OSSVProGoodsCCellModel *proCellModel = [[OSSVProGoodsCCellModel alloc] init];
                            proCellModel.dataSource = resultArr[i];
                            [module.sectionDataList addObject:proCellModel];
                        }
                        
                        [self.themeManagerView.layout inserSection:[self.themeManagerView.dataSourceList count] - 1];
                        [self.themeManagerView.themeCollectionView performBatchUpdates:^{
                            [self.themeManagerView.themeCollectionView reloadSections:[NSIndexSet indexSetWithIndex:[self.themeManagerView.dataSourceList count] - 1]];
                        } completion:NULL];
                        
                    }
//
                } else {
                    
                    OSSVWaterrFallViewMould *goodsModule = [[OSSVWaterrFallViewMould alloc] init];
                    [self.themeManagerView.dataSourceList addObject:goodsModule];
                    for (int i=0; i<resultArr.count; i++) {
                        OSSVProGoodsCCellModel *proCellModel = [[OSSVProGoodsCCellModel alloc] init];
                        proCellModel.dataSource = resultArr[i];
                        [goodsModule.sectionDataList addObject:proCellModel];
                    }
                }
                
                
            }
            if (resultArr.count <= 0) {
                [self.themeManagerView.themeCollectionView.mj_footer endRefreshingWithNoMoreData];

            }
        }
        
        self.themeManagerView.emptyShowType = self.themeManagerView.dataSourceList.count > 0 ? EmptyViewShowTypeHide : EmptyViewShowTypeNoData;
        [self.themeManagerView reloadView:YES];

        
    } failure:^(id _Nonnull msg) {
        @strongify(self)
        [self.themeManagerView endHeaderOrFooterRefresh:!isLoadMore];
        
        self.themeManagerView.emptyShowType = self.themeManagerView.dataSourceList.count > 0 ? EmptyViewShowTypeHide : EmptyViewShowTypeNoData;
        [self.themeManagerView reloadView:YES];

    }];
}


/** 初始化下拉刷新控件 */
- (void)addListViewRefreshKit {
    BOOL shouldRequest = NO;
    
    @weakify(self)
    [self.themeManagerView addListHeaderRefreshBlock:^{
        @strongify(self)
        // 列表 顶部广告banner等数据
        BOOL showLoading = (self.themeManagerView.dataSourceList.count == 0);
        [self requestCustomData:showLoading];
        
        //统计下拉或者分页的埋点
        [OSSVAnalyticsTool analyticsSensorsEventWithName:@"LoadingRefresh" parameters:@{@"method": @"1"}];
    } PullingShowBannerBlock:^{
        //@strongify(self)
        //[self actionDropBanner];
    } footerRefreshBlock:nil startRefreshing:NO];
    
    if (shouldRequest) { //加载时取消动画
        [self.themeManagerView.themeCollectionView headerRefreshingByAnimation:NO];
    }
}

/**
 * 设置是否能上拉加载更多
 */
- (void)addFooterLoadingMore:(BOOL)showLoadingMore {
    @weakify(self)
    [self.themeManagerView addFooterLoadingMore:showLoadingMore footerBlock:^{
        @strongify(self)
        if (self.isChannel) {
            [self loadMenuGoods:YES];
        } else {
            // 列表 底部推荐商品数据
            [self loadActivityGoods:YES];
        }
        
        //统计下拉或者分页的埋点
        [OSSVAnalyticsTool analyticsSensorsEventWithName:@"LoadingRefresh" parameters:@{@"method": @"0"}];
    }];
}

#pragma mark - STLThemeManagerViewProtocol

/** 0元、新用户商品*/
- (void)stl_themeManagerView:(OSSVAPPThemeHandleMangerView *)managerView collectionView:(UICollectionView *)collectionView themeCell:(UICollectionViewCell *)cell itemCell:(UICollectionViewCell *)itemCell isMore:(BOOL)isMore {
    
    if ([cell isKindOfClass:[OSSVThemeZeorsActivyCCell class]]) {//0元
        if (itemCell && [itemCell isKindOfClass:[STLThemeZeorGoodsItemCell class]]) {
            STLThemeZeorGoodsItemCell *zeorCell = (STLThemeZeorGoodsItemCell *)itemCell;
            [self themeZeorActivity:(OSSVThemeZeroPrGoodsModel *)zeorCell.model isMore:isMore];
        }
    } else if([cell isKindOfClass:[OSSVScrollCCell class]]) {//秒杀
        [self themeScrollerCell:(OSSVScrollCCell *)cell itemCell:itemCell];
        
    } else if([cell isKindOfClass:[OSSVAsinglesAdvCCell class]]) {//广告
        OSSVAsinglesAdvCCell *asingleCell = (OSSVAsinglesAdvCCell *)cell;
        [self themeAdvCell:asingleCell contentModel:asingleCell.model.dataSource];
        
    } else if([cell isKindOfClass:[OSSVScrolllGoodsCCell class]]) {//滑动商品
        STLScrollerGoodsItemCell *goodsItemCell = (STLScrollerGoodsItemCell *)itemCell;
        [self themeScrollGoodCell:goodsItemCell contentModel:goodsItemCell.model isMore:isMore];
        
    } else if([cell isKindOfClass:[OSSVThemeGoodsItesRankModuleCCell class]]) {//商品排行组件
        if ([itemCell isKindOfClass:[OSSVThemeGoodsItesRankCCell class]]) {
            OSSVThemeGoodsItesRankCCell *rankCell = (OSSVThemeGoodsItesRankCCell *)itemCell;
            [self themeRankModuleGoodCell:rankCell contentModel:rankCell.model isMore:NO];
        }
    } else if([cell isKindOfClass:[OSSVThemeGoodsItesRankCCell class]]) {//商品排行列表
        OSSVThemeGoodsItesRankCCell *rankCell = (OSSVThemeGoodsItesRankCCell *)itemCell;
        [self themeRankModuleGoodCell:rankCell contentModel:rankCell.model isMore:NO];
    } else if ([cell isKindOfClass:[OSSVZeroActivyDoulesLineCCell class]]){
        OSSVZeroActivyDoulesLineCCell *doubleLinesCell = (OSSVZeroActivyDoulesLineCCell *)itemCell;
        [self themeZeorActivity:(OSSVThemeZeroPrGoodsModel *)doubleLinesCell.model isMore:isMore];
    }
}

- (void)stl_themeManagerView:(OSSVAPPThemeHandleMangerView *)managerView collectionView:(UICollectionView *)collectionView themeCell:(UICollectionViewCell *)cell itemCell:(UICollectionViewCell *)itemCell addCart:(id)model {
    if ([cell isKindOfClass:[OSSVThemeGoodsItesRankCCell class]]) {//底部可以加载的
        if (model && [model isKindOfClass:[STLHomeCGoodsModel class]]) {
            
            NSInteger index=0;
            if(self.recommedDatas) {
                index = [self.recommedDatas indexOfObject:model];
            }
            /////
            [self showGoodsAttribute:model index:index];
        }
    } else if(itemCell && [cell isKindOfClass:[OSSVThemeGoodsItesRankModuleCCell class]]) { //列表组件
        NSInteger index=0;
        if (cell && [cell isKindOfClass:[OSSVThemeGoodsItesRankModuleCCell class]]) {
            OSSVThemeGoodsItesRankModuleCCell *rankModuleCell = (OSSVThemeGoodsItesRankModuleCCell *)cell;
            
            NSIndexPath *currentIndexPath  = [rankModuleCell.collectionView indexPathForCell:itemCell];
            index=currentIndexPath.row;
        }
        [self showGoodsAttribute:model index:index];

    }else if (itemCell && [cell isKindOfClass:[OSSVZeroActivyDoulesLineCCell class]]){
        OSSVZeroActivyDoulesLineCCell *doubleLinesCell = (OSSVZeroActivyDoulesLineCCell *)cell;
        if (model && [model isKindOfClass:[OSSVThemeZeroPrGoodsModel class]]) {
            NSInteger index=0;
            NSIndexPath *indexPath = [doubleLinesCell.collectionView indexPathForCell:itemCell];
            index = indexPath.item;
            /////
            [self showGoodsAttribute:model index:index];
        }
    }
}

- (void)stl_themeManagerView:(OSSVAPPThemeHandleMangerView *)managerView collectionView:(UICollectionView *)collectionView themeCell:(UICollectionViewCell *)cell itemCell:(UICollectionViewCell *)itemCell addWishList:(id)model{
    if ([OSSVAccountsManager sharedManager].isSignIn) {
        if ([cell isKindOfClass:[OSSVThemeGoodsItesRankCCell class]]) {
            if (model && [model isKindOfClass:[STLHomeCGoodsModel class]]) {
                ///收藏或者取消收藏
                NSIndexPath *index = [collectionView indexPathForCell:cell];
                [self showWishListAttribute:model withIndex:index];
            }
        }
    }else{
        // 登录
        SignViewController *signVC = [SignViewController new];
        signVC.modalPresentationStyle = UIModalPresentationFullScreen;
        @weakify(self)
        signVC.modalBlock = ^{
            @strongify(self)
            // 重新请求一下接口
            [self requestCustomData:NO];
        };
        [self.navigationController presentViewController:signVC animated:YES completion:nil];
    }
    
}

/** 商品详情*/
- (void)stl_themeManagerView:(OSSVAPPThemeHandleMangerView *)managerView collectionView:(UICollectionView *)collectionView themeCell:(UICollectionViewCell *)cell goodsModel:(STLHomeCGoodsModel *)goodsModel {
    
    if ([goodsModel isKindOfClass:[STLHomeCGoodsModel class]]) {
        STLHomeCGoodsModel *productModel = (STLHomeCGoodsModel *)goodsModel;
        OSSVDetailsVC *goodsDetailsVC = [[OSSVDetailsVC alloc] init];
        if (!STLIsEmptyString(productModel.goodsId)) {
            goodsDetailsVC.goodsId = productModel.goodsId;
        }
        if (!STLIsEmptyString(productModel.goods_id)) {
            goodsDetailsVC.goodsId = productModel.goods_id;
        }

        goodsDetailsVC.wid = productModel.wid;
        goodsDetailsVC.coverImageUrl = productModel.goods_original;
        goodsDetailsVC.sourceType = STLAppsflyerGoodsSourceThemeActivity;
        
        NSInteger index=0;
        if(self.recommedDatas) {
            index = [self.recommedDatas indexOfObject:goodsModel];
        }
        NSDictionary *dic = @{kAnalyticsAction:[OSSVAnalyticsTool sensorsSourceStringWithType:STLAppsflyerGoodsSourceThemeActivity sourceID:@""],
                              kAnalyticsUrl:STLToString(self.customId),
                              kAnalyticsPositionNumber:@(index+1),
        };
        [goodsDetailsVC.transmitMutDic addEntriesFromDictionary:dic];
        [self.navigationController pushViewController:goodsDetailsVC animated:YES];
        
        self.rankGoodsModel = goodsModel;
        self.rankIndexPath = [collectionView indexPathForCell:cell];
        
        return;
    }
}

/** 领取优惠券*/
- (void)stl_themeManagerView:(OSSVAPPThemeHandleMangerView *)managerView collectionView:(UICollectionView *)collectionView themeCell:(UICollectionViewCell *)cell getCoupons:(NSString *)couponsString {
    if ([cell isKindOfClass:OSSVThemesCouponsCCell.class]) {
        [self themeCouponGet:couponsString isNewCoupons:YES];
    }else{
        [self themeCouponGet:couponsString isNewCoupons:NO];
    }
    
}



/** 只是用于统计*/
- (void)stl_themeManagerView:(OSSVAPPThemeHandleMangerView *)managerView collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

/** 只是用于统计*/
- (void)stl_themeManagerView:(OSSVAPPThemeHandleMangerView *)managerView collectionView:(UICollectionView *)collectionView didSelectItemCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - private

/// 0元活动
- (void)themeZeorActivity:(OSSVThemeZeroPrGoodsModel *)model isMore:(BOOL)isMore{
    
    if (isMore) {
        OSSVThemeZeroPrGoodsModel *productModel = model;
        OSSVCategorysNewZeroListVC *ctrl = [[OSSVCategorysNewZeroListVC alloc] init];
        ctrl.specialId = productModel.specialId;
        NSString *type = nil;
        if (model.type > 0) {
            type = [NSString stringWithFormat:@"%ld", model.type];
        }else{
            type = @"12";
        }
        ctrl.type      = type;
        ctrl.titleName = self.titleName;
        ctrl.isFromZeroYuan = YES;
        [self.navigationController pushViewController:ctrl animated:YES];
        return;
    }
    if (![OSSVAccountsManager sharedManager].isSignIn) {
        
//        SignViewController *sign = [SignViewController new];
//        sign.modalPresentationStyle = UIModalPresentationFullScreen;
//        @weakify(self)
//        //如果登录后自动执行，可以在block中填写代码
//        sign.signBlock = ^{
//            @strongify(self)
            OSSVThemeZeroPrGoodsModel *productModel = model;
            OSSVDetailsVC *goodsDetailsVC = [[OSSVDetailsVC alloc] init];
            goodsDetailsVC.goodsId = productModel.goods_id;
            goodsDetailsVC.wid = productModel.wid;
            goodsDetailsVC.coverImageUrl = productModel.goods_img;
            goodsDetailsVC.sourceType = STLAppsflyerGoodsSourceThemeActivity;
            goodsDetailsVC.specialId = productModel.specialId;
            [self.navigationController pushViewController:goodsDetailsVC animated:YES];
//        };
//        [self.navigationController presentViewController:sign animated:YES completion:nil];
        
    } else {

        OSSVThemeZeroPrGoodsModel *productModel = model;
        OSSVDetailsVC *goodsDetailsVC = [[OSSVDetailsVC alloc] init];
        goodsDetailsVC.goodsId = productModel.goods_id;
        goodsDetailsVC.wid = productModel.wid;
        goodsDetailsVC.coverImageUrl = productModel.goods_img;
        goodsDetailsVC.sourceType = STLAppsflyerGoodsSourceThemeActivity;
        goodsDetailsVC.specialId = productModel.specialId;
        [self.navigationController pushViewController:goodsDetailsVC animated:YES];
        
    }
}

///秒杀
- (void)themeScrollerCell:(OSSVScrollCCell *)cell itemCell:(UICollectionViewCell *)productCell {
    
    if ([cell isMoreEvent:productCell]) {
        if ([cell.model.dataSource isKindOfClass:[OSSVSecondsKillsModel class]]) {
            [OSSVAdvsEventsManager advEventTarget:self.viewController withEventModel:(OSSVAdvsEventsModel*)cell.datasourceModel.end_more];
        }
    } else if ([cell.model.dataSource isKindOfClass:[OSSVSecondsKillsModel class]]) {
        [OSSVAdvsEventsManager advEventTarget:self.viewController withEventModel:(OSSVAdvsEventsModel*)cell.datasourceModel.banner];

    } else if (productCell && [productCell isKindOfClass:[OSSVPductGoodsCCell class]]) {
        
        OSSVPductGoodsCCell *goodsCell = (OSSVPductGoodsCCell *)productCell;
        OSSVHomeGoodsListModel *model = goodsCell.model;
        OSSVDetailsVC *goodsDetailsVC = [OSSVDetailsVC new];
        goodsDetailsVC.goodsId = model.goodsId;
        goodsDetailsVC.wid = model.wid;
        goodsDetailsVC.coverImageUrl = model.goodsImageUrl;
        goodsDetailsVC.sourceType = STLAppsflyerGoodsSourceThemeActivity;
        [self.navigationController pushViewController:goodsDetailsVC animated:YES];

    }
}

///广告
- (void)themeAdvCell:(OSSVAsinglesAdvCCell *)cell contentModel:(id)model {
    
    if (model && [model isKindOfClass:[STLAdvEventSpecialModel class]]) {
        STLAdvEventSpecialModel *specialModel = (STLAdvEventSpecialModel *)model;
        
        OSSVAdvsEventsModel *advEventModel = [[OSSVAdvsEventsModel alloc] initWhtiSpecialModel:specialModel];
        [OSSVAdvsEventsManager advEventTarget:self.viewController withEventModel:advEventModel];
    }
}

///滑动商品
- (void)themeScrollGoodCell:(STLScrollerGoodsItemCell *)cell contentModel:(id)model isMore:(BOOL)isMore{
    
    if (model && [model isKindOfClass:[STLDiscoveryBlockSlideGoodsModel class]]) {//首页滑动商品
        STLDiscoveryBlockSlideGoodsModel *slideGoodsModel = (STLDiscoveryBlockSlideGoodsModel *)model;
        
        if (isMore) {
            //原生专题
            OSSVAppNewThemeVC *newThemeCtrl = [[OSSVAppNewThemeVC alloc] init];
            newThemeCtrl.customId = slideGoodsModel.special_id;
            [self.navigationController pushViewController:newThemeCtrl animated:YES];
            return;
        }
        
//        //如果有viewAll 并且专题ID为空---跳转商品列表页，用父 专题ID
//        if (isMore && STLIsEmptyString(slideGoodsModel.special_id)) {
//            //原生专题
//            OSSVCategorysNewZeroListVC *ctrl = [[OSSVCategorysNewZeroListVC alloc] init];
//            ctrl.specialId = self.customId;
//            ctrl.type      = @"6";
//            ctrl.titleName = self.titleName;
//            ctrl.isFromZeroYuan = NO;
//            [self.navigationController pushViewController:ctrl animated:YES];
//            return;
//        }

        OSSVDetailsVC *goodsDetailsVC = [[OSSVDetailsVC alloc] init];
        goodsDetailsVC.goodsId = slideGoodsModel.goodsId;
        goodsDetailsVC.wid = slideGoodsModel.wid;
        goodsDetailsVC.coverImageUrl = slideGoodsModel.goods_img;
        goodsDetailsVC.sourceType = STLAppsflyerGoodsSourceThemeActivity;
        goodsDetailsVC.specialId = slideGoodsModel.special_id;
        [self.navigationController pushViewController:goodsDetailsVC animated:YES];

    } else if(model && [model isKindOfClass:[OSSVHomeGoodsListModel class]]) {//原生专题滑动商品
        OSSVHomeGoodsListModel *themeGoodListModel = (OSSVHomeGoodsListModel *)model;
        
        //如果有viewAll 并且专题ID不为空
        if (isMore && !STLIsEmptyString(themeGoodListModel.specialId)) {
            //原生专题
            OSSVAppNewThemeVC *newThemeCtrl = [[OSSVAppNewThemeVC alloc] init];
            newThemeCtrl.customId = themeGoodListModel.specialId;
            [self.navigationController pushViewController:newThemeCtrl animated:YES];
            return;
        }
        //如果有viewAll 并且专题ID为空---跳转商品列表页，用父 专题ID
        if (isMore && STLIsEmptyString(themeGoodListModel.specialId)) {
            //原生专题
            NSLog(@"跳转上列表页，父专题ID：%@", self.customId);
            OSSVCategorysNewZeroListVC *ctrl = [[OSSVCategorysNewZeroListVC alloc] init];
            ctrl.specialId = self.customId;
            ctrl.type      = @"6";
            ctrl.titleName = self.titleName;
            ctrl.isFromZeroYuan = NO;
            [self.navigationController pushViewController:ctrl animated:YES];
            return;
        }

        OSSVDetailsVC *goodsDetailsVC = [OSSVDetailsVC new];
        goodsDetailsVC.goodsId = themeGoodListModel.goodsId;
        goodsDetailsVC.wid = themeGoodListModel.wid;
        goodsDetailsVC.coverImageUrl = themeGoodListModel.goodsImageUrl;
        goodsDetailsVC.sourceType = STLAppsflyerGoodsSourceThemeActivity;
        [self.navigationController pushViewController:goodsDetailsVC animated:YES];
    }
}

///滑动商品 暂时没有more
- (void)themeRankModuleGoodCell:(OSSVThemeGoodsItesRankCCell *)cell contentModel:(id)model isMore:(BOOL)isMore {
    
    STLHomeCGoodsModel *goodsModel = nil;
    if (model && [model isKindOfClass:[STLHomeCGoodsModel class]]) {//商品排行组件
        goodsModel = (STLHomeCGoodsModel *)model;
        
    } else if(model && [model isKindOfClass:[OSSVThemeItemsGoodsRanksCCellModel class]]) {//商品排行列表
        OSSVThemeItemsGoodsRanksCCellModel *rankModel = (OSSVThemeItemsGoodsRanksCCellModel *)model;
        if ([rankModel.dataSource isKindOfClass:[STLHomeCGoodsModel class]]) {
            goodsModel = (STLHomeCGoodsModel *)rankModel.dataSource;
        }
    }
    
    if (!isMore && goodsModel) {
        
        OSSVDetailsVC *goodsDetailsVC = [OSSVDetailsVC new];
        goodsDetailsVC.goodsId = goodsModel.goods_id;
        goodsDetailsVC.wid = goodsModel.wid;
        goodsDetailsVC.coverImageUrl = goodsModel.goods_img;
        goodsDetailsVC.sourceType = STLAppsflyerGoodsSourceThemeActivity;
        [self.navigationController pushViewController:goodsDetailsVC animated:YES];
    }
}
#pragma mark ---领取优惠券请求
- (void)themeCouponGet:(NSString *)couponIds isNewCoupons:(BOOL)isNew
{
    if (STLIsEmptyString(couponIds)) {
        return;
    }
    
    if (![OSSVAccountsManager sharedManager].isSignIn) {
        
        SignViewController *sign = [SignViewController new];
        sign.modalPresentationStyle = UIModalPresentationFullScreen;
        @weakify(self)
        //如果登录后自动执行，可以在block中填写代码
        sign.signBlock = ^{
            @strongify(self)
            OSSVHomesCouponsAip *api = [[OSSVHomesCouponsAip alloc] initWithCouponCode:couponIds specialID:STLToString(self.customId)];
            [api.accessoryArray addObject:[[STLRequestAccessory alloc] initWithApperOnView:self]];
            
            @weakify(self)
            [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
                @strongify(self)
                id requestJSON = [OSSVNSStringTool desEncrypt:request];
                
                NSString *message = requestJSON[@"message"];
                if ([requestJSON[kStatusCode] integerValue] == 20001) {//老用户领取新人优惠券时，提示
                    [self.couponAlertView showView:WINDOW msg:message];
                } else {
                    if (!isNew) {
                        [HUDManager showHUDWithMessage:message];
                    }
                }
                if ([requestJSON[kStatusCode] integerValue] == kStatusCode_200) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_ChangeAccountRedDot object:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_getCouponsSuccess object:nil];
                }
            } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
                
            }];
            [self.operations addObject:api];

        };
        [self.navigationController presentViewController:sign animated:YES completion:nil];
        
    } else {
        OSSVHomesCouponsAip *api = [[OSSVHomesCouponsAip alloc] initWithCouponCode:couponIds specialID:STLToString(self.customId)];
        [api.accessoryArray addObject:[[STLRequestAccessory alloc] initWithApperOnView:self]];
        
        @weakify(self)
        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            @strongify(self)
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            
            NSString *message = requestJSON[@"message"];
            if ([requestJSON[kStatusCode] integerValue] == 20001) {//老用户领取新人优惠券时，提示
                [self.couponAlertView showView:WINDOW msg:message];
            } else {
                if (!isNew) {
                    [HUDManager showHUDWithMessage:message];
                }
            }
            if ([requestJSON[kStatusCode] integerValue] == kStatusCode_200) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_ChangeAccountRedDot object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_getCouponsSuccess object:nil];
            }
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            
        }];
        [self.operations addObject:api];

    }
 }


#pragma mark 加购商品
- (void)showGoodsAttribute:(STLHomeCGoodsModel *)newUserGoodsModel index:(NSInteger)index{
    self.hasFirtFlash = NO;
    self.goodsAttributeSheet.analyticsDic = @{kAnalyticsPositionNumber:@(index+1)}.mutableCopy;
    if ([newUserGoodsModel isKindOfClass:OSSVThemeZeroPrGoodsModel.class]) {
        OSSVThemeZeroPrGoodsModel *productModel = (OSSVThemeZeroPrGoodsModel *)newUserGoodsModel;
        [self requestAttribute:STLToString(newUserGoodsModel.goods_id) wid:STLToString(newUserGoodsModel.wid) isRelead:NO withReplaceFree:productModel.cart_exists withSpecialid:productModel.specialId];
    }else{
        [self requestAttribute:STLToString(newUserGoodsModel.goods_id) wid:STLToString(newUserGoodsModel.wid) isRelead:NO];
    }
    
}

#pragma mark 收藏商品
- (void)showWishListAttribute:(STLHomeCGoodsModel *)newUserGoodsModel withIndex:(NSIndexPath *)index{
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        NSInteger is_collect = newUserGoodsModel.is_collect;
        NSArray *parm = @[newUserGoodsModel.goods_id, newUserGoodsModel.wid];
        if (is_collect) {
            // 已经收藏 取消收藏
            [self requestCollectDelNetwork:parm completion:^(id obj) {
                ShowToastToViewWithText(nil, STLLocalizedString_(@"removedWishlist", nil));
                newUserGoodsModel.is_collect = 0;
                NSInteger count = [newUserGoodsModel.collect_count integerValue] - 1;
                count = count >=0 ? count : 0;
                newUserGoodsModel.collect_count = [NSString stringWithFormat:@"%ld", count];
                [self.themeManagerView.themeCollectionView reloadItemsAtIndexPaths:@[index]];
            } failure:^(id obj) {
                
            }];
        }else{
            // 收藏
            [self requestCollectAddNetwork:parm completion:^(id obj) {
                ShowToastToViewWithText(nil, STLLocalizedString_(@"addedWishlist", nil));
                newUserGoodsModel.is_collect = 1;
                NSInteger count = [newUserGoodsModel.collect_count integerValue] + 1;
                count = count >=0 ? count : 0;
                newUserGoodsModel.collect_count = [NSString stringWithFormat:@"%ld", count];
                [self.themeManagerView.themeCollectionView reloadItemsAtIndexPaths:@[index]];
            } failure:^(id obj) {
                
            }];
        }
    } exception:^{
        [HUDManager showHUDWithMessage:STLLocalizedString_(@"networkErrorMsg", nil)];
    }];
}

//收藏接口
- (void)requestCollectAddNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    NSArray *array = (NSArray *)parmaters;
    OSSVAddCollectApi *api = [[OSSVAddCollectApi alloc] initWithAddCollectGoodsId:array[0] wid:array[1]];
    [api.accessoryArray addObject:[[STLRequestAccessory alloc] initWithApperOnView:self]];

    [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
        if (completion) {
            completion(nil);
        }
    } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
        if (failure) {
            failure(nil);
        }
    }];
}

//取消收藏
- (void)requestCollectDelNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    NSArray *array = (NSArray *)parmaters;
    OSSVDelCollectApi *api = [[OSSVDelCollectApi alloc] initWithAddCollectGoodsId:array[0] wid:array[1]];
    [api.accessoryArray addObject:[[STLRequestAccessory alloc] initWithApperOnView:self]];
    [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
        if (completion) {
            completion(nil);
        }
    } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
        if (failure) {
            failure(nil);
        }
    }];
}

// 刷新收藏
- (void)refreshFavoriteValues:(NSNotification *)notification{
    OSSVDetailsBaseInfoModel *infoModel = (OSSVDetailsBaseInfoModel *)notification.object;

    if ([self.rankGoodsModel.goods_id isEqualToString:infoModel.goodsId] && [self.rankGoodsModel.wid isEqualToString:infoModel.goodsWid]) {
        if (infoModel.isCollect) {
            // 收藏
            self.rankGoodsModel.is_collect = 1;
            NSInteger count = [self.rankGoodsModel.collect_count integerValue] + 1;
            count = count >=0 ? count : 0;
            self.rankGoodsModel.collect_count = [NSString stringWithFormat:@"%ld", count];
            [self.themeManagerView.themeCollectionView reloadItemsAtIndexPaths:@[self.rankIndexPath]];
            return;
        }else{
            // 取消收藏
            self.rankGoodsModel.is_collect = 0;
            NSInteger count = [self.rankGoodsModel.collect_count integerValue] - 1;
            count = count >=0 ? count : 0;
            self.rankGoodsModel.collect_count = [NSString stringWithFormat:@"%ld", count];
            [self.themeManagerView.themeCollectionView reloadItemsAtIndexPaths:@[self.rankIndexPath]];
            return;
        }
    }
}


-(void)hideGoodsAttribute {
    
    self.goodsAttributeSheet.hidden = YES;
    if (self.goodsAttributeSheet.superview) {
        [self.goodsAttributeSheet removeFromSuperview];
    }
}

#pragma mark - setter / getter

- (NSMutableArray *)recommedDatas {
    if (!_recommedDatas) {
        _recommedDatas = [[NSMutableArray alloc] init];
    }
    return _recommedDatas;
}
- (OSSVThemesViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[OSSVThemesViewModel alloc] init];
        _viewModel.contentView = self;
    }
    return _viewModel;
}
- (OSSVDetailsViewModel *)goodsViewModel {
    if (!_goodsViewModel) {
        _goodsViewModel = [[OSSVDetailsViewModel alloc] init];
    }
    return _goodsViewModel;
}


- (OSSVAPPThemeHandleMangerView *)themeManagerView {
    if (!_themeManagerView) {
        _themeManagerView = [[OSSVAPPThemeHandleMangerView alloc] initWithFrame:self.bounds channelId:self.customId showRecommend:YES];
        _themeManagerView.customName = self.title;
        [_themeManagerView baseConfigureSource:STLAppsflyerGoodsSourceHome analyticsId:[NSString stringWithFormat:@"%@_%@",NSStringFromClass(OSSAPPThemesMainView.class),self.title] screenName:NSStringFromClass(OSSAPPThemesMainView.class)];
        _themeManagerView.delegate = self;
        [_themeManagerView forbidCollectionRecognizeSimultaneously:YES];
        
        @weakify(self)
        _themeManagerView.emptyTouchBlock = ^{
            @strongify(self)
            if (!self.themeManagerView.themeCollectionView.mj_header.isRefreshing) {
                [self.themeManagerView.themeCollectionView.mj_header beginRefreshing];
            }
        };
    }
    return _themeManagerView;
}


- (OSSVCouponsAlertView *)couponAlertView {
    if (!_couponAlertView) {
        _couponAlertView = [[OSSVCouponsAlertView alloc] initWithFrame:CGRectZero];
        _couponAlertView.operateBlock = ^{
            
        };
    }
    return _couponAlertView;
}

- (STLActionSheet *)goodsAttributeSheet {
    if (!_goodsAttributeSheet) {
        
        CGFloat detailSheetY = kIS_IPHONEX? 88.f : 64.f;
        _goodsAttributeSheet = [[STLActionSheet alloc] initWithFrame:CGRectMake(0, -detailSheetY, SCREEN_WIDTH, SCREEN_HEIGHT)];
//        _goodsAttributeSheet.isNewUser = YES;
        _goodsAttributeSheet.specialId = self.customId;
        _goodsAttributeSheet.sourceType = STLAppsflyerGoodsSourceThemeActivity;
        _goodsAttributeSheet.isListSheet = YES;
        _goodsAttributeSheet.addCartType = 1;
        @weakify(self)
        _goodsAttributeSheet.cancelViewBlock = ^{   // cancel block
            @strongify(self)
            self.hasFirtFlash = NO;
            [self hideGoodsAttribute];
        };
        _goodsAttributeSheet.attributeBlock = ^(NSString *goodsId,NSString *wid) {
            @strongify(self)
            [self requestAttribute:goodsId wid:wid isRelead:YES];
        };
        
        _goodsAttributeSheet.attributeNewBlock = ^(NSString *goodsId, NSString *wid, NSString *specialId) {
            @strongify(self)
            [self requestAttribute:goodsId wid:wid specialId:specialId isRelead:YES];
        };

        _goodsAttributeSheet.zeroStockBlock = ^(NSString *goodsId, NSString *wid) {
            @strongify(self)
            [self requestAttribute:goodsId wid:wid isRelead:YES];
            //[self requestCustomData:NO];
        };
        
        _goodsAttributeSheet.goNewToDetailBlock = ^(NSString *goodsId, NSString *wid, NSString *specialId, NSString *goodsImageUrl) {
            @strongify(self)
            OSSVDetailsVC *detailVC = [[OSSVDetailsVC alloc] init];
            detailVC.goodsId = goodsId;
            detailVC.wid = wid;
            detailVC.specialId = specialId;
            detailVC.sourceType = STLAppsflyerGoodsSourceThemeActivity;
            detailVC.coverImageUrl = STLToString(goodsImageUrl);
            [self.navigationController pushViewController:detailVC animated:YES];
            
            [self.goodsAttributeSheet dismiss];
        };
        _goodsAttributeSheet.collectionStateBlock = ^(BOOL isCollection, NSString *wishCount) {
            @strongify(self)
            if ([self.goodsAttributeSheet.baseInfoModel.goodsId isEqualToString:self.tempNewsUserProductModel.goodsId]) {
                self.tempNewsUserProductModel.isCollect = isCollection;
            }
        };
    }
    return _goodsAttributeSheet;
}



- (void)requestAttribute:(NSString *)goodsId wid:(NSString *)wid isRelead:(BOOL)isRelad{
    
    self.userInteractionEnabled = NO;
    self.goodsAttributeSheet.goodsId = goodsId;
    self.goodsAttributeSheet.wid = wid;
    @weakify(self)
    [self.goodsViewModel requestGoodsListBaseInfo:@{@"goods_id":STLToString(goodsId),
                                          @"wid":STLToString(wid)} completion:^(id obj) {
        @strongify(self)
        if (obj && [obj isKindOfClass:[OSSVDetailsBaseInfoModel class]]) {
            OSSVDetailsBaseInfoModel *baseInfoModel = (OSSVDetailsBaseInfoModel *)obj;
            
            if (!isRelad) {
                self.detailModel = baseInfoModel;
                
                // 0 > 闪购 > 满减
                if (STLIsEmptyString(self.detailModel.specialId) && self.detailModel.flash_sale && !STLIsEmptyString(self.detailModel.flash_sale.active_discount) && [self.detailModel.flash_sale.active_discount floatValue] > 0) {
                    if (!self.hasFirtFlash) {
                        self.hasFirtFlash = YES;
                    }
                }
                self.goodsAttributeSheet.hasFirtFlash = self.hasFirtFlash;
                
                self.goodsAttributeSheet.baseInfoModel = baseInfoModel;
                self.goodsAttributeSheet.hadManualSelectSize = YES;

                self.goodsAttributeSheet.hidden = NO;
                if (!self.goodsAttributeSheet.superview) {
                    [self.viewController.view addSubview:self.goodsAttributeSheet];
                }
                
                [UIView animateWithDuration: 0.25 animations: ^{
                    [self.goodsAttributeSheet shouAttribute];
                    self.goodsAttributeSheet.sourceType = STLAppsflyerGoodsSourceThemeActivity;
                    self.goodsAttributeSheet.type = GoodsDetailEnumTypeAdd;
                } completion: nil];
            } else {
                self.detailModel = baseInfoModel;
                self.goodsAttributeSheet.baseInfoModel = baseInfoModel;
            }
        }
        self.userInteractionEnabled = YES;

    } failure:^(id obj) {
        @strongify(self)
        self.userInteractionEnabled = YES;

    }];
    
}

- (void)requestAttribute:(NSString *)goodsId wid:(NSString *)wid specialId:(NSString *)specialId isRelead:(BOOL)isRelad{
    
    self.userInteractionEnabled = NO;
    self.goodsAttributeSheet.goodsId = goodsId;
    self.goodsAttributeSheet.wid = wid;
    @weakify(self)
    [self.goodsViewModel requestGoodsListBaseInfo:@{@"goods_id":STLToString(goodsId),
                                          @"wid":STLToString(wid),
                                          @"specialId":STLToString(specialId)
    } completion:^(id obj) {
        @strongify(self)
        if (obj && [obj isKindOfClass:[OSSVDetailsBaseInfoModel class]]) {
            OSSVDetailsBaseInfoModel *baseInfoModel = (OSSVDetailsBaseInfoModel *)obj;
            
            if (!isRelad) {
                self.detailModel = baseInfoModel;
                
                // 0 > 闪购 > 满减
                if (STLIsEmptyString(self.detailModel.specialId) && self.detailModel.flash_sale && !STLIsEmptyString(self.detailModel.flash_sale.active_discount) && [self.detailModel.flash_sale.active_discount floatValue] > 0) {
                    if (!self.hasFirtFlash) {
                        self.hasFirtFlash = YES;
                    }
                }
                self.goodsAttributeSheet.hasFirtFlash = self.hasFirtFlash;
                
                self.goodsAttributeSheet.baseInfoModel = baseInfoModel;
                self.goodsAttributeSheet.hadManualSelectSize = YES;

                self.goodsAttributeSheet.hidden = NO;
                if (!self.goodsAttributeSheet.superview) {
                    [self.viewController.view addSubview:self.goodsAttributeSheet];
                }
                
                [UIView animateWithDuration: 0.25 animations: ^{
                    [self.goodsAttributeSheet shouAttribute];
                    self.goodsAttributeSheet.sourceType = STLAppsflyerGoodsSourceThemeActivity;
                    self.goodsAttributeSheet.type = GoodsDetailEnumTypeAdd;
                } completion: nil];
            } else {
                self.detailModel = baseInfoModel;
                self.goodsAttributeSheet.baseInfoModel = baseInfoModel;
            }
        }
        self.userInteractionEnabled = YES;

    } failure:^(id obj) {
        @strongify(self)
        self.userInteractionEnabled = YES;

    }];
    
}

- (void)requestAttribute:(NSString *)goodsId wid:(NSString *)wid isRelead:(BOOL)isRelad withReplaceFree:(NSInteger)isReplaceFree withSpecialid:(NSString *)specialid{
    
    self.userInteractionEnabled = NO;
    self.goodsAttributeSheet.goodsId = goodsId;
    self.goodsAttributeSheet.wid = wid;
    @weakify(self)
    [self.goodsViewModel requestGoodsListBaseInfo:@{@"goods_id":STLToString(goodsId),
                                                    @"wid":STLToString(wid),
                                                    @"specialId":STLToString(specialid)
    } completion:^(id obj) {
        @strongify(self)
        if (obj && [obj isKindOfClass:[OSSVDetailsBaseInfoModel class]]) {
            OSSVDetailsBaseInfoModel *baseInfoModel = (OSSVDetailsBaseInfoModel *)obj;
            
            if (!isRelad) {
                self.detailModel = baseInfoModel;
                
                // 0 > 闪购 > 满减
                if (STLIsEmptyString(self.detailModel.specialId) && self.detailModel.flash_sale && !STLIsEmptyString(self.detailModel.flash_sale.active_discount) && [self.detailModel.flash_sale.active_discount floatValue] > 0) {
                    if (!self.hasFirtFlash) {
                        self.hasFirtFlash = YES;
                    }
                }
                self.goodsAttributeSheet.hasFirtFlash = self.hasFirtFlash;
                self.goodsAttributeSheet.cart_exits = isReplaceFree;
                NSArray <OSSVSpecsModel *> *goods_specs = baseInfoModel.GoodsSpecs;
                for (OSSVSpecsModel *specModel in goods_specs) {
                    specModel.isSelectSize = YES;
                }
                
                self.goodsAttributeSheet.baseInfoModel = baseInfoModel;
                self.goodsAttributeSheet.hadManualSelectSize = YES;

                self.goodsAttributeSheet.hidden = NO;
                if (!self.goodsAttributeSheet.superview) {
                    [self.viewController.view addSubview:self.goodsAttributeSheet];
                }
                
                [UIView animateWithDuration: 0.25 animations: ^{
                    [self.goodsAttributeSheet shouAttribute];
                    self.goodsAttributeSheet.sourceType = STLAppsflyerGoodsSourceThemeActivity;
                    self.goodsAttributeSheet.type = GoodsDetailEnumTypeAdd;
                } completion: nil];
            } else {
                self.detailModel = baseInfoModel;
                self.goodsAttributeSheet.baseInfoModel = baseInfoModel;
            }
        }
        self.userInteractionEnabled = YES;

    } failure:^(id obj) {
        @strongify(self)
        self.userInteractionEnabled = YES;

    }];
    
}


-(NSMutableArray <OSSVBasesRequests *>*)operations {
    if (!_operations) {
        _operations = [[NSMutableArray alloc] init];
    }
    return _operations;
}


- (OSSVThemeAnalyseAP *)themeAnalyticsAOP {
    if (!_themeAnalyticsAOP) {
        _themeAnalyticsAOP = [[OSSVThemeAnalyseAP alloc] init];
        _themeAnalyticsAOP.sourceKey = self.customId;
        _themeAnalyticsAOP.source = STLAppsflyerGoodsSourceThemeActivity;
    }
    return _themeAnalyticsAOP;
}
@end
