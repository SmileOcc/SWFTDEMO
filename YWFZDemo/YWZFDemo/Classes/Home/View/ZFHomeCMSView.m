//
//  ZFHomeCMSView.m
//  ZZZZZ
//
//  Created by YW on 2019/6/12.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFHomeCMSView.h"

#import "ZFInitViewProtocol.h"
#import "Masonry.h"
#import "UIView+ZFViewCategorySet.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "ZFLocalizationString.h"
#import "ZFFireBaseAnalytics.h"
#import "ZFNotificationDefiner.h"
#import "ZF3DTouchHeader.h"
#import "ZFProgressHUD.h"
#import "ZFCommunityHomeTableFooterView.h"
#import "ZFCommunityHomeMenuView.h"
#import "ZFCommunityHomeCMSFooterView.h"
#import "ZFNoDataTableViewCell.h"
#import "ZFCommunityChannelModel.h"
#import "CommunityEnumComm.h"
#import "ZFGoodsDetailViewController.h"
#import "ZFCMSVideoPlayerManager.h"
#import "ZFNetworkManager.h"

@interface ZFHomeCMSView ()<ZFCMSManagerViewProtocol,UIScrollViewDelegate>
@property (nonatomic, strong) ZFCMSVideoPlayerManager *videoManager;

@property (nonatomic, strong) NSDictionary *pageInfo;

@end

@implementation ZFHomeCMSView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)zf_viewDidShow {
    self.cmsViewModel.controller = self.viewController;
}

- (instancetype)initWithFrame:(CGRect)frame
                 firstChannel:(NSString *)firstChannel
                      channel:(NSString *)channel
                        title:(NSString *)title {
    self = [super initWithFrame:frame];
    if (self) {
        self.title = title;
        self.firstChannelId = firstChannel;
        self.channelId = channel;
        
        // 获取历史浏览记录
        [self.cmsViewModel fetchRecentlyGoods:nil];
        [[AnalyticsInjectManager shareInstance] analyticsInject:self injectObject:self.analyticsAOP];

        [self zfInitView];
        [self zfAutoLayoutView];
        [self addNotification];
    }
    return self;
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(insertGoodsToHistoryFromAdGroup) name:kAdGroupGoodsKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCurrency) name:kCurrencyNotification object:nil];
    // 登录刷新通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loginChangeCollectionRefresh) name:kLoginNotification object:nil];
}

- (void)setAllowScrollToRecommend:(BOOL)allowScrollToRecommend {
    _allowScrollToRecommend = allowScrollToRecommend;
    self.cmsManagerView.allowScrollToRecommend = allowScrollToRecommend;
}

- (void)setRecommendSectionIndex:(NSUInteger)recommendSectionIndex {
    _recommendSectionIndex = recommendSectionIndex;
    self.cmsManagerView.recommendSectionIndex = recommendSectionIndex;
}

#pragma mark - Notifacation
/// 汇率切换需要刷新列表的价格
- (void)changeCurrency {
    [self.cmsManagerView reloadView:NO];
}

/**
 * 插入来自延迟深度链接带入的广告商品数据
 */
- (void)insertGoodsToHistoryFromAdGroup {
    // 检索出fb广告链接带进来的商品数据
    @weakify(self)
    [self.cmsViewModel retrievalAFGoodsGoodsData:^{
        @strongify(self)
        // 获取历史浏览记录
        [self updateCMSHistoryGoods];
    }];
}

- (void)loginChangeCollectionRefresh {

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // 读取本地数据
        [[ZFCMSCouponManager manager] getLocalCmsCouponList];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.cmsViewModel configCMSCouponItemsSource:self.cmsManagerView.cmsSectionModelArr fillData:nil];
            [self.cmsManagerView reloadView:NO];
            [self.cmsManagerView.collectionView showRequestTip:self.pageInfo];
        });
    });
}
#pragma mark - ============ 请求列表数据 ============

/**
 * CMS列表 顶部广告banner等数据
 */
- (void)requestCMSAdvertData:(BOOL)showLoading {
    
    @weakify(self)
    self.allowScrollToRecommend = NO;
    self.recommendSectionIndex = 0;
    if (showLoading) {
        ShowLoadingToView(self);
    }
    [self.cmsViewModel requestHomeListData:self.channelId isRequestCMSMainUrl:YES completion:^(NSArray<ZFCMSSectionModel *>*cmsModelArr, BOOL isCacheData) {
        @strongify(self)
        HideLoadingFromView(self);
        
        [self dealwithHomeListData:cmsModelArr isCacheData:isCacheData];
        [self.cmsManagerView reloadView:YES];
        
        // 推荐接口没回来之前先保留上拉控件
        if (!isCacheData) {
            [self.cmsManagerView.collectionView showRequestTip:@{kTotalPageKey  : @(100),
            kCurrentPageKey: @(1)}];
        }
    }];
}

/**
 * 主页列表数据源
 */
- (void)dealwithHomeListData:(NSArray<ZFCMSSectionModel *> *)cmsModelArr isCacheData:(BOOL)isCacheData
{
    if (![cmsModelArr isKindOfClass:[NSArray class]]) return;
    [self.cmsManagerView removeSectionBgColorView];
    self.cmsManagerView.cmsSectionModelArr = [NSMutableArray arrayWithArray:cmsModelArr];
    [self.cmsManagerView.recommendGoodsArr removeAllObjects];
    
    // 设置是否上拉加载
    BOOL showFooter = (self.cmsViewModel.recommendSectionModel) ? YES : NO;
    [self addFooterLoadingMore:showFooter];
    if (showFooter && !isCacheData) {
        /**
         * 请求推荐商品数据
         * V4.6.0 因推送打开App的并发量过高造成后台压力过大,
         * 在后续版本中去掉进入主页后立马请求推荐商品数据的操作, 当滚到底部时才上拉触发请求
         */
        // [self requestCMSCommenderData:YES];
    }
    
    // 遍历查询是否需要异步请求滑动SKU组件的商品数据
    [self requestSlideSKUModuleData];
    
    // 请求优惠券信息
    [self requestCMSCouponRelateData];
    
    // 显示下拉banner数据
    if (![self.cmsManagerView.collectionView.mj_header isKindOfClass:[ZFRefreshHeader class]]) return;
    
    ZFBannerModel *pullBannerModel = [self.cmsViewModel.cmsPullDownModel configDeeplinkBannerModel];
    if (!ZFIsEmptyString(pullBannerModel.image)) {
        self.cmsManagerView.collectionView.showDropBanner = YES;
        ((ZFRefreshHeader *)self.cmsManagerView.collectionView.mj_header).bannerModel = pullBannerModel;
    } else {
        self.cmsManagerView.collectionView.showDropBanner = NO;
        ((ZFRefreshHeader *)self.cmsManagerView.collectionView.mj_header).bannerModel = nil;
    }
}

/// 请求优惠券信息
- (void)requestCMSCouponRelateData {
    
    __block NSMutableArray *couponArrays = [[NSMutableArray alloc] init];
    [self.cmsManagerView.cmsSectionModelArr enumerateObjectsUsingBlock:^(ZFCMSSectionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.type == ZFCMS_CouponModule_Type) {
            [obj.list enumerateObjectsUsingBlock:^(ZFCMSItemModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (!ZFIsEmptyString(obj.coupon_id)) {
                    [couponArrays addObject: obj.coupon_id];
                }
            }];
        }
    }];
    
    NSString *couponString = [couponArrays componentsJoinedByString:@","];
    if (!ZFIsEmptyString(couponString)) {
        
        @weakify(self)
        [self.cmsViewModel requestCMSCouponData:couponString completion:^(NSArray<ZFCMSCouponModel *> * _Nonnull array) {
            @strongify(self)
            
            if (ZFJudgeNSArray(array) && array.count > 0) {
                [self.cmsViewModel configCMSCouponItemsSource:self.cmsManagerView.cmsSectionModelArr fillData:array];
                [self.cmsManagerView reloadView:NO];
                [self.cmsManagerView.collectionView showRequestTip:self.pageInfo];
            }
            
        } failure:^(NSError * _Nonnull error) {
            
        }];
    }
}

/**
 * 遍历查询是否需要异步请求滑动SKU组件的商品数据
 */
- (void)requestSlideSKUModuleData {
    
    [self.cmsManagerView.cmsSectionModelArr enumerateObjectsUsingBlock:^(ZFCMSSectionModel *sectionModel, NSUInteger idx, BOOL * _Nonnull stop) {
        // 仅商品运营平台选品组件
        if (sectionModel.type == ZFCMS_SlideBanner_Type && sectionModel.subType == ZFCMS_SkuSelection_SubType) {
            if ((!sectionModel.list || sectionModel.list.count == 0)) {
                
                @weakify(self)
                [self.cmsViewModel requestSlidSkuModuleData:sectionModel
                                                  channelID:self.channelId
                                                 completion:^(NSArray<ZFGoodsModel *> * _Nonnull array) {
                    @strongify(self)
                    if (ZFJudgeNSArray(array) && array.count > 0) {
                        [self.cmsViewModel configSlideSKUModuleData:sectionModel
                                                        cmsModelArr:self.cmsManagerView.cmsSectionModelArr
                                                           fillData:array];
                        [self.cmsManagerView reloadView:NO];
                        [self.cmsManagerView.collectionView showRequestTip:self.pageInfo];
                    }
                    
                } failure:nil];
            }
        }
    }];
}

/**
 * CMS列表 底部推荐商品数据
 */
- (void)requestCMSCommenderData:(BOOL)firstPage {
    @weakify(self)
    self.cmsManagerView.allowScrollToRecommend = NO;
    self.recommendSectionIndex = 0;
    ZFCMSSectionModel *recommendModel = self.cmsViewModel.recommendSectionModel;
    [self.cmsViewModel requestCmsRecommendData:firstPage
                                  sectionModel:recommendModel
                                     channelID:self.channelId
                                    completion:^(NSArray<ZFGoodsModel *> * currentPageGoodsArr, NSDictionary *pageInfo) {
                                        @strongify(self)
                                        if (firstPage) {
                                            [self.cmsManagerView.recommendGoodsArr removeAllObjects];
                                        }
                                        if (currentPageGoodsArr.count > 0) {
                                            [self.cmsManagerView.recommendGoodsArr addObjectsFromArray:currentPageGoodsArr];
                                        }
                                        //设置统计代码中的实验id
                                        self.analyticsAOP.af_params = pageInfo[@"af_params"];
                                        self.pageInfo = pageInfo;
                                        [self.cmsManagerView reloadView:NO];
                                        [self.cmsManagerView.collectionView showRequestTip:pageInfo];
                                        
                                        // 找到推荐商品位置,单击Tabbar时用到
                                        if (self.cmsManagerView.recommendGoodsArr.count > 0) {
                                            for (NSInteger i=0; i<self.cmsManagerView.cmsSectionModelArr.count; i++) {
                                                ZFCMSSectionModel *sectionModel = self.cmsManagerView.cmsSectionModelArr[i];
                                                if (sectionModel.type == ZFCMS_RecommendGoods_Type) {
                                                    self.cmsManagerView.recommendSectionIndex = i;
                                                    self.cmsManagerView.allowScrollToRecommend = YES;
                                                    break;
                                                }
                                            }
                                        }
                                    } failure:^(NSError *error){
                                        @strongify(self)
                                        if (self.cmsManagerView.cmsSectionModelArr.count > 0) {
                                            //ShowToastToViewWithText(self.view, error.domain); V4.6.0不需要提示
                                        }
                                        [self.cmsManagerView.collectionView showRequestTip:nil];
                                    }];
}

/// 处理优惠券信息
- (void)receiveCoupon:(ZFCMSCouponModel *)couponModel complect:(void (^)(BOOL success,NSInteger state))completion{

    showSystemStatusBar();
    @weakify(self)
    [self.viewController judgePresentLoginVCCompletion:^{
        @strongify(self)
        hideSystemStatusBar();

        // 领取优惠券
        ShowLoadingToView(self.viewController.view);
        
        // 1. 调取领劵接口
        @weakify(self)
        [ZFCommunityLiveVideoGoodsModel requestGetGoodsCoupon:couponModel.idx completion:^(BOOL success, NSInteger couponStatus) {
            @strongify(self)

            // 1:领劵成功;2:领券Coupon不存在;3:已领券;4:没到领取时间;5:已过期;6:coupon已领取完;7:赠送coupon失败
            // 默认提示已领完
            NSString *tiptext = ZFLocalizedString(@"Hom_Coupon_Claimed_Failed", nil);

            // 注意界面显示状态 // coupon状态；1:可领取;2:已领取;3:已领取完
            NSInteger state = 1;
            if (success) {
                if (couponStatus == 1) {
                    tiptext = ZFLocalizedString(@"Hom_Coupon_Claimed_Success", nil);
                    state = 2;

                } else if(couponStatus == 3) {
                    tiptext = ZFLocalizedString(@"Hom_Coupon_Claimed", nil);
                    state = 2;
                }
                else if (couponStatus == 6) {
                    tiptext = ZFLocalizedString(@"Hom_Coupon_No_Left", nil);
                    state = 3;

                } else if(couponStatus == 2 || couponStatus == 7) {
                    state = 3;
                } else if(couponStatus == 4) {
                    tiptext = ZFLocalizedString(@"Hom_Coupon_UnStart", nil);
                } else if(couponStatus == 5) {
                    tiptext = ZFLocalizedString(@"Hom_Coupon_Expired", nil);
                    state = 3;
                }
                if (completion) {
                    completion(YES,state);
                }
                ShowToastToViewWithText(self.viewController.view, tiptext);

                // 保存优惠券数据到本地,是否可以点击
            } else {
                ShowToastToViewWithText(self.viewController.view, tiptext);
                if (completion) {
                    completion(NO,state);
                }
            }
        }];
    } cancelCompetion:^{
        hideSystemStatusBar();
    }];
}

#pragma mark - Private method

- (void)actionDropBanner {
    if (self.cmsViewModel.cmsPullDownModel.list.count > 0) {
        ZFCMSItemModel *itemModel = self.cmsViewModel.cmsPullDownModel.list[0];
        [self zf_cmsManagerView:self.cmsManagerView collectionView:self.cmsManagerView.collectionView eventCell:nil deeplinkItem:itemModel source:@""];
    }
}


/** 初始化下拉刷新控件 */
- (void)addListViewRefreshKit {
    BOOL shouldRequest = YES;
    
    if (ZFJudgeNSArray(self.homeSectionModelArr) && self.homeSectionModelArr.count > 0) {
        NSArray<ZFCMSSectionModel *> *configModelArr = [self.cmsViewModel configCMSListData:self.homeSectionModelArr];
        [self dealwithHomeListData:configModelArr isCacheData:NO];
        shouldRequest = NO;
    }
    
    @weakify(self)
    [self.cmsManagerView addListHeaderRefreshBlock:^{
        @strongify(self)
        // CMS列表 顶部广告banner等数据
        BOOL showLoading = (self.cmsManagerView.cmsSectionModelArr.count == 0);
        [self requestCMSAdvertData:showLoading];
        [self.videoManager stopCurrentPlayer];
        
    } PullingShowBannerBlock:^{
        @strongify(self)
        [self actionDropBanner];
    } footerRefreshBlock:nil startRefreshing:NO];
    
    if (shouldRequest) { //加载时取消动画
        [self.cmsManagerView.collectionView headerRefreshingByAnimation:NO];
    }
}

/**
 * 设置是否能上拉加载更多
 */
- (void)addFooterLoadingMore:(BOOL)showLoadingMore {
    @weakify(self)
    [self.cmsManagerView addFooterLoadingMore:showLoadingMore footerBlock:^{
        @strongify(self)
        // CMS列表 底部推荐商品数据
        [self requestCMSCommenderData:NO];
    }];
}

/** 动态设置预加载偏移值*/
- (void)updateRefreshFooterAutomaticallyValue:(BOOL)isAutomatically {
    
    // 问题：在刷新时，底部也在刷新，造成头部位置问题
    // 刷新时，先设置预加载为1，防止刷新时预加载触发底部加载更多事件
    MJRefreshFooter *refreshFooter = self.cmsManagerView.collectionView.mj_footer;
    if ([refreshFooter isMemberOfClass:[ZFRefreshFooter class]]) {
        ZFRefreshFooter *zfRefreshFooter = (ZFRefreshFooter *)refreshFooter;

        if (isAutomatically) {
            CGFloat preloadHight = KScreenHeight * 1; ///< 预加载一页数据
            zfRefreshFooter.triggerAutomaticallyRefreshPercent = -preloadHight / zfRefreshFooter.mj_h;;
        } else {
            zfRefreshFooter.triggerAutomaticallyRefreshPercent = 1.0;
        }
    }
}

/** 更新历史浏览记录 */
- (void)updateCMSHistoryGoods {
    if (self.cmsManagerView.cmsSectionModelArr.count == 0) return;
    if (!self.cmsViewModel.historySectionModel) return;
    
    @weakify(self)
    [self.cmsViewModel fetchRecentlyGoods:^(NSArray<ZFCMSItemModel *> *itemModelArr) {
        @strongify(self)
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

/*
 * 滚动到推荐商品位置
 */
- (void)scrollToRecommendPosition {
    [self.cmsManagerView scrollToRecommendPosition];
}

- (BOOL)isHomePage
{
    if ([self.firstChannelId isEqualToString:self.channelId]) {
        return YES;
    }
    return NO;
}

#pragma mark - ZFCMSManagerViewProtocol

- (void)zf_cmsManagerView:(ZFCMSManagerView *)managerView collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    //Aop 统计代码方法，不能删除
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
    
    //标记是从3DTouch进来不传动画视图进入商详
    if (cell && goodsModel) {
        NSIndexPath *indexPath = [managerView.collectionView indexPathForCell:cell];
        if (indexPath) {
            NSNumber *from3DTouchFlag = objc_getAssociatedObject(indexPath, k3DTouchRelationCellComeFrom);
            UIImageView *sourceView = [from3DTouchFlag boolValue] ? nil : cell.goodsImageView;
            
            //增加首页AFParams 传递
            AFparams *afParams = [AFparams yy_modelWithJSON:self.analyticsAOP.af_params];
            
            ZFGoodsDetailViewController *goodsDetailVC = [[ZFGoodsDetailViewController alloc] init];
            goodsDetailVC.goodsId = ZFToString(goodsModel.goods_id);
            goodsDetailVC.afParams = afParams;
            ZFAppsflyerInSourceType type = ZFAppsflyerInSourceTypeHome;
            if (![self isHomePage]) {
                type = ZFAppsflyerInSourceTypeHomeChannel;
                goodsDetailVC.sourceID = self.channelId;
            }
            goodsDetailVC.sourceType = type;
            goodsDetailVC.af_rank = goodsModel.af_rank;
            goodsDetailVC.hidesBottomBarWhenPushed = YES;
            if (sourceView) {
                goodsDetailVC.transformSourceImageView = sourceView;
                self.navigationController.delegate = goodsDetailVC;
            } else {
                self.navigationController.delegate = nil;
            }
            [self.navigationController pushViewController:goodsDetailVC animated:YES];
        }
    }
}

/** 点击优惠券*/
- (void)zf_cmsManagerView:(ZFCMSManagerView *)managerView collectionView:(UICollectionView *)collectionView couponCell:(ZFCMSCouponCCell *)cell model:(ZFCMSItemModel *)model {
    

    if (model && model.couponModel.couponState != 2) { // 非已领取下，都触发接口
        
        [self receiveCoupon:model.couponModel complect:^(BOOL success,NSInteger state) {
            
            if (success) {
                
                ZFCMSSectionModel *sectionModel;
                NSIndexPath *indexPath = [collectionView indexPathForCell:cell];
                
                if (managerView.cmsSectionModelArr.count > indexPath.section) {
                    sectionModel = managerView.cmsSectionModelArr[indexPath.section];
                    
                    if (ZFJudgeNSArray(sectionModel.list)) {
                        [sectionModel.list enumerateObjectsUsingBlock:^(ZFCMSItemModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            if ([obj.col_id isEqualToString:model.col_id]) {
                                obj.couponModel.couponState = state;
                                [ZFCMSCouponManager saveCouponStateModel:obj.couponModel];
                                
                                *stop = YES;
                            }
                        }];
                    }
                }
                
                [cell updateItem:sectionModel.list sctionModel:sectionModel];
            }
        }];
    }
    
    
}

- (void)zf_cmsManagerView:(ZFCMSManagerView *)managerView collectionView:(UICollectionView *)collectionView recommendCell:(ZFCMSRecommendGoodsCCell *)cell dislikeRecommendGoods:(ZFGoodsModel *)goodsModel {
    if (cell && goodsModel) {
        
    }
}

- (void)zf_cmsManagerView:(ZFCMSManagerView *)managerView collectionView:(UICollectionView *)collectionView clearHistoryCompletion:(BOOL)flag {
    [self.cmsViewModel clearCMSHistoryAction];
}

- (void)zf_cmsManagerView:(ZFCMSManagerView *)managerView collectionView:(UICollectionView *)collectionView videoPlayerCell:(ZFCMSVideoCCell *)cell model:(ZFCMSItemModel *)model
{
    [self.videoManager startPlayer:model.video_id frame:cell.frame];
}

////
- (void)zf_cmsScrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ([scrollView isEqual:self.cmsManagerView.collectionView]) {
        
        BOOL showFloatInputBar = ((scrollView.mj_offsetY > kFloatHomeBarHeight) ? YES : NO);
        if (self.showFloatInputBarBlock) {
            self.showFloatInputBarBlock(showFloatInputBar, scrollView.contentOffset.y);
        }
        [self.videoManager videoPlayerScrollViewDidScroll:scrollView];
        [self updateRefreshFooterAutomaticallyValue:scrollView.mj_offsetY >= 50];
    }
}

- (void)zf_cmsScrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.showFloatBannerBlock) {
        self.showFloatBannerBlock(YES);
    }
    [self.videoManager videoPlayerScrollViewDidEndDecelerating:scrollView];
}

- (void)zf_cmsScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([scrollView isEqual:self.cmsManagerView.collectionView]) {
        if (!decelerate && self.showFloatBannerBlock) {
            self.showFloatBannerBlock(YES);
        }
        [self.videoManager videoPlayerScrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)zf_cmsScrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    if ([scrollView isEqual:self.cmsManagerView.collectionView]) {
        if (self.showFloatBannerBlock) {
            self.showFloatBannerBlock(NO);
        }
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

#pragma mark - Property Method

- (ZFCMSViewModel *)cmsViewModel {
    if (!_cmsViewModel) {
        _cmsViewModel = [[ZFCMSViewModel alloc] init];
        //如果视图还没加到控制器上是，取不到
        _cmsViewModel.controller = self.viewController;
    }
    return _cmsViewModel;
}

- (ZFCMSManagerView *)cmsManagerView {
    if (!_cmsManagerView) {
        _cmsManagerView = [[ZFCMSManagerView alloc] initWithFrame:self.bounds channelId:self.channelId showRecommend:YES];
        _cmsManagerView.channelName = self.title;
        [_cmsManagerView baseConfigureSource:ZFAnalyticsAOPSourceHome analyticsId:[NSString stringWithFormat:@"%@_%@",NSStringFromClass(ZFHomeCMSView.class),self.title] screenName:NSStringFromClass(ZFHomeCMSView.class)];
        _cmsManagerView.delegate = self;
        [_cmsManagerView forbidCollectionRecognizeSimultaneously:YES];
    }
    return _cmsManagerView;
}

- (ZFCMSVideoPlayerManager *)videoManager
{
    if (!_videoManager) {
        _videoManager = [ZFCMSVideoPlayerManager manager:ZFVideoPlayerType_OnlyOne superView:self.cmsManagerView.collectionView];
    }
    return _videoManager;
}

-(ZFCMSHomeAnalyticsAOP *)analyticsAOP {
    if (!_analyticsAOP) {
        _analyticsAOP = [[ZFCMSHomeAnalyticsAOP alloc] init];
        if ([self.firstChannelId isEqualToString:self.channelId]) {
            _analyticsAOP.isHomePage = YES;
        }
        _analyticsAOP.channel_name = self.title;
        _analyticsAOP.channel_id = self.channelId;
        NSString *analyticsId = [NSString stringWithFormat:@"%@_%@",ZFToString(self.title),ZFToString(self.channelId)];
        [_analyticsAOP baseConfigureSource:ZFAnalyticsAOPSourceHome analyticsId:analyticsId];
        
    }
    return _analyticsAOP;
}

@end
