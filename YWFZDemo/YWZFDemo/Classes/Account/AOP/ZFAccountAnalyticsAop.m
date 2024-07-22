//
//  ZFAccountAnalyticsAop.m
//  ZZZZZ
//
//  Created by YW on 2019/3/14.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFAccountAnalyticsAop.h"
#import "ZFAccountProductCell.h"
#import "ZFAccountBannerTableViewCell.h"
#import "ZFAppsflyerAnalytics.h"
#import "ZFGrowingIOAnalytics.h"
#import "YWCFunctionTool.h"
#import "ZFBannerModel.h"
#import "AccountManager.h"
#import <UIKit/UIKit.h>
#import "Constants.h"
#import "UIViewController+ZFViewControllerCategorySet.h"

@interface ZFAccountAnalyticsAop ()

@property (nonatomic, strong) NSMutableArray *analyticsSet;
@property (nonatomic, weak) UIViewController *currentController;
@property (nonatomic, copy) NSString *af_recommend_name;
@property (nonatomic, assign) ZFAppsflyerInSourceType sourceType;
@property (nonatomic, copy) NSString *af_first_entrance;

@end

@implementation ZFAccountAnalyticsAop

-(void)dealloc
{
    YWLog(@"ZFAccountAnalyticsAop dealloc");
}

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

    //订单列表Aop
    if ([NSStringFromClass(self.currentController.class) isEqualToString:@"ZFMyOrderListViewController"]) {
        self.af_recommend_name = @"recommend_orderlist";
        self.sourceType = ZFAppsflyerInSourceTypeMyOrderListRecommend;
        self.af_first_entrance = @"recommend_orderlist";
    }
}

- (void)after_requestAccountRecommendProduct
{
    [self.analyticsSet removeAllObjects];
}

- (void)after_requestRecommendProduct:(BOOL)isFirstPage
{
    if (isFirstPage) {
        [self.analyticsSet removeAllObjects];
    }
}

- (void)after_viewDidLoad
{
    NSDictionary *params = @{
                             @"af_content_type": @"viewpersonalpage",
                             };
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_view_personal_page" withValues:params];
}

- (void)after_tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[ZFAccountProductCell class]]) {
        ZFAccountProductCell *productCell = (ZFAccountProductCell *)cell;
        [productCell.goodsList enumerateObjectsUsingBlock:^(ZFGoodsModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![self.analyticsSet containsObject:ZFToString(obj.goods_id)]) {
                [self.analyticsSet addObject:ZFToString(obj.goods_id)];
                obj.af_rank = (idx + 1) + (indexPath.row * productCell.goodsList.count);
                [ZFAppsflyerAnalytics trackGoodsList:@[obj] inSourceType:self.sourceType AFparams:nil];
                [ZFGrowingIOAnalytics ZFGrowingIOProductShow:obj page:GIOSourceAccountRecommend];
            }
        }];
    }
    if ([cell isKindOfClass:[ZFAccountBannerTableViewCell class]]) {
        ZFAccountBannerTableViewCell *bannerCell = (ZFAccountBannerTableViewCell *)cell;
        [bannerCell.banners enumerateObjectsUsingBlock:^(ZFBannerModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![self.analyticsSet containsObject:ZFToString(obj.banner_id)]) {
                [self.analyticsSet addObject:ZFToString(obj.banner_id)];
                //增加AppsFlyer统计
                NSDictionary *appsflyerParams = @{@"af_content_type" : @"banner impression",  //固定值 banner impression
                                                  @"af_banner_name" : ZFToString(obj.name), //banenr名，如叫拼团
                                                  @"af_channel_name" : ZFToString(obj.menuid), //菜单id，如Homepage / NEW TO SALE
                                                  @"af_ad_id" : ZFToString(obj.banner_id), //banenr id，数据来源于后台配置返回的id
                                                  @"af_component_id" : ZFToString(obj.componentId),//组件id，数据来源于后台返回的组件id
                                                  @"af_col_id" : ZFToString(obj.colid), //坑位id，数据来源于后台返回的坑位id
                                                  @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type) //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                                  };
                [ZFAppsflyerAnalytics zfTrackEvent:@"af_banner_impression" withValues:appsflyerParams];
//                [ZFGrowingIOAnalytics ZFGrowingIOActivityImpByCMS:obj];
                [ZFGrowingIOAnalytics ZFGrowingIOBannerImpWithBannerModel:obj page:GIOSourceAccount];
            }
        }];
    }
}

- (void)after_ZFAccountProductCellDidSelectProduct:(ZFGoodsModel *)goodsModel {
    // appflyer统计
    NSDictionary *appsflyerParams = @{@"af_content_id" : ZFToString(goodsModel.goods_sn),
                                      @"af_spu_id" : ZFToString(goodsModel.goods_spu),
                                      @"af_recommend_name" : @"recommend_orderlist",
                                      @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                      @"af_page_name" : ZFToString(self.af_recommend_name),    // 当前页面名称
                                      @"af_second_entrance" : @"recommend_orderlist"
                                      };
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_recommend_click" withValues:appsflyerParams];
    
    [ZFGrowingIOAnalytics ZFGrowingIOProductClick:goodsModel page:GIOSourceOrderRecommend sourceParams:@{
        GIOGoodsTypeEvar : GIOGoodsTypeRecommend,
        GIOGoodsNameEvar : @"recommend_orderlist",
        GIOFistEvar : GIOSourceAccount,
        GIOSndNameEvar : GIOSourceOrderRecommend
    }];
}

///after 注入事件
-(NSDictionary *)injectMenthodParams
{
    //订单列表Aop
    if ([NSStringFromClass(self.currentController.class) isEqualToString:@"ZFMyOrderListViewController"]) {
        NSDictionary *params = @{
                                 NSStringFromSelector(@selector(tableView:willDisplayCell:forRowAtIndexPath:)) : @"after_tableView:willDisplayCell:forRowAtIndexPath:",
                                 @"requestRecommendProduct:" : @"after_requestRecommendProduct:",
                                 @"ZFAccountProductCellDidSelectProduct:" : @"after_ZFAccountProductCellDidSelectProduct:"
                                 };
        return params;
    }
    return nil;
}

@end
