//
//  ZFCommunityHomeShowAOP.m
//  ZZZZZ
//
//  Created by YW on 2019/6/15.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityHomeShowAOP.h"
#import "ZFGrowingIOAnalytics.h"
#import "YWCFunctionTool.h"
#import "AccountManager.h"
#import "ZFCommunityBaseCCell.h"


@interface ZFCommunityHomeShowAOP ()

@property (nonatomic, copy) NSString *channel_id;
@property (nonatomic, copy) NSString *channel_name;

@end

@implementation ZFCommunityHomeShowAOP

- (void)baseConfigureChannelId:(NSString *)channelId channelName:(NSString *)channelName {
    _channel_id =  ZFToString(channelId);
    _channel_name = ZFToString(channelName);
}

- (instancetype)initChannelId:(NSString *)channelId {
    self = [super init];
    if (self) {
        self.channel_id = channelId;
    }
    return self;
}

-(NSDictionary *)injectMenthodParams
{
    NSDictionary *params = @{
                             @"collectionView:willDisplayCell:forItemAtIndexPath:" :
                                 @"after_collectionView:willDisplayCell:forItemAtIndexPath:",
                             @"collectionView:didSelectItemAtIndexPath:" :
                                 @"after_collectionView:didSelectItemAtIndexPath:",
                             @"requestShowsListData:" :
                                 @"after_requestShowsListData:",
                             };
    
    return params;
}

-(void)startHeadReferesh {
    //下拉刷新时，需要重新计算曝光
    ZFCommunityHomeShowAnalyticsSet *showSets = [ZFCommunityHomeShowAnalyticsSet sharedInstance];
    [showSets removeAllObjects];
}

- (void)after_requestShowsListData:(BOOL)firstPage {
    if (firstPage) {
        [self startHeadReferesh];
    }
}

- (void)after_collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ZFCommunityHomeShowAnalyticsSet *homeShowSets = [ZFCommunityHomeShowAnalyticsSet sharedInstance];
    if (![cell isKindOfClass:[ZFCommunityBaseCCell class]]) {
        return;
    }
    //帖子
    ZFCommunityBaseCCell *baseCell = (ZFCommunityBaseCCell *)cell;
    ZFCommunityFavesItemModel *model = baseCell.favesItemModel;
    
    NSString *reviewId = model.reviewId;
    if (model.type == 4) {//lookbook 没reviewid
        reviewId = model.banner_id;
    }
    if ([homeShowSets containsObject:ZFToString(reviewId)] || ZFIsEmptyString(reviewId)) {
        return;
    }
    [homeShowSets addObject:ZFToString(reviewId)];

    if (model.type == 4) { // lookbook
//        NSString *screenName = [NSString stringWithFormat:@"%@_%@_%@", @"1", @"1", model.banner_id];
        //GrowingIO 活动展示统计
        ZFBannerModel *bannerModel = [[ZFBannerModel alloc] init];
        bannerModel.banner_id = model.banner_id;
        bannerModel.name = model.title;
        [ZFGrowingIOAnalytics ZFGrowingIOBannerImpWithBannerModel:bannerModel page:GIOSourceCommunity];
//        [ZFGrowingIOAnalytics ZFGrowingIOActivityImp:@"Lookbook"
//                                               floor:screenName
//                                            position:@"1"
//                                                page:@"Community Screen"];
        //增加AppsFlyer统计
        NSDictionary *appsflyerParams = @{@"af_content_type" : @"banner impression",  //固定值 banner impression
                                          @"af_banner_name" : ZFToString(bannerModel.name), //banenr名，如叫拼团
                                          @"af_channel_name" : ZFToString(bannerModel.menuid), //菜单id，如Homepage / NEW TO SALE
                                          @"af_ad_id" : ZFToString(bannerModel.banner_id), //banenr id，数据来源于后台配置返回的id
                                          @"af_component_id" : ZFToString(bannerModel.componentId),//组件id，数据来源于后台返回的组件id
                                          @"af_col_id" : ZFToString(bannerModel.colid), //坑位id，数据来源于后台返回的坑位id
                                          @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type) //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                          };
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_banner_impression" withValues:appsflyerParams];
    } else {
        
        // appflyer统计 社区帖子曝光
        NSDictionary *appsflyerParams = @{@"af_content_id"   : ZFToString(reviewId),
                                          @"af_country_code" : ZFToString([AccountManager sharedManager].accountCountryModel.region_code),
                                          @"af_page_name"    : @"community_homepage",
                                          @"af_post_channel" : ZFToString(self.channel_name)
                                          };
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_posts_impression" withValues:appsflyerParams];
    }
    
}

- (void)after_collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if (![cell isKindOfClass:[ZFCommunityBaseCCell class]]) {
        return;
    }
    //帖子
    ZFCommunityBaseCCell *baseCell = (ZFCommunityBaseCCell *)cell;
    ZFCommunityFavesItemModel *model = baseCell.favesItemModel;
    
    //数据类型,1:帖子 2:话题 3:视频 4:lookbook
    if (model.type == 1 || model.type == 2 || model.type == 3) {
        NSString *postType = @"normal";
        if (model.type == 2) {
            postType = @"topic";
        } else if(model.type == 3) {
            postType = @"video";
        }
        //增加AppsFlyer统计
        NSDictionary *appsflyerParams = @{@"af_postid" : ZFToString(model.reviewId),
                                          @"af_post_channel" : ZFToString(self.channel_id),
                                          @"af_post_type" : postType,
                                          @"af_post_userid" : ZFToString(model.userId),
                                          @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                          @"af_page_name" : @"community_homepage",    // 当前页面名称
                                          @"af_first_entrance" : @"community_homepage"  // 一级入口名
                                          };
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_post_click" withValues:appsflyerParams];
    } else if(model.type == 4) {
        
        NSString *screenName = [NSString stringWithFormat:@"%@_%@_%@", @"1", @"1", model.banner_id];
        //GrowingIO 活动展示统计
//        [ZFGrowingIOAnalytics ZFGrowingIOActivityClick:model.title
//                                                 floor:screenName
//                                              position:@"1"
//                                                  page:@"Community Screen"];

        // 社区活动点击 转化变量
        [ZFGrowingIOAnalytics ZFGrowingIOCommunityActivityClick];
        ZFBannerModel *bannerModel = [ZFBannerModel new];
        bannerModel.banner_id = model.banner_id;
        bannerModel.name = model.title;
        [ZFGrowingIOAnalytics ZFGrowingIObannerClickWithBannerModel:bannerModel page:GIOSourceCommunity channelID:self.channel_id floorVar:screenName sourceParams:@{
            GIOFistEvar : GIOSourceCommunity,
            GIOSndIdEvar : ZFToString(model.banner_id),
            GIOSndNameEvar : ZFToString(model.title)
        }];
        
        // appflyer统计
        NSDictionary *appsflyerParams = @{@"af_content_type" : @"banner impression",  //固定值 banner impression
                                          @"af_banner_name" : ZFToString(model.title), //banenr名，如叫拼团
                                          @"af_channel_name" : ZFToString(self.channel_id), //菜单id，如Homepage / NEW TO SALE
                                          @"af_ad_id" : ZFToString(model.banner_id), //banenr id，数据来源于后台配置返回的id
                                          @"af_component_id" : @"",//组件id，数据来源于后台返回的组件id
                                          @"af_col_id" : @"", //坑位id，数据来源于后台返回的坑位id
                                          @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                          @"af_page_name" : @"community_homepage",    // 当前页面名称
                                          @"af_first_entrance" : @"community_homepage"  // 一级入口名
                                          };
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_banner_click" withValues:appsflyerParams];
    }
}


@end










@interface ZFCommunityHomeShowAnalyticsSet ()

@property (nonatomic, strong) NSMutableArray *list;

@end

@implementation ZFCommunityHomeShowAnalyticsSet

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static ZFCommunityHomeShowAnalyticsSet *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[ZFCommunityHomeShowAnalyticsSet alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.list = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addObject:(NSString *)object
{
    [self.list addObject:object];
}

- (BOOL)containsObject:(NSString *)object
{
    return [self.list containsObject:object];
}

- (void)removeObject:(NSString *)object
{
    [self.list removeObject:object];
}

- (void)removeAllObjects
{
    [self.list removeAllObjects];
}

@end
