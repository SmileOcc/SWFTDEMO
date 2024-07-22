//
//  ZFHomeAnalysis.m
//  ZZZZZ
//
//  Created by YW on 22/5/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFHomeAnalysis.h"
#import "ZFBannerModel.h"
#import "ZFGoodsModel.h"
#import "ZFFireBaseAnalytics.h"
#import "ZFGrowingIOAnalytics.h"
#import "AccountManager.h"
#import "YWCFunctionTool.h"
#import "ZFAppsflyerAnalytics.h"

@implementation ZFHomeAnalysis


/**
 * 统计显示首页广告浮窗
 */
+ (void)showHomeFloatingAdvertWindow:(ZFBannerModel *)floatBanner {
    NSMutableArray *screenNames = [NSMutableArray array];
    NSString *screenName = [NSString stringWithFormat:@"impression_floatingWindow_%@", floatBanner.name];
    [screenNames addObject:@{@"name":screenName}];
    [ZFAnalytics showAdvertisementWithBanners:screenNames position:nil screenName:@"Home"];
    
    //增加AppsFlyer统计
    NSDictionary *appsflyerParams = @{@"af_content_type" : @"banner impression",  //固定值 banner impression
                                      @"af_banner_name" : ZFToString(floatBanner.name), //banenr名，如叫拼团
                                      @"af_channel_name" : ZFToString(floatBanner.menuid), //菜单id，如Homepage / NEW TO SALE
                                      @"af_ad_id" : ZFToString(floatBanner.banner_id), //banenr id，数据来源于后台配置返回的id
                                      @"af_component_id" : ZFToString(floatBanner.componentId),//组件id，数据来源于后台返回的组件id
                                      @"af_col_id" : ZFToString(floatBanner.colid), //坑位id，数据来源于后台返回的坑位id
                                      @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type) //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                      };
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_banner_impression" withValues:appsflyerParams];
//    [ZFGrowingIOAnalytics ZFGrowingIOActivityImpByCMS:floatBanner];
    [ZFGrowingIOAnalytics ZFGrowingIOBannerImpWithBannerModel:floatBanner page:GIOSourceHomeFloat];
}

/**
 * 统计点击首页广告浮窗
 */
+ (void)clickHomeFloatingAdvertWindow:(ZFBannerModel *)floatBanner {
    NSString *GABannerId   = floatBanner.banner_id;
    NSString *GABannerName = [NSString stringWithFormat:@"impression_floatingWindow_%@", floatBanner.name];
    NSString *position = @"impression_FloatingWindow - P0";
    [ZFAnalytics clickAdvertisementWithId:GABannerId name:GABannerName position:position];
    
    [ZFAnalytics clickButtonWithCategory:@"Home" actionName:@"Home_FloatingWindow" label:GABannerName];
    [ZFFireBaseAnalytics selectContentWithItemId:GABannerName itemName:@"Home_FloatingWindow" ContentType:@"Home - Banner" itemCategory:@"Banner"];
    
    //增加AppsFlyer统计
    NSDictionary *appsflyerParams = @{@"af_content_type" : @"banner impression",  //固定值 banner impression
                                      @"af_banner_name" : ZFToString(floatBanner.name), //banenr名，如叫拼团
                                      @"af_channel_name" : ZFToString(floatBanner.menuid), //菜单id，如Homepage / NEW TO SALE
                                      @"af_ad_id" : ZFToString(floatBanner.banner_id), //banenr id，数据来源于后台配置返回的id
                                      @"af_component_id" : ZFToString(floatBanner.componentId),//组件id，数据来源于后台返回的组件id
                                      @"af_col_id" : ZFToString(floatBanner.colid), //坑位id，数据来源于后台返回的坑位id
                                      @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                      @"af_page_name" : @"homepage",    // 当前页面名称
                                      @"af_first_entrance" : @"float_window"  // 一级入口名
                                      };
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_banner_click" withValues:appsflyerParams];
//    [ZFGrowingIOAnalytics ZFGrowingIOActivityClickByCMS:floatBanner];
    [ZFGrowingIOAnalytics ZFGrowingIObannerClickWithBannerModel:floatBanner page:GIOSourceHomeFloat sourceParams:@{
        GIOFistEvar : GIOSourceHomeFloat,
        GIOSndIdEvar : ZFToString(floatBanner.banner_id),
        GIOSndNameEvar : ZFToString(floatBanner.name)
    }];
}


@end
