//
//  OSSVAPPThemeHandleMangerView.h
// OSSVAPPThemeHandleMangerView
//
//  Created by odd on 2021/3/25.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomerLayoutSectionModuleProtocol.h"

#import "OSSVCustomThemeMultiMould.h"
#import "OSSVAsinglViewMould.h"
#import "OSSVWaterrFallViewMould.h"
#import "OSSVMultiColumnsGoodItemsViewMould.h"
#import "OSSVMutilBranchMould.h"
#import "OSSVThemeItemGoodsRanksModuleModel.h"

#import "OSSVThemesMainLayout.h"
#import "OSSVAsinglesAdvCCell.h"
#import "OSSVPrGoodsSPecialCCell.h"
#import "OSSVMultiPGoodsSPecialCCell.h"
#import "OSSVThemesChannelsCCell.h"
#import "OSSVThemeZeorsActivyCCell.h"
#import "OSSVZeroActivyDoulesLineCCell.h"
#import "OSSVThemeCouponCCellModel.h"
#import "OSSVScrolllGoodsCCell.h"
#import "OSSVThemesCouponsCCell.h"
#import "OSSVThemeGoodsItesRankCCell.h"
#import "OSSVCouponsAlertView.h"
#import "STLActionSheet.h"


#import "OSSVScrollCCellModel.h"
#import "OSSVDetailsBaseInfoModel.h"
#import "OSSVHomeCThemeModel.h"
#import "OSSVDetailsViewModel.h"
#import "OSSVProGoodsCCellModel.h"
#import "OSSVMultProGoodsCCellModel.h"
#import "OSSVHomeChannelCCellModel.h"
#import "OSSVCustThemePrGoodsListCacheModel.h"
#import "OSSVAPPNewThemeMultiCCellModel.h"
#import "OSSVThemesZeroActivyCellModel.h"
#import "OSSVThemeZeroActivyTwoCCellModel.h"
#import "OSSVThemeItemsGoodsRanksCCellModel.h"


#import "UIColor+Extend.h"
#import "WMMenuView.h"

@class STLThemeCollectionView;
@protocol STLThemeManagerViewProtocol;

@interface OSSVAPPThemeHandleMangerView : UIView

@property (nonatomic, copy) NSString *customId;
@property (nonatomic, copy) NSString *customName;

@property (nonatomic, strong) NSMutableArray <id<CustomerLayoutSectionModuleProtocol>>*dataSourceList;
@property (nonatomic, weak) id<STLThemeManagerViewProtocol> delegate;

@property (nonatomic, strong) STLThemeCollectionView           *themeCollectionView;
///是否有频道楼层
@property (nonatomic, assign) BOOL isChannel;
@property (nonatomic, strong) NSMutableDictionary <NSNumber *, OSSVCustThemePrGoodsListCacheModel *>*customProductListCache;                          ///<商品列表缓存

@property (nonatomic, strong) OSSVThemesMainLayout                    *layout;
@property (nonatomic, strong) WMMenuView                        *menuView;
@property (nonatomic, strong) OSSVCouponsAlertView                *couponAlertView;

@property (nonatomic, strong) NSMutableArray                    *allCoupons;

@property (nonatomic, strong) EmptyCustomViewManager            *emptyViewManager;
@property (nonatomic, assign) EmptyViewShowType                 emptyShowType;
@property (nonatomic, copy) void(^emptyTouchBlock)();
@property (nonatomic, copy) STLRefreshingBlock                  footerBlock;

@property (nonatomic, strong) UIColor                    *bgColor;

///禁掉默认方法
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

-(void)firstSaveProductList:(NSInteger)index list:(NSMutableArray *)productList sort:(NSString *)sort;

- (void)clearDatas;

-(void)menuEndfootRefresh;

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
- (void)baseConfigureSource:(STLAppsflyerGoodsSourceType)source analyticsId:(NSString *)idx screenName:(NSString *)screenName;

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
- (void)addListHeaderRefreshBlock:(STLRefreshingBlock)headerBlock
           PullingShowBannerBlock:(PullingBannerBlock)pullingBannerBlock
               footerRefreshBlock:(STLRefreshingBlock)footerBlock
                  startRefreshing:(BOOL)startRefreshing;

/** 处理是否能加载更多*/
- (void)addFooterLoadingMore:(BOOL)showLoadingMore footerBlock:(void (^)(void))footerBlock;

- (void)endHeaderOrFooterRefresh:(BOOL)isEndHeader;

@end




@interface STLThemeCollectionView : UICollectionView
//<UIGestureRecognizerDelegate>

@property (nonatomic, assign) BOOL isRecognizeSimultaneously;

@end



@protocol STLThemeManagerViewProtocol <NSObject>

/** Deeeplink跳转事件, 需要组装一个完整的deeplink字典来做跳转 */
//- (void)stl_themeManagerView:(STLThemeManagerView *)managerView collectionView:(UICollectionView *)collectionView eventCell:(UICollectionViewCell *)cell deeplinkItem:(STLThemeItemModel *)itemModel source:(NSString *)source;
//
///** 点击推荐商品*/
//- (void)stl_themeManagerView:(STLThemeManagerView *)managerView collectionView:(UICollectionView *)collectionView recommendCell:(STLThemeRecommendGoodsCCell *)cell recommendGoods:(STLGoodsModel *)goodsModel;
//
///** 点击优惠券*/
//- (void)stl_themeManagerView:(STLThemeManagerView *)managerView collectionView:(UICollectionView *)collectionView couponCell:(STLThemeCouponCCell *)cell model:(STLThemeItemModel *)model;
//
///** 清除历史数据成功*/
//- (void)stl_themeManagerView:(STLThemeManagerView *)managerView collectionView:(UICollectionView *)collectionView clearHistoryCompletion:(BOOL)flag;
//
//@optional
//
//- (void)stl_themeManagerView:(STLThemeManagerView *)managerView collectionView:(UICollectionView *)collectionView videoPlayerCell:(STLThemeVideoCCell *)cell model:(STLThemeItemModel *)model;
//
///** 不喜欢推荐商品*/
//- (void)stl_themeManagerView:(STLThemeManagerView *)managerView collectionView:(UICollectionView *)collectionView recommendCell:(STLThemeRecommendGoodsCCell *)cell dislikeRecommendGoods:(STLGoodsModel *)goodsModel;


/** 0元 滑动*/
- (void)stl_themeManagerView:(OSSVAPPThemeHandleMangerView *)managerView collectionView:(UICollectionView *)collectionView themeCell:(UICollectionViewCell *)cell itemCell:(UICollectionViewCell *)itemCell isMore:(BOOL)isMore;

/** 商品排行组件，商品排行列表*/
- (void)stl_themeManagerView:(OSSVAPPThemeHandleMangerView *)managerView collectionView:(UICollectionView *)collectionView themeCell:(UICollectionViewCell *)cell itemCell:(UICollectionViewCell *)itemCell addCart:(id)model;

/** 商品收藏*/
- (void)stl_themeManagerView:(OSSVAPPThemeHandleMangerView *)managerView collectionView:(UICollectionView *)collectionView themeCell:(UICollectionViewCell *)cell itemCell:(UICollectionViewCell *)itemCell addWishList:(id)model;

/** 商品详情*/
- (void)stl_themeManagerView:(OSSVAPPThemeHandleMangerView *)managerView collectionView:(UICollectionView *)collectionView themeCell:(UICollectionViewCell *)cell goodsModel:(STLHomeCGoodsModel *)goodsModel;

/** 领取优惠券*/
- (void)stl_themeManagerView:(OSSVAPPThemeHandleMangerView *)managerView collectionView:(UICollectionView *)collectionView themeCell:(UICollectionViewCell *)cell getCoupons:(NSString *)couponsString;



/** 只是用于统计*/
- (void)stl_themeManagerView:(OSSVAPPThemeHandleMangerView *)managerView collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath;

/** 只是用于统计*/
- (void)stl_themeManagerView:(OSSVAPPThemeHandleMangerView *)managerView collectionView:(UICollectionView *)collectionView didSelectItemCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)stl_themeScrollViewDidScroll:(UIScrollView *)scrollView;

- (void)stl_themeScrollViewDidEndDecelerating:(UIScrollView *)scrollView;

- (void)stl_themeScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

- (void)stl_themeScrollViewWillBeginDragging:(UIScrollView *)scrollView;

- (void)stl_themeScrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView;

@end
