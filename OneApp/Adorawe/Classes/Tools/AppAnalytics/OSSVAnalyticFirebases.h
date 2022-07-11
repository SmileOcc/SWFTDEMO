//
//  OSSVAnalyticFirebases.h
// XStarlinkProject
//
//  Created by odd on 2021/1/30.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *kGA_screen_group = @"screen_group";
static NSString *kGA_position = @"position";

typedef NS_ENUM(NSInteger, STLAppsGASourceType) {
    /**首页*/
    STLAppsGASourceHome = 1,
    STLAppsGASourceHomeLike,
    STLAppsGASourceHomeOther,

    /**社区详情*/
    STLAppsGASourceYoMeDetail,
    /**购物车商品*/
    STLAppsGASourceCart,
    /**购物车推荐商品*/
    STLAppsGASourceCartRecommend,
    /**首页推荐商品*/
    STLAppsGASourceHomeRecommend,
    /**个人中心推荐商品*/
    STLAppsGASourceAccountRecommend,
    /**商品详情推荐商品*/
    STLAppsGASourceDetailRecommendLike,
    STLAppsGASourceDetailRecommendOften,
    /**收藏夹*/
    STLAppsGASourceWishlist,
    /**原生专题*/
    STLAppsGASourceThemeActivity,
    /**分类列表*/
    STLAppsGASourceCategoryList,
    /**商品详情*/
    STLAppsGASourceGoodsDetail,
    /**搜索列表*/
    STLAppsGASourceSearchResult,
    /**从配置的链接进入*/
    STLAppsGASourceCustomPath,
    /**浏览历史列表*/
    STLAppsGASourceHistory,
    /**个人底部浏览历史*/
    STLAppsGASourceAccountHistory,
    /**0元活动列表*/
    STLAppsGASourceZeroActivity,
    /**订单*/
    STLAppsGASourceOrder,
    /**闪购来源*/
    STLAppsGASourceFlashList,
    //**** 热搜****//
    STLAppsGASourceHotSearch,
    /**商品相似列表*/
    STLAppsGASourceDetailSimilar,
    /**首页NEW*/
    STLAppsGASourceMainNew,
};


NS_ASSUME_NONNULL_BEGIN

@interface OSSVAnalyticFirebases : NSObject

#pragma mark - //===============  firebase事件统计 GA ===============//

///**
// *  firebase事件统计 GA
// */
+ (void)firebaseLogEventWithName:(NSString *)eventName parameters:(NSDictionary *)parameters;

+ (void)firebaseClickEventWithName:(NSString *)eventName;

//设置用户ID  Setting the user ID
+ (void)firebaseSetUserID:(NSString *)userId;

+ (NSString *)gaSourceStringWithType:(STLAppsGASourceType)type sourceID:(NSString *)sourceID;


///屏幕浏览 kFIREventScreenView

@end

NS_ASSUME_NONNULL_END
