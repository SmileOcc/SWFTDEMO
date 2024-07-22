//
//  ZFCMSHomeAnalyticsAOP.m
//  ZZZZZ
//
//  Created by YW on 2018/12/24.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFCMSHomeAnalyticsAOP.h"
#import "ZFCMSManagerView.h"
#import "ZFCMSNormalBannerCell.h"
#import "ZFCMSSkuBannerCell.h"
#import "ZFCMSRecommendGoodsCCell.h"
#import "ZFCMSCouponCCell.h"

#import "GoodsDetailModel.h"
#import "ZFLocalizationString.h"
#import "ZFAnalytics.h"
#import "ZFGrowingIOAnalytics.h"
#import "YWCFunctionTool.h"
#import "AccountManager.h"
#import "ZFCMSViewModel.h"

NSString *const TrackerCustomeArgsRow = @"zf_row";
NSString *const TrackerCustomeArgsSection = @"zf_section";
NSString *const TrackerCustomeArgsModel = @"zf_model";
NSString *const TrackerCustomePublicParams = @"zf_publicparams";

NSString *const TrackerCustomePublicParamsisHome = @"zf_home";
NSString *const TrackerCustomePublicParamsAfParams = @"zf_afparams";
NSString *const TrackerCustomePublicParamsChannelId = @"zf_channelid";
NSString *const TrackerCustomePublicParamsChannelTitle = @"zf_channelTitle";

@interface ZFCMSHomeAnalyticsAOP ()

@property (nonatomic, copy) NSString *localLanguage;
@property (nonatomic, copy) NSString *channleTitle;
@property (nonatomic, strong) AFparams *afparams;

@end

@implementation ZFCMSHomeAnalyticsAOP

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.channleTitle = [UIViewController currentTopViewController].title;
        self.localLanguage = [[ZFLocalizationString shareLocalizable] currentLanguageMR];
    }
    return self;
}

- (void)baseConfigureSource:(ZFAnalyticsAOPSource)source analyticsId:(NSString *)idx {
    self.source = ZFAnalyticsAOPSourceHome;
    self.idx = idx ? idx : NSStringFromClass(ZFCMSHomeAnalyticsAOP.class);
}
- (void)after_addListViewRefreshKit
{
    if ([AccountManager sharedManager].isFilterAnalytics && [ZFToString(self.channel_id) isEqualToString:ZFToString([AccountManager sharedManager].channelId)]) {
        // 推送延时统计
        return;
    }
    ///app首页进入的时候，统计一下view_homepage
    NSDictionary *afParams = @{ @"af_content_type" : @"view homepage",  //固定值 banner impression
                                @"af_channel_name" : ZFToString(self.channel_name),
                                @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                @"af_channel_id" : ZFToString(self.channel_id)
                                };
    
    [ZFAnalytics appsFlyerTrackEvent:@"af_view_homepage" withValues:afParams];
}

-(void)startHeadReferesh
{
    //下拉刷新时，需要重新计算曝光
    ZFAnalyticsExposureSet *homeSets = [ZFAnalyticsExposureSet sharedInstance];
    [homeSets removeAllObjectsAnalyticsId:self.idx];
}

- (void)after_cmsManagerView:(ZFCMSManagerView *)managerView collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZFAnalyticsExposureSet *homeSets = [ZFAnalyticsExposureSet sharedInstance];
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
        
    } else if([cell isKindOfClass:[ZFCMSRecommendGoodsCCell class]]) {
        
        ZFCMSRecommendGoodsCCell *skuCell = (ZFCMSRecommendGoodsCCell *)cell;
        ZFGoodsModel *model = nil;
        
        //推荐商品的数据
        model = skuCell.goodsModel;
        if ([homeSets containsObject:ZFToString(model.goods_id) analyticsId:self.idx]) {
            return;
        }
        [homeSets addObject:ZFToString(model.goods_id) analyticsId:self.idx];
        //商品类型
        // growingIO 统计
        model.recommentType = GIORecommHistory;
        [ZFGrowingIOAnalytics ZFGrowingIOProductShow:model page:@"首页推荐位"];
        
        //AF 统计
        AFparams *afParams = self.afparams;
        model.af_rank = indexPath.row + 1;
        if (self.isHomePage) {
            //表示首页
            [ZFAppsflyerAnalytics trackGoodsList:@[model]
                                    inSourceType:ZFAppsflyerInSourceTypeHome AFparams:afParams];
        }else{
            [ZFAppsflyerAnalytics trackGoodsList:@[model]
                                    inSourceType:ZFAppsflyerInSourceTypeHomeChannel sourceID:self.channel_id
                                        aFparams:afParams];
        }
    } else if([cell isKindOfClass:[ZFCMSCouponCCell class]]) {
        
        ZFCMSCouponCCell *couponCell = (ZFCMSCouponCCell *)cell;
        NSArray *itemModelArrays = couponCell.itemModelArrays;
        [itemModelArrays enumerateObjectsUsingBlock:^(ZFCMSItemModel *  _Nonnull itemModel, NSUInteger idx, BOOL * _Nonnull stop) {
            
            //广告类型
            //Appfly 统计
            [self analyticsItemModel:itemModel indexPath:indexPath];
        }];
        
    }
}

- (void)analyticsItemModel:(ZFCMSItemModel *)itemModel indexPath:(NSIndexPath *)indexPath
{
    //广告类型
    //Appfly 统计
    ZFAnalyticsExposureSet *homeSets = [ZFAnalyticsExposureSet sharedInstance];
    if ([homeSets containsObject:ZFToString(itemModel.ad_id) analyticsId:self.idx]) {
        return;
    }
    [homeSets addObject:ZFToString(itemModel.ad_id) analyticsId:self.idx];
    // 推送延时统计
    if ([AccountManager sharedManager].isFilterAnalytics) {
        [[AccountManager sharedManager].filterAnalyticsArray addObject:itemModel];
        return;
    }
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
    
//    [ZFGrowingIOAnalytics ZFGrowingIOActivityImpByCMS:itemModel channelId:self.channel_id];
    [ZFGrowingIOAnalytics ZFGrowingIOBannerImpWithCMSItemModel:itemModel page:self.channel_name channelID:self.channel_id floorVar:nil];
}

- (void)after_cmsManagerView:(ZFCMSManagerView *)managerView collectionView:(UICollectionView *)collectionView didSelectItemCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[ZFCMSNormalBannerCell class]]) {
        ZFCMSNormalBannerCell *bannerCell = (ZFCMSNormalBannerCell *)cell;
        ZFCMSItemModel *itemModel = bannerCell.itemModel;
        // appflyer统计
        NSDictionary *appsflyerParams = @{@"af_content_type" : @"banner impression",  //固定值 banner impression
                                          @"af_banner_name" : ZFToString(itemModel.name), //banenr名，如叫拼团
                                          @"af_channel_name" : ZFToString(self.channel_id), //菜单id，如Homepage / NEW TO SALE
                                          @"af_ad_id" : ZFToString(itemModel.ad_id), //banenr id，数据来源于后台配置返回的id
                                          @"af_component_id" : ZFToString(itemModel.component_id),//组件id，数据来源于后台返回的组件id
                                          @"af_col_id" : ZFToString(itemModel.col_id), //坑位id，数据来源于后台返回的坑位id
                                          @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                          @"af_page_name" : @"homepage",    // 当前页面名称
                                          @"af_first_entrance" : ZFToString(self.channel_id)  // 一级入口名
                                          };
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_banner_click" withValues:appsflyerParams];
        
        //GrowingIO转化变量点击
        [ZFGrowingIOAnalytics ZFGrowingIObannerClickWithCMSItemModel:itemModel page:self.channel_name channelID:self.channel_id floorVar:nil sourceParams:@{
            GIOFistEvar : ZFToString(self.channel_name),
            GIOSndIdEvar : ZFToString(itemModel.ad_id),
            GIOSndNameEvar : ZFToString(itemModel.name)
        }];
//        [ZFGrowingIOAnalytics ZFGrowingIOActivityClickByCMS:itemModel channelId:self.channel_id];
    }
    
    //只做推荐商品统计
    if([cell isKindOfClass:[ZFCMSRecommendGoodsCCell class]]) {
        
        // growingIO 统计
        ZFCMSRecommendGoodsCCell *skuCell = (ZFCMSRecommendGoodsCCell *)cell;
        
        if (skuCell.goodsModel) {
            ZFGoodsModel *model = nil;
            model = skuCell.goodsModel;
            model.recommentType = GIORecommHistory;
            
            // appflyer统计
            NSDictionary *appsflyerParams = @{@"af_content_id" : ZFToString(model.goods_sn),
                                              @"af_spu_id" : ZFToString(model.goods_spu),
                                              @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                              @"af_page_name" : @"homepage", // 当前页面名称
                                              @"af_first_entrance" : ZFToString(self.channel_id),  // 一级入口名
                                              @"af_channel_name" : ZFToString(self.channel_id),
                                              @"af_recommend_name" : @"recommend_homepage"
                                              };
            [ZFAppsflyerAnalytics zfTrackEvent:@"af_recommend_click" withValues:appsflyerParams];
            [ZFGrowingIOAnalytics ZFGrowingIOProductClick:model page:GIOSourceHome sourceParams:@{
                GIOGoodsTypeEvar : GIOGoodsTypeRecommend,
                GIOGoodsNameEvar : [NSString stringWithFormat:@"recommend_channel_%@", ZFToString(self.channel_name)],
                GIOFistEvar : ZFToString(self.channel_name),
                GIOSndNameEvar : GIOSourceHomeChannel
            }];
        }
    }
}

- (void)after_cmsManagerView:(ZFCMSManagerView *)managerView collectionView:(UICollectionView *)collectionView eventCell:(UICollectionViewCell *)cell deeplinkItem:(ZFCMSItemModel *)itemModel source:(NSString *)source {
    
    ZFGoodsModel *model = itemModel.goodsModel;
    if (model) {//历史浏览记录
        // appflyer统计
        NSDictionary *appsflyerParams = @{@"af_content_id" : ZFToString(model.goods_sn),
                                          @"af_spu_id" : ZFToString(model.goods_spu),
                                          @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                          @"af_page_name" : @"homepage",    // 当前页面名称
                                          @"af_first_entrance" : ZFToString(self.channel_id)  // 一级入口名
                                          };
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_sku_click" withValues:appsflyerParams];
        
        [ZFGrowingIOAnalytics ZFGrowingIOProductClick:model page:GIOSourceHome sourceParams:@{
            GIOGoodsTypeEvar : GIOGoodsTypeOther,
            GIOGoodsNameEvar : @"recommend_homepage_recentviewed",
            GIOFistEvar : ZFToString(self.channel_name),
            GIOSndNameEvar : GIOSourceHomeChannel
            
        }];
    }
}

- (void)after_cmsManagerView:(ZFCMSManagerView *)managerView collectionView:(UICollectionView *)collectionView recommendCell:(ZFCMSRecommendGoodsCCell *)cell dislikeRecommendGoods:(ZFGoodsModel *)goodsModel {
    
    if (goodsModel) {
        
        NSString *inner_source = [ZFAppsflyerAnalytics
                                  sourceStringWithType:ZFAppsflyerInSourceTypeHome sourceID:@""];
        if (!self.isHomePage) {
            inner_source = [ZFAppsflyerAnalytics
                            sourceStringWithType:ZFAppsflyerInSourceTypeHomeChannel sourceID:self.channel_id];
        }
        // appflyer统计
        NSDictionary *appsflyerParams = @{@"af_content_type" : @"dislikeproduct",
                                          @"af_content_id" : ZFToString(goodsModel.goods_sn),
                                          @"af_spu_id" : ZFToString(goodsModel.goods_spu),
                                          @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                          @"af_page_name" : @"homepage",    // 当前页面名称
                                          @"af_inner_mediasource" :ZFToString(inner_source),
                                          @"af_first_entrance" : ZFToString(self.channel_id)  // 一级入口名
                                          };
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_dislikeproduct" withValues:appsflyerParams];
    }
}

/** 点击优惠券*/
- (void)after_cmsManagerView:(ZFCMSManagerView *)managerView collectionView:(UICollectionView *)collectionView couponCell:(ZFCMSCouponCCell *)cell model:(ZFCMSItemModel *)model {
    
    if([cell isKindOfClass:[ZFCMSCouponCCell class]] && model) {
                   
        ZFCMSItemModel *itemModel = model;
        // appflyer统计
        NSDictionary *appsflyerParams = @{@"af_content_type" : @"banner impression",  //固定值 banner impression
                                          @"af_banner_name" : ZFToString(itemModel.name), //banenr名，如叫拼团
                                          @"af_channel_name" : ZFToString(self.channel_id), //菜单id，如Homepage / NEW TO SALE
                                          @"af_ad_id" : ZFToString(itemModel.ad_id), //banenr id，数据来源于后台配置返回的id
                                          @"af_component_id" : ZFToString(itemModel.component_id),//组件id，数据来源于后台返回的组件id
                                          @"af_col_id" : ZFToString(itemModel.col_id), //坑位id，数据来源于后台返回的坑位id
                                          @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                          @"af_page_name" : @"homepage",    // 当前页面名称
                                          @"af_first_entrance" : ZFToString(self.channel_id)  // 一级入口名
                                          };
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_banner_click" withValues:appsflyerParams];
        
        //GrowingIO转化变量点击
        [ZFGrowingIOAnalytics ZFGrowingIObannerClickWithCMSItemModel:itemModel page:self.channel_name channelID:self.channel_id floorVar:nil sourceParams:@{
            GIOFistEvar : ZFToString(self.channel_name),
            GIOSndIdEvar : ZFToString(itemModel.ad_id),
            GIOSndNameEvar : ZFToString(itemModel.name)
        }];

    }
}

- (void)after_requestCMSAdvertData
{
    [self startHeadReferesh];
    
    NSDictionary *afParams = @{ @"af_content_type" : @"view homepage",  //固定值 banner impression
                                @"af_channel_name" : ZFToString(self.channel_name),
                                @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                @"af_channel_id" : ZFToString(self.channel_id)
                                };
    
    [ZFAnalytics appsFlyerTrackEvent:@"af_view_homepage" withValues:afParams];
}

//- (void)after_sliderSkuClick:(ZFCMSItemModel *)itemModel sectionModel:(ZFCMSSectionModel *)sectionModel {
//    ZFGoodsModel *model = itemModel.goodsModel;
//    if (model) {
//        // appflyer统计
//        NSDictionary *appsflyerParams = @{@"af_content_id" : ZFToString(model.goods_sn),
//                                          @"af_spu_id" : ZFToString(model.goods_spu),
//                                          @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
//                                          @"af_page_name" : @"homepage",    // 当前页面名称
//                                          @"af_first_entrance" : ZFToString(self.channel_id)  // 一级入口名
//                                          };
//        [ZFAppsflyerAnalytics zfTrackEvent:@"af_sku_click" withValues:appsflyerParams];
//    }
//}

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
//    NSDictionary *params = @{
//                             NSStringFromSelector(@selector(collectionView:didSelectItemAtIndexPath:)) :
//                                 NSStringFromSelector(@selector(after_collectionView:didSelectItemAtIndexPath:)),
//                             @"collectionView:willDisplayCell:forItemAtIndexPath:" :
//                             @"after_collectionView:willDisplayCell:forItemAtIndexPath:",
//                             @"requestCMSAdvertData" :
//                             @"after_requestCMSAdvertData",
//                             @"sliderSkuClick:sectionModel:" : @"after_sliderSkuClick:sectionModel:",
//                             @"addListViewRefreshKit" :
//                             @"after_addListViewRefreshKit",
//                             };
    
    NSDictionary *params = @{
                             @"zf_cmsManagerView:collectionView:willDisplayCell:forItemAtIndexPath:" :
                                 @"after_cmsManagerView:collectionView:willDisplayCell:forItemAtIndexPath:",
                             @"zf_cmsManagerView:collectionView:didSelectItemCell:forItemAtIndexPath:" :
                                 @"after_cmsManagerView:collectionView:didSelectItemCell:forItemAtIndexPath:",
                             @"zf_cmsManagerView:collectionView:eventCell:deeplinkItem:source:" :
                                 @"after_cmsManagerView:collectionView:eventCell:deeplinkItem:source:",
                             @"zf_cmsManagerView:collectionView:recommendCell:dislikeRecommendGoods:" :
                                 @"after_cmsManagerView:collectionView:recommendCell:dislikeRecommendGoods:",
                             @"zf_cmsManagerView:collectionView:couponCell:model:" :
                             @"after_cmsManagerView:collectionView:couponCell:model:",
                             @"requestCMSAdvertData" :
                                 @"after_requestCMSAdvertData",
                             @"addListViewRefreshKit" :
                                 @"after_addListViewRefreshKit",
                             };
    
    return params;
}

-(void)module:(NSString *)moduleName pageName:(NSString *)pageName duration:(NSUInteger)duration args:(NSDictionary *)args
{
    YWLog(@"\nmoduleName-%@\nduration-%ld\nargs-%@", moduleName, duration, args);
    
    NSDictionary *af_params = args[TrackerCustomePublicParams][TrackerCustomePublicParamsAfParams];
    BOOL isHome = args[TrackerCustomePublicParams][TrackerCustomePublicParamsisHome];
    NSString *channelid = args[TrackerCustomePublicParams][TrackerCustomePublicParamsChannelId];
    NSString *channelTitle = args[TrackerCustomePublicParams][TrackerCustomePublicParamsChannelTitle];
    
    self.isHomePage = isHome;
    self.af_params = af_params;
    self.channel_id = channelid;
    self.channleTitle = channelTitle;
    
    id model = args[TrackerCustomeArgsModel];
    if ([model isKindOfClass:[ZFCMSItemModel class]]) {
        ZFCMSItemModel *itemModel = (ZFCMSItemModel *)model;
        NSInteger row = [args[TrackerCustomeArgsRow] integerValue];
        //Appfly 统计
        NSString *appflykey = @"af_banner_impression";
        NSDictionary *appflyParams = @{
                                            @"af_content_type" : @"banner impression",  //固定值 banner impression
                                            @"af_banner_name" : ZFToString(itemModel.name), //banenr名，如叫拼团
                                            @"af_channel_name" : ZFToString(self.channel_id), //菜单id，如Homepage / NEW TO SALE
                                            @"af_ad_id" : ZFToString(itemModel.ad_id), //banenr id，数据来源于后台配置返回的id
                                            @"af_component_id" : ZFToString(itemModel.component_id), //组件id，数据来源于后台返回的组件id
                                            @"af_col_id" : ZFToString(itemModel.col_id), //坑位id，数据来源于后台返回的坑位id
                                            @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                            @"af_bannerExposureTimes" : ZFToString(args[@"exposureTimes"]), //曝光总次数
                                            @"af_bannerExposureTime" : @(duration) //曝光总时长
                                        };
        [ZFAppsflyerAnalytics zfTrackEvent:appflykey withValues:appflyParams];
        
        //GrowingIO 活动展示统计
        
        NSString *floorIndex = [NSString stringWithFormat:@"%ld", row];
        NSString *screenName = [NSString stringWithFormat:@"impression_channel_banner_branch%@_%@_%@", itemModel.col_id, floorIndex, itemModel.name];
        [ZFGrowingIOAnalytics ZFGrowingIOBannerImpWithCMSItemModel:itemModel page:self.channel_name channelID:self.channel_id floorVar:screenName];
//        [ZFGrowingIOAnalytics ZFGrowingIOActivityImp:itemModel.name
//                                               floor:screenName
//                                            position:floorIndex
//                                                page:ZFToString(self.channleTitle)];

    }else if ([model isKindOfClass:[ZFGoodsModel class]]) {
        //商品类型
        NSInteger row = [args[TrackerCustomeArgsRow] integerValue];
        // growingIO 统计
        ZFGoodsModel *goodsModel = (ZFGoodsModel *)model;
        goodsModel.recommentType = GIORecommHistory;
        [ZFGrowingIOAnalytics ZFGrowingIOProductShow:model page:@"首页推荐位"];

        //AF 统计
        AFparams *afParams = self.afparams;
        goodsModel.af_rank = row + 1;
        if (self.isHomePage) {
            //表示首页
            [ZFAppsflyerAnalytics trackGoodsList:@[goodsModel]
                                    inSourceType:ZFAppsflyerInSourceTypeHome AFparams:afParams];
        } else {
            [ZFAppsflyerAnalytics trackGoodsList:@[goodsModel]
                                    inSourceType:ZFAppsflyerInSourceTypeHomeChannel sourceID:self.channel_id
                                        aFparams:afParams];
        }
    }
}

@end
