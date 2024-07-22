//
//  ZFCMSManagerView.m
//  ZZZZZ
//
//  Created by YW on 2019/5/16.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCMSManagerView.h"
#import "ZFInitViewProtocol.h"
#import "Masonry.h"
#import "ZFHomeCMSView.h"
#import "ZFProgressHUD.h"

@interface ZFCMSManagerView ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,ZFInitViewProtocol>

/** 组的背景色值数据源*/
@property (nonatomic, strong) NSMutableArray                           *sectionBgColorViewArr;

@property (nonatomic, assign) BOOL                                     isShowRecommend;

@property (nonatomic, strong) ZFCMSRecommendGoodsCCell                 *lastRecommendCell;


/**用于统计区分*/
@property (nonatomic, assign) ZFAnalyticsAOPSource                     source;
@property (nonatomic, copy) NSString                                   *viewID;
@property (nonatomic, copy) NSString                                   *screenName;

@end

@implementation ZFCMSManagerView

- (instancetype)init {
    @throw [NSException exceptionWithName:@"ZFCMSManagerView init error" reason:@"Please use the designated initializer." userInfo:nil];
    return [self initWithFrame:CGRectZero channelId:NSStringFromClass(ZFCMSManagerView.class) showRecommend:NO];
}

- (instancetype)initWithFrame:(CGRect)frame channelId:(NSString *)channelId showRecommend:(BOOL)showRecommend {
    self = [super initWithFrame:frame];
    if (self) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
           // 读取本地数据
            [[ZFCMSCouponManager manager] getLocalCmsCouponList];
        });
        
        self.channelId = channelId;
        self.isShowRecommend = showRecommend;
        [self zfInitView];
        [self zfAutoLayoutView];
        
        // 登录刷新通知
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loginChangeCollectionRefresh) name:kLoginNotification object:nil];
        // 登出刷新通知
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(logoutChangeCollectionRefresh) name:kLogoutNotification object:nil];
    }
    return self;
}

- (void)baseConfigureSource:(ZFAnalyticsAOPSource)source analyticsId:(NSString *)idx screenName:(NSString *)screenName {
    self.viewID = idx ? idx : NSStringFromClass(ZFCMSManagerView.class);
    self.screenName = screenName ? screenName : NSStringFromClass(ZFCMSManagerView.class);
    self.source = source;
}

- (void)loginChangeCollectionRefresh {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
       // 读取本地数据
       [[ZFCMSCouponManager manager] getLocalCmsCouponList];
    });
}

- (void)logoutChangeCollectionRefresh {
    
    [[ZFCMSCouponManager manager].localCouponList removeAllObjects];
    [self.cmsSectionModelArr enumerateObjectsUsingBlock:^(ZFCMSSectionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.type == ZFCMS_CouponModule_Type) {
            if (ZFJudgeNSArray(obj.list)) {
                [obj.list enumerateObjectsUsingBlock:^(ZFCMSItemModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (obj.couponModel) {
                        obj.couponModel.couponState = 0;
                    }
                }];
            }
        }
    }];
    [self reloadView:NO];
}

#pragma mark - ZFInitViewProtocol

- (void)zfInitView {
    [self addSubview:self.collectionView];
}

- (void)zfAutoLayoutView {
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
}

#pragma mark - UICollectionDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.cmsSectionModelArr.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    ZFCMSSectionModel *sectionModel = self.cmsSectionModelArr[section];
    if (sectionModel.type == ZFCMS_RecommendGoods_Type) {
        if (!self.isShowRecommend) {
            return 0;
        }
        return self.recommendGoodsArr.count;
    } else {
        return sectionModel.sectionItemCount;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // 做好异常兼容,防止数据异常崩溃
    if (self.cmsSectionModelArr.count <= indexPath.section) {
        return [self configDefaultCell:indexPath];
    }
    ZFCMSSectionModel *sectionModel = self.cmsSectionModelArr[indexPath.section];
    ZFCMSItemModel *itemModel = nil;
    
    if (sectionModel.type == ZFCMS_RecommendGoods_Type) {
        if (self.recommendGoodsArr.count <= indexPath.item) {
            return [self configDefaultCell:indexPath];
        }
    } else {
        if (sectionModel.list.count <= indexPath.item) {
            return [self configDefaultCell:indexPath];
        } else {
            itemModel = sectionModel.list[indexPath.item];
        }
    }
    
    switch (sectionModel.type) {
        case ZFCMS_BannerPop_Type:  //弹窗
        case ZFCMS_DropDownBanner_Type: //下拉banner
        case ZFCMS_FloatingGBanner_Type: //页面右下角小浮窗banner
        {
            YWLog(@"CMS列表暂时不处理 %ld 类型数据", (long)sectionModel.type);
        }
            break;
            
        case ZFCMS_CycleBanner_Type: //轮播banner
        case ZFCMS_VerCycleBanner_Type:
        {
            ZFCMSCycleBannerCell *cycleBannerCell = [ZFCMSCycleBannerCell cycleBannerCellWith:collectionView forIndexPath:indexPath];
            [cycleBannerCell.analyticsAop baseConfigureSource:self.source analyticsId:self.viewID];
            cycleBannerCell.channel_id = ZFToString(self.channelId);
            cycleBannerCell.channel_name = ZFToString(self.channelName);
            [cycleBannerCell updateCycleBanner:sectionModel indexPath:indexPath];
            
            @weakify(self);
            @weakify(cycleBannerCell)
            cycleBannerCell.cycleBannerClick = ^(ZFCMSItemModel *itemModel) {
                @strongify(self);
                @strongify(cycleBannerCell)
                [self clickCell:cycleBannerCell sectionItemModel:itemModel source:nil];
            };
        
            return cycleBannerCell;
        }
            break;
            
        case ZFCMS_BranchBanner_Type: //多分馆即固定
        {
            ZFCMSNormalBannerCell *branchBannerCell = [ZFCMSNormalBannerCell reusableNormalBannerCell:collectionView forIndexPath:indexPath];
            branchBannerCell.itemModel = itemModel;
            branchBannerCell.cellBackgroundColor = sectionModel.bgColor;
            //倒计时:配置位置
            [branchBannerCell updateCmsAttributes:sectionModel.attributes cellHeight:sectionModel.sectionItemSize.height];
            return branchBannerCell;
        }
            break;
            
        case ZFCMS_SlideBanner_Type:    //滑动banner (subType: 商品类型, banner类型, 商品历史浏览记录)
        {
            // 滑动普通banner
            if (sectionModel.subType == ZFCMS_NormalBanner_SubType) {
                
                ZFCMSSliderNormalBannerSectionView *normalBannerCell = [ZFCMSSliderNormalBannerSectionView reusableNormalBanner:collectionView forIndexPath:indexPath];
                
                [normalBannerCell.analyticsAOP baseConfigureSource:self.source analyticsId:self.viewID];
                normalBannerCell.channel_id = ZFToString(self.channelId);
                normalBannerCell.channel_name = ZFToString(self.channelName);
                normalBannerCell.sectionModel = sectionModel;
                @weakify(self)
                @weakify(normalBannerCell)
                normalBannerCell.normalBannerClick = ^(ZFCMSItemModel *itemModel) {
                    @strongify(self)
                    @strongify(normalBannerCell)
                    [self clickCell:normalBannerCell sectionItemModel:itemModel source:nil];
                };
                return normalBannerCell;
                
                // 滑动商品banner
                // 滑动商品历史浏览记录
                // 滑动商品运营平台选品
            } else if (sectionModel.subType == ZFCMS_SkuBanner_SubType ||
                       sectionModel.subType == ZFCMS_SkuSelection_SubType ||
                       sectionModel.subType == ZFCMS_HistorSku_SubType) {
                
                ZFCMSSliderSKUBannerSectionView *skuBannerCell = [ZFCMSSliderSKUBannerSectionView reusableSkuBanner:collectionView forIndexPath:indexPath];
                skuBannerCell.channel_id = ZFToString(self.channelId);
                skuBannerCell.channel_name = ZFToString(self.channelName);
                [skuBannerCell.sliderSKUanalyticsAOP baseConfigureSource:self.source analyticsId:self.viewID];
                skuBannerCell.sectionModel = sectionModel;
                
                @weakify(self)
                @weakify(skuBannerCell)
                skuBannerCell.clickSliderSkuBlock = ^(ZFCMSItemModel *itemModel) {
                    @strongify(self)
                    @strongify(skuBannerCell)
                    [self clickSliderSkuCell:skuBannerCell sectionModel:sectionModel itemModel:itemModel];
                };
                
                skuBannerCell.clickClearHistSkuBlock = ^(void) {
                    @strongify(self)
                    sectionModel.sectionItemCount = 0;
                    [ZFGoodsModel deleteAllGoods];
                    [collectionView performBatchUpdates:^{
                        [collectionView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
                    } completion:^(BOOL finished) {
                        [self clearHistorySuccess];
                    }];
                };
                return skuBannerCell;
            }
        }
            break;
            
        case ZFCMS_GridMode_Type:      // 平铺,格子模式 (subType: 商品类型, banner类型)
        {
            //平铺banner类型
            if (sectionModel.subType == ZFCMS_NormalBanner_SubType) {
                ZFCMSNormalBannerCell *bannerCell = [ZFCMSNormalBannerCell reusableNormalBannerCell:collectionView forIndexPath:indexPath];
                bannerCell.itemModel = itemModel;
                bannerCell.cellBackgroundColor= sectionModel.bgColor;
                
                // 设置平铺Section背景颜色
                [self showSectionBgColor:indexPath sectionY:CGRectGetMinY(bannerCell.frame) sectionModel:sectionModel];
                return bannerCell;
                
                //平铺商品类型
            } else if (sectionModel.subType == ZFCMS_SkuBanner_SubType) {
                ZFCMSSkuBannerCell *skuCell = [ZFCMSSkuBannerCell reusableSkuBannerCell:collectionView forIndexPath:indexPath];
                skuCell.itemModel = itemModel;
                //skuCell.attributes = sectionModel.attributes;
                skuCell.cellBackgroundColor = sectionModel.bgColor;
                
                // 设置平铺Section背景颜色
                [self showSectionBgColor:indexPath sectionY:CGRectGetMinY(skuCell.frame) sectionModel:sectionModel];
                return skuCell;
            }
        }
            break;
            
        case ZFCMS_SecKillModule_Type:   // 秒杀组件
        {
            ZFCMSSliderSecKillSectionView *secKillCell = [ZFCMSSliderSecKillSectionView reusableSecKillView:collectionView forIndexPath:indexPath];
            secKillCell.channel_id = ZFToString(self.channelId);
            [secKillCell.sliderSKUanalyticsAOP baseConfigureSource:self.source analyticsId:self.viewID];
            secKillCell.sectionModel = sectionModel;
        
            @weakify(self)
            @weakify(secKillCell)
            secKillCell.sliderSkuClick = ^(ZFCMSItemModel *itemModel) {
                @strongify(self)
                @strongify(secKillCell)
                [self clickCell:secKillCell sectionItemModel:itemModel source:nil];
            };
            return secKillCell;
        }
            break;
            
        case ZFCMS_TextModule_Type:  // 纯文本栏目
        {
            ZFCMSTextModuleCell *textModuleCell = [ZFCMSTextModuleCell reusableTextModuleCell:collectionView forIndexPath:indexPath];
            textModuleCell.sectionModel = sectionModel;
            return textModuleCell;
        }
            break;
            
        case ZFCMS_RecommendGoods_Type:  // 推荐商品栏
        {
            ZFCMSRecommendGoodsCCell *recommendCell = [ZFCMSRecommendGoodsCCell reusableRecommendGoodsCell:collectionView forIndexPath:indexPath];
            ZFGoodsModel *goodsModel = self.recommendGoodsArr[indexPath.item];
            recommendCell.goodsModel = goodsModel;
            recommendCell.attributes = sectionModel.attributes;
        
            if (self.viewController) {
                [self.viewController register3DTouchAlertWithDelegate:collectionView sourceView:recommendCell goodsModel:goodsModel];
            }
            @weakify(self)
            @weakify(recommendCell)
            recommendCell.dislikeBlock = ^(ZFGoodsModel *goodsModel) {
                @strongify(self)
                @strongify(recommendCell)
                [self clickCellRecommendGoods:recommendCell dislikeGoodsModel:goodsModel];
            };
        
            recommendCell.coverShowBlock = ^(BOOL isShow) {
                @strongify(self)
                @strongify(recommendCell);
                if (self.lastRecommendCell && [self.lastRecommendCell isKindOfClass:[ZFCMSRecommendGoodsCCell class]] && self.lastRecommendCell != recommendCell) {
                    [self.lastRecommendCell showCoverMaskView:NO];
                }
                self.lastRecommendCell = recommendCell;
            };
        
            return recommendCell;
        }
            break;
        case ZFCMS_VideoPlayer_Type:
        {
            ZFCMSVideoCCell *videoCell = [ZFCMSVideoCCell reusableTextModuleCell:collectionView forIndexPath:indexPath];
            videoCell.itemModel = itemModel;
            @weakify(self)
            @weakify(videoCell)
            videoCell.CMSCellPlayerVideo = ^(ZFCMSItemModel * _Nonnull itemModel) {
                @strongify(self)
                @strongify(videoCell)
                [self clickVideoPlayer:videoCell model:itemModel];
            };
            return videoCell;
        }
            break;
        case ZFCMS_CouponModule_Type: {
            
            ZFCMSCouponCCell *couponCell;
            
            if ([sectionModel.display_count integerValue] == 2) {
                couponCell = (ZFCMSCouponTwoCCell *)[ZFCMSCouponTwoCCell reusableCouponModuleCell:collectionView forIndexPath:indexPath];
                
            } else if ([sectionModel.display_count integerValue] == 3) {
                couponCell = (ZFCMSCouponThreeCCell *)[ZFCMSCouponThreeCCell reusableCouponModuleCell:collectionView forIndexPath:indexPath];
                
            } else if ([sectionModel.display_count integerValue] == 4) {
                couponCell = (ZFCMSCouponFourCCell *)[ZFCMSCouponFourCCell reusableCouponModuleCell:collectionView forIndexPath:indexPath];
                
            } else {
                couponCell = (ZFCMSCouponOneCCell *)[ZFCMSCouponOneCCell reusableCouponModuleCell:collectionView forIndexPath:indexPath];
            }
           
            [couponCell updateItem:sectionModel.list sctionModel:sectionModel];
            
            @weakify(self)
            @weakify(couponCell)
            couponCell.selectBlock = ^(ZFCMSItemModel *itemModel) {
                @strongify(self)
                @strongify(couponCell)
                [self clickCouponCell:couponCell model:itemModel];
            };
            return couponCell;
            
        }
        default:
            break;
    }
    return [self configDefaultCell:indexPath];
}

- (UICollectionViewCell *)configDefaultCell:(NSIndexPath *)indexPath {
    return [self.collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class]) forIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    if (self.cmsSectionModelArr.count <= indexPath.section) return;
    ZFCMSSectionModel *sectionModel = self.cmsSectionModelArr[indexPath.section];
    
    //用于统计
    if ([self.delegate respondsToSelector:@selector(zf_cmsManagerView:collectionView:didSelectItemCell:forItemAtIndexPath:)]) {
        [self.delegate zf_cmsManagerView:self collectionView:collectionView didSelectItemCell:cell forItemAtIndexPath:indexPath];
    }
    
    if (sectionModel.type == ZFCMS_RecommendGoods_Type) {
        if (self.recommendGoodsArr.count <= indexPath.item) return;
        ZFGoodsModel *goodsModel = self.recommendGoodsArr[indexPath.item];
        [self clickCellRecommendGoods:(ZFCMSRecommendGoodsCCell *)cell goodsModel:goodsModel];
        
    } else {
        if (sectionModel.list.count <= indexPath.item) return;
        
        //防止浏览历史记录底部配置很宽,点击底部空白时会触发第一个Cell
        if (sectionModel.type == ZFCMS_SlideBanner_Type && sectionModel.subType == ZFCMS_HistorSku_SubType) return;
        
        if (sectionModel.type == ZFCMS_TextModule_Type) { // 纯文本栏目
            return;
        }
        if (sectionModel.type == ZFCMS_VideoPlayer_Type) { // 视频点击不跳转
            return;
        }
        [self clickCell:cell sectionItemModel:sectionModel.list[indexPath.item] source:nil];
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(zf_cmsManagerView:collectionView:willDisplayCell:forItemAtIndexPath:)]) {
        [self.delegate zf_cmsManagerView:self collectionView:collectionView willDisplayCell:cell forItemAtIndexPath:indexPath];
    }
}

#pragma mark - UICollectionDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFCMSSectionModel *sectionModel = self.cmsSectionModelArr[indexPath.section];
    return sectionModel.sectionItemSize;
}

// 两行之间的上下间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    ZFCMSSectionModel *sectionModel = self.cmsSectionModelArr[section];
    return sectionModel.sectionMinimumLineSpacing;
}

// 两个cell之间的左右间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    ZFCMSSectionModel *sectionModel = self.cmsSectionModelArr[section];
    return sectionModel.sectionMinimumInteritemSpacing;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    ZFCMSSectionModel *sectionModel = self.cmsSectionModelArr[section];
    
    //特殊处理，不显示推荐商品模块时
    if (!self.isShowRecommend && sectionModel.type == ZFCMS_RecommendGoods_Type) {
        return UIEdgeInsetsZero;
    }
    return sectionModel.sectionInsetForSection;
}

// 设置区头尺寸高度
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{

    CGSize size = CGSizeZero;
    if (self.firstHeaderView && (section == self.cmsSectionModelArr.count-1)) {
        size = CGSizeMake(KScreenWidth, CGRectGetHeight(self.firstHeaderView.frame));
    }
    return size;
}
// 设置区尾尺寸高度
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    CGSize size = CGSizeZero;
    if (self.lastFooterView && (section == self.cmsSectionModelArr.count-1)) {
        size = CGSizeMake(KScreenWidth, CGRectGetHeight(self.lastFooterView.frame));
    }
    return size;
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{

    UICollectionReusableView *reusableView = nil;
    // 区头
    if (kind == UICollectionElementKindSectionHeader && self.firstHeaderView && (indexPath.section == self.cmsSectionModelArr.count-1)) {

        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ZFCMSManagerHeaderReusableView" forIndexPath:indexPath];
        [headerView addSubview:self.firstHeaderView];

        reusableView = headerView;

    }
    // 区尾
    if (kind == UICollectionElementKindSectionFooter && self.lastFooterView && (indexPath.section == self.cmsSectionModelArr.count-1)) {

        UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"ZFCMSManagerFooterReusableView" forIndexPath:indexPath];
        [footerView addSubview:self.lastFooterView];
        reusableView = footerView;
    }
    return reusableView;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(zf_cmsScrollViewDidScroll:)]) {
        [self.delegate zf_cmsScrollViewDidScroll:scrollView];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(zf_cmsScrollViewDidEndDecelerating:)]) {
        [self.delegate zf_cmsScrollViewDidEndDecelerating:scrollView];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.delegate && [self.delegate respondsToSelector:@selector(zf_cmsScrollViewDidEndDragging:willDecelerate:)]) {
        [self.delegate zf_cmsScrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(zf_cmsScrollViewWillBeginDragging:)]) {
        [self.delegate zf_cmsScrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(zf_cmsScrollViewDidEndScrollingAnimation:)]) {
        [self.delegate zf_cmsScrollViewDidEndScrollingAnimation:scrollView];
    }
}

#pragma mark - Action

- (void)scrollToRecommendPosition {
    
    if (!self.allowScrollToRecommend || self.recommendSectionIndex < 1) return;
    
    NSInteger recommendTitleSection = self.recommendSectionIndex - 1;
    if (recommendTitleSection < 0) return;
    
    NSIndexPath *recommendPath = [NSIndexPath indexPathForRow:0 inSection:recommendTitleSection];
    if (!recommendPath) return;
    
    UICollectionViewCell *recommendCell = [self collectionView:self.collectionView cellForItemAtIndexPath:recommendPath];
    CGFloat offsetY = CGRectGetMinY(recommendCell.frame);
    
    if (offsetY < 0 || self.collectionView.mj_offsetY >= offsetY) {
        [self.collectionView setContentOffset:CGPointMake(0, 0) animated:YES];
    } else {
        [self.collectionView setContentOffset:CGPointMake(0, offsetY) animated:YES];
    }
}

/**
 * 主页Cell Item 点击 Deeeplink跳转事件, 需要组装一个完整的deeplink字典来做跳转
 * ZZZZZ://action?actiontype=2&url=14&name=swimwear&source=deeplink
 */
- (void)clickCell:(UICollectionViewCell *)cell sectionItemModel:(ZFCMSItemModel *)itemModel source:(NSString *)source {
    if (itemModel && self.delegate && [self.delegate respondsToSelector:@selector(zf_cmsManagerView:collectionView:eventCell:deeplinkItem:source:)]) {
        [self.delegate zf_cmsManagerView:self collectionView:self.collectionView eventCell:cell deeplinkItem:itemModel source:source];
    }
}


/**
 点击推荐商品
 */
- (void)clickCellRecommendGoods:(ZFCMSRecommendGoodsCCell *)cell goodsModel:(ZFGoodsModel *)goodsModel{
    if (goodsModel && self.delegate && [self.delegate respondsToSelector:@selector(zf_cmsManagerView:collectionView:recommendCell:recommendGoods:)]) {
        [self.delegate zf_cmsManagerView:self collectionView:self.collectionView recommendCell:cell recommendGoods:goodsModel];
    }
}

/**
 删除不喜欢推荐的商品
 */
- (void)clickCellRecommendGoods:(ZFCMSRecommendGoodsCCell *)cell dislikeGoodsModel:(ZFGoodsModel *)goodsModel {
    
    NSIndexPath *recommendSection = [self.collectionView indexPathForCell:cell];
    if (self.cmsSectionModelArr.count > recommendSection.section) {
        
        ZFCMSSectionModel *sectionModel = self.cmsSectionModelArr[recommendSection.section];
        if (sectionModel.type == ZFCMS_RecommendGoods_Type) {
            
            if (self.recommendGoodsArr.count > recommendSection.item) {
                [self.recommendGoodsArr removeObjectAtIndex:recommendSection.item];
                [self.collectionView deleteItemsAtIndexPaths:@[recommendSection]];
                
                if (goodsModel && self.delegate && [self.delegate respondsToSelector:@selector(zf_cmsManagerView:collectionView:recommendCell:dislikeRecommendGoods:)]) {
                    [self.delegate zf_cmsManagerView:self collectionView:self.collectionView recommendCell:cell dislikeRecommendGoods:goodsModel];
                }
            }
        }
    }
}

//点击了视频播放组件
- (void)clickVideoPlayer:(ZFCMSVideoCCell *)cell model:(ZFCMSItemModel *)model
{
    if (model && self.delegate && [self.delegate respondsToSelector:@selector(zf_cmsManagerView:collectionView:videoPlayerCell:model:)]) {
        [self.delegate zf_cmsManagerView:self collectionView:self.collectionView videoPlayerCell:cell model:model];
    }
}


- (void)clickSliderSkuCell:(UICollectionViewCell *)cell sectionModel:(ZFCMSSectionModel *)sectionModel itemModel:(ZFCMSItemModel *)itemModel  {
    NSString *source = nil;
    if (sectionModel.subType == ZFCMS_HistorSku_SubType) {
        source = @"recommend_history";
    }
    if (itemModel && self.delegate && [self.delegate respondsToSelector:@selector(zf_cmsManagerView:collectionView:eventCell:deeplinkItem:source:)]) {
        [self.delegate zf_cmsManagerView:self
                          collectionView:self.collectionView
                               eventCell:cell
                            deeplinkItem:itemModel
                                  source:source];
    }
}

//点击优惠券
- (void)clickCouponCell:(ZFCMSCouponCCell *)cell model:(ZFCMSItemModel *)model {
    
    ZFCMSSectionModel *sectionModel;
    __block ZFCMSItemModel *itemModel = nil;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    
    if (self.cmsSectionModelArr.count > indexPath.section) {
        sectionModel = self.cmsSectionModelArr[indexPath.section];
        
        if (ZFJudgeNSArray(sectionModel.list)) {
            [sectionModel.list enumerateObjectsUsingBlock:^(ZFCMSItemModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.col_id isEqualToString:model.col_id]) {
                    itemModel = obj;
                    *stop = YES;
                }
            }];
        }
    }
    
    if (itemModel
        && !ZFIsEmptyString(itemModel.couponModel.idx)) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(zf_cmsManagerView:collectionView:couponCell:model:)]) {
            [self.delegate zf_cmsManagerView:self collectionView:self.collectionView couponCell:cell model:model];
        }
    }
    
//    if (itemModel
//        && !ZFIsEmptyString(itemModel.couponModel.idx)
//        && itemModel.couponModel.couponState <= 1) {
//
//        if ([itemModel.couponModel.left_rate isEqualToString:@"0"] && [itemModel.couponModel.is_no_limit isEqualToString:@"1"]) {
//
//            ShowToastToViewWithText(self, ZFLocalizedString(@"Hom_Coupon_No_Left", nil));
//
//        } else {
//
//            if (self.delegate && [self.delegate respondsToSelector:@selector(zf_cmsManagerView:collectionView:couponCell:model:)]) {
//                [self.delegate zf_cmsManagerView:self collectionView:self.collectionView couponCell:cell model:model];
//            }
//        }
//    } else if (itemModel && !ZFIsEmptyString(itemModel.couponModel.idx) && itemModel.couponModel.couponState == 2) {
//
//        ShowToastToViewWithText(self, ZFLocalizedString(@"Hom_Coupon_Claimed", nil));
//
//    }  else if (itemModel && !ZFIsEmptyString(itemModel.couponModel.idx) && itemModel.couponModel.couponState == 3) {
//
//        ShowToastToViewWithText(self, ZFLocalizedString(@"Hom_Coupon_No_Left", nil));
//    }
}

- (void)clearHistorySuccess {
    if (self.delegate && [self.delegate respondsToSelector:@selector(zf_cmsManagerView:collectionView:clearHistoryCompletion:)]) {
        [self.delegate zf_cmsManagerView:self collectionView:self.collectionView clearHistoryCompletion:YES];
    }
}

#pragma mark - Property Method

- (NSMutableArray<ZFCMSSectionModel *> *)cmsSectionModelArr {
    if (!_cmsSectionModelArr) {
        _cmsSectionModelArr = [NSMutableArray array];
    }
    return _cmsSectionModelArr;
}

- (NSMutableArray<ZFGoodsModel *> *)recommendGoodsArr {
    if (!_recommendGoodsArr) {
        _recommendGoodsArr = [NSMutableArray array];
    }
    return _recommendGoodsArr;
}

- (NSMutableArray *)sectionBgColorViewArr {
    if (!_sectionBgColorViewArr) {
        _sectionBgColorViewArr = [NSMutableArray array];
    }
    return _sectionBgColorViewArr;
}

- (ZFCMSCollectionView *)collectionView {
    if (!_collectionView) {
        CGRect rect = self.bounds;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[ZFCMSCollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.showsVerticalScrollIndicator = YES;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [_collectionView registerClass:[UICollectionViewCell class]  forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
        
        [_collectionView registerClass:[ZFCMSCycleBannerCell class]  forCellWithReuseIdentifier:NSStringFromClass([ZFCMSCycleBannerCell class])];
        
        [_collectionView registerClass:[ZFCMSSliderSecKillSectionView class]  forCellWithReuseIdentifier:NSStringFromClass([ZFCMSSliderSecKillSectionView class])];
        
        [_collectionView registerClass:[ZFCMSSliderSKUBannerSectionView class]  forCellWithReuseIdentifier:NSStringFromClass([ZFCMSSliderSKUBannerSectionView class])];
        
        [_collectionView registerClass:[ZFCMSSliderNormalBannerSectionView class]  forCellWithReuseIdentifier:NSStringFromClass([ZFCMSSliderNormalBannerSectionView class])];
        
        [_collectionView registerClass:[ZFCMSNormalBannerCell class]  forCellWithReuseIdentifier:NSStringFromClass([ZFCMSNormalBannerCell class])];
        
        [_collectionView registerClass:[ZFCMSTextModuleCell class]  forCellWithReuseIdentifier:NSStringFromClass([ZFCMSTextModuleCell class])];
        
        [_collectionView registerClass:[ZFCMSSkuBannerCell class]  forCellWithReuseIdentifier:NSStringFromClass([ZFCMSSkuBannerCell class])];
        
        [_collectionView registerClass:[ZFCMSVideoCCell class] forCellWithReuseIdentifier:NSStringFromClass([ZFCMSVideoCCell class])];
        
        [_collectionView registerClass:[ZFCMSRecommendGoodsCCell class] forCellWithReuseIdentifier:NSStringFromClass([ZFCMSRecommendGoodsCCell class])];
        
        [_collectionView registerClass:[ZFCMSCouponOneCCell class] forCellWithReuseIdentifier:NSStringFromClass([ZFCMSCouponOneCCell class])];
        
        [_collectionView registerClass:[ZFCMSCouponTwoCCell class] forCellWithReuseIdentifier:NSStringFromClass([ZFCMSCouponTwoCCell class])];

        [_collectionView registerClass:[ZFCMSCouponThreeCCell class] forCellWithReuseIdentifier:NSStringFromClass([ZFCMSCouponThreeCCell class])];

        [_collectionView registerClass:[ZFCMSCouponFourCCell class] forCellWithReuseIdentifier:NSStringFromClass([ZFCMSCouponFourCCell class])];
        
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ZFCMSManagerHeaderReusableView"];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"ZFCMSManagerFooterReusableView"];
    }
    return _collectionView;
}

#pragma mark - 配置
- (void)reloadView:(BOOL)isEmptyDataRefresh {
    
    if (isEmptyDataRefresh) {//清除数据刷新时
        [[ZFAnalyticsExposureSet sharedInstance] removeAllObjectsAnalyticsId:self.viewID];
    }
    [self.collectionView reloadData];
}

//需求: 给平铺模式Section添加一个背景视图来 设置背景颜色
- (void)showSectionBgColor:(NSIndexPath *)indexPath
                  sectionY:(CGFloat)sectionY
              sectionModel:(ZFCMSSectionModel *)sectionModel
{
    if (ZFIsEmptyString(sectionModel.bg_color)) return;
    
    if ([self.sectionBgColorViewArr containsObject:sectionModel]) return;
    [self.sectionBgColorViewArr addObject:sectionModel];
    
    CGFloat topMagin = sectionModel.sectionInsetForSection.top;
    CGFloat bottomMagin = sectionModel.sectionInsetForSection.bottom;
    
    CGFloat minimumLineSpacing = sectionModel.sectionMinimumLineSpacing;
    CGFloat rowCount = sectionModel.sectionItemCount / [sectionModel.display_count floatValue];
    CGFloat bgColorHeight = topMagin + sectionModel.sectionItemSize.height * ceil(rowCount) + minimumLineSpacing * (ceil(rowCount) - 1) + bottomMagin;
    
    UIView *sectionBgColorView = [[UIView alloc] init];
    sectionBgColorView.frame = CGRectMake(0, sectionY-topMagin, KScreenWidth, ceil(bgColorHeight));
    [self.collectionView insertSubview:sectionBgColorView atIndex:0];
    sectionBgColorView.backgroundColor = sectionModel.bgColor;
    [self.sectionBgColorViewArr addObject:sectionBgColorView];
    
    YWLog(@"平铺模式添加背景色====%@", self.sectionBgColorViewArr);
    for (UIView *bgColorView in self.sectionBgColorViewArr) {
        if ([bgColorView isKindOfClass:[UIView class]]) {
            [self.collectionView insertSubview:bgColorView atIndex:0];
        }
    }
}

/**
 * 重新请求数据,删除浏览历史记录时,可能会改变位置,因此平铺模式下背景view都需要移除来重新创建
 */
- (void)removeSectionBgColorView {
    for (UIView *bgColorView in self.sectionBgColorViewArr) {
        if ([bgColorView isKindOfClass:[UIView class]]) {
            [bgColorView removeFromSuperview];
        }
    }
    [self.sectionBgColorViewArr removeAllObjects];
}

- (CGFloat)noContainRecommendsGoodsHeight {
    __block CGFloat contentH = 0;
    [self.cmsSectionModelArr enumerateObjectsUsingBlock:^(ZFCMSSectionModel * _Nonnull sectionModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if (sectionModel.type != ZFCMS_RecommendGoods_Type) {
            CGFloat row = sectionModel.sectionItemCount / [sectionModel.display_count floatValue];
            NSInteger rowInt = ceilf(row);
            contentH += sectionModel.sectionInsetForSection.top + sectionModel.sectionInsetForSection.bottom;
            contentH += sectionModel.sectionMinimumLineSpacing * (rowInt - 1);
            contentH += sectionModel.sectionItemSize.height * rowInt;
        }
    }];
    
    contentH += CGRectGetHeight(self.firstHeaderView.frame);
    contentH += CGRectGetHeight(self.lastFooterView.frame);
    
    return contentH;
}

- (CGFloat)lastSectionFooterMinY {
    if (self.lastFooterView.superview) {
        CGFloat lastY = CGRectGetMinY(self.lastFooterView.superview.frame);
        return lastY;
    } else if (!self.isShowRecommend) {
        return [self noContainRecommendsGoodsHeight] - CGRectGetHeight(self.lastFooterView.frame);
    }
    return 0;
}


/** 初始化下拉刷新控件 */

- (void)addListHeaderRefreshBlock:(ZFRefreshingBlock)headerBlock
                PullingShowBannerBlock:(PullingBannerBlock)pullingBannerBlock
                    footerRefreshBlock:(ZFRefreshingBlock)footerBlock
                  startRefreshing:(BOOL)startRefreshing {
    
    
    [self.collectionView addCommunityHeaderRefreshBlock:headerBlock
                                 PullingShowBannerBlock:pullingBannerBlock footerRefreshBlock:footerBlock
                                        startRefreshing:startRefreshing];
}

/**
 * 设置是否能上拉加载更多
 */
- (void)addFooterLoadingMore:(BOOL)showLoadingMore footerBlock:(void (^)(void))footerBlock {
    
    if (showLoadingMore && (!self.collectionView.mj_footer || self.collectionView.mj_footer.isHidden)) {
        self.collectionView.mj_footer = [ZFRefreshFooter footerWithRefreshingBlock:^{
            if (footerBlock) {
                footerBlock();
            }
        }];
    }
    self.collectionView.mj_footer.hidden = !showLoadingMore;
}

- (void)forbidCollectionRecognizeSimultaneously:(BOOL)forbid {
    self.collectionView.isRecognizeSimultaneously = forbid;
}

@end



#pragma mark -
#pragma mark -
@implementation ZFCMSCollectionView

/**
 * 此方法是支持多手势，当滑动子控制器中的scrollView时，外层 scrollView 也能接收滑动事件
 * 当前类仅供社区个人中心三个列表使用
 */

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    //YWLog(@"inView: %@",otherGestureRecognizer.view);
    if ([otherGestureRecognizer.view isKindOfClass:[ZFCMSCollectionView class]] ||
        [otherGestureRecognizer.view isKindOfClass:[WMScrollView class]] || self.isRecognizeSimultaneously) {//添加不支持
        return NO;
    }

    return YES;
}

@end
