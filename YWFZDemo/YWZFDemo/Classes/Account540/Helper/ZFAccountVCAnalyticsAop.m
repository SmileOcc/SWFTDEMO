//
//  ZFAccountVCAnalyticsAop.m
//  ZZZZZ
//
//  Created by YW on 2019/11/12.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFAccountVCAnalyticsAop.h"
#import "YWCFunctionTool.h"
#import "ZFProductCCell.h"
#import "ZFAccountBannerCCell.h"
#import "ZFAccountCategoryCCell.h"
#import "ZFAccountDetailTextCCell.h"

#import "ZFGrowingIOAnalytics.h"
#import "ZFFireBaseAnalytics.h"
#import "ZFAnalytics.h"

#import "AccountManager.h"
#import "ZFGoodsModel.h"
#import "ZFAccountHeaderCellTypeModel.h"
#import "ZFAccountCategorySectionModel.h"

@interface ZFAccountVCAnalyticsAop ()
@property (nonatomic, strong) NSMutableArray *analyticsSet;
@property (nonatomic, weak) UIViewController *currentController;
@end

@implementation ZFAccountVCAnalyticsAop

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)gainCurrentAopClass:(id)currentAopClass {
    self.currentController = currentAopClass;
    
    if ([NSStringFromClass(self.currentController.class) isEqualToString:@"ZFAccountViewController540"]) {
    }
}

- (void)after_viewDidLoad
{
    NSDictionary *params = @{
                             @"af_content_type": @"viewpersonalpage",
                             };
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_view_personal_page" withValues:params];
}

///统计: 点击个人中心分类事件
- (void)after_jumpActionFromCategoryItemCell:(ZFAccountTableAllCellActionType)actionType {
    
    NSDictionary *menuDict = @{
        @(ZFAccountCategoryCell_OrderType) : @"orders",
        @(ZFAccountCategoryCell_WishListType): @"wishlist",
        @(ZFAccountCategoryCell_CouponType) : @"coupons",
        @(ZFAccountCategoryCell_ZPointType) : @"z_points"
    };
    NSString *menuName = menuDict[@(actionType)];
    //增加AppsFlyer统计
    NSDictionary *appsflyerParams = @{@"af_menu_name" : ZFToString(menuName),  //点击的菜单名
                                      @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                      @"af_page_name" : @"account_page",    // 当前页面名称
                                      @"af_first_entrance" : @"account_page"  // 一级入口名
                                      };
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_account_menu_click" withValues:appsflyerParams];
    [ZFGrowingIOAnalytics ZFGrowingIOSetEvar:@{GIOFistEvar : GIOSourceAccount,
                                               GIOSndNameEvar : ZFToString(menuName)
    }];
}

/// 统计个人中心 [Z-me]
- (void)after_ZFAccountHeaderCReusableViewDidClickZ_ME
{
    NSDictionary *appsflyerParams = @{@"af_menu_name" : @"z_me",  //点击的菜单名
                                      @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type),
                                      @"af_page_name" : @"account_page",    // 当前页面名称
                                      @"af_first_entrance" : @"account_page"  // 一级入口名
                                      };
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_account_menu_click" withValues:appsflyerParams];
}

/// AppsFlyer统计个人中心点击 未支付订单
- (void)after_dealWithUnpaidAction:(ZFAccountTableAllCellActionType)actionType
                  orderModel:(MyOrdersModel *)orderModel
{
    if (![orderModel isKindOfClass:[MyOrdersModel class]]) return;
    if (actionType == ZFAccountUnpaidCell_GoPayAction) {
        NSDictionary *appsflyerParams = @{
            @"af_content_type" : @"personal_page",
            @"af_reciept_id" : ZFToString(orderModel.order_id),
            @"af_price" : ZFToString(orderModel.total_fee),
        };
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_orderlistpay_click" withValues:appsflyerParams];
    }
}

/// 统计个人中心点击 CMS Banner
- (void)after_didSelectedAccountCmsBanner:(ZFBannerModel *)bannerModel
                           allBannerArray:(NSArray *)bannerArray
{
    if ([bannerModel isKindOfClass:[ZFBannerModel class]]) {
        
        // firebase
        [bannerArray enumerateObjectsUsingBlock:^(ZFNewBannerModel *newBannerModel, NSUInteger section, BOOL * _Nonnull stop1) {
            if (![newBannerModel isKindOfClass:[ZFNewBannerModel class]]) {
                *stop1 = YES;
            }
                
            [newBannerModel.banners enumerateObjectsUsingBlock:^(ZFBannerModel *touchBannerModel, NSUInteger row, BOOL * _Nonnull stop2) {
                if (![touchBannerModel isKindOfClass:[ZFBannerModel class]]) {
                    *stop2 = YES;
                }
                
                if ([touchBannerModel isEqual:bannerModel]) {
                    [ZFFireBaseAnalytics selectContentWithItemId:[NSString stringWithFormat:@"impression_accout_banner%ld.%ld_%@", section + 1, row + 1, bannerModel.name] itemName:bannerModel.name ContentType:@"account_banner" itemCategory:@"banner"];
                }
            }];
        }];
        
        // 谷歌统计
        NSString *GABannerId   = bannerModel.banner_id;
        NSString *GABannerName = [NSString stringWithFormat:@"%@_%@",ZFGAAccountInternalPromotion, bannerModel.name];
        [ZFAnalytics clickAdvertisementWithId:GABannerId name:GABannerName position:nil];
        
        //增加AppsFlyer统计
        NSDictionary *appsflyerParams = @{
            @"af_content_type" : @"banner impression",  //固定值 banner impression
            @"af_banner_name" : ZFToString(bannerModel.name), //banenr名，如叫拼团
            @"af_channel_name" : ZFToString(bannerModel.menuid), //菜单id，如Homepage / NEW TO SALE
            @"af_ad_id" : ZFToString(bannerModel.banner_id), //banenr id，数据来源于后台配置返回的id
            @"af_component_id" : ZFToString(bannerModel.componentId),//组件id，数据来源于后台返回的组件id
            @"af_col_id" : ZFToString(bannerModel.colid), //坑位id，数据来源于后台返回的坑位id
            @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
            @"af_page_name" : @"account_page",    // 当前页面名称
            @"af_first_entrance" : @"account_page"  // 一级入口名
        };
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_banner_click" withValues:appsflyerParams];
        // [ZFGrowingIOAnalytics ZFGrowingIOActivityClickByCMS:bannerModel];
        [ZFGrowingIOAnalytics ZFGrowingIObannerClickWithBannerModel:bannerModel page:GIOSourceAccount sourceParams:@{
            GIOFistEvar : GIOSourceAccount,
            GIOSndIdEvar : ZFToString(bannerModel.banner_id),
            GIOSndNameEvar : ZFToString(bannerModel.name)
        }];
    }
}

-(NSDictionary *)injectMenthodParams
{
    NSDictionary *params = @{
        NSStringFromSelector(@selector(viewDidLoad)) :
            NSStringFromSelector(@selector(after_viewDidLoad)),
        
        @"ZFAccountHeaderCReusableViewDidClickZ_ME" : @"after_ZFAccountHeaderCReusableViewDidClickZ_ME",
        
        @"didSelectedAccountCmsBanner:allBannerArray:" : @"after_didSelectedAccountCmsBanner:allBannerArray:",
        
        @"jumpActionFromCategoryItemCell:" : @"after_jumpActionFromCategoryItemCell:",
        
        @"dealWithUnpaidAction:orderModel:" : @"after_dealWithUnpaidAction:orderModel:"
    };
    return params;
}

@end
