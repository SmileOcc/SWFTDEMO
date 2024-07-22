//
//  ZFCollectionPostAnalyticsAOP.m
//  ZZZZZ
//
//  Created by YW on 2019/6/20.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCollectionPostAnalyticsAOP.h"
#import "ZFAnalytics.h"
#import "ZFGrowingIOAnalytics.h"
#import "YWCFunctionTool.h"
#import "Constants.h"

#import "ZFCollectionPostCCell.h"

@implementation ZFCollectionPostAnalyticsAOP

-(void)dealloc
{
    YWLog(@"ZFCollectionPostAnalyticsAOP dealloc");
}

- (void)baseConfigureSource:(ZFAnalyticsAOPSource)source analyticsId:(NSString *)idx {
    self.idx = idx ? idx : NSStringFromClass(ZFCollectionPostAnalyticsAOP.class);
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.idx = NSStringFromClass(ZFCollectionPostAnalyticsAOP.class);
    }
    return self;
}

- (void)after_collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[ZFCollectionPostCCell class]]) {
        ZFCollectionPostCCell *baseCell = (ZFCollectionPostCCell *)cell;
        ZFCollectionPostItemModel *model = baseCell.model;
        if (!model) {
            return;
        }
        
        NSString *reviewId = model.idx;
        ZFAnalyticsExposureSet *recentSet = [ZFAnalyticsExposureSet sharedInstance];
        if ([recentSet containsObject:ZFToString(reviewId) analyticsId:self.idx] || ZFIsEmptyString(reviewId)) {
            return;
        }
        [recentSet addObject:ZFToString(reviewId) analyticsId:self.idx];
        
        // appflyer统计 社区帖子曝光
        NSDictionary *appsflyerParams = @{@"af_content_id" : ZFToString(reviewId),
                                          @"af_country_code" : ZFToString([AccountManager sharedManager].accountCountryModel.region_code),
                                          @"af_page_name" : @"wishlist_posts",
                                          //v4.8.0 收藏不需要频道,只社区首页，话题详情，帖子分类
                                          @"af_post_channel" : @""
                                          };
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_posts_impression" withValues:appsflyerParams];
    }
}

-(void)after_collectionView:(UICollectionView *)collectionView
   didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    ZFCollectionPostItemModel *model;
    
    if ([cell isKindOfClass:[ZFCollectionPostCCell class]]) {
        ZFCollectionPostCCell *baseCell = (ZFCollectionPostCCell *)cell;
        model = baseCell.model;
    }
    
    if (!model) {
        return;
    }
    
    //数据类型,只有 0 和 1 ， 0：普通帖，1：穿搭帖
    //增加AppsFlyer统计
    NSDictionary *appsflyerParams = @{@"af_postid" : ZFToString(model.idx),
                                      @"af_post_channel" : @"",
                                      @"af_post_type" : @"normal",
                                      @"af_post_userid" : ZFToString(model.user_id),
                                      @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                      @"af_page_name" : @"wishlist_posts",    // 当前页面名称
                                      };
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_post_click" withValues:appsflyerParams];
}


- (void)after_requestPost:(BOOL)firstPage {
    if (firstPage) {
        [[ZFAnalyticsExposureSet sharedInstance] removeAllObjectsAnalyticsId:self.idx];
    }
}

- (nonnull NSDictionary *)injectMenthodParams {
    NSDictionary *params = @{
                             @"collectionView:willDisplayCell:forItemAtIndexPath:" :
                                 @"after_collectionView:willDisplayCell:forItemAtIndexPath:",
                             NSStringFromSelector(@selector(collectionView:didSelectItemAtIndexPath:)) :
                                 NSStringFromSelector(@selector(after_collectionView:didSelectItemAtIndexPath:)),
                             @"requestPost:":@"after_requestPost:",
                             };
    return params;
}

@end
