//
//  ZFCMSSKUBannerAnalyticsAOP.m
//  ZZZZZ
//
//  Created by YW on 2018/10/9.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFCMSSKUBannerAnalyticsAOP.h"
#import "ZFCMSNormalBannerCell.h"
#import "ZFCMSSectionModel.h"
#import "ZFLocalizationString.h"
#import "ZFAnalytics.h"
#import "ZFGrowingIOAnalytics.h"
#import "YWCFunctionTool.h"
#import "Constants.h"

@interface ZFCMSSKUBannerAnalyticsAOP ()

//@property (nonatomic, strong) NSMutableArray *analyticsSet;
@property (nonatomic, copy) NSString *channleTitle;
@property (nonatomic, copy) NSString *localLanguage;
@property (nonatomic, copy) NSString *af_page_name;



@end

@implementation ZFCMSSKUBannerAnalyticsAOP

-(void)dealloc
{
    YWLog(@"ZFHomeSKUBannerAnalyticsManager dealloc");
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.idx = NSStringFromClass(ZFCMSSKUBannerAnalyticsAOP.class);
        self.channleTitle = [UIViewController currentTopViewController].title;
        self.localLanguage = [[ZFLocalizationString shareLocalizable] currentLanguageMR];
    }
    return self;
}

- (void)baseConfigureSource:(ZFAnalyticsAOPSource)source analyticsId:(NSString *)idx {
    
    self.source = source;
    self.idx = idx;
    
    self.impressionList = @"";
    self.af_page_name = @"";
    if (self.source == ZFAnalyticsAOPSourceHome) {
        self.impressionList = [NSString stringWithFormat:@"%@_%@",self.sourceKey,@"Channel_List"];
        self.af_page_name = @"homepage";

    } else if(self.source == ZFAnalyticsAOPSourceCommunityHome) {
        self.impressionList = [NSString stringWithFormat:@"%@_%@",self.sourceKey,@"Channel_List"];
        self.af_page_name = @"community_homepage";
    }
}
- (void)after_collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZFAnalyticsExposureSet *skuBannerSet = [ZFAnalyticsExposureSet sharedInstance];
    //新版本CMS统计
    if ([cell isKindOfClass:[ZFCMSNormalBannerCell class]]) {
        ZFCMSNormalBannerCell *bannerCell = (ZFCMSNormalBannerCell *)cell;
        ZFCMSItemModel *itemModel = bannerCell.itemModel;
        
        if ([skuBannerSet containsObject:ZFToString(itemModel.ad_id) analyticsId:self.idx] || ZFIsEmptyString(itemModel.ad_id)) {
            return;
        }
        [skuBannerSet addObject:ZFToString(itemModel.ad_id) analyticsId:self.idx];
        
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
        
//        NSString *floorIndex = [NSString stringWithFormat:@"%ld", indexPath.row];
//        NSString *screenName = [NSString stringWithFormat:@"impression_channel_banner_branch%@_%@_%@", itemModel.col_id, floorIndex, itemModel.name];
        //GrowingIO 活动展示统计
        [ZFGrowingIOAnalytics ZFGrowingIOBannerImpWithCMSItemModel:itemModel page:self.channel_name channelID:self.channel_id floorVar:nil];
//        [ZFGrowingIOAnalytics ZFGrowingIOActivityImpByCMS:itemModel channelId:self.channel_id];
        
//        [ZFGrowingIOAnalytics ZFGrowingIOActivityImp:itemModel.name
//                                               floor:screenName
//                                            position:floorIndex
//                                                page:@"首页"];
    }
}

-(void)after_collectionView:(UICollectionView *)collectionView
   didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    //新版本CMS统计
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
                                          @"af_page_name" : ZFToString(self.af_page_name),    // 当前页面名称
                                          @"af_first_entrance" : ZFToString(self.channel_id)  // 一级入口名
                                          };
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_banner_click" withValues:appsflyerParams];
        [ZFGrowingIOAnalytics ZFGrowingIObannerClickWithCMSItemModel:itemModel page:self.channel_name channelID:self.channel_id floorVar:nil sourceParams:@{
            GIOFistEvar : ZFToString(self.channel_name),
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
}

- (nonnull NSDictionary *)injectMenthodParams {
    NSDictionary *params = @{
                             NSStringFromSelector(@selector(collectionView:didSelectItemAtIndexPath:)) :
                             NSStringFromSelector(@selector(after_collectionView:didSelectItemAtIndexPath:)),
                             @"collectionView:willDisplayCell:forItemAtIndexPath:" :
                             @"after_collectionView:willDisplayCell:forItemAtIndexPath:",
                             };
    return params;
}

@end
