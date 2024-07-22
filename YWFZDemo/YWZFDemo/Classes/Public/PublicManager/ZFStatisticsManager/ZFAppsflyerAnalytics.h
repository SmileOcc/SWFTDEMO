//
//  ZFAppsflyerAnalytics.h
//  ZZZZZ
//
//  Created by YW on 2018/7/5.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BigDataParams @"bigDataParams"

typedef NS_ENUM(NSInteger, ZFAppsflyerInSourceType) {
    ZFAppsflyerInSourceTypeDefault = 0,
    ZFAppsflyerInSourceTypeHome,
    ZFAppsflyerInSourceTypeGoodsDetail,
    ZFAppsflyerInSourceTypeZMeExploreid,
    ZFAppsflyerInSourceTypeZMeOutfitid,
    ZFAppsflyerInSourceTypeZMeVideoid,
    ZFAppsflyerInSourceTypeZMeFollow,
    ZFAppsflyerInSourceTypeCategoryList,
    ZFAppsflyerInSourceTypePromotion,
    ZFAppsflyerInSourceTypeSearchResult,
    ZFAppsflyerInSourceTypeAIRecommend,
    ZFAppsflyerInSourceTypeHomeChannel,
    ZFAppsflyerInSourceTypeHomeRecomNewin,
    ZFAppsflyerInSourceTypeCarRecommend,
    ZFAppsflyerInSourceTypeVirtualCategoryList,
    ZFAppsflyerInSourceTypeRecommendHistory,
    /** 社区帖子详情推荐商品*/
    ZFAppsflyerInSourceTypeZMePostDetailRecommend,
    /** 社区帖子详情底部视图related推荐商品*/
    ZFAppsflyerInSourceTypeZMePostDetailBottomRelatedRecommend,
    /** 社区视频帖子详情推荐商品*/
    ZFAppsflyerInSourceTypeZMeVideoDetailRecommend,
    /** 社区入口为全部相似帖列表页商品*/
    ZFAppsflyerInSourceTypeZMeAllSimilarList,
    /** 商品详情关联的帖子show详情页的商品*/
    ZFAppsflyerInSourceTypeZMeRemommendItemsShow,
    /** 直播间详情*/
    ZFAppsflyerInSourceTypeZMeLiveDetail,
    ZFAppsflyerInSourceTypeSearchImageCamera,
    ZFAppsflyerInSourceTypeSearchImagePhotos,
    /** 联想词搜索*/
    ZFAppsflyerInSourceTypeSearchAssociation,
    /** 历史词搜索*/
    ZFAppsflyerInSourceTypeSearchHistory,
    /** 直接搜索*/
    ZFAppsflyerInSourceTypeSearchDirect,
    /** 纠错词搜索*/
    ZFAppsflyerInSourceTypeSearchFix,
    /** 搜索页的推荐词搜索*/
    ZFAppsflyerInSourceTypeSearchRecommend,
    /** deeplink进入搜索*/
    ZFAppsflyerInSourceTypeSearchDeeplink,
    /** 下架商品找相似*/
    ZFAppsflyerInSourceTypeSearchImageitems,
    /** 个人中心推荐位*/
    ZFAppsflyerInSourceTypeSerachRecommendPersonal,
    /** 购物车新版空数据时的大数据接口推荐位 */
    ZFAppsflyerInSourceTypeCartEmptyDataRecommend,
    /** 结算成功页大数据接口推荐位 */
    ZFAppsflyerInSourceTypePaySuccessRecommend,
    /** 社区CMS首页*/
    ZFAppsflyerInSourceTypeZMeCMSHome,
    /** 订单列表推荐商品*/
    ZFAppsflyerInSourceTypeMyOrderListRecommend,
    /** Coupon列表推荐商品*/
    ZFAppsflyerInSourceTypeMyCouponListRecommend,
    /** 收藏列表推荐商品*/
    ZFAppsflyerInSourceTypeWishListRecommend,
    /** 收藏列表推荐来源*/
    ZFAppsflyerInSourceTypeWishListSourceMedia,
    /** 购物车凑单列表来源*/
    ZFAppsflyerInSourceTypeCartPiecing,
    /** 新人专享页面*/
    ZFAppsflyerInSourceTypeNewUserGoods,
    /** 新人秒杀商品列表页*/
    ZFAppsflyerInSourceTypeNewUsersRush,
    /** 原生专题商品列表页*/
    ZFAppsflyerInSourceTypeNativeBanner,
    /** 订单详情里的商品*/
    ZFAppsflyerInSourceTypeOrderDetailsProduct,
    /** 购物车满赠商品列表页*/
    ZFAppsflyerInSourceTypeFreeGift,
    /** 购物车满减活动页面商品列表*/
    ZFAppsflyerInSourceTypeFullReduction,
    /** 个人中心历史浏览记录*/
    ZFAppsflyerInSourceTypeAccountRecentviewedProduct,
    /** 购物车加购商品*/
    ZFAppsflyerInSourceTypeCartProduct,
    /** 搭配购商品*/
    ZFAppsflyerInSourceTypeCollocation,
    /** 商详关联穿搭商品*/
    ZFAppsflyerInSourceTypeDetailOutfits,
    /** 原生专题*/
    ZFAppsflyerInSourceTypeNativeTopic
};

typedef NS_ENUM(NSInteger, ZFOperateRemotePushType) {
    /** 操作页面当前事件 */
    ZFOperateRemotePush_Default = 0,
    /**引导页:点击 Yep 次数*/
    ZFOperateRemotePush_guide_yes,
    /**引导页:点击 NO 次数*/
    ZFOperateRemotePush_guide_no,
    /**系统授权:点击 允许 次数*/
    ZFOperateRemotePush_sys_yes,
    /**系统授权:点击 拒绝 次数*/
    ZFOperateRemotePush_sys_no,
    /**系统授权:未知*/
    ZFOperateRemotePush_sys_unKonw,
};

@class ZFGoodsModel;
@class AFparams;
@class UIViewController;

/**
 Appsflyer 统计
 */
@interface ZFAppsflyerAnalytics : NSObject

/**
 *  事件统计量
 *
 *  @param
 */
+ (void)trackEventWithContentType:(NSString *)contentType;
/**
 *  事件统计量
 *  @param
 */
+ (void)zfTrackEvent:(NSString *)eventName withValues:(NSDictionary *)values;

/**
 统计上列表浏览

 @param goodsArray 商品列表数据
 @param type 商品列表数据来源
 @param sourceID 数据来源标识
 */
+ (void)trackGoodsList:(NSArray <ZFGoodsModel *> *)goodsArray inSourceType:(ZFAppsflyerInSourceType)type sourceID:(NSString *)sourceID;

+ (void)trackGoodsList:(NSArray <ZFGoodsModel *> *)goodsArray inSourceType:(ZFAppsflyerInSourceType)type AFparams:(AFparams *)afparams;

+ (void)trackGoodsList:(NSArray <ZFGoodsModel *> *)goodsArray
          inSourceType:(ZFAppsflyerInSourceType)type
              sourceID:(NSString *)sourceID
              aFparams:(AFparams *)afparams;

+ (void)trackGoodsList:(NSArray <ZFGoodsModel *> *)goodsArray
          inSourceType:(ZFAppsflyerInSourceType)type
              sourceID:(NSString *)sourceID
                  sort:(NSString *)sort
              aFparams:(AFparams *)afparams;

/**
 数据来源标识

 @param type 商品数据来源
 @param sourceID 数据来源标识
 @return 数据来源标识
 */
+ (NSString *)sourceStringWithType:(ZFAppsflyerInSourceType)type sourceID:(NSString *)sourceID;

/**
 * 统计页面显示打开推送的权限点击量
 * trackEvent: Startpage, signup, paysucess, Orderlist, Setting
 * remoteType: 操作推送事件类型枚举
 */
+ (void)analyticsPushEvent:(NSString *)pageName
                 remoteType:(ZFOperateRemotePushType)remoteType;


+ (void)appsflyerViewViewDidAppear:(UIViewController *)currentViewController;

+ (void)appsflyerViewViewDisAppear:(UIViewController *)currentViewController;
@end
