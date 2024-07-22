//
//  ZFCommunityPostCategoryAOP.m
//  ZZZZZ
//
//  Created by YW on 2019/6/19.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityPostCategoryAOP.h"
#import "ZFGrowingIOAnalytics.h"
#import "YWCFunctionTool.h"
#import "AccountManager.h"

#import "ZFCommunityCategoryPostListCell.h"

@interface ZFCommunityPostCategoryAOP ()

@property (nonatomic, strong) NSMutableArray *analyticsArray;

@property (nonatomic, copy) NSString *channel_id;
@property (nonatomic, copy) NSString *channel_name;


@end

@implementation ZFCommunityPostCategoryAOP

- (NSMutableArray *)analyticsArray {
    if (!_analyticsArray) {
        _analyticsArray = [[NSMutableArray alloc] init];
    }
    return _analyticsArray;
}

- (void)baseConfigureChannelId:(NSString *)channelId channelName:(NSString *)channelName{
    _channel_id =  ZFToString(channelId);
    _channel_name = ZFToString(channelName);
}

-(NSDictionary *)injectMenthodParams
{
    NSDictionary *params = @{
                             @"collectionView:willDisplayCell:forItemAtIndexPath:" :
                                 @"after_collectionView:willDisplayCell:forItemAtIndexPath:",
                             @"collectionView:didSelectItemAtIndexPath:" :
                                 @"after_collectionView:didSelectItemAtIndexPath:",
                             @"requestChannelPageData:" :
                                 @"after_requestChannelPageData:",
                             };
    
    return params;
}

-(void)startHeadReferesh {
    //下拉刷新时，需要重新计算曝光
    [self.analyticsArray removeAllObjects];
}

- (void)after_requestChannelPageData:(BOOL)isFirstPage {
    if (isFirstPage) {
        [self startHeadReferesh];
    }
}

- (void)after_collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell isKindOfClass:[ZFCommunityCategoryPostListCell class]]) {
        ZFCommunityCategoryPostListCell *baseCell = (ZFCommunityCategoryPostListCell *)cell;
        ZFCommunityCategoryPostItemModel *model = baseCell.model;
        
        if (!model) {
            return;
        }
        
        NSString *postId = model.post_id;
        if ([self.analyticsArray containsObject:ZFToString(postId)] || ZFIsEmptyString(postId)) {
            return;
        }
        [self.analyticsArray addObject:ZFToString(postId)];
        
        // appflyer统计 社区帖子曝光
        NSDictionary *appsflyerParams = @{@"af_content_id" : ZFToString(postId),
                                          @"af_country_code" : ZFToString([AccountManager sharedManager].accountCountryModel.region_code),
                                          @"af_page_name" : @"post_category",
                                          @"af_post_channel" : ZFToString(self.channel_name)
                                          };
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_posts_impression" withValues:appsflyerParams];
    }
    
}

- (void)after_collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[ZFCommunityCategoryPostListCell class]]) {
        ZFCommunityCategoryPostListCell *baseCell = (ZFCommunityCategoryPostListCell *)cell;
        ZFCommunityCategoryPostItemModel *model = baseCell.model;
        
        //增加AppsFlyer统计
        NSDictionary *appsflyerParams = @{@"af_postid" : ZFToString(model.post_id),
                                          @"af_post_channel" : ZFToString(self.channel_id),
                                          @"af_post_type" : @"normal",
                                          @"af_post_userid" : ZFToString(model.user_id),
                                          @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                          @"af_page_name" : @"community_post_category",    // 当前页面名称
                                          };
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_post_click" withValues:appsflyerParams];
    }
    
}


@end
