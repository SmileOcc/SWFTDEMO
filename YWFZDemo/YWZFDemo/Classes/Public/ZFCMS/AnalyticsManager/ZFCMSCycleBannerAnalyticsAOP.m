//
//  ZFCMSCycleBannerAnalyticsAOP.m
//  ZZZZZ
//
//  Created by YW on 2018/10/17.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFCMSCycleBannerAnalyticsAOP.h"
#import "SDCycleScrollView.h"
#import "ZFHomeAnalysis.h"
#import "ZFCMSSectionModel.h"
#import "NSStringUtils.h"
#import "ZFLocalizationString.h"
#import "ZFFireBaseAnalytics.h"
#import "ZFGrowingIOAnalytics.h"
#import "YWCFunctionTool.h"
#import "Constants.h"

@interface ZFCMSCycleBannerAnalyticsAOP ()

@property (nonatomic, copy) NSString *localLanguage;
@property (nonatomic, copy) NSString *af_component_id;
@property (nonatomic, strong) NSArray *dataList;
@property (nonatomic, copy) NSString *channel_id;
@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, copy) NSString *impression_name_banner;
@property (nonatomic, copy) NSString *content_type;
@property (nonatomic, copy) NSString *actionName;
@property (nonatomic, copy) NSString *eventParamContentType;
@property (nonatomic, copy) NSString *af_page_name;


@end

@implementation ZFCMSCycleBannerAnalyticsAOP

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.dataList = [[NSArray alloc] init];
        self.localLanguage = [[ZFLocalizationString shareLocalizable] currentLanguageMR];
    }
    return self;
}

- (void)baseConfigureSource:(ZFAnalyticsAOPSource)source analyticsId:(NSString *)idx {
    
    self.source = source;
    self.idx = idx ? idx : NSStringFromClass(ZFCMSCycleBannerAnalyticsAOP.class);
    if (self.source == ZFAnalyticsAOPSourceHome) {
        
        self.impression_name_banner = [NSString stringWithFormat:@"impression_%@_banner",self.sourceKey];
        self.content_type = [NSString stringWithFormat:@"%@ - Banner",self.sourceKey];
        self.actionName = [NSString stringWithFormat:@"%@_Banner",self.sourceKey];
        self.eventParamContentType = [NSString stringWithFormat:@"%@Banner",self.sourceKey];
        self.af_page_name = @"homepage";
        
    } else if(self.source == ZFAnalyticsAOPSourceCommunityHome) {
        self.af_page_name = @"community_homepage";
    }
}

- (void)after_cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    //点击广告统计
    id idModel = self.dataList[index];
    
    if ([idModel isKindOfClass:[ZFBannerModel class]]) {
        ZFBannerModel *model = idModel;
        
        NSString *itemId = [NSString stringWithFormat:@"%@%ld.%ld_%@",ZFToString(self.impression_name_banner), self.indexPath.section + 1, self.indexPath.row + 1, model.name];
        
        // 谷歌统计
        NSString *GABannerId = model.banner_id;
        NSString *GABannerName = [NSString stringWithFormat:@"impression_channel_banner1_%@", model.name];
        
        if (self.source == ZFAnalyticsAOPSourceHome) {// v4.7.0 只加首页的，其他的没提
            
            [ZFAnalytics clickAdvertisementWithId:ZFToString(GABannerId)
                                             name:GABannerName
                                         position:nil];
            
            // 查看分类下的商品列表、查看某个营销活动的商品列表
            NSMutableDictionary *valuesDic = [NSMutableDictionary dictionary];
            valuesDic[AFEventParamContentType] = [NSString stringWithFormat:@"%@/%@",ZFToString(self.eventParamContentType),model.name];
            
            [ZFAnalytics appsFlyerTrackEvent:@"af_view_list"
                                  withValues:valuesDic];
            
            [ZFAnalytics clickButtonWithCategory:ZFToString(self.sourceKey)
                                      actionName:ZFToString(self.actionName)
                                           label:itemId];
        }
        
        [ZFFireBaseAnalytics selectContentWithItemId:itemId
                                            itemName:model.name
                                         ContentType:ZFToString(self.content_type)
                                        itemCategory:@"scroll_banner"];
        
        
        NSString *position = [NSString stringWithFormat:@"%ld", index];
        //GrowingIO转化变量点击
        [ZFGrowingIOAnalytics ZFGrowingIObannerClickWithBannerModel:model page:self.channel_name channelID:self.channel_id floorVar:nil sourceParams:@{
            GIOFistEvar : ZFToString(self.channel_name),
            GIOSndIdEvar : ZFToString(model.banner_id),
            GIOSndNameEvar : ZFToString(model.name)
        }];
//        [ZFGrowingIOAnalytics ZFGrowingIOActivityClick:model.name
//                                                 floor:GABannerName
//                                              position:position
//                                                  page:ZFToString(self.page)];
        
        // appflyer统计
        NSString *user_id = [NSStringUtils isEmptyString:USERID] ? @"0" : USERID;
        NSString *bannerName = model.name ? : @"unKnown";
        NSString *bannerId = model.banner_id ? : @"unKnown";
        NSString *userType = [AccountManager sharedManager].af_user_type;
        NSDictionary *appsflyerParams = @{@"af_content_type" : @"banner impression",
                                          @"af_banner_name" : ZFToString(bannerName),
                                          @"af_screen_name" : self.sourceKey,
                                          @"af_banner_id" : ZFToString(bannerId),
                                          @"af_userid" : ZFToString(user_id),
                                          @"af_user_type" : ZFToString(userType),
                                          @"af_page_name" : ZFToString(self.af_page_name),    // 当前页面名称
                                          @"af_first_entrance" : ZFToString(self.channel_id)  // 一级入口名
                                          };
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_banner_click" withValues:appsflyerParams];
    }
    
    if ([idModel isKindOfClass:[ZFCMSItemModel class]]) {
        ZFCMSItemModel *itemModel = idModel;
        // appflyer统计
        NSDictionary *appsflyerParams = @{@"af_content_type" : @"banner impression",  //固定值 banner impression
                                          @"af_banner_name" : ZFToString(itemModel.name), //banenr名，如叫拼团
                                          @"af_channel_name" : ZFToString(self.channel_id), //菜单id，如Homepage / NEW TO SALE等等菜单对应的id （必要参数，不允许为"")
                                          @"af_ad_id" : ZFToString(itemModel.ad_id), //banenr id，数据来源于后台配置返回的id
                                          @"af_component_id" : ZFToString(self.af_component_id),//组件id，数据来源于后台返回的组件id
                                          @"af_col_id" : ZFToString(itemModel.col_id), //坑位id，数据来源于后台返回的坑位id
                                          @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                          @"af_page_name" : ZFToString(self.af_page_name),    // 当前页面名称
                                          @"af_first_entrance" : ZFToString(self.channel_id)  // 一级入口名
                                          };
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_banner_click" withValues:appsflyerParams];
        
        //GrowingIO转化变量点击
        NSString *fistEvar = ZFToString(self.channel_name);
        if (self.source == ZFAnalyticsAOPSourceCommunityHome) {
            fistEvar = GIOSourceCommunity;
        }
        [ZFGrowingIOAnalytics ZFGrowingIObannerClickWithCMSItemModel:itemModel page:self.channel_name channelID:self.channel_id floorVar:nil sourceParams:@{
            GIOFistEvar : ZFToString(fistEvar),
            GIOSndIdEvar : ZFToString(itemModel.ad_id),
            GIOSndNameEvar : ZFToString(itemModel.name)
        }];
//        [ZFGrowingIOAnalytics ZFGrowingIOActivityClickByCMS:itemModel channelId:self.channel_id];
    }
}

- (void)after_cycleScrollView:(SDCycleScrollView *)cycleScrollView didScrollToIndex:(NSInteger)index
{
    if ([self.dataList count] <= index) {
        return;
    }
    ///统计滚动广告
    id idModel = self.dataList[index];
    
    ZFAnalyticsExposureSet *analyticsSets = [ZFAnalyticsExposureSet sharedInstance];
    
    if ([idModel isKindOfClass:[ZFBannerModel class]]) {
        ZFBannerModel *model = idModel;
        if ([analyticsSets containsObject:ZFToString(model.name) analyticsId:self.idx]) {
            return;
        }
        [analyticsSets addObject:ZFToString(model.name) analyticsId:self.idx];
        //GrowingIO 活动展示统计
        NSString *screenName = [NSString stringWithFormat:@"impression_channel_banner1_%@", model.name];
//        NSString *position = [NSString stringWithFormat:@"%ld", index];
//        [ZFGrowingIOAnalytics ZFGrowingIOActivityImp:model.name
//                                               floor:screenName
//                                            position:position
//                                                page:ZFToString(self.page)];
        [ZFGrowingIOAnalytics ZFGrowingIOBannerImpWithBannerModel:model page:self.channel_name channelID:self.channel_id floorVar:screenName];
        
        if (self.source == ZFAnalyticsAOPSourceHome) {// v4.7.0 只加首页的，其他的没提
            //GA 统计
            [ZFAnalytics showAdvertisementWithBanners:@[@{@"name":screenName}]
                                             position:nil
                                           screenName:ZFToString(self.sourceKey)];
        }
    }
    
    if ([idModel isKindOfClass:[ZFCMSItemModel class]]) {
        ZFCMSItemModel *itemModel = idModel;
        if ([analyticsSets containsObject:ZFToString(itemModel.ad_id) analyticsId:self.idx]) {
            return;
        }
        [analyticsSets addObject:ZFToString(itemModel.ad_id) analyticsId:self.idx];
        //GrowingIO 活动展示统计
//        [ZFGrowingIOAnalytics ZFGrowingIOActivityImpByCMS:itemModel channelId:self.channel_id];
        [ZFGrowingIOAnalytics ZFGrowingIOBannerImpWithCMSItemModel:itemModel page:self.channel_name channelID:self.channel_id floorVar:nil];
        
        // 推送延时统计
        if ([AccountManager sharedManager].isFilterAnalytics && self.source == ZFAnalyticsAOPSourceHome) {
            [[AccountManager sharedManager].filterAnalyticsArray addObject:itemModel];
            return;
        }
        
        //Appfly 统计
        NSDictionary *appsflyerParams =  @{
                                           @"af_content_type" : @"banner impression",  //固定值 banner impression
                                           @"af_banner_name" : ZFToString(itemModel.name), //banenr名，如叫拼团
                                           @"af_channel_name" : ZFToString(self.channel_id), //菜单id，如Homepage / NEW TO SALE等等菜单对应的id （必要参数，不允许为"")
                                           @"af_ad_id" : ZFToString(itemModel.ad_id), //banenr id，数据来源于后台配置返回的id
                                           @"af_component_id" : ZFToString(self.af_component_id),//组件id，数据来源于后台返回的组件id
                                           @"af_col_id" : ZFToString(itemModel.col_id), //坑位id，数据来源于后台返回的坑位id
                                           @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type) //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                           };
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_banner_impression" withValues:appsflyerParams];
    }
}

- (void)after_updateCycleBanner:(ZFCMSSectionModel *)sectionModel indexPath:(NSIndexPath *)indexPath
{
    self.af_component_id = sectionModel.component_id;
    
    if ([_dataList isKindOfClass:[NSArray class]] && [_dataList count] == 1) {
        //只有一个数据的时候，强制曝光一次，有时候运营只会配一条数据，导致cycleScrollView回调不会执行，曝光会不正常，所以，当发现只有一个条数据的时候，强制曝光一次
        [self after_cycleScrollView:nil didScrollToIndex:0];
    }
}

- (void)after_setChannel_id:(NSString *)channelId
{
    self.channel_id = channelId;
}

- (void)after_setAdBannerArray:(NSArray *)dataList
{
    self.dataList = dataList;
}

- (void)after_setIndexPath:(NSIndexPath *)indexPath
{
    self.indexPath = indexPath;
}

- (nonnull NSDictionary *)injectMenthodParams {
    NSDictionary *params = @{
                             NSStringFromSelector(@selector(cycleScrollView:didSelectItemAtIndex:)) :
                             NSStringFromSelector(@selector(after_cycleScrollView:didSelectItemAtIndex:)),
                             NSStringFromSelector(@selector(cycleScrollView:didScrollToIndex:)) :
                             NSStringFromSelector(@selector(after_cycleScrollView:didScrollToIndex:)),
                             @"setChannel_id:" :
                                 @"after_setChannel_id:",
                             @"setAdBannerArray:" :
                                 @"after_setAdBannerArray:",
                             @"updateCycleBanner:indexPath:" :
                                 @"after_updateCycleBanner:indexPath:",
                             //这个方法是在 ZFHomeCycleBannerCell 里的方法，因为这个AOP复用了新旧两个循环视图
                             @"setIndexPath:" :
                                 @"after_setIndexPath:"
                             };
    return params;
}

-(NSArray<NSString *> *)whiteListAssert
{
    ///这个AOP多出复用，过滤的是ZFCMSCycleBannerCell里面的方法
    return @[@"setChannel_id:",
             @"setAdBannerArray:",
             @"updateCycleBanner:indexPath:",
             @"setIndexPath:"];
}

@end
