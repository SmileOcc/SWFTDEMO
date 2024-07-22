//
//  ZFCommunityHomeCMSView.m
//  ZZZZZ
//
//  Created by YW on 2019/5/20.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityHomeCMSView.h"
#import "UIView+ZFViewCategorySet.h"

#import "ZFInitViewProtocol.h"
#import "Masonry.h"
#import "UIView+ZFViewCategorySet.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "ZFLocalizationString.h"
#import "ZFFireBaseAnalytics.h"
#import "ZFNotificationDefiner.h"
#import "ZF3DTouchHeader.h"
#import "ZFNetworkManager.h"

#import "ZFCommunityHomeTableFooterView.h"
#import "ZFCommunityHomeMenuView.h"
#import "ZFCommunityHomeCMSFooterView.h"
#import "ZFNoDataTableViewCell.h"

#import "ZFCommunityChannelModel.h"
#import "ZFCommunityHomeViewModel.h"

#import "CommunityEnumComm.h"

#import "ZFGoodsDetailViewController.h"
#import "ZFCommunityHomeCMSViewAOP.h"
#import "ZFCommunityHomeCMSViewModel.h"
#import "ZFCMSViewModel.h"

@interface ZFCommunityHomeCMSView ()<ZFCMSManagerViewProtocol,ZFCommunityHomeTableFooterViewDelegate,UIScrollViewDelegate>


@property (nonatomic, strong) ZFCommunityHomeCMSViewModel           *cmsViewModel;
@property (nonatomic, strong) ZFCMSViewModel                    *historyViewModel;

@property (nonatomic, strong) ZFCommunityHomeViewModel                   *viewModel;
/** 频道菜单*/
@property (nonatomic, strong) ZFCommunityChannelModel               *channelModel;

@property (nonatomic, strong) ZFCommunityHomeTableFooterView         *tableFooterView;
@property (nonatomic, strong) NSArray                                *baseMenusDatas;
@property (nonatomic, strong) ZFCommunityHomeMenuView                *menuView;
@property (nonatomic, assign) BOOL                                   canScroll;

@property (nonatomic, assign) BOOL                                   onlyOneMenuRequest;
@property (nonatomic, assign) BOOL                                   onlyAddOnce;

@property (nonatomic, strong) UIView                                 *footerView;

@property (nonatomic, copy) NSString                                  *channel_id;
@property (nonatomic, copy) NSString                                  *channel_name;
@property (nonatomic, strong) ZFCommunityHomeCMSViewAOP               *analyticsAOP;
@property (nonatomic, assign) CGFloat                                 lastOffSetY;


@end

@implementation ZFCommunityHomeCMSView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)zf_viewDidShow {
    //FIXME: occ Bug 1101
    self.cmsViewModel.controller = self.viewController;
    self.historyViewModel.controller = self.viewController;
//
//    if (self.cmsManagerView.cmsSectionModelArr.count <= 0) { //加载时取消动画
//        [self.cmsManagerView.collectionView headerRefreshingByAnimation:NO];
//    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [[AnalyticsInjectManager shareInstance] analyticsInject:self injectObject:self.analyticsAOP];
        self.canScroll = YES;
        ZFCommunityChannelItemModel *showsModel = [[ZFCommunityChannelItemModel alloc] init];
        showsModel.cat_name = ZFLocalizedString(@"MyStylePage_SubVC_Shows", nil);
        showsModel.idx = @"0";
        ZFCommunityChannelItemModel *outfitsModel = [[ZFCommunityChannelItemModel alloc] init];
        outfitsModel.cat_name = ZFLocalizedString(@"Community_Tab_Title_Outfits", nil);
        outfitsModel.idx = @"1";
        
        self.baseMenusDatas = @[showsModel,outfitsModel];
        
        [self zfInitView];
        [self zfAutoLayoutView];
        [self addNotification];
    }
    return self;
}

- (void)addNotification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(canMove:) name:kCommunityExploreScrollStatus object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
}

- (void)channelDataRefreshNotification {
    
    NSInteger index = self.menuView.selectIndex;
    if (self.menuView.datasArray.count > index) {
        ZFCommunityChannelItemModel *item = self.menuView.datasArray[index];
        [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshCommunityChannelRefreshNotification object:item];
    }
}

#pragma mark - request

- (void)requestMenuData {
    @weakify(self)
    [self.viewModel requestDiscoverChannelCompletion:^(ZFCommunityChannelModel *channelModel) {
        @strongify(self)
        if (channelModel) {
            self.channelModel = channelModel;
            [self updateMenuViewData];
        }
    }];
}

- (void)requestCMSAdvertData {
    @weakify(self)
    [self.cmsViewModel requestCMSListDataCompletion:^(NSArray<ZFCMSSectionModel *>*cmsModelArr, BOOL isCacheData) {
        @strongify(self)
        
        // 当有数据时，再次刷新不读缓存数据
        if (isCacheData && self.cmsManagerView.cmsSectionModelArr.count > 0) {
            
        } else {
            
            self.channel_id = ZFToString(self.cmsViewModel.menu_id);
            self.channel_name = ZFToString(self.cmsViewModel.menu_name);
            self.cmsManagerView.channelId = ZFToString(self.cmsViewModel.menu_id);
            //统计配置
            self.analyticsAOP.channel_id = self.channel_id;
            self.analyticsAOP.channel_name = self.channel_name;
            
            [self dealwithHomeListData:cmsModelArr isCacheData:isCacheData];
            if (self.cmsManagerView.cmsSectionModelArr.count <= 0) { //顶部广告数据没有时，显示底部菜单视图
                if (self.footerView.superview) {
                    [self.footerView removeFromSuperview];
                }
                self.cmsManagerView.lastFooterView = nil;
                [self.cmsManagerView.collectionView addSubview:self.footerView];
            } else {
                if (self.footerView.superview) {
                    [self.footerView removeFromSuperview];
                }
                self.cmsManagerView.lastFooterView = self.footerView;
            }
            
            
            [self.cmsManagerView reloadView:YES];
            if (!self.onlyAddOnce) {
                self.onlyAddOnce = YES;
                [self updateMenuViewData];
            }
        }
        self.tableFooterView.hidden = NO;
        [self.cmsManagerView.collectionView.mj_header endRefreshing];
        
        if (self.scrollDirectionUpBlock) {
            self.scrollDirectionUpBlock(NO);
        }
    }];
    
    //只请求一次数据，或没读到配置的菜单数据时，每次刷新都获取
    if (!self.onlyOneMenuRequest || self.channelModel.data.count <= 0) {
        self.onlyOneMenuRequest = YES;
        [self requestMenuData];
    }
}
/**
 * 主页列表数据源
 */
- (void)dealwithHomeListData:(NSArray<ZFCMSSectionModel *> *)cmsModelArr isCacheData:(BOOL)isCacheData
{
    if (![cmsModelArr isKindOfClass:[NSArray class]]) {
        // 设置刷新文案
        self.cmsManagerView.collectionView.showDropBanner = NO;
        ((ZFRefreshHeader *)self.cmsManagerView.collectionView.mj_header).bannerModel = nil;
        return;
    }
    [self.cmsManagerView removeSectionBgColorView];
    self.cmsManagerView.cmsSectionModelArr = [NSMutableArray arrayWithArray:cmsModelArr];
    
    ZFBannerModel *pullBannerModel = [self.cmsViewModel.cmsPullDownModel configDeeplinkBannerModel];
    if (!ZFIsEmptyString(pullBannerModel.image)) {
        self.cmsManagerView.collectionView.showDropBanner = YES;
        ((ZFRefreshHeader *)self.cmsManagerView.collectionView.mj_header).bannerModel = pullBannerModel;
    } else {
        self.cmsManagerView.collectionView.showDropBanner = NO;
        ((ZFRefreshHeader *)self.cmsManagerView.collectionView.mj_header).bannerModel = nil;
    }
    
    //历史数据
    if (!ZFJudgeNSArray(self.cmsViewModel.historyModelArr)) {
        [self updateCMSHistoryGoods];
    }
}


- (void)updateMenuViewData {
    NSMutableArray *menusArray  = [[NSMutableArray alloc] initWithArray:self.baseMenusDatas];
    if (self.channelModel.data.count > 0) {
        [menusArray addObjectsFromArray:self.channelModel.data];
    }
    self.menuView.datasArray = [[NSArray alloc] initWithArray:menusArray];
    [self.tableFooterView updateDatas:self.menuView.datasArray];
}

#pragma mark - Action

- (void)scrollToTopOrRefresh {
    
    if (self.cmsManagerView.collectionView.isDecelerating) {//减速中
        YWLog(@"------------- cmsManagerView.collectionView 减速中");
        return;
    }
    
    UICollectionView *currentChannelCollectionView = [self.tableFooterView currentCollectionView];
    if (currentChannelCollectionView) {
        if (currentChannelCollectionView.isDecelerating) {//减速中
            YWLog(@"------------- currentChannel 减速中");
            return;
        }
    }
    
    CGFloat offsetY = self.cmsManagerView.collectionView.contentOffset.y;
    if (offsetY <= 0) {
        
        if (self.cmsManagerView.collectionView.mj_header.state == MJRefreshStateIdle) {//闲置中
            [self.cmsManagerView.collectionView.mj_header beginRefreshing];
        }
        [self sendAllNotice:YES];
        
        // 在请求成功回调中触发--显示

    } else {
        
        [self sendAllNotice:YES];
        [self.cmsManagerView.collectionView setContentOffset:CGPointZero animated:YES];
        
        // 延迟触发，防止在滚动中时，
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.scrollDirectionUpBlock) {
                self.scrollDirectionUpBlock(NO);
            }
        });

    }
    
}
- (void)actionSelectMenuIndex:(NSInteger)index {
    
    UIView *lastView = self.cmsManagerView.lastFooterView;
    if (lastView && lastView.superview) {//当视图还没显示时
        CGRect lastConvertFrame = [lastView.superview convertRect:lastView.frame toView:self.cmsManagerView.collectionView];
        [self.cmsManagerView.collectionView setContentOffset:CGPointMake(0, CGRectGetMinY(lastConvertFrame)) animated:YES];
    } else if(lastView){
        CGFloat minY = [self.cmsManagerView lastSectionFooterMinY];
        [self.cmsManagerView.collectionView setContentOffset:CGPointMake(0, minY) animated:YES];
    }
    self.menuView.selectIndex = index;
}

- (void)actionDropBanner {

    if (self.cmsViewModel.cmsPullDownModel.list.count > 0) {
        ZFCMSItemModel *itemModel = self.cmsViewModel.cmsPullDownModel.list[0];
        [self zf_cmsManagerView:self.cmsManagerView collectionView:self.cmsManagerView.collectionView eventCell:nil deeplinkItem:itemModel source:@""];
    }
}

- (ZFBTSModel *)communityHomeBts {
    if (self.cmsViewModel.cmsBtsModel) {
        if ([self.cmsViewModel.cmsBtsModel isReallyBTSModel]) {
            return self.cmsViewModel.cmsBtsModel;
        }
    }
    return nil;
}

/// 设置同类菜单底部视图回到初始位置
- (void)sendNotice:(BOOL)status{
    NSDictionary *dic = @{@"status":@(status),
                          @"type" :@(self.menuView.selectIndex)};
    [[NSNotificationCenter defaultCenter] postNotificationName:kCommunityExploreNestViewScrollStatus object:nil userInfo:dic];
}

- (void)sendAllNotice:(BOOL)status {
    NSDictionary *dic = @{@"status":@(status),
                          @"type" :@(-1)};
    [[NSNotificationCenter defaultCenter] postNotificationName:kCommunityExploreNestViewScrollStatus object:nil userInfo:dic];
}

/// 设置是否可以滚动到顶部
- (void)canMove:(NSNotification *)notice {
    
    NSNumber *status = notice.object;
    self.canScroll = [status boolValue];
    if (self.canScroll) {
        self.cmsManagerView.collectionView.scrollsToTop = YES;
    } else {
        self.cmsManagerView.collectionView.scrollsToTop = NO;
    }
}

- (void)reachabilityChanged:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    AFNetworkReachabilityStatus status = [userInfo[AFNetworkingReachabilityNotificationStatusItem] intValue];
    switch (status) {
        case AFNetworkReachabilityStatusNotReachable:
            break;
        case AFNetworkReachabilityStatusUnknown:
            break;
        case AFNetworkReachabilityStatusReachableViaWWAN:
        case AFNetworkReachabilityStatusReachableViaWiFi:{
            [self requestCMSAdvertData];
        }
            break;
        default:
            break;
    }
}
#pragma mark - ZFInitViewProtocol

- (void)zfInitView{
    [self addSubview:self.cmsManagerView];
}

- (void)zfAutoLayoutView{
    [self.cmsManagerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self).insets(UIEdgeInsetsZero);
    }];
}

/** 更新历史浏览记录 */
- (void)updateCMSHistoryGoods {
    if (self.cmsManagerView.cmsSectionModelArr.count == 0) return;
    if (!self.cmsViewModel.historySectionModel) return;
    
    @weakify(self)
    [self.historyViewModel fetchRecentlyGoods:^(NSArray<ZFCMSItemModel *> *itemModelArr) {
        @strongify(self)
        
        //历史数据
        self.cmsViewModel.historyModelArr = [[NSMutableArray alloc] initWithArray:itemModelArr];
        
        NSInteger historTypeIndex = -1;
        ZFCMSSectionModel *historSectionModel = nil;
        NSArray *tmpSectionModelArr = [NSArray arrayWithArray:self.cmsManagerView.cmsSectionModelArr];
        
        for (NSInteger i=0; i<tmpSectionModelArr.count; i++) {
            ZFCMSSectionModel *cmsSectionModel = tmpSectionModelArr[i];
            if (cmsSectionModel.type == ZFCMS_SlideBanner_Type) {
                if (cmsSectionModel.subType == ZFCMS_HistorSku_SubType) {// 商品历史浏览记录
                    historTypeIndex = i;
                    historSectionModel = cmsSectionModel;
                }
            }
        }
        //没有浏览历史
        if (historTypeIndex == -1) return ;
        
        if (itemModelArr.count == 0) {
            historSectionModel.sectionItemCount = 0;//这里不能删除数据源,因为每个cmsSectionModel都要计算Item宽高
        } else {
            historSectionModel.sectionItemCount = 1;
            historSectionModel.list = [NSMutableArray arrayWithArray:itemModelArr];
            //每次更新历史记录要滚到第一个位置 (-1标识阿语后最后一个)
            historSectionModel.sliderScrollViewOffsetX = [SystemConfigUtils isRightToLeftShow] ? -1 : 0.0;
            if (self.cmsManagerView.cmsSectionModelArr.count > historTypeIndex) {
                [self.cmsManagerView.cmsSectionModelArr replaceObjectAtIndex:historTypeIndex withObject:historSectionModel];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.cmsManagerView removeSectionBgColorView];
            [self.cmsManagerView reloadView:NO];
        });
    }];
}


#pragma mark - ZFCMSManagerViewProtocol

- (void)zf_cmsManagerView:(ZFCMSManagerView *)managerView collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)zf_cmsManagerView:(ZFCMSManagerView *)managerView collectionView:(UICollectionView *)collectionView didSelectItemCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)zf_cmsManagerView:(ZFCMSManagerView *)managerView collectionView:(UICollectionView *)collectionView eventCell:(UICollectionViewCell *)cell deeplinkItem:(ZFCMSItemModel *)itemModel source:(NSString *)source {
    
    if (ZFIsEmptyString(source)) {
        source = @"deeplink";
    }
    NSString *deeplink = [NSString stringWithFormat:@"ZZZZZ://action?actiontype=%@&url=%@&source=%@",itemModel.actionType, ZFToString(ZFEscapeString(itemModel.url, YES)), source];
    //如果actionType=-2,则特殊处理自定义完整ddeplink
    if (itemModel.actionType.integerValue == -2) {
        deeplink = ZFToString(ZFEscapeString(itemModel.url, YES));
        if (ZFIsEmptyString(deeplink)) return;
    }
    
    NSMutableDictionary *paramDict = [BannerManager parseDeeplinkParamDicWithURL:[NSURL URLWithString:deeplink]];
    NSString *name = paramDict[@"name"];
    if (ZFIsEmptyString(name)) {
        paramDict[@"name"] = itemModel.name;
    }
    [BannerManager jumpDeeplinkTarget:self.viewController deeplinkParam:paramDict];
}


- (void)zf_cmsManagerView:(ZFCMSManagerView *)managerView collectionView:(UICollectionView *)collectionView recommendCell:(ZFCMSRecommendGoodsCCell *)cell recommendGoods:(ZFGoodsModel *)goodsModel {
    
    /// 社区没有推荐商品
}

/** 点击优惠券*/
- (void)zf_cmsManagerView:(ZFCMSManagerView *)managerView collectionView:(UICollectionView *)collectionView couponCell:(ZFCMSCouponCCell *)cell model:(ZFCMSItemModel *)model {
    /// 社区没有推荐商品
}

- (void)zf_cmsManagerView:(ZFCMSManagerView *)managerView collectionView:(UICollectionView *)collectionView clearHistoryCompletion:(BOOL)flag {
    [self.cmsViewModel clearCMSHistoryAction];
}

////
- (void)zf_cmsScrollViewDidScroll:(UIScrollView *)scrollView {
    
    BOOL isMenuTop = NO;
    if ([scrollView isEqual:self.cmsManagerView.collectionView]) {
        
        if (scrollView.contentOffset.y - self.lastOffSetY > 0) {//向上滚动不显示
            [self handAllScrollDirectionUp:YES];
            
        } else if (scrollView.contentOffset.y - self.lastOffSetY < 0) {
            [self handAllScrollDirectionUp:NO];
        }
        CGFloat offsetY = [self.cmsManagerView lastSectionFooterMinY];
        
//        YWLog(@"--ccc contentSize.height: %f  lastFooterMinY:%f  lastFooterH:%f",self.cmsManagerView.collectionView.contentSize.height,[self.cmsManagerView lastSectionFooterMinY],CGRectGetHeight(self.cmsManagerView.lastFooterView.frame));
//        YWLog(@"------ccccccccccc contentH: %f",[self.cmsManagerView noContainRecommendsGoodsHeight]);
        
        if (self.canScroll) {
            scrollView.showsVerticalScrollIndicator = YES;
            
            if (self.cmsManagerView.lastFooterView) {//顶部有数据显示
                // offsetY >= 0, 是因为顶部有广告数据，但是没显示高度
                if (scrollView.contentOffset.y >= offsetY && self.cmsManagerView.lastFooterView.superview && offsetY >= 0 ) {//有尾部视图
                    
                    //[self.viewController.navigationController.navigationBar setShadowImage:nil];//恢复导航线条
                    scrollView.contentOffset = CGPointMake(0, offsetY);
                    [self sendNotice:YES];
                    self.menuView.isHiddenUnderLineView = NO;
                    isMenuTop = YES;
                    
                    if (self.menuTopBlock) {
                        self.menuTopBlock(isMenuTop);
                    }
                    
                } else{
                    [self sendNotice:NO];
                    if (self.menuTopBlock) {
                        self.menuTopBlock(isMenuTop);
                    }
                }
                
            } else if(scrollView.contentOffset.y >= offsetY && self.footerView && offsetY >= 0) { //无尾部，
                //[self.viewController.navigationController.navigationBar setShadowImage:nil];//恢复导航线条
                scrollView.contentOffset = CGPointMake(0, offsetY);
                [self sendNotice:YES];
                self.menuView.isHiddenUnderLineView = NO;
                isMenuTop = YES;
                
                if (self.menuTopBlock) {
                    self.menuTopBlock(isMenuTop);
                }
            } else{
                [self sendNotice:NO];
                if (self.menuTopBlock) {
                    self.menuTopBlock(isMenuTop);
                }
            }
            
        }else{
            scrollView.showsVerticalScrollIndicator = NO;
            scrollView.contentOffset = CGPointMake(0, offsetY);
            [self.viewController.navigationController.navigationBar setShadowImage:[UIImage new]];//去导航线条
            /** 需要放手在发通知让show/outfit/video cell contentOffset设置0 */
            if (!scrollView.isDragging) {
                [self sendNotice:YES];
            }
        }
    }
}

- (void)zf_cmsScrollViewDidEndDecelerating:(UIScrollView *)scrollView {
}

- (void)zf_cmsScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
}

- (void)zf_cmsScrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.cmsManagerView.collectionView]) {
        self.lastOffSetY = scrollView.contentOffset.y;
    }
}

- (void)zf_cmsScrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {

    YWLog(@"---------------cccccccccc end");
}

- (void)handAllScrollDirectionUp:(BOOL)directionUp {
    
    //如果子频道视图在滚动时，
//    UICollectionView *currentChannelCollectionView = [self.tableFooterView currentCollectionView];
//    if (currentChannelCollectionView) {
//        BOOL isMoving = (currentChannelCollectionView.tracking && currentChannelCollectionView.dragging) || currentChannelCollectionView.decelerating;
//        if (isMoving) {//滚动中
//            return;
//        }
//    }
    if (self.scrollDirectionUpBlock) {
        self.scrollDirectionUpBlock(directionUp);
    }
}

#pragma mark - ZFCommunityHomeTableFooterViewDelegate

- (void)communityHomeTableFooterView:(ZFCommunityHomeTableFooterView *)footerView scrollUp:(BOOL)scrollUp {
    if (self.scrollDirectionUpBlock) {
        self.scrollDirectionUpBlock(scrollUp);
    }
}

#pragma mark - Property Method

- (void)setSelectIndex:(NSInteger)selectIndex {
    _selectIndex = selectIndex;
    [self actionSelectMenuIndex:selectIndex];
}

- (ZFCMSViewModel *)historyViewModel {
    if (!_historyViewModel) {
        _historyViewModel = [[ZFCMSViewModel alloc] init];
        _historyViewModel.controller = self.viewController;
    }
    return _historyViewModel;
}

- (ZFCommunityHomeCMSViewModel *)cmsViewModel {
    if (!_cmsViewModel) {
        _cmsViewModel = [[ZFCommunityHomeCMSViewModel alloc] init];
        _cmsViewModel.controller = self.viewController;
    }
    return _cmsViewModel;
}

- (ZFCommunityHomeViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFCommunityHomeViewModel alloc] init];
        _viewModel.controller = self.viewController;
    }
    return _viewModel;
}

- (ZFCMSManagerView *)cmsManagerView {
    if (!_cmsManagerView) {
        _cmsManagerView = [[ZFCMSManagerView alloc] initWithFrame:CGRectZero channelId:self.channel_id showRecommend:NO];
        _cmsManagerView.channelName = ZFToString(self.channel_name);
        [_cmsManagerView baseConfigureSource:ZFAnalyticsAOPSourceCommunityHome analyticsId:NSStringFromClass(ZFCommunityHomeCMSView.class) screenName:NSStringFromClass(ZFCommunityHomeCMSView.class)];
        _cmsManagerView.delegate = self;
        
        @weakify(self)
        [_cmsManagerView addListHeaderRefreshBlock:^{
            @strongify(self)
            [self requestCMSAdvertData];
            [self channelDataRefreshNotification];
            
        } PullingShowBannerBlock:^{
            @strongify(self)
            [self actionDropBanner];

        } footerRefreshBlock:^{
            

        } startRefreshing:YES];
    }
    return _cmsManagerView;
}


- (ZFCommunityHomeMenuView *)menuView {
    if (!_menuView) {
        _menuView = [[ZFCommunityHomeMenuView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 44)];
        _menuView.backgroundColor = ZFC0xFFFFFF();

        @weakify(self)
        _menuView.selectBlock = ^(NSInteger index) {
            @strongify(self)
            
            self.tableFooterView.selectIndex = index;
            if (self.menuView.datasArray.count > index) {
                
                ZFCommunityChannelItemModel *itemModel = self.menuView.datasArray[index];
                
                // firebase
                NSString *itemName = ZFToString(itemModel.cat_name);
                switch (index) {
                    case ZFCommunityHomeSelectTypeExplore:
                        itemName = @"explore";
                        break;
                    case ZFCommunityHomeSelectTypeOutfits:
                        itemName = @"outfits";
                        break;
                    default:
                        break;
                }
                NSString *itemId   = [NSString stringWithFormat:@"click_%@", itemName];
                NSString *contentType = [NSString stringWithFormat:@"community_%@", itemName];
                [ZFFireBaseAnalytics selectContentWithItemId:itemId itemName:itemName ContentType:contentType itemCategory:itemName];
            }
        };
    }
    return _menuView;
}


- (ZFCommunityHomeTableFooterView *)tableFooterView {
    if (!_tableFooterView) {
        
        CGFloat height = 0;
        if (IPHONE_X_5_15) {
            height = KScreenHeight - STATUSHEIGHT - 44 - 83 - 44;
        }else{
            height = KScreenHeight - STATUSHEIGHT - 44 - 49 - 44;
        }

        _tableFooterView = [[ZFCommunityHomeTableFooterView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, height) baseData:self.baseMenusDatas];
        _tableFooterView.hidden = YES;
        _tableFooterView.delegate = self;
        
        @weakify(self)
        _tableFooterView.selectBlock = ^(NSInteger index) {
            @strongify(self)
            self.menuView.selectIndex = index;
        };
        
        
        
    }
    return _tableFooterView;
}

- (UIView *)footerView {
    if (!_footerView) {
        
        CGFloat height = 0;
        if (IPHONE_X_5_15) {
            height = KScreenHeight - STATUSHEIGHT - 44 - 83;
        }else{
            height = KScreenHeight - STATUSHEIGHT - 44 - 49;
        }
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, height)];
        [_footerView addSubview:self.menuView];
        self.tableFooterView.frame = CGRectMake(0, 44, KScreenWidth, height - 44);
        [_footerView addSubview:self.tableFooterView];
    }
    return _footerView;
}

-(ZFCommunityHomeCMSViewAOP *)analyticsAOP {
    if (!_analyticsAOP) {
        _analyticsAOP = [[ZFCommunityHomeCMSViewAOP alloc] init];
    }
    return _analyticsAOP;
}

@end
