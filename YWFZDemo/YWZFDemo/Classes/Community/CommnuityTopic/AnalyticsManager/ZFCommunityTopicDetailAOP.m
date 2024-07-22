//
//  ZFCommunityTopicDetailAOP.m
//  ZZZZZ
//
//  Created by YW on 2019/6/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityTopicDetailAOP.h"
#import "ZFGrowingIOAnalytics.h"
#import "YWCFunctionTool.h"
#import "AccountManager.h"
#import "ZFCommnuityTopicDetailBigCCell.h"
#import "ZFCommunityTopicDetailListCell.h"

@interface ZFCommunityTopicDetailAOP ()

@property (nonatomic, strong) NSMutableArray *analyticsArray;

@property (nonatomic, copy) NSString         *channel_id;
@property (nonatomic, copy) NSString         *channel_name;

@end

@implementation ZFCommunityTopicDetailAOP


- (void)baseConfigureChannelId:(NSString *)channelId channelName:(NSString *)channelName {
    self.channel_id = ZFToString(channelId);
    self.channel_name = ZFToString(channelName);
}

- (NSMutableArray *)analyticsArray {
    if (!_analyticsArray) {
        _analyticsArray = [[NSMutableArray alloc] init];
    }
    return _analyticsArray;
}

-(NSDictionary *)injectMenthodParams
{
    NSDictionary *params = @{
                             @"collectionView:willDisplayCell:forItemAtIndexPath:" :
                                 @"after_collectionView:willDisplayCell:forItemAtIndexPath:",
                             @"collectionView:didSelectItemAtIndexPath:" :
                                 @"after_collectionView:didSelectItemAtIndexPath:",
                             @"requestTopicPageData:" :
                                 @"after_requestTopicPageData:",
                             };
    
    return params;
}

-(void)startHeadReferesh {
    //下拉刷新时，需要重新计算曝光
    [self.analyticsArray removeAllObjects];
}

- (void)after_requestTopicPageData:(BOOL)isFirstPage {
    if (isFirstPage) {
        [self startHeadReferesh];
    }
}

- (void)after_collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell isKindOfClass:[ZFCommnuityTopicDetailBigCCell class]] || [cell isKindOfClass:[ZFCommunityTopicDetailListCell class]]) {
        
        //帖子
        ZFCommunityTopicDetailListModel *model;
        if ([cell isKindOfClass:[ZFCommnuityTopicDetailBigCCell class]]) {
            ZFCommnuityTopicDetailBigCCell *baseCell = (ZFCommnuityTopicDetailBigCCell *)cell;
            model = baseCell.model;
        } else if([cell isKindOfClass:[ZFCommunityTopicDetailListCell class]]) {
            ZFCommunityTopicDetailListCell *baseCell = (ZFCommunityTopicDetailListCell *)cell;
            model = baseCell.model;
        }

        if (!model) {
            return;
        }
        
        NSString *reviewId = model.reviewsId;
        if ([self.analyticsArray containsObject:ZFToString(reviewId)] || ZFIsEmptyString(reviewId)) {
            return;
        }
        [self.analyticsArray addObject:ZFToString(reviewId)];
        
        // appflyer统计 社区帖子曝光
        NSDictionary *appsflyerParams = @{@"af_content_id" : ZFToString(reviewId),
                                          @"af_country_code" : ZFToString([AccountManager sharedManager].accountCountryModel.region_code),
                                          @"af_page_name" : @"community_topic",
                                          @"af_post_channel" : ZFToString(self.channel_name)
                                          };
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_posts_impression" withValues:appsflyerParams];
    }
    
}

- (void)after_collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[ZFCommnuityTopicDetailBigCCell class]] || [cell isKindOfClass:[ZFCommunityTopicDetailListCell class]]) {
        
        //帖子
        ZFCommunityTopicDetailListModel *model;
        if ([cell isKindOfClass:[ZFCommnuityTopicDetailBigCCell class]]) {
            ZFCommnuityTopicDetailBigCCell *baseCell = (ZFCommnuityTopicDetailBigCCell *)cell;
            model = baseCell.model;
        } else if([cell isKindOfClass:[ZFCommunityTopicDetailListCell class]]) {
            ZFCommunityTopicDetailListCell *baseCell = (ZFCommunityTopicDetailListCell *)cell;
            model = baseCell.model;
        }
        
        if (!model) {
            return;
        }
        
        //增加AppsFlyer统计
        NSDictionary *appsflyerParams = @{@"af_postid" : ZFToString(model.reviewsId),
                                          @"af_post_channel" : @"",
                                          @"af_post_type" : @"normal",
                                          @"af_post_userid" : ZFToString(model.userId),
                                          @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                          @"af_page_name" : @"community_topic",    // 当前页面名称
                                          };
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_post_click" withValues:appsflyerParams];
    }
    
}


@end
