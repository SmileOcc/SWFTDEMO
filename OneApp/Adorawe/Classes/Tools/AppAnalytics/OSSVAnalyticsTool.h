//
//  OSSVAnalyticsTool.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/25.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STLGoodsBaseModel.h"
#import "OSSVDetailsBaseInfoModel.h"
#import "OSSVAnalyticFirebases.h"
#import "OSSVAnalyticSensorrs.h"
#import "OSSVAnalyticPagesManager.h"
#import "OSSVRequestsUtils.h"

#ifdef FirebaseAnalyticsEnabled
#import <Firebase.h>
#endif

static NSString *kAnalyticsKeyWord = @"key_word";
static NSString *kAnalyticsPositionNumber = @"position_number";
static NSString *kAnalyticsThirdPartId = @"third_part_id";
static NSString *kAnalyticsAction = @"action";
static NSString *kAnalyticsUrl = @"url";
static NSString *kAnalyticsSku = @"sku";
static NSString *kAnalyticsRequestId = @"request_id";
static NSString *kAnalyticsRequestIdWebType = @"webtype";
///商品详情的requestID
static NSString *kAnalyticsRequestIdFromItem = @"request_id_item";
static NSString *kAnalyticsRecommendPartId = @"recommend_part_id";

typedef NS_ENUM(NSInteger, STLAppsflyerGoodsSourceType) {
    /**首页*/
    STLAppsflyerGoodsSourceHome = 1,
    STLAppsflyerGoodsSourceHomeLike,
    STLAppsflyerGoodsSourceHomeOther,

    /**社区详情*/
    STLAppsflyerGoodsSourceYoMeDetail,
    /**购物车商品*/
    STLAppsflyerGoodsSourceCart,
    /**购物车推荐商品*/
    STLAppsflyerGoodsSourceCartRecommend,
    /**首页推荐商品*/
    STLAppsflyerGoodsSourceHomeRecommend,
    /**个人中心推荐商品*/
    STLAppsflyerGoodsSourceAccountRecommend,
    /**商品详情推荐商品*/
    STLAppsflyerGoodsSourceDetailRecommendLike,
    STLAppsflyerGoodsSourceDetailRecommendOften,
    /**收藏夹*/
    STLAppsflyerGoodsSourceWishlist,
    /**原生专题*/
    STLAppsflyerGoodsSourceThemeActivity,
    /**分类列表*/
    STLAppsflyerGoodsSourceCategoryList,
    /**商品详情*/
    STLAppsflyerGoodsSourceGoodsDetail,
    /**搜索列表*/
    STLAppsflyerGoodsSourceSearchResult,
    /**从配置的链接进入*/
    STLAppsflyerGoodsSourceCustomPath,
    /**浏览历史列表*/
    STLAppsflyerGoodsSourceHistory,
    /**个人底部浏览历史*/
    STLAppsflyerGoodsSourceAccountHistory,
    /**0元活动列表*/
    STLAppsflyerGoodsSourceZeroActivity,
    /**订单*/
    STLAppsflyerGoodsSourceOrder,
    /**闪购来源*/
    STLAppsflyerGoodsSourceFlashList,
    //**** 热搜****//
    STLAppsflyerGoodsSourceHotSearch,
    /**商品相似列表*/
    STLAppsflyerGoodsSourceDetailSimilar,
    /**首页NEW*/
    STLAppsflyerGoodsSourceMainNew,
};

@class OSSVAccounteMyOrderseDetailModel,OSSVDetailsBaseInfoModel,CartModel,OSSVCartCheckModel,OSSVOrderInfoeModel,OSSVAdvsEventsModel,OSSVCreateOrderModel;

@interface OSSVAnalyticsTool : NSObject

+ (OSSVAnalyticsTool *)sharedManager;

@property (nonatomic, strong) NSDictionary  *appsFlyerInstallData;
@property (nonatomic, strong) NSSet<NSString *>     *analyticsTypeSet;

@property (nonatomic, copy) NSString *analytics_uuid;

+ (NSString *)appsAnalyticUUID;

#pragma mark - //=============== AppsFlyer ===============//
+ (void)appsFlyerTrackEvent:(NSString *)eventName withValues:(NSDictionary *)values;

/**
*  注册统计
*/
+ (void)appsFlyerRegister:(NSDictionary *)dic;


/**
*  登录统计
*/
+ (void)appsFlyerLogin:(NSDictionary *)dic;

/**
*  搜索统计
*/
+ (void)appsFlyerSearch:(NSDictionary *)dic;

/**
*  商品详情统计
*/
+ (void)appsFlyerProducts:(NSDictionary *)dic;

/**
 *  添加购物车
 */
+ (void)appsFlyerAddToCartWithProduct:(CartModel *)cartItem fromProduct:(BOOL)isFromProduct;

/**
*  移除购物车
*/
+ (void)appsFlyerRemoveFromCartWithProduct:(CartModel *)cartItem;
/**
 *  购买下单成功
 */
+ (void)appsFlyerOrderSuccess:(NSDictionary *)dic;


/**
*  购买完成
*/
+ (void)appsFlyerOrderPaySuccess:(NSDictionary *)dic;

/**
*  订单取消
*/
+ (void)appsFlyerOrderCancel:(NSDictionary *)dic;


/**
 *  添加到愿望清单
 */
+ (void)appsFlyeraAddToWishlistWithProduct:(OSSVDetailsBaseInfoModel *)product fromProduct:(BOOL)isFromProduct;


+ (void)appsFlyerTrackGoodsList:(NSArray <OSSVDetailsBaseInfoModel *> *)goodsArray inSourceType:(STLAppsflyerGoodsSourceType)type sourceID:(NSString *)sourceID;

#pragma mark - //=============== 新统计 ===============//


//+ (void)analyticsEventWithName:(NSString *)eventName parameters:(NSDictionary *)parameters;

////GA
+ (void)analyticsGASetUserID:(NSString *)userId;
////GA
+ (void)analyticsGAEventWithName:(NSString *)eventName parameters:(NSDictionary *)parameters;
///GA来源标识
+ (NSString *)gaSourceStringWithType:(STLAppsGASourceType)type sourceID:(NSString *)sourceID;

////神策
+ (void)sensorsDynamicConfigure;
+ (void)analyticsSensorsEventWithName:(NSString *)eventName parameters:(NSDictionary *)parameters;
+ (void)analyticsSensorsEventFlush;



///神策来源标识
+ (NSString *)sensorsSourceStringWithType:(STLAppsflyerGoodsSourceType)type sourceID:(NSString *)sourceID;
@end
