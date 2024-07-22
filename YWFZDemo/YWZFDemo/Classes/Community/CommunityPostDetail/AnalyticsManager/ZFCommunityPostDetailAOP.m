//
//  ZFCommunityPostDetailAOP.m
//  ZZZZZ
//
//  Created by YW on 2019/6/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityPostDetailAOP.h"
#import "ZFGrowingIOAnalytics.h"
#import "YWCFunctionTool.h"
#import "AccountManager.h"
#import "ZFCommunityPostCollectionViewCell.h"


@interface ZFCommunityPostDetailAOP ()

@property (nonatomic, strong) NSMutableArray *analyticsArray;

@end

@implementation ZFCommunityPostDetailAOP

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
                             @"requestDatas" :
                                 @"after_requestDatas",
                             };
    
    return params;
}

-(void)startHeadReferesh {
    //下拉刷新时，需要重新计算曝光
    [self.analyticsArray removeAllObjects];
}

- (void)after_requestDatas {
    [self startHeadReferesh];
}

- (void)after_collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (![cell isKindOfClass:[ZFCommunityPostCollectionViewCell class]]) {
        return;
    }
    //帖子
    ZFCommunityPostCollectionViewCell *baseCell = (ZFCommunityPostCollectionViewCell *)cell;
    ZFCommunityPostListInfoModel *model = baseCell.infoModel;
    
    NSString *reviewId = model.reviewId;
    if ([self.analyticsArray containsObject:ZFToString(reviewId)] || ZFIsEmptyString(reviewId)) {
        return;
    }
    [self.analyticsArray addObject:ZFToString(reviewId)];
    
    // appflyer统计 社区帖子曝光
    NSDictionary *appsflyerParams = @{@"af_content_id" : ZFToString(reviewId),
                                      @"af_country_code" : ZFToString([AccountManager sharedManager].accountCountryModel.region_code),
                                      @"af_page_name" : @"post_detail",
                                      @"af_post_channel" : @""
                                      };
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_posts_impression" withValues:appsflyerParams];
}

- (void)after_collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if (![cell isKindOfClass:[ZFCommunityPostCollectionViewCell class]]) {
        return;
    }
    //帖子
    ZFCommunityPostCollectionViewCell *baseCell = (ZFCommunityPostCollectionViewCell *)cell;
    ZFCommunityPostListInfoModel *model = baseCell.infoModel;

    NSString *reviewID = model.reviewId;
    NSString *userID = model.userId;
    
    //增加AppsFlyer统计
    NSDictionary *appsflyerParams = @{@"af_postid" : ZFToString(reviewID),
                                      @"af_post_channel" : @"",
                                      @"af_post_type" : @"normal",
                                      @"af_post_userid" : ZFToString(userID),
                                      @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                      @"af_page_name" : @"post_detail",    // 当前页面名称
                                      };
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_post_click" withValues:appsflyerParams];
}

@end

