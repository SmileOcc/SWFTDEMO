//
//  ZFCMSManagerView.h
//  ZZZZZ
//
//  Created by YW on 2019/5/16.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WMScrollView.h"
#import "UIColor+ExTypeChange.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "UIView+ZFViewCategorySet.h"

#import "ZFCMSViewModel.h"

#import "ZFCMSCycleBannerCell.h"
#import "ZFCMSSliderSecKillSectionView.h"
#import "ZFCMSSliderSKUBannerSectionView.h"
#import "ZFCMSSliderNormalBannerSectionView.h"
#import "ZFCMSNormalBannerCell.h"
#import "ZFCMSSkuBannerCell.h"
#import "ZFCMSTextModuleCell.h"
#import "ZFCMSVideoCCell.h"
#import "ZFCMSRecommendGoodsCCell.h"
#import "ZFCMSCouponCCell.h"

#import "SystemConfigUtils.h"
#import "BannerManager.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "ZFRefreshHeader.h"
#import "ZFRefreshFooter.h"
#import "Constants.h"
#import "ZFBTSModel.h"
#import "ZFCMSCouponManager.h"

@protocol ZFCMSManagerViewProtocol;
@class ZFCMSCollectionView;

@interface ZFCMSManagerView : UIView

@property (nonatomic, weak) id<ZFCMSManagerViewProtocol>               delegate;

/** 每个频道的ChannelId*/
@property (nonatomic, copy)   NSString                                 *channelId;
@property (nonatomic, copy)   NSString                                 *channelName;

/** Cell数据源*/
@property (nonatomic, strong) NSMutableArray<ZFCMSSectionModel *>      *cmsSectionModelArr;
/** 推荐数据源*/
@property (nonatomic, strong) NSMutableArray<ZFGoodsModel *>           *recommendGoodsArr;

/** 推荐商品相关*/
@property (nonatomic, assign) BOOL                                     allowScrollToRecommend;
@property (nonatomic, assign) NSUInteger                               recommendSectionIndex;


@property (nonatomic, strong) ZFCMSCollectionView                      *collectionView;

/**可配置第一个头部*/
@property (nonatomic, strong) UIView                                   *firstHeaderView;
/**可配置最后一个头部*/
@property (nonatomic, strong) UIView                                   *lastFooterView;

///禁掉默认方法
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

/**
 视图创建

 @param frame
 @param channelId：cms频道ID
 @param showRecommend ：是否显示推荐商品
 @return 
 */
- (instancetype)initWithFrame:(CGRect)frame channelId:(NSString *)channelId showRecommend:(BOOL)showRecommend;


/**
 配置来源

 @param source： 来源
 @param idx：必须配置 统计唯一标识
 @param screenName： 屏幕名
 */
- (void)baseConfigureSource:(ZFAnalyticsAOPSource)source analyticsId:(NSString *)idx screenName:(NSString *)screenName;

/**
 视图显示刷新
 @param isEmptyDataRefresh ：YES：重置刷新，NO:加载刷新
 */
- (void)reloadView:(BOOL)isEmptyDataRefresh;

/**
 禁止collect手势同时穿透传递
 @param forbid ：默认开启
 */
- (void)forbidCollectionRecognizeSimultaneously:(BOOL)forbid;

/**
 不包括推荐商品高度
 @return
 */
- (CGFloat)noContainRecommendsGoodsHeight;

/**
 获取最后一组的组尾minY
 @return
 */
- (CGFloat)lastSectionFooterMinY;

/**
 双击tabbar滚动到推荐商品标题栏目位置
 */
- (void)scrollToRecommendPosition;

/**
 移除组的背景图
 */
- (void)removeSectionBgColorView;

/** 添加刷新事件*/
- (void)addListHeaderRefreshBlock:(ZFRefreshingBlock)headerBlock
           PullingShowBannerBlock:(PullingBannerBlock)pullingBannerBlock
               footerRefreshBlock:(ZFRefreshingBlock)footerBlock
                  startRefreshing:(BOOL)startRefreshing;

/** 处理是否能加载更多*/
- (void)addFooterLoadingMore:(BOOL)showLoadingMore footerBlock:(void (^)(void))footerBlock;


@end


@protocol ZFCMSManagerViewProtocol <NSObject>

/** Deeeplink跳转事件, 需要组装一个完整的deeplink字典来做跳转 */
- (void)zf_cmsManagerView:(ZFCMSManagerView *)managerView collectionView:(UICollectionView *)collectionView eventCell:(UICollectionViewCell *)cell deeplinkItem:(ZFCMSItemModel *)itemModel source:(NSString *)source;

/** 点击推荐商品*/
- (void)zf_cmsManagerView:(ZFCMSManagerView *)managerView collectionView:(UICollectionView *)collectionView recommendCell:(ZFCMSRecommendGoodsCCell *)cell recommendGoods:(ZFGoodsModel *)goodsModel;

/** 点击优惠券*/
- (void)zf_cmsManagerView:(ZFCMSManagerView *)managerView collectionView:(UICollectionView *)collectionView couponCell:(ZFCMSCouponCCell *)cell model:(ZFCMSItemModel *)model;

/** 清除历史数据成功*/
- (void)zf_cmsManagerView:(ZFCMSManagerView *)managerView collectionView:(UICollectionView *)collectionView clearHistoryCompletion:(BOOL)flag;

@optional

- (void)zf_cmsManagerView:(ZFCMSManagerView *)managerView collectionView:(UICollectionView *)collectionView videoPlayerCell:(ZFCMSVideoCCell *)cell model:(ZFCMSItemModel *)model;

/** 不喜欢推荐商品*/
- (void)zf_cmsManagerView:(ZFCMSManagerView *)managerView collectionView:(UICollectionView *)collectionView recommendCell:(ZFCMSRecommendGoodsCCell *)cell dislikeRecommendGoods:(ZFGoodsModel *)goodsModel;


/** 只是用于统计*/
- (void)zf_cmsManagerView:(ZFCMSManagerView *)managerView collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath;

/** 只是用于统计*/
- (void)zf_cmsManagerView:(ZFCMSManagerView *)managerView collectionView:(UICollectionView *)collectionView didSelectItemCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)zf_cmsScrollViewDidScroll:(UIScrollView *)scrollView;

- (void)zf_cmsScrollViewDidEndDecelerating:(UIScrollView *)scrollView;

- (void)zf_cmsScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

- (void)zf_cmsScrollViewWillBeginDragging:(UIScrollView *)scrollView;

- (void)zf_cmsScrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView;


@end





@interface ZFCMSCollectionView : UICollectionView<UIGestureRecognizerDelegate>

@property (nonatomic, assign) BOOL isRecognizeSimultaneously;

@end
