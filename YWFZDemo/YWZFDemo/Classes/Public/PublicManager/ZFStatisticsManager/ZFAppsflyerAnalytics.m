//
//  ZFAppsflyerAnalytics.m
//  ZZZZZ
//
//  Created by YW on 2018/7/5.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFAppsflyerAnalytics.h"
#import "ZFGoodsModel.h"
#import "GoodsDetailModel.h"

#import "AccountManager.h"
#import "YWCFunctionTool.h"
#import "ZFRequestModel.h"
#import "Constants.h"
#import "YWLocalHostManager.h"
#import "ZFLocalizationString.h"

#import "ZFNetworkManager.h"
#import "ZFDeviceInfoManager.h"

#ifdef AppsFlyerAnalyticsEnabled
#import <AppsFlyerLib/AppsFlyerTracker.h>
#endif
#import <AFNetworking/AFNetworking.h>
#import "NSStringUtils.h"
#import <GGAppsflyerAnalyticsSDK/GGAppsflyerAnalytics.h>
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "ZFBaseViewController.h"
#import "ZFAnalyticsQueueManager.h"
#import "ZFBTSDataSets.h"

@implementation ZFAppsflyerAnalytics

/**
 *  事件统计量
 *
 *  @param
 */
+ (void)trackEventWithContentType:(NSString *)contentType {
#ifdef AppsFlyerAnalyticsEnabled
    [self zfTrackEvent:contentType withValues:@{AFEventParamContentType : contentType}];
#endif
}

/**
 *  事件统计量
 *  @param
 */
+ (void)zfTrackEvent:(NSString *)eventName withValues:(NSDictionary *)values {
#ifdef AppsFlyerAnalyticsEnabled
    //v4.4.0 所有的AF事件加一个国家code
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if ([values isKindOfClass:[NSDictionary class]]) {
        params = [values mutableCopy];
        NSString *regionCode = [AccountManager sharedManager].accountCountryModel.region_code;
        [params setObject:ZFToString(regionCode) forKey:@"af_country_code"];
        [params setObject:ZFToString(GetUserDefault(kLocationInfoPipeline)) forKey:@"af_national_code"];
        [params setObject:ZFToString([[ZFLocalizationString shareLocalizable] currentLanguageMR]) forKey:@"af_lang"];
    }
    //获取链条BTS数据
    NSArray *afBts = [[ZFBTSDataSets sharedInstance] gainBtsSets];
    [params setObject:afBts forKey:@"af_bts"];
    // 只有在线上才统计
    if ([YWLocalHostManager isDistributionOnlineRelease]) {
        // 上传到大数据 BigDataParams 先上传到ZZZZZ大数据平台，随后移除 BigDataParams
        [GGAppsflyerAnalytics uploadBigDataWithEvent:eventName params:params];
        if ([params objectForKey:BigDataParams]) {
            [params removeObjectForKey:BigDataParams];
        }
        // 上传到Appsflyer， Appsflyer 不需要 BigDataParams 数据，所以要移除
        [[AppsFlyerTracker sharedTracker] trackEvent:eventName withValues:params];
    } else {
        //非发布环境才上传Appsflyer统计日志
        [self uploadAppsflyerLogWithEvent:eventName withValues:params];
#warning TODO:xiao 增加上传测试队列
        [ZFAnalyticsQueueManager asyncAnalyticsEvent:eventName withValues:params];
    }
#endif
}

+ (void)trackGoodsList:(NSArray<ZFGoodsModel *> *)goodsArray
          inSourceType:(ZFAppsflyerInSourceType)type {
    [self trackGoodsList:goodsArray
            inSourceType:type
                sourceID:@""];
}

+ (void)trackGoodsList:(NSArray <ZFGoodsModel *> *)goodsArray
          inSourceType:(ZFAppsflyerInSourceType)type
              sourceID:(NSString *)sourceID
{
    [self trackGoodsList:goodsArray
            inSourceType:type
                sourceID:sourceID
                    sort:nil
                aFparams:nil];
}

+ (void)trackGoodsList:(NSArray <ZFGoodsModel *> *)goodsArray
          inSourceType:(ZFAppsflyerInSourceType)type
              AFparams:(AFparams *)afparams
{
    [self trackGoodsList:goodsArray
            inSourceType:type
                sourceID:nil
                    sort:nil
                aFparams:afparams];
}

+ (void)trackGoodsList:(NSArray <ZFGoodsModel *> *)goodsArray
          inSourceType:(ZFAppsflyerInSourceType)type
              sourceID:(NSString *)sourceID
              aFparams:(AFparams *)afparams {
    [self trackGoodsList:goodsArray
            inSourceType:type
                sourceID:sourceID
                    sort:nil
                aFparams:afparams];
    
}

+ (void)trackGoodsList:(NSArray <ZFGoodsModel *> *)goodsArray
          inSourceType:(ZFAppsflyerInSourceType)type
              sourceID:(NSString *)sourceID
                  sort:(NSString *)sort
              aFparams:(AFparams *)afparams
{
    NSString *sourceTypeString = [ZFAppsflyerAnalytics sourceStringWithType:type sourceID:sourceID];
    NSMutableString *goodsSN = [NSMutableString new];
    NSMutableString *rank = [NSMutableString new];
    NSMutableArray *goodsAnalyticsParams = [[NSMutableArray alloc] init];
    for (ZFGoodsModel *goodsModel in goodsArray) {
        if (goodsModel.goods_sn) {
            if (goodsModel == [goodsArray lastObject]) {
                [goodsSN appendString:goodsModel.goods_sn];
                [rank appendString:[NSString stringWithFormat:@"%ld", goodsModel.af_rank]];
            } else {
                [goodsSN appendString:goodsModel.goods_sn];
                [goodsSN appendString:@","];
                [rank appendString:[NSString stringWithFormat:@"%ld", goodsModel.af_rank]];
                [rank appendString:@","];
            }
        }
        [goodsAnalyticsParams addObject:[goodsModel gainAnalyticsParams]];
    }
    
    if ([goodsSN length] > 0 && [sourceTypeString length] > 0) {
        NSDictionary *values = @{
                                 @"af_content_id"       : ZFToString(goodsSN),
                                 @"af_inner_mediasource": ZFToString(sourceTypeString),
                                 @"af_sort"             : ZFToString(sort),
                                 @"af_rank"             : ZFToString(rank),
                                 //大数据需要的附加数据，不上传到appslfyer, 只上传到我们自己的服务器
                                 BigDataParams          : goodsAnalyticsParams,
                                 };
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_impression" withValues:values];
    }
}

+ (NSString *)sourceStringWithType:(ZFAppsflyerInSourceType)type sourceID:(NSString *)sourceID {
    NSString *sourceTypeString = @"";
    switch (type) {
        case ZFAppsflyerInSourceTypeDefault:
            sourceTypeString = @"unknow mediasource";
            break;
        case ZFAppsflyerInSourceTypeHome:
            sourceTypeString = @"recommend_homepage";
            break;
        case ZFAppsflyerInSourceTypeGoodsDetail:
            sourceTypeString = @"recommend productdetail";
            break;
        case ZFAppsflyerInSourceTypeZMeExploreid:
            sourceTypeString = [NSString stringWithFormat:@"recommend_zme_exploreid_%@", sourceID];
            break;
        case ZFAppsflyerInSourceTypeZMeOutfitid:
            sourceTypeString = [NSString stringWithFormat:@"recommend_zme_outfitid_%@", sourceID];
            break;
        case ZFAppsflyerInSourceTypeZMeVideoid:
            sourceTypeString = [NSString stringWithFormat:@"recommend_zme_videoid_%@", sourceID];
            break;
        case ZFAppsflyerInSourceTypeZMeFollow:
            sourceTypeString = [NSString stringWithFormat:@"recommend_zme_followid_%@", sourceID];
            break;
        case ZFAppsflyerInSourceTypeCategoryList:
            sourceTypeString = [NSString stringWithFormat:@"category_%@", sourceID];
            break;
        case ZFAppsflyerInSourceTypePromotion:
            sourceTypeString = [NSString stringWithFormat:@"promotion_%@", sourceID];
            break;
        case ZFAppsflyerInSourceTypeSearchResult:
            sourceTypeString = [NSString stringWithFormat:@"search_%@", sourceID];
            break;
        case ZFAppsflyerInSourceTypeAIRecommend:
            //v410修改了字段名  old AI_recommend_
            sourceTypeString = [NSString stringWithFormat:@"recommend_push"];
            break;
        case ZFAppsflyerInSourceTypeHomeChannel:
            sourceTypeString = [NSString stringWithFormat:@"recommend_channel_%@", sourceID];
            break;
        case ZFAppsflyerInSourceTypeHomeRecomNewin:
            sourceTypeString = @"recommend_newin";
            break;
        case ZFAppsflyerInSourceTypeCarRecommend:
            sourceTypeString = @"recommend_cartpage";
            break;
        case ZFAppsflyerInSourceTypeVirtualCategoryList:
            sourceTypeString = [NSString stringWithFormat:@"%@_%@", @"virtual_category", sourceID];
            break;
        case ZFAppsflyerInSourceTypeRecommendHistory:
            sourceTypeString = [NSString stringWithFormat:@"recommend_history"];
            break;
        case ZFAppsflyerInSourceTypeZMePostDetailRecommend:
            sourceTypeString = [NSString stringWithFormat:@"recommend_zme_postdetail_%@",sourceID];
            break;
        case ZFAppsflyerInSourceTypeZMePostDetailBottomRelatedRecommend:
            sourceTypeString = [NSString stringWithFormat:@"recommend_zme_postdetail_bottom_%@",sourceID];
            break;
        case ZFAppsflyerInSourceTypeZMeVideoDetailRecommend:
            sourceTypeString = [NSString stringWithFormat:@"recommend_zme_videodetail_%@",sourceID];
            break;
        case ZFAppsflyerInSourceTypeZMeAllSimilarList:
            sourceTypeString = [NSString stringWithFormat:@"recommend_zme_allsimilar_%@",sourceID];
            break;
        case ZFAppsflyerInSourceTypeZMeRemommendItemsShow:
            sourceTypeString = @"recommend_z_me_items_shows";
            break;
        case ZFAppsflyerInSourceTypeSearchImageCamera:
            sourceTypeString = @"search_image_camera";
            break;
        case ZFAppsflyerInSourceTypeSearchImagePhotos:
            sourceTypeString = @"search_image_photos";
            break;
        case ZFAppsflyerInSourceTypeSearchAssociation:
            sourceTypeString = [NSString stringWithFormat:@"association_search_%@", sourceID];
            break;
        case ZFAppsflyerInSourceTypeSearchHistory:
            sourceTypeString = [NSString stringWithFormat:@"history_search_%@", sourceID];
            break;
        case ZFAppsflyerInSourceTypeSearchDirect:
            sourceTypeString = [NSString stringWithFormat:@"direct_search_%@", sourceID];
            break;
        case ZFAppsflyerInSourceTypeSearchFix:
            sourceTypeString = [NSString stringWithFormat:@"fix_search_%@", sourceID];
            break;
        case ZFAppsflyerInSourceTypeSearchRecommend:
            sourceTypeString = [NSString stringWithFormat:@"recommend_search_%@", sourceID];
            break;
        case ZFAppsflyerInSourceTypeSearchDeeplink:
            sourceTypeString = [NSString stringWithFormat:@"deeplink_search_%@", sourceID];
            break;
        case ZFAppsflyerInSourceTypeSearchImageitems:
            sourceTypeString = @"search_image_items";
            break;
        case ZFAppsflyerInSourceTypeSerachRecommendPersonal:
            sourceTypeString = @"recommend_personal";
            break;
        case ZFAppsflyerInSourceTypeZMeLiveDetail:
            sourceTypeString = [NSString stringWithFormat:@"zme_live_%@",sourceID];
            break;
        case ZFAppsflyerInSourceTypeCartEmptyDataRecommend:
            sourceTypeString = @"recommend_nullcartpage";
            break;
        case ZFAppsflyerInSourceTypePaySuccessRecommend:
            sourceTypeString = @"recommend_purchasepage";
            break;
        case ZFAppsflyerInSourceTypeZMeCMSHome:
            sourceTypeString = @"recommend_zme_cms_homepage";
            break;
        case ZFAppsflyerInSourceTypeWishListRecommend:
            sourceTypeString = @"recommend_wishlist";
            break;
        case ZFAppsflyerInSourceTypeMyOrderListRecommend:
            sourceTypeString = @"recommend_orderlist";
            break;
        case ZFAppsflyerInSourceTypeMyCouponListRecommend:
            sourceTypeString = @"recommend_couponlist";
            break;
        case ZFAppsflyerInSourceTypeWishListSourceMedia:
            sourceTypeString = @"addwishlist";
            break;
        case ZFAppsflyerInSourceTypeCartPiecing:
            sourceTypeString = @"recommend_coudan";
            break;
        case ZFAppsflyerInSourceTypeNewUserGoods:
            sourceTypeString = @"newusers_exclusive";
            break;
        case ZFAppsflyerInSourceTypeNewUsersRush:
            sourceTypeString = @"newusers_flashsale";
            break;
        case ZFAppsflyerInSourceTypeNativeBanner:
            sourceTypeString = [NSString stringWithFormat:@"Primitive_%@", sourceID];
            break;
        case ZFAppsflyerInSourceTypeOrderDetailsProduct:
            sourceTypeString = @"orderdetails_product";
            break;
        case ZFAppsflyerInSourceTypeFreeGift:
            sourceTypeString = @"gift_product";
            break;
        case ZFAppsflyerInSourceTypeFullReduction:
            sourceTypeString = @"discount_product";
            break;
        case ZFAppsflyerInSourceTypeAccountRecentviewedProduct:
            sourceTypeString = @"recommend_personnal_recentviewed";
            break;
        case ZFAppsflyerInSourceTypeCartProduct:
            sourceTypeString = @"cart_product";
            break;
        case ZFAppsflyerInSourceTypeCollocation:
            sourceTypeString = @"recommend_collocation";
            break;
        case ZFAppsflyerInSourceTypeDetailOutfits:
            sourceTypeString = [NSString stringWithFormat:@"product_detail_outfits_%@", sourceID];
            break;
        case ZFAppsflyerInSourceTypeNativeTopic:
            sourceTypeString = [NSString stringWithFormat:@"native_topic_%@", sourceID];
            break;
        default:
            break;
    }
    return sourceTypeString;
}

/**
 * 上传Appsflyer统计日志ZZZZZ日志系统
 */
+ (void)uploadAppsflyerLogWithEvent:(NSString *)eventName
                         withValues:(NSDictionary *)values
{
    if (!ZFJudgeNSDictionary(values)) return;
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.forbidEncrypt = YES;
    requestModel.forbidAddPublicArgument = YES;
    requestModel.parmaters = values;
    NSString *inputCatchLogTag = [[NSUserDefaults standardUserDefaults] objectForKey:@"kInputCatchLogTagKey"];
    NSString *url = nil;
    if (inputCatchLogTag.length) {
        url = [NSString stringWithFormat:@"Appsflyer统计日志->%@ %@", inputCatchLogTag, ZFToString(eventName)];
    }else{
        url = [NSString stringWithFormat:@"Appsflyer统计日志->%@", ZFToString(eventName)];
    }
    requestModel.url = url;
    [ZFNetworkHttpRequest uploadStatisticsLog:requestModel responseObject:values];
}

/**
 * appsFlyer统计页面显示打开推送的权限点击量
 */
+ (void)analyticsPushEvent:(NSString *)pageName
                 remoteType:(ZFOperateRemotePushType)remoteType
{
    NSString *eventName = @"";
    NSString *contentType = @"";
    switch (remoteType) {
        case ZFOperateRemotePush_Default: //操作页面展示事件
        {
            eventName = @"af_guide_push";
            contentType = @"guide_push";
        }
            break;
        case ZFOperateRemotePush_sys_unKonw: ///**系统授权:未知*/
        {
            eventName = @"af_pushguide_click";
            contentType = @"unKonw";
        }
            break;
        case ZFOperateRemotePush_guide_yes: //引导页:点击 Yep
        {
            eventName = @"af_pushguide_click";
            contentType = @"yes";
        }
            break;
        case ZFOperateRemotePush_guide_no: //引导页:点击 NO
        {
            eventName = @"af_pushguide_click";
            contentType = @"no";
        }
            break;
        case ZFOperateRemotePush_sys_yes: //系统授权:点击 允许
        {
            eventName = @"af_system_pushguide_click";
            contentType = @"yes";
        }
            break;
        case ZFOperateRemotePush_sys_no: //系统授权:点击 拒绝
        {
            eventName = @"af_system_pushguide_click";
            contentType = @"no";
        }
            break;
        default:
            break;
    }
    if (eventName.length > 0 && pageName.length > 0 && contentType.length > 0) {
        NSDictionary *afDict = @{AFEventParamContentType : ZFToString(contentType),
                                 @"af_page_name"         : ZFToString(pageName)};
        [ZFAppsflyerAnalytics zfTrackEvent:eventName withValues:afDict];
    }
}

+ (BOOL)isSameBtsParams:(ZFBTSModel *)old new:(ZFBTSModel *)new
{
    if ([old.planid isEqualToString:new.planid] &&
        [old.bucketid isEqualToString:new.bucketid] &&
        [old.versionid isEqualToString:new.versionid] &&
        [old.plancode isEqualToString:new.plancode] &&
        [old.policy isEqualToString:new.policy]) {
        return YES;
    }
    return NO;
}

+ (BOOL)isEmptyParams:(ZFBTSModel *)btsModel
{
    if (ZFToString(btsModel.planid).length ||
        ZFToString(btsModel.bucketid).length ||
        ZFToString(btsModel.versionid).length ||
        ZFToString(btsModel.plancode).length ||
        ZFToString(btsModel.policy).length) {
        return YES;
    } else {
        return NO;
    }
}

+ (AFHTTPSessionManager *)sessionManager
{
    static dispatch_once_t onceToken;
    static AFHTTPSessionManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [AFHTTPSessionManager manager];
    });
    return manager;
}

+ (NSMutableArray <ZFBTSModel *> *)sharedBtsArray
{
    static NSMutableArray <ZFBTSModel *> *array = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        array = [[NSMutableArray alloc] init];
    });
    return array;
}

+ (void)appsflyerViewViewDidAppear:(UIViewController *)currentViewController
{
//    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
//    NSString *key = [NSString stringWithFormat:@"%@-%lf", NSStringFromClass(currentViewController.class), timeInterval];
//    [[ZFAnalyticsQueueManager sharedInstance] setCurrentPageName:key];
//    [[ZFAnalyticsQueueManager sharedInstance] creatOperationWithKey:key];
}

+ (void)appsflyerViewViewDisAppear:(UIViewController *)currentViewController
{
    
}

@end
