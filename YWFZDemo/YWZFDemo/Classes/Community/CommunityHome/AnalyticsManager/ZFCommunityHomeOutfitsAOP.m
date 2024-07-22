//
//  ZFCommunityHomeOutfitsAOP.m
//  ZZZZZ
//
//  Created by YW on 2019/6/15.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityHomeOutfitsAOP.h"
#import "ZFGrowingIOAnalytics.h"
#import "YWCFunctionTool.h"
#import "AccountManager.h"

#import "ZFCommunityOutfitsListCell.h"
#import "ZFCommunityOutfitsModel.h"

@interface ZFCommunityHomeOutfitsAOP ()
@property (nonatomic, copy) NSString *channel_id;
@property (nonatomic, copy) NSString *channel_name;
@end

@implementation ZFCommunityHomeOutfitsAOP

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
                             @"requestOutfitsListData:" :
                                 @"after_requestOutfitsListData:",
                             };
    
    return params;
}

-(void)startHeadReferesh {
    //下拉刷新时，需要重新计算曝光
    ZFCommunityHomeOutfitsAnalyticsSet *showSets = [ZFCommunityHomeOutfitsAnalyticsSet sharedInstance];
    [showSets removeAllObjects];
}

- (void)after_requestOutfitsListData:(BOOL)firstPage {
    if (firstPage) {
        [self startHeadReferesh];
    }
}

- (void)after_collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ZFCommunityHomeOutfitsAnalyticsSet *homeOutfitSets = [ZFCommunityHomeOutfitsAnalyticsSet sharedInstance];
    if (![cell isKindOfClass:[ZFCommunityOutfitsListCell class]]) {
        return;
    }
    //帖子
    ZFCommunityOutfitsListCell *baseCell = (ZFCommunityOutfitsListCell *)cell;
    ZFCommunityOutfitsModel *model = baseCell.model;
    
    NSString *reviewId = model.reviewId;
    if ([homeOutfitSets containsObject:ZFToString(reviewId)] || ZFIsEmptyString(reviewId)) {
        return;
    }
    [homeOutfitSets addObject:ZFToString(reviewId)];
    
    // appflyer统计 社区帖子曝光
    NSDictionary *appsflyerParams = @{@"af_content_id" : ZFToString(reviewId),
                                      @"af_country_code" : ZFToString([AccountManager sharedManager].accountCountryModel.region_code),
                                      @"af_page_name" : @"community_homepage",
                                      @"af_post_channel" : ZFToString(self.channel_name)
                                      };
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_posts_impression" withValues:appsflyerParams];
    
}

- (void)after_collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if (![cell isKindOfClass:[ZFCommunityOutfitsListCell class]]) {
        return;
    }
    //帖子
    ZFCommunityOutfitsListCell *baseCell = (ZFCommunityOutfitsListCell *)cell;
    ZFCommunityOutfitsModel *model = baseCell.model;
    
    //增加AppsFlyer统计
    NSString *reviewType = @"normal";   ///数据类型,1:帖子 2:话题 3:视频
    if ([model.reviewType isEqualToString:@"1"]) {
        reviewType = @"outfits";
    }
    NSDictionary *appsflyerParams = @{@"af_postid" : ZFToString(model.reviewId),
                                      @"af_post_channel" : ZFToString(self.channel_id),
                                      @"af_post_type" : ZFToString(reviewType),
                                      @"af_post_userid" : ZFToString(model.userId),
                                      @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                      @"af_page_name" : @"community_homepage",    // 当前页面名称
                                      @"af_first_entrance" : @"community_homepage"  // 一级入口名
                                      };
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_post_click" withValues:appsflyerParams];
}


@end




@interface ZFCommunityHomeOutfitsAnalyticsSet ()

@property (nonatomic, strong) NSMutableArray *list;

@end

@implementation ZFCommunityHomeOutfitsAnalyticsSet

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static ZFCommunityHomeOutfitsAnalyticsSet *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[ZFCommunityHomeOutfitsAnalyticsSet alloc] init];
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
