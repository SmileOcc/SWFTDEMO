//
//  ZFCMSRecentlyAnalyticsAOP.m
//  ZZZZZ
//
//  Created by YW on 2018/10/9.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFCMSRecentlyAnalyticsAOP.h"
#import "ZFCMSSkuBannerCell.h"
#import "ZFCMSSecKillSkuCell.h"
#import "ZFCMSSectionModel.h"
#import "ZFAnalytics.h"
#import "ZFGrowingIOAnalytics.h"
#import "YWCFunctionTool.h"
#import "Constants.h"

@interface ZFCMSRecentlyAnalyticsAOP ()

//新版本首页需要的统计数据
@property (nonatomic, assign) ZFHomeCMSModuleSubType subType;
@property (nonatomic, copy) NSString                 *recommendName;
@property (nonatomic, copy) NSString                 *af_page_name;

@end

@implementation ZFCMSRecentlyAnalyticsAOP

-(void)dealloc
{
    YWLog(@"ZFHomeRecentlyAnalyticsManager dealloc");
}

- (void)baseConfigureSource:(ZFAnalyticsAOPSource)source analyticsId:(NSString *)idx{
    
    self.source = source;
    self.idx = idx ? idx : NSStringFromClass(ZFCMSRecentlyAnalyticsAOP.class);

    if (self.source == ZFAnalyticsAOPSourceHome) {
        self.impressionList = [NSString stringWithFormat:@"%@_%@",self.sourceKey,@"Recently_List"];
        self.sourceType = ZFAppsflyerInSourceTypeRecommendHistory;
        self.af_page_name = @"homepage";
        self.recommendName = GIOSourceHome;
    } else if(self.source == ZFAnalyticsAOPSourceCommunityHome) {
        self.sourceType = ZFAppsflyerInSourceTypeZMeCMSHome;
        self.af_page_name = @"community_homepage";
        self.recommendName = GIOSourceCommunity;
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.idx = NSStringFromClass(ZFCMSRecentlyAnalyticsAOP.class);
    }
    return self;
}

- (void)after_collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZFAnalyticsExposureSet *analyticsSets = [ZFAnalyticsExposureSet sharedInstance];
    ZFGoodsModel *model = nil;
    NSString *name = [NSString stringWithFormat:@"%@%@",self.recommendName,@"历史浏览推荐位"];
    if ([cell isKindOfClass:[ZFCMSSkuBannerCell class]]) {
        ZFCMSSkuBannerCell *skucell = (ZFCMSSkuBannerCell *)cell;
        if (skucell.itemModel.goodsModel) {
            model = skucell.itemModel.goodsModel;
            if (self.subType == ZFCMS_SkuBanner_SubType ||
                self.subType == ZFCMS_SkuSelection_SubType) {
                name = [NSString stringWithFormat:@"%@%@",self.recommendName,@"SKU Banner"];;
            }
        }else{
            return;
        }
    }
    
    if ([cell isKindOfClass:[ZFCMSSecKillSkuCell class]]) {
        ZFCMSSecKillSkuCell *skucell = (ZFCMSSecKillSkuCell *)cell;
        ZFCMSItemModel *itemModel = skucell.itemModel;
        
        if ([analyticsSets containsObject:ZFToString(itemModel.ad_id) analyticsId:self.idx]) {
            return;
        }
        [analyticsSets addObject:ZFToString(itemModel.ad_id) analyticsId:self.idx];
        
        // 推送延时统计
        if ([AccountManager sharedManager].isFilterAnalytics && self.source == ZFAnalyticsAOPSourceHome) {
            [[AccountManager sharedManager].filterAnalyticsArray addObject:itemModel];
            return;
        }
        
        //广告类型
        //Appfly 统计
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
        [ZFGrowingIOAnalytics ZFGrowingIOBannerImpWithCMSItemModel:itemModel page:self.channel_name channelID:self.channel_id floorVar:nil];
        
    }
    
    
    if (!model) {
        return;
    }
    
    ZFAnalyticsExposureSet *recentSet = [ZFAnalyticsExposureSet sharedInstance];
    if ([recentSet containsObject:ZFToString(model.goods_id) analyticsId:self.idx] || ZFIsEmptyString(model.goods_id)) {
        return;
    }
    [recentSet addObject:ZFToString(model.goods_id) analyticsId:self.idx];
    [ZFGrowingIOAnalytics ZFGrowingIOProductShow:model page:name];
    
    if (self.source == ZFAnalyticsAOPSourceHome) {// v4.7.0 只加首页的，其他的没提
        //GA 统计
        [ZFAnalytics showAdvertisementWithBanners:@[@{@"name" : ZFGAHomeRecentlyInternalPromotion}] position:nil screenName:nil];
        //搜集商品点击
        [ZFAnalytics showProductsWithProducts:@[model]
                                     position:(int)indexPath.row
                               impressionList:ZFToString(self.impressionList)
                                   screenName:ZFToString(self.sourceKey)
                                        event:@"load"];
    }
    
    //AF统计
    model.af_rank = indexPath.row + 1;
    [ZFAppsflyerAnalytics trackGoodsList:@[model] inSourceType:self.sourceType sourceID:nil];
}

-(void)after_collectionView:(UICollectionView *)collectionView
   didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    ZFGoodsModel *model = nil;
    NSString *name = [NSString stringWithFormat:@"%@%@",self.recommendName,@"历史浏览推荐位"];
    if ([cell isKindOfClass:[ZFCMSSkuBannerCell class]]) {
        ZFCMSSkuBannerCell *skucell = (ZFCMSSkuBannerCell *)cell;
        if (skucell.itemModel.goodsModel) {
            model = skucell.itemModel.goodsModel;
            if (self.subType == ZFCMS_SkuBanner_SubType ||
                self.subType == ZFCMS_SkuSelection_SubType) {
                name = [NSString stringWithFormat:@"%@%@",self.recommendName,@"SKU Banner"];;
            }
        }else{
            return;
        }
    } else if ([cell isKindOfClass:[ZFCMSSecKillSkuCell class]]) {
        
        ZFCMSSecKillSkuCell *skucell = (ZFCMSSecKillSkuCell *)cell;
        ZFCMSItemModel *itemModel = skucell.itemModel;
        
        // appflyer统计
        NSDictionary *appsflyerParams = @{@"af_content_type" : @"banner impression",  //固定值 banner impression
                                          @"af_banner_name" : ZFToString(itemModel.name), //banenr名，如叫拼团
                                          @"af_channel_name" : ZFToString(self.channel_id), //菜单id，如Homepage / NEW TO SALE
                                          @"af_ad_id" : ZFToString(itemModel.ad_id), //banenr id，数据来源于后台配置返回的id
                                          @"af_component_id" : ZFToString(itemModel.component_id),//组件id，数据来源于后台返回的组件id
                                          @"af_col_id" : ZFToString(itemModel.col_id), //坑位id，数据来源于后台返回的坑位id
                                          @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                          @"af_page_name" : ZFToString(self.af_page_name),    // 当前页面名称
                                          @"af_first_entrance" : ZFToString(self.channel_id)  // 一级入口名
                                          };
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_banner_click" withValues:appsflyerParams];
        [ZFGrowingIOAnalytics ZFGrowingIObannerClickWithCMSItemModel:itemModel page:self.channel_name channelID:self.channel_id floorVar:nil sourceParams:@{
            GIOFistEvar : ZFToString(self.channel_name),
            GIOSndIdEvar : ZFToString(itemModel.ad_id),
            GIOSndNameEvar : ZFToString(itemModel.name)
        }];
    }
    
    if (model) {
        [ZFGrowingIOAnalytics ZFGrowingIOProductClick:model page:name sourceParams:@{
                       GIOGoodsTypeEvar : GIOGoodsTypeRecommend,
                       GIOGoodsNameEvar : @"recommend_homepage_recentviewed"
                   }];
    }
    
    if (self.source == ZFAnalyticsAOPSourceHome) {// v4.7.0 只加首页的，其他的没提
        //GA 统计
        [ZFAnalytics clickAdvertisementWithId:ZFToString(model.goods_id) name:ZFGAHomeRecentlyInternalPromotion position:nil];
        
        //搜集商品列表点击
        [ZFAnalytics clickProductWithProduct:model
                                    position:(int)indexPath.row
                                  actionList:ZFToString(self.impressionList)];
    }
}

- (void)before_setSectionModel:(ZFCMSSectionModel *)sectionModel
{
    self.subType = sectionModel.subType;
}

- (nonnull NSDictionary *)injectMenthodParams {
    NSDictionary *params = @{
                             @"collectionView:willDisplayCell:forItemAtIndexPath:" :
                                 @"after_collectionView:willDisplayCell:forItemAtIndexPath:",
                             NSStringFromSelector(@selector(collectionView:didSelectItemAtIndexPath:)) :
                             NSStringFromSelector(@selector(after_collectionView:didSelectItemAtIndexPath:)),
                             };
    return params;
}

-(nonnull NSDictionary *)beforeInjectMenthodParams
{
    NSDictionary *params = @{
                             @"setSectionModel:" :
                                 @"before_setSectionModel:",
                             };
    return params;
}

-(NSArray<NSString *> *)whiteListAssert
{
    return @[@"setSectionModel:"];
}

@end

