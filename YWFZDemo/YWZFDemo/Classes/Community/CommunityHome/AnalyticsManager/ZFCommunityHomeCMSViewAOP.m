//
//  ZFCommunityHomeCMSViewAOP.m
//  ZZZZZ
//
//  Created by YW on 2019/6/14.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityHomeCMSViewAOP.h"
#import "ZFCMSManagerView.h"
#import "ZFCMSCycleBannerCell.h"
#import "ZFCMSSliderNormalBannerSectionView.h"
#import "ZFCMSNormalBannerCell.h"
#import "ZFCMSSkuBannerCell.h"
#import "ZFCMSTextModuleCell.h"
#import "ZFCMSRecommendGoodsCCell.h"

#import "GoodsDetailModel.h"
#import "ZFLocalizationString.h"
#import "ZFAnalytics.h"
#import "ZFGrowingIOAnalytics.h"
#import "YWCFunctionTool.h"
#import "AccountManager.h"
#import "ZFCommunityHomeAnalyticsSet.h"
#import "ZFCMSViewModel.h"


@interface ZFCommunityHomeCMSViewAOP ()

//@property (nonatomic, strong) NSMutableArray *analyticsSet;
//@property (nonatomic, strong) NSMutableArray *analyticsProductSet;
@property (nonatomic, copy) NSString *localLanguage;
@property (nonatomic, copy) NSString *channleTitle;
@property (nonatomic, strong) AFparams *afparams;

@end

@implementation ZFCommunityHomeCMSViewAOP

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.channleTitle = [UIViewController currentTopViewController].title;
        self.localLanguage = [[ZFLocalizationString shareLocalizable] currentLanguageMR];
    }
    return self;
}

-(void)startHeadReferesh
{
    //下拉刷新时，需要重新计算曝光
    ZFCommunityHomeAnalyticsSet *homeSets = [ZFCommunityHomeAnalyticsSet sharedInstance];
    [homeSets removeAllObjects];
}

- (void)after_cmsManagerView:(ZFCMSManagerView *)managerView collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZFCommunityHomeAnalyticsSet *homeSets = [ZFCommunityHomeAnalyticsSet sharedInstance];
    if ([cell isKindOfClass:[ZFCMSNormalBannerCell class]]){
        ZFCMSNormalBannerCell *bannerCell = (ZFCMSNormalBannerCell *)cell;
        ZFCMSItemModel *itemModel = bannerCell.itemModel;
        //广告类型
        //Appfly 统计
        [self analyticsItemModel:itemModel indexPath:indexPath];
    }
    
    if ([cell isKindOfClass:[ZFCMSSkuBannerCell class]]){
        ZFCMSSkuBannerCell *skuCell = (ZFCMSSkuBannerCell *)cell;
        //平铺商品类型当做sku
        if (skuCell.itemModel) {
            [self analyticsItemModel:skuCell.itemModel indexPath:indexPath];
        }
    } else if([cell isKindOfClass:[ZFCMSRecommendGoodsCCell class]]) {//推荐商品的数据
        ZFCMSRecommendGoodsCCell *skuCell = (ZFCMSRecommendGoodsCCell *)cell;
        if (skuCell.goodsModel) {
            ZFGoodsModel *model = nil;
            model = skuCell.goodsModel;
            if ([homeSets containsObject:ZFToString(model.goods_id)]) {
                return;
            }
            [homeSets addObject:ZFToString(model.goods_id)];
            //商品类型
            // growingIO 统计
            model.recommentType = GIORecommHistory;
            [ZFGrowingIOAnalytics ZFGrowingIOProductShow:model page:GIOSourceCommunity];
            
            //AF 统计
            AFparams *afParams = self.afparams;
            model.af_rank = indexPath.row + 1;
            [ZFAppsflyerAnalytics trackGoodsList:@[model]
                                    inSourceType:ZFAppsflyerInSourceTypeZMeCMSHome sourceID:self.channel_id
                                        aFparams:afParams];
        }
    }
}

- (void)analyticsItemModel:(ZFCMSItemModel *)itemModel indexPath:(NSIndexPath *)indexPath
{
    //广告类型
    //Appfly 统计
    ZFCommunityHomeAnalyticsSet *homeSets = [ZFCommunityHomeAnalyticsSet sharedInstance];
    if ([homeSets containsObject:ZFToString(itemModel.ad_id)]) {
        return;
    }
    [homeSets addObject:ZFToString(itemModel.ad_id)];
    NSDictionary *appsflyerParams =  @{
                                       @"af_content_type" : @"banner impression",  //固定值 banner impression
                                       @"af_banner_name" : ZFToString(itemModel.name), //banenr名，如叫拼团
                                       @"af_channel_name" : ZFToString(self.channel_id), //菜单id，如Homepage / NEW TO SALE
                                       @"af_ad_id" : ZFToString(itemModel.ad_id), //banenr id，数据来源于后台配置返回的id
                                       @"af_component_id" : ZFToString(itemModel.component_id),//组件id，数据来源于后台返回的组件id
                                       @"af_col_id" : ZFToString(itemModel.col_id), //坑位id，数据来源于后台返回的坑位id
                                       @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type) //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                       };
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_banner_impression" withValues:appsflyerParams];
    //
    //    NSString *floorIndex = [NSString stringWithFormat:@"%ld", indexPath.row];
    //    NSString *screenName = [NSString stringWithFormat:@"impression_channel_banner_branch%@_%@_%@", itemModel.col_id, floorIndex, itemModel.name];
    
//    [ZFGrowingIOAnalytics ZFGrowingIOActivityImpByCMS:itemModel channelId:self.channel_id];
    [ZFGrowingIOAnalytics ZFGrowingIOBannerImpWithCMSItemModel:itemModel page:self.channel_name channelID:self.channel_id floorVar:nil];
    //GrowingIO 活动展示统计
    //    [ZFGrowingIOAnalytics ZFGrowingIOActivityImp:itemModel.name
    //                                           floor:screenName
    //                                        position:floorIndex
    //                                            page:ZFToString(self.channleTitle)];
}

- (void)after_cmsManagerView:(ZFCMSManagerView *)managerView collectionView:(UICollectionView *)collectionView didSelectItemCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[ZFCMSNormalBannerCell class]]) {
        ZFCMSSkuBannerCell *bannerCell = (ZFCMSSkuBannerCell *)cell;
        ZFCMSItemModel *itemModel = bannerCell.itemModel;
        // appflyer统计
        NSDictionary *appsflyerParams = @{@"af_content_type" : @"banner impression",  //固定值 banner impression
                                          @"af_banner_name" : ZFToString(itemModel.name), //banenr名，如叫拼团
                                          @"af_channel_name" : ZFToString(self.channel_id), //菜单id，如Homepage / NEW TO SALE
                                          @"af_ad_id" : ZFToString(itemModel.ad_id), //banenr id，数据来源于后台配置返回的id
                                          @"af_component_id" : ZFToString(itemModel.component_id),//组件id，数据来源于后台返回的组件id
                                          @"af_col_id" : ZFToString(itemModel.col_id), //坑位id，数据来源于后台返回的坑位id
                                          @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                          @"af_page_name" : @"community_homepage",    // 当前页面名称
                                          @"af_first_entrance" : ZFToString(self.channel_id)  // 一级入口名
                                          };
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_banner_click" withValues:appsflyerParams];
        [ZFGrowingIOAnalytics ZFGrowingIObannerClickWithCMSItemModel:itemModel page:GIOSourceCommunity channelID:self.channel_id floorVar:nil sourceParams:@{
            GIOFistEvar : GIOSourceCommunity,
            GIOSndIdEvar : ZFToString(itemModel.ad_id),
            GIOSndNameEvar : ZFToString(itemModel.name)
        }];
        //        NSString *position = [NSString stringWithFormat:@"%ld", indexPath.row];
        //        NSString *GABannerName = [NSString stringWithFormat:@"impression_channel_banner1_%@", itemModel.name];
        //GrowingIO转化变量点击
//        [ZFGrowingIOAnalytics ZFGrowingIOActivityClickByCMS:itemModel channelId:self.channel_id];
        //        [ZFGrowingIOAnalytics ZFGrowingIOActivityClick:itemModel.name
        //                                                 floor:GABannerName
        //                                              position:position
        //                                                  page:ZFToString(self.channleTitle)];
    }

    if ([cell isKindOfClass:[ZFCMSRecommendGoodsCCell class]]) {
        // growingIO 统计
        ZFCMSRecommendGoodsCCell *skuCell = (ZFCMSRecommendGoodsCCell *)cell;
        if (skuCell.goodsModel) {
            ZFGoodsModel *model = nil;
            model = skuCell.goodsModel;
            model.recommentType = GIORecommHistory;
            [ZFGrowingIOAnalytics ZFGrowingIOProductClick:model page:@"社区首页推荐位" sourceParams:@{
                GIOGoodsTypeEvar : GIOGoodsTypeCommunity,
                GIOGoodsNameEvar : @"community_homepage",
                GIOFistEvar : GIOSourceCommunity,
            }];
            
            // appflyer统计
            NSDictionary *appsflyerParams = @{@"af_content_id" : ZFToString(model.goods_sn),
                                              @"af_spu_id" : ZFToString(model.goods_spu),
                                              @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                              @"af_page_name" : @"community_homepage",    // 当前页面名称
                                              @"af_first_entrance" : ZFToString(self.channel_id)  // 一级入口名
                                              };
            [ZFAppsflyerAnalytics zfTrackEvent:@"af_sku_click" withValues:appsflyerParams];
        }
    }
}

- (void)after_cmsManagerView:(ZFCMSManagerView *)managerView collectionView:(UICollectionView *)collectionView eventCell:(UICollectionViewCell *)cell deeplinkItem:(ZFCMSItemModel *)itemModel source:(NSString *)source {
    
    ZFGoodsModel *model = itemModel.goodsModel;
    if (model) {
        // appflyer统计
        NSDictionary *appsflyerParams = @{@"af_content_id" : ZFToString(model.goods_sn),
                                          @"af_spu_id" : ZFToString(model.goods_spu),
                                          @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                          @"af_page_name" : @"community_homepage",    // 当前页面名称
                                          @"af_first_entrance" : ZFToString(self.channel_id)  // 一级入口名
                                          };
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_sku_click" withValues:appsflyerParams];
        
        [ZFGrowingIOAnalytics ZFGrowingIOSetEvar:@{
            GIOGoodsTypeEvar : GIOGoodsTypeCommunity,
            GIOGoodsNameEvar : @"community_homepage",
            GIOFistEvar : GIOSourceCommunity,
        }];
    }
}

- (void)after_requestCMSAdvertData
{
    [self startHeadReferesh];
    
}

-(void)setAf_params:(NSDictionary *)af_params
{
    _af_params = af_params;
    //一定要置空，因为有可能没有试验数据
    self.afparams = nil;
    
    if (_af_params) {
        self.afparams = [AFparams yy_modelWithJSON:af_params];
    }
}

-(NSDictionary *)injectMenthodParams
{
    NSDictionary *params = @{
                             @"zf_cmsManagerView:collectionView:willDisplayCell:forItemAtIndexPath:" :
                                 @"after_cmsManagerView:collectionView:willDisplayCell:forItemAtIndexPath:",
                             @"zf_cmsManagerView:collectionView:didSelectItemCell:forItemAtIndexPath:" :
                                 @"after_cmsManagerView:collectionView:didSelectItemCell:forItemAtIndexPath:",
                             @"zf_cmsManagerView:collectionView:eventCell:deeplinkItem:source:" :
                                 @"after_cmsManagerView:collectionView:eventCell:deeplinkItem:source:",
                             @"requestCMSAdvertData" :
                                 @"after_requestCMSAdvertData",
                             };
    
    return params;
}



@end
