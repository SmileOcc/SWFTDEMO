//
//  OSSVAnalyticsTool.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/25.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVAnalyticsTool.h"

#import "OSSVAccounteMyOrderseDetailModel.h"
#import "OSSVDetailsBaseInfoModel.h"
#import "CartModel.h"
#import "OSSVDetailNowAttributeModel.h"
#import "OSSVDetailsAttributeListModel.h"
#import "OSSVCartCheckModel.h"
#import "OSSVCartGoodsModel.h"
#import "OSSVOrderInfoeModel.h"
#import "OSSVCartPaymentModel.h"
#import "OSSVCreateOrderModel.h"


#ifdef AppsFlyerAnalyticsEnabled
//#import <AppsFlyerLib/AppsFlyerLib.h>
#endif
//
#ifdef FirebaseAnalyticsEnabled
#import <Firebase.h>
#endif

@implementation OSSVAnalyticsTool


+ (OSSVAnalyticsTool *)sharedManager {
    static OSSVAnalyticsTool *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.analyticsTypeSet = [[NSSet alloc] initWithObjects:@"GA",@"AL", nil];
    });
    return sharedInstance;
}

- (NSString *)analytics_uuid {
    if (STLIsEmptyString(_analytics_uuid)) {
        _analytics_uuid = [OSSVAnalyticsTool appsAnalyticUUID];
    }
    return _analytics_uuid;
}

+ (NSString *)appsAnalyticUUID {
    NSString *device = [OSSVAccountsManager sharedManager].device_id;
    NSString *timeP = [OSSVNSStringTool getCurrentTimestamp];
    NSString *aopUUId = [NSString stringWithFormat:@"adoos%@%@",device,timeP];
    return aopUUId;
}

+ (NSString *)sourceStringWithType:(STLAppsflyerGoodsSourceType)type sourceID:(NSString *)sourceID {
    NSString *sourceTypeString = @"";
    switch (type) {
        case STLAppsflyerGoodsSourceHome:
            sourceTypeString = @"recommend_homepage";
            break;
        case STLAppsflyerGoodsSourceYoMeDetail:
            sourceTypeString = [NSString stringWithFormat:@"recommend_yome_detail_%@", sourceID];
            break;
        case STLAppsflyerGoodsSourceCart:
            sourceTypeString = @"cartpage";
            break;
        case STLAppsflyerGoodsSourceCartRecommend:
            sourceTypeString = @"recommend_cartpage";//购物车推荐
            break;
        case STLAppsflyerGoodsSourceAccountRecommend:
            sourceTypeString = @"recommend_account";//个人中心推荐
            break;
        case STLAppsflyerGoodsSourceHomeRecommend:
            sourceTypeString = @"recommend_homepage";//首页发现推荐+首页普通频道推荐
            break;
        case STLAppsflyerGoodsSourceDetailRecommendLike:
            sourceTypeString = @"goods_detail_you_also_like";//商品详情推荐
            break;
        case STLAppsflyerGoodsSourceDetailRecommendOften:
            sourceTypeString = @"goods_detail_often_bought_with";//商品详情推荐
            break;
        case STLAppsflyerGoodsSourceWishlist:
            sourceTypeString = @"recommend_favorites";//收藏推荐
            break;
        case STLAppsflyerGoodsSourceThemeActivity:
            sourceTypeString = [NSString stringWithFormat:@"recommend_theme_activity_%@", sourceID];
            break;
        case STLAppsflyerGoodsSourceCategoryList:
            sourceTypeString = [NSString stringWithFormat:@"category_%@", sourceID];//商品列表
            break;
        case STLAppsflyerGoodsSourceGoodsDetail:
            sourceTypeString = [NSString stringWithFormat:@"recommend_goods_detail_%@", sourceID];
            break;
        case STLAppsflyerGoodsSourceSearchResult:
            sourceTypeString = [NSString stringWithFormat:@"search_%@", sourceID];//搜索列表
            break;
        case STLAppsflyerGoodsSourceCustomPath:
            sourceTypeString = @"customPath";
            break;
        case STLAppsflyerGoodsSourceMainNew:
            sourceTypeString = @"new";
            break;
        default:
            break;
    }
    return sourceTypeString;
}

#pragma mark - AppsFlyerAnalytics
/**
 *  事件统计量
 *
 *  @param
 */
+ (void)appsFlyerTrackEvent:(NSString *)eventName withValues:(NSDictionary *)values
{
    
//#ifdef DEBUG
//
//    if (!STLJudgeNSDictionary(values)) {
//        values = @{};
//    }
//    NSString *parJson = [OSSVNSStringTool jsonStringWithDict:values];
//
//    [OSSVRequestsUtils debugLogWithPlatform:[NSString stringWithFormat:@"AF--%@",eventName] paramsJSON:parJson];
//#endif
//
//    if (STLIsEmptyString(eventName) || ![OSSVConfigDomainsManager isDistributionOnlineRelease]) {
//        return;
//    }
#ifdef AppsFlyerAnalyticsEnabled
//    [[AppsFlyerLib shared] logEvent:eventName withValues:values];
//    [AppsFlyerLib shared].customerUserID = USERID_STRING;
#endif
}

/**
 统计上列表浏览
 
 @param goodsArray 商品列表数据
 @param type 商品列表数据来源
 @param sourceID 数据来源标识
 */
+ (void)appsFlyerTrackGoodsList:(NSArray <OSSVDetailsBaseInfoModel *> *)goodsArray inSourceType:(STLAppsflyerGoodsSourceType)type sourceID:(NSString *)sourceID {
    
#ifdef AppsFlyerAnalyticsEnabled
    NSString *sourceTypeString = [OSSVAnalyticsTool sourceStringWithType:type sourceID:sourceID];
    NSMutableArray *goodsnArray = [[NSMutableArray alloc] init];
    for (OSSVDetailsBaseInfoModel *goodsModel in goodsArray) {
        
        [goodsnArray addObject:STLToString(goodsModel.goods_sn)];
    }
    if (goodsnArray.count > 0) {
        
        NSDictionary *values = @{
            @"af_content_list": goodsnArray,
            @"af_content_type": sourceTypeString
        };
        
        [OSSVAnalyticsTool appsFlyerTrackEvent:@"af_list_view" withValues:values];
    }
#endif
    
}

#pragma mark - //=============== AppsFlyer ===============//

+ (void)appsFlyerRegister:(NSDictionary *)dic {
    [OSSVAnalyticsTool appsFlyerTrackEvent:@"af_complete_registration" withValues:dic];
}

+ (void)appsFlyerLogin:(NSDictionary *)dic {
    [OSSVAnalyticsTool appsFlyerTrackEvent:@"af_login" withValues:nil];
}

+ (void)appsFlyerSearch:(NSDictionary *)dic {
    
    NSDictionary *valueDic = @{
                        //@"af_content_list" : STLToString(dic[@"af_content_list"]),
                        @"af_search_string" : STLToString(dic[@"af_search_string"])
    };
    //暂时不统计搜索结果
    [OSSVAnalyticsTool appsFlyerTrackEvent:@"af_search" withValues:valueDic];
}

+ (void)appsFlyerProducts:(NSDictionary *)dic {
    
    NSDictionary *valueDic = @{@"af_content_id"        : STLToString(dic[@"af_content_id"]),
                               @"af_content_type"      : STLToString(dic[@"af_content_type"]),
                               @"af_currency"          : STLToString(dic[@"af_currency"]),
                              @"af_price"             : STLToString(dic[@"af_price"]),
                            //@"af_inner_mediasource" : [OSSVAnalyticsTool sourceStringWithType:self.sourceType sourceID:self.detailModel.goodsSku],
    };
    [OSSVAnalyticsTool appsFlyerTrackEvent:@"af_content_view" withValues:valueDic];

}
/**
 *  添加购物车
 *
 *  @param sd_product 展示的产品，id和name必传一个，其他非必须
 *  @param isFromProduct 添加购物车方式，YES - 从产品列表页， NO - 从收藏夹
 */
+ (void)appsFlyerAddToCartWithProduct:(CartModel *)cartItem fromProduct:(BOOL)isFromProduct {
    
//#ifdef AppsFlyerAnalyticsEnabled
//
//    CGFloat price = [cartItem.goodsPrice floatValue];;
//    // 0 > 闪购 > 满减
//    if (!STLIsEmptyString(cartItem.specialId)) {//0元
//        price = [cartItem.goodsPrice floatValue];
//
//    } else if (STLIsEmptyString(cartItem.specialId) && !STLIsEmptyString(cartItem.activeId) && cartItem.flash_sale) {//闪购
//        price = [cartItem.flash_sale.active_price floatValue];
//    }
//    CGFloat allPrice = cartItem.goodsNumber * price;
//
//    NSDictionary *dic = @{
//                            //AFEventParamContentType   : STLToString(cartItem.catName),
//                            AFEventParamContentId     : STLToString(cartItem.goods_sn),
//                            AFEventParamPrice         : [NSString stringWithFormat:@"%f",price],
//                            AFEventParamQuantity      : [NSString stringWithFormat:@"%zd",cartItem.goodsNumber],
//                            AFEventParamCurrency      : @"USD",
//                            AFEventParamRevenue      : [NSString stringWithFormat:@"%f",allPrice],
//                            @"af_param_user_id"      : USERID_STRING,
//
//                            //@"af_inner_mediasource"   : sourceId,
//                        };
//
//
//    [OSSVAnalyticsTool appsFlyerTrackEvent:@"af_add_to_cart" withValues:dic];
//
//#endif
}


+ (void)appsFlyerRemoveFromCartWithProduct:(CartModel *)cartItem {
    
//    NSDictionary *dic = @{AFEventParamContentType   : STLToString(cartItem.cat_name),
//                          AFEventParamContentId     : STLToString(cartItem.goods_sn),
//                          //@"af_inner_mediasource"   : sourceId,
//                        };
//    // 谷歌统计 移除购物车
//    [OSSVAnalyticsTool appsFlyerTrackEvent:@"remove_from_cart" withValues:dic];
}
+ (void)appsFlyerOrderSuccess:(NSDictionary *)dic {
    
    // 谷歌统计 购买下单成功
    [OSSVAnalyticsTool appsFlyerTrackEvent:@"af_initiated_checkout" withValues:dic];
}

+ (void)appsFlyerOrderPaySuccess:(NSDictionary *)dic {
    
    // 谷歌统计 已完成购买
    [OSSVAnalyticsTool appsFlyerTrackEvent:@"completed_purchase" withValues:dic];
} 

+ (void)appsFlyerOrderCancel:(NSDictionary *)dic {
    // 谷歌统计 已完成购买
    [OSSVAnalyticsTool appsFlyerTrackEvent:@"order_cancel" withValues:dic];
}
+ (void)appsFlyeraAddToWishlistWithProduct:(OSSVDetailsBaseInfoModel *)product fromProduct:(BOOL)isFromProduct {
    
    NSDictionary *dic = @{@"af_price":STLToString(product.shop_price),
                          @"af_content_id":STLToString(product.goods_sn),
                          @"af_content_type":STLToString(product.cat_name),
                          @"af_currency":@"USD"};
    [OSSVAnalyticsTool appsFlyerTrackEvent:@"af_add_to_wishlist" withValues:dic];
}


//+ (void)analyticsEventWithName:(NSString *)eventName parameters:(NSDictionary *)parameters {
//    return;
//    if ([[OSSVAnalyticsTool sharedManager].analyticsTypeSet containsObject:@"GA"]) {
//        [OSSVAnalyticFirebases firebaseLogEventWithName:eventName parameters:parameters];
//    }
//}

+ (void)analyticsGASetUserID:(NSString *)userId {
    //如果是开发环境，但是配置是线上，也不上报
    if ((![OSSVConfigDomainsManager isDistributionOnlineRelease] && [OSSVLocaslHosstManager isFirebaseConfigureRelease])) {
        return;
    }
    [OSSVAnalyticFirebases firebaseSetUserID:userId];
}
+ (void)analyticsGAEventWithName:(NSString *)eventName parameters:(NSDictionary *)parameters {
    
#ifdef DEBUG
    
    if (!STLJudgeNSDictionary(parameters)) {
        parameters = @{};
    }
    NSString *parJson = [OSSVNSStringTool jsonStringWithDict:parameters];
    
    [OSSVRequestsUtils debugLogWithPlatform:[NSString stringWithFormat:@"GA--%@",eventName] paramsJSON:parJson];
#endif
    
    //如果是开发环境，但是配置是线上，也不上报
    if (STLIsEmptyString(eventName) || (![OSSVConfigDomainsManager isDistributionOnlineRelease] && [OSSVLocaslHosstManager isFirebaseConfigureRelease])) {
        return;
    }
    
    [OSSVAnalyticFirebases firebaseLogEventWithName:eventName parameters:parameters];
}

///GA来源标识
+ (NSString *)gaSourceStringWithType:(STLAppsGASourceType)type sourceID:(NSString *)sourceID {
    return [OSSVAnalyticFirebases gaSourceStringWithType:type sourceID:sourceID];
}

////神策

+ (void)sensorsDynamicConfigure {
    [OSSVAnalyticSensorrs sensorsDynamicConfigure];
}


+ (void)analyticsSensorsEventWithName:(NSString *)eventName parameters:(NSDictionary *)parameters {
    
#ifdef DEBUG
    
    if (!STLJudgeNSDictionary(parameters)) {
        parameters = @{};
    }
    NSString *parJson = [OSSVNSStringTool jsonStringWithDict:parameters];
    
    [OSSVRequestsUtils debugLogWithPlatform:[NSString stringWithFormat:@"SEN--%@",eventName] paramsJSON:parJson];
#endif
    
  
    ///神策配置了正式与测试环境
    [OSSVAnalyticSensorrs sensorsLogEvent:eventName parameters:parameters];
}
+ (void)analyticsSensorsEventFlush {
    [OSSVAnalyticSensorrs sensorsLogEventFlush];
}


//"search（搜索）
//flash_list (闪购列表)
//free_list (0元商品列表)
//topic (专题)
//category（类目）
//home (首页推荐)
//me_recently (浏览记录)
//me_recommend (我的-推荐)
//goods_detail_recommend（商品详情推荐）
//collection (收藏列表)
//virtual_list (虚拟商品列表)  ？？？暂时没用
//goods_detail_similar (商品详情相似列表)
//h5_draw (H5大转盘活动页)
//h5_invite (H5拉新页)
//h5_checkin (H5签到页)
//other (其它)"
//"search（搜索）
//flash_list (闪购列表)
//free_list (0元商品列表)
//topic (专题)
//category（类目）
//home-like (首页喜欢推荐)
//home-other(首页其他推荐)
//me_recently (浏览记录)
//me_recommend (我的-推荐)
//me_viewed (我的-历史浏览)
//goods_detail_recommend（商品详情推荐）
//collection (收藏列表)
//goods_detail_similar (商品详情相似列表)
//h5_draw (H5大转盘活动页)
//h5_invite (H5拉新页)
//h5_checkin (H5签到页)"
//shopping_bag(购物车)
+ (NSString *)sensorsSourceStringWithType:(STLAppsflyerGoodsSourceType)type sourceID:(NSString *)sourceID {
    NSString *sourceTypeString = @"other";
    switch (type) {
        case STLAppsflyerGoodsSourceHome:
            sourceTypeString = @"home";
            break;
        case STLAppsflyerGoodsSourceHomeLike:
            sourceTypeString = @"home-like";
            break;
        case STLAppsflyerGoodsSourceHomeOther:
            sourceTypeString = @"home-other";
            break;
        case STLAppsflyerGoodsSourceYoMeDetail:
            break;
        case STLAppsflyerGoodsSourceCart:
            sourceTypeString = @"shopping_bag";
            break;
        case STLAppsflyerGoodsSourceCartRecommend:
            break;
        case STLAppsflyerGoodsSourceAccountRecommend:
            sourceTypeString = @"me_recommend";//个人中心推荐
            break;
        case STLAppsflyerGoodsSourceHomeRecommend:
            break;
        case STLAppsflyerGoodsSourceDetailRecommendLike:
            sourceTypeString = @"goods_detail_you_also_like";//商品详情推荐
            break;
        case STLAppsflyerGoodsSourceDetailRecommendOften:
            sourceTypeString = @"goods_detail_often_bought_with";//商品详情推荐
            break;
        case STLAppsflyerGoodsSourceWishlist:
            sourceTypeString = @"collection";//收藏推荐
            break;
        case STLAppsflyerGoodsSourceThemeActivity:
            sourceTypeString = @"topic";
            break;
        case STLAppsflyerGoodsSourceCategoryList:
            sourceTypeString = @"category";//商品列表
            break;
        case STLAppsflyerGoodsSourceGoodsDetail:
            sourceTypeString = @"other";
            break;
        case STLAppsflyerGoodsSourceSearchResult:
            sourceTypeString = @"search";//搜索列表
            break;
        case STLAppsflyerGoodsSourceHistory:
            sourceTypeString = @"me_viewed";
            break;
        case STLAppsflyerGoodsSourceAccountHistory:
            sourceTypeString = @"me_recently";
            break;
        case STLAppsflyerGoodsSourceFlashList:
            sourceTypeString = @"flash_list";
            break;
        case STLAppsflyerGoodsSourceHotSearch:
            break;
        case STLAppsflyerGoodsSourceZeroActivity:
            sourceTypeString = @"free_list";
            break;
        case STLAppsflyerGoodsSourceDetailSimilar:
            sourceTypeString = @"goods_detail_similar";
            break;
        case STLAppsflyerGoodsSourceMainNew:
            sourceTypeString = @"new";
            break;
        default:
            break;
    }
    return sourceTypeString;
}
@end
        
