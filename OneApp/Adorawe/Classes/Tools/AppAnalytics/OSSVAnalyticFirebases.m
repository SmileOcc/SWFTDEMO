//
//  OSSVAnalyticFirebases.m
// XStarlinkProject
//
//  Created by odd on 2021/1/30.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVAnalyticFirebases.h"

#ifdef FirebaseAnalyticsEnabled
#import <Firebase.h>
#endif

@implementation OSSVAnalyticFirebases

#pragma mark - FirebaseAnalytics
+ (void)firebaseLogEventWithName:(NSString *)eventName parameters:(NSDictionary *)parameters {
    
#ifdef FirebaseAnalyticsEnabled
    [FIRAnalytics logEventWithName:eventName
                        parameters:parameters];
#endif
}

+ (void)firebaseClickEventWithName:(NSString *)eventName {
#ifdef FirebaseAnalyticsEnabled
    [self firebaseLogEventWithName:@"click_event" parameters:@{
                                                               kFIREventSelectContent : STLToString(eventName)
                                                               }];
#endif
}

+ (void)firebaseSetUserID:(NSString *)userId {
    
#ifdef FirebaseAnalyticsEnabled
    [FIRAnalytics setUserID:STLToString(userId)];
    [FIRAnalytics setUserPropertyString:STLToString(userId) forName:@"uid"];
    if (STLIsEmptyString(userId)) {
        [FIRAnalytics setUserPropertyString:@"Not Logged in" forName:@"login_status"];
    } else {
        [FIRAnalytics setUserPropertyString:@"Logged in" forName:@"login_status"];
    }
#endif
}

+ (NSString *)gaSourceStringWithType:(STLAppsGASourceType)type sourceID:(NSString *)sourceID {
    
    NSString *sourceTypeString = @"other";
    switch (type) {
        case STLAppsGASourceHome:
            sourceTypeString = @"home";
            break;
        case STLAppsGASourceHomeLike:
            sourceTypeString = @"home-like";
            break;
        case STLAppsGASourceHomeOther:
            sourceTypeString = @"home-other";
            break;
        case STLAppsGASourceYoMeDetail:
            break;
        case STLAppsGASourceCart:
            sourceTypeString = @"shopping_bag";
            break;
        case STLAppsGASourceCartRecommend:
            break;
        case STLAppsGASourceAccountRecommend:
            sourceTypeString = @"me_recommend";//个人中心推荐
            break;
        case STLAppsGASourceHomeRecommend:
            break;
        case STLAppsGASourceDetailRecommendLike:
            sourceTypeString = @"goods_detail_you_also_like";//商品详情推荐
            break;
        case STLAppsGASourceDetailRecommendOften:
            sourceTypeString = @"goods_detail_often_bought_with";//商品详情推荐
            break;
        case STLAppsGASourceWishlist:
            sourceTypeString = @"WishList";//收藏推荐
            break;
        case STLAppsGASourceThemeActivity:
            sourceTypeString = @"topic";
            break;
        case STLAppsGASourceCategoryList:
            sourceTypeString = @"category";//商品列表
            break;
        case STLAppsGASourceGoodsDetail:
            sourceTypeString = @"other";
            break;
        case STLAppsGASourceSearchResult:
            sourceTypeString = @"search";//搜索列表
            break;
        case STLAppsGASourceHistory:
            sourceTypeString = @"me_viewed";
            break;
        case STLAppsGASourceAccountHistory:
            sourceTypeString = @"me_recently";
            break;
        case STLAppsGASourceFlashList:
            sourceTypeString = @"flash_list";
            break;
        case STLAppsGASourceHotSearch:
            break;
        case STLAppsGASourceZeroActivity:
            sourceTypeString = @"free_list";
            break;
        case STLAppsGASourceDetailSimilar:
            sourceTypeString = @"goods_detail_similar";
            break;
        case STLAppsGASourceMainNew:
            sourceTypeString = @"new";
            break;
        default:
            break;
    }
    return sourceTypeString;
}

@end
