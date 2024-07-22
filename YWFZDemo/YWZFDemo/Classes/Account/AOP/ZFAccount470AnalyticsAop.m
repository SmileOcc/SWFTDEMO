//
//  ZFAccount470AnalyticsAop.m
//  ZZZZZ
//
//  Created by YW on 2019/7/5.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFAccount470AnalyticsAop.h"
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
#import "ZFAccountCategorySectionModel.h"

@interface ZFAccount470AnalyticsAop ()

@property (nonatomic, strong) NSMutableArray *analyticsSet;
@property (nonatomic, weak) UIViewController *currentController;
@property (nonatomic, copy) NSString *af_recommend_name;
@property (nonatomic, assign) ZFAppsflyerInSourceType sourceType;
@property (nonatomic, copy) NSString *af_first_entrance;

@end

@implementation ZFAccount470AnalyticsAop

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.analyticsSet = [[NSMutableArray alloc] init];
        self.af_recommend_name = @"account_page";
        self.sourceType = ZFAppsflyerInSourceTypeDefault;
        self.af_first_entrance = @"discover_your_style_muse";
    }
    return self;
}

- (void)gainCurrentAopClass:(id)currentAopClass
{
    self.currentController = currentAopClass;
    
    if ([NSStringFromClass(self.currentController.class) isEqualToString:@"ZFAccountViewController"]) {
        self.af_recommend_name = @"account_page";
        self.sourceType = ZFAppsflyerInSourceTypeSerachRecommendPersonal;
    }
}

- (void)after_requestAccountAllData
{
    [self.analyticsSet removeAllObjects];
}

- (void)after_viewDidLoad
{
    NSDictionary *params = @{
                             @"af_content_type": @"viewpersonalpage",
                             };
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_view_personal_page" withValues:params];
}

- (void)after_collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[ZFProductCCell class]]) {
        ZFProductCCell *productCell = (ZFProductCCell *)cell;
        if ([productCell.model isKindOfClass:[ZFGoodsModel class]]) {
            ZFGoodsModel *goodsModel = (ZFGoodsModel *)productCell.model;
            if ([self.analyticsSet containsObject:ZFToString(goodsModel.goods_id)]) {
                return;
            }
            [self.analyticsSet addObject:ZFToString(goodsModel.goods_id)];
            goodsModel.af_rank = indexPath.row + 1;
            [ZFAppsflyerAnalytics trackGoodsList:@[goodsModel] inSourceType:self.sourceType AFparams:nil];
            [ZFGrowingIOAnalytics ZFGrowingIOProductShow:goodsModel page:GIOSourceAccountRecommend];
        }
    }
    if ([cell isKindOfClass:[ZFAccountBannerCCell class]]) {
        ZFAccountBannerCCell *bannerCell = (ZFAccountBannerCCell *)cell;
        //增加AppsFlyer统计
        if ([bannerCell.model isKindOfClass:[ZFBannerModel class]]) {
            ZFBannerModel *bannerModel = (ZFBannerModel *)bannerCell.model;
            if ([self.analyticsSet containsObject:ZFToString(bannerModel.name)]) {
                return;
            }
            [self.analyticsSet addObject:ZFToString(bannerModel.name)];
            NSDictionary *appsflyerParams = @{@"af_content_type" : @"banner impression",  //固定值 banner impression
                                              @"af_banner_name" : ZFToString(bannerModel.name), //banenr名，如叫拼团
                                              @"af_channel_name" : ZFToString(bannerModel.menuid), //菜单id，如Homepage / NEW TO SALE
                                              @"af_ad_id" : ZFToString(bannerModel.banner_id), //banenr id，数据来源于后台配置返回的id
                                              @"af_component_id" : ZFToString(bannerModel.componentId),//组件id，数据来源于后台返回的组件id
                                              @"af_col_id" : ZFToString(bannerModel.colid), //坑位id，数据来源于后台返回的坑位id
                                              @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type) //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                              };
            [ZFAppsflyerAnalytics zfTrackEvent:@"af_banner_impression" withValues:appsflyerParams];
//            [ZFGrowingIOAnalytics ZFGrowingIOActivityImpByCMS:bannerModel];
            [ZFGrowingIOAnalytics ZFGrowingIOBannerImpWithBannerModel:bannerModel page:GIOSourceAccount];
        }
    }
}

-(void)after_collectionView:(UICollectionView *)collectionView
   didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[ZFAccountBannerCCell class]]) {
        ZFAccountBannerCCell *bannerCell = (ZFAccountBannerCCell *)cell;
        if ([bannerCell.model isKindOfClass:[ZFBannerModel class]]) {
            ZFBannerModel *bannerModel = (ZFBannerModel *)bannerCell.model;
            
            // firebase
            [ZFFireBaseAnalytics selectContentWithItemId:[NSString stringWithFormat:@"impression_accout_banner%ld.%ld_%@", indexPath.section + 1, indexPath.item + 1, bannerModel.name] itemName:bannerModel.name ContentType:@"account_banner" itemCategory:@"banner"];
            
            // 谷歌统计
            NSString *GABannerId   = bannerModel.banner_id;
            NSString *GABannerName = [NSString stringWithFormat:@"%@_%@",ZFGAAccountInternalPromotion, bannerModel.name];
            [ZFAnalytics clickAdvertisementWithId:GABannerId name:GABannerName position:nil];
            
            //增加AppsFlyer统计
            NSDictionary *appsflyerParams = @{@"af_content_type" : @"banner impression",  //固定值 banner impression
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
//            [ZFGrowingIOAnalytics ZFGrowingIOActivityClickByCMS:bannerModel];
            [ZFGrowingIOAnalytics ZFGrowingIObannerClickWithBannerModel:bannerModel page:GIOSourceAccount sourceParams:@{
                GIOFistEvar : GIOSourceAccount,
                GIOSndIdEvar : ZFToString(bannerModel.banner_id),
                GIOSndNameEvar : ZFToString(bannerModel.name)
            }];
        }
    }
    
    if ([cell isKindOfClass:[ZFAccountCategoryCCell class]]) {
        //个人中心分类点击事件
        ZFAccountCategoryCCell *categoryCell = (ZFAccountCategoryCCell *)cell;
        if ([categoryCell.model isKindOfClass:[ZFAccountCategoryModel class]]) {
            ZFAccountCategoryModel *categoryModel = (ZFAccountCategoryModel *)categoryCell.model;
            NSString *menuName = categoryModel.analyticsMenuName;
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
    }
    
    if ([cell isKindOfClass:[ZFAccountDetailTextCCell class]]) {
        //个人中心用户cell点击
        ZFAccountDetailTextCCell *detailTextCell = (ZFAccountDetailTextCCell *)cell;
        if ([detailTextCell.model isKindOfClass:[ZFAccountDetailTextModel class]]) {
            ZFAccountDetailTextModel *textModel = detailTextCell.model;
            NSString *menuName = textModel.analyticsMenuName;
            //增加AppsFlyer统计
            NSDictionary *appsflyerParams = @{@"af_menu_name" : ZFToString(menuName),  //点击的菜单名
                                              @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                              @"af_page_name" : @"account_page",    // 当前页面名称
                                              @"af_first_entrance" : @"account_page"  // 一级入口名
                                              };
            [ZFAppsflyerAnalytics zfTrackEvent:@"af_account_menu_click" withValues:appsflyerParams];
        }
    }
    if ([cell isKindOfClass:[ZFProductCCell class]]) {
        // appflyer统计
        ZFProductCCell *product = (ZFProductCCell *)cell;
        if ([product.model isKindOfClass:[ZFGoodsModel class]]) {
            ZFGoodsModel *goodsModel = product.model;
            NSDictionary *appsflyerParams = @{@"af_content_id" : ZFToString(goodsModel.goods_sn),
                                              @"af_spu_id" : ZFToString(goodsModel.goods_spu),
                                              @"af_recommend_name" : @"recommend_personal",
                                              @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                              @"af_page_name" : @"account_page",    // 当前页面名称
                                              @"af_first_entrance" : @"account_page"
                                              };
            [ZFAppsflyerAnalytics zfTrackEvent:@"af_recommend_click" withValues:appsflyerParams];
            
            [ZFGrowingIOAnalytics ZFGrowingIOProductClick:goodsModel page:GIOSourceAccountRecommend sourceParams:@{
                GIOGoodsTypeEvar : GIOGoodsTypeRecommend,
                GIOGoodsNameEvar : @"recommend_personal",
                GIOFistEvar : GIOSourceAccount,
                GIOSndNameEvar : GIOSourceAccountRecommend
            }];
        }
    }
}

- (void)after_ZFAccountHeaderCReusableViewDidClickZ_ME
{
    //增加AppsFlyer统计
    NSDictionary *appsflyerParams = @{@"af_menu_name" : @"z_me",  //点击的菜单名
                                      @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                      @"af_page_name" : @"account_page",    // 当前页面名称
                                      @"af_first_entrance" : @"account_page"  // 一级入口名
                                      };
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_account_menu_click" withValues:appsflyerParams];
}

- (void)after_ZFAccountRecentlyCellDidClickProductItem:(ZFCMSItemModel *)itemModel {
    // appflyer统计
    NSDictionary *appsflyerParams = @{@"af_content_id" : ZFToString(itemModel.goodsModel.goods_sn),
                                      @"af_spu_id" : ZFToString(itemModel.goodsModel.goods_spu),
                                      @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                      @"af_page_name" : @"account_page",    // 当前页面名称
                                      @"af_first_entrance" : @"recently_viewed"
                                      };
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_sku_click" withValues:appsflyerParams];
    
    [ZFGrowingIOAnalytics ZFGrowingIOProductClick:itemModel.goodsModel page:GIOSourceAccount sourceParams:@{
        GIOGoodsTypeEvar : GIOGoodsTypeOther,
        GIOGoodsNameEvar : @"recommend_personnal_recentviewed",
        GIOFistEvar : GIOSourceAccount,
        GIOSndNameEvar : GIOSourceRecenty
    }];
}

-(NSDictionary *)injectMenthodParams
{
    NSDictionary *params = @{
                                     NSStringFromSelector(@selector(collectionView:willDisplayCell:forItemAtIndexPath:)) : NSStringFromSelector(@selector(after_collectionView:willDisplayCell:forItemAtIndexPath:)),
                                     NSStringFromSelector(@selector(collectionView:didSelectItemAtIndexPath:)) :
                                         NSStringFromSelector(@selector(after_collectionView:didSelectItemAtIndexPath:)),
                                     NSStringFromSelector(@selector(viewDidLoad)) :
                                         NSStringFromSelector(@selector(after_viewDidLoad)),
                                     @"requestAccountAllData" : @"after_requestAccountAllData",
                                     @"ZFAccountHeaderCReusableViewDidClickZ_ME" : @"after_ZFAccountHeaderCReusableViewDidClickZ_ME",
                                     @"ZFAccountRecentlyCellDidClickProductItem:" : @"after_ZFAccountRecentlyCellDidClickProductItem:"
                                     };

    return params;
}

@end
