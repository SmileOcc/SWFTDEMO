//
//  ZFCommunityAccountAOP.m
//  ZZZZZ
//
//  Created by YW on 2019/6/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityAccountAOP.h"
#import "ZFGrowingIOAnalytics.h"
#import "YWCFunctionTool.h"
#import "AccountManager.h"

#import "ZFCommunityAccountShowView.h"
#import "ZFCommunityAccountFavesView.h"
#import "ZFCommunityAccountShowCell.h"
#import "ZFCommunityAccountFavesCell.h"


@interface ZFCommunityAccountAOP ()

@property (nonatomic, strong) NSMutableArray *analyticsFavesArray;
@property (nonatomic, strong) NSMutableArray *analyticsShowsArray;

@end

@implementation ZFCommunityAccountAOP

- (NSMutableArray *)analyticsFavesArray {
    if (!_analyticsFavesArray) {
        _analyticsFavesArray = [[NSMutableArray alloc] init];
    }
    return _analyticsFavesArray;
}

- (NSMutableArray *)analyticsShowsArray {
    if (!_analyticsShowsArray) {
        _analyticsShowsArray = [[NSMutableArray alloc] init];
    }
    return _analyticsShowsArray;
}

-(NSDictionary *)injectMenthodParams
{
    NSDictionary *params = @{
                             @"zf_accountShowView:collectionView:willDisplayCell:forItemAtIndexPath:" :
                                 @"after_accountShowView:collectionView:willDisplayCell:forItemAtIndexPath:",
                             @"zf_accountShowView:collectionView:didSelectItemCell:forItemAtIndexPath:" :
                                 @"after_accountShowView:collectionView:didSelectItemCell:forItemAtIndexPath:",
                             @"zf_accountShowView:requestAccountShowListData:" :
                                 @"after_accountShowView:requestAccountShowListData:",
                             
                             @"zf_accountFavesView:collectionView:willDisplayCell:forItemAtIndexPath:" :
                                 @"after_accountFavesView:collectionView:willDisplayCell:forItemAtIndexPath:",
                             @"zf_accountFavesView:collectionView:didSelectItemCell:forItemAtIndexPath:" :
                                 @"after_accountFavesView:collectionView:didSelectItemCell:forItemAtIndexPath:",
                             @"zf_accountFavesView:requestAccountFavesListData:" :
                                 @"after_accountFavesView:requestAccountFavesListData:",
                             };
    
    return params;
}

#pragma mark - ZFCommunityAccountShowView

-(void)showStartHeadReferesh {
    //下拉刷新时，需要重新计算曝光
    [self.analyticsShowsArray removeAllObjects];
}

- (void)after_accountShowView:(ZFCommunityAccountShowView *)showsView collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (![cell isKindOfClass:[ZFCommunityAccountShowCell class]]) {
        return;
    }
    ZFCommunityAccountShowCell *showCell = (ZFCommunityAccountShowCell *)cell;
    ZFCommunityAccountShowsModel *model = showCell.showsModel;
    
    NSString *reviewId = model.reviewId;
    if ([self.analyticsShowsArray containsObject:ZFToString(reviewId)] || ZFIsEmptyString(reviewId)) {
        return;
    }
    [self.analyticsShowsArray addObject:ZFToString(reviewId)];
    
    // appflyer统计 社区帖子曝光
    NSDictionary *appsflyerParams = @{@"af_content_id"   : ZFToString(reviewId),
                                      @"af_country_code" : ZFToString([AccountManager sharedManager].accountCountryModel.region_code),
                                      @"af_page_name"    : @"community_account",
                                      @"af_post_channel" : @""
                                      };
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_posts_impression" withValues:appsflyerParams];
}

- (void)after_accountShowView:(ZFCommunityAccountShowView *)showsView collectionView:(UICollectionView *)collectionView didSelectItemCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (![cell isKindOfClass:[ZFCommunityAccountShowCell class]]) {
        return;
    }
    ZFCommunityAccountShowCell *showCell = (ZFCommunityAccountShowCell *)cell;
    ZFCommunityAccountShowsModel *model = showCell.showsModel;
    
    //增加AppsFlyer统计
    NSDictionary *appsflyerParams = @{@"af_postid" : ZFToString(model.reviewId),
                                      @"af_post_channel" : @"",
                                      @"af_post_type" : @"normal",
                                      @"af_post_userid" : ZFToString(model.userId),
                                      @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                      @"af_page_name" : @"community_account",    // 当前页面名称
                                      };
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_post_click" withValues:appsflyerParams];
}

- (void)after_accountShowView:(ZFCommunityAccountShowView *)showsView requestAccountShowListData:(BOOL)isFirstPage {
    if (isFirstPage) {
        [self showStartHeadReferesh];
    }
}

#pragma mark - ZFCommunityAccountFavesView

- (void)after_accountFavesView:(ZFCommunityAccountFavesView *)favesView collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (![cell isKindOfClass:[ZFCommunityAccountFavesCell class]]) {
        return;
    }
    ZFCommunityAccountFavesCell *favesCell = (ZFCommunityAccountFavesCell *)cell;
    ZFCommunityFavesItemModel *model = favesCell.favesModel;
    
    NSString *reviewId = model.reviewId;
    if ([self.analyticsFavesArray containsObject:ZFToString(reviewId)] || ZFIsEmptyString(reviewId)) {
        return;
    }
    [self.analyticsFavesArray addObject:ZFToString(reviewId)];
    
    // appflyer统计 社区帖子曝光
    NSDictionary *appsflyerParams = @{@"af_content_id"   : ZFToString(reviewId),
                                      @"af_country_code" : ZFToString([AccountManager sharedManager].accountCountryModel.region_code),
                                      @"af_page_name"    : @"community_account",
                                      @"af_post_channel" : @""
                                      };
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_posts_impression" withValues:appsflyerParams];
}

- (void)after_accountFavesView:(ZFCommunityAccountFavesView *)favesView collectionView:(UICollectionView *)collectionView didSelectItemCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (![cell isKindOfClass:[ZFCommunityAccountFavesCell class]]) {
        return;
    }
    ZFCommunityAccountFavesCell *favesCell = (ZFCommunityAccountFavesCell *)cell;
    ZFCommunityFavesItemModel *model = favesCell.favesModel;
    
    //增加AppsFlyer统计
    NSString *reviewType = @"normal"; ///数据类型,1:帖子 2:话题 3:视频 4:banner
    if (model.type == 2) {
        reviewType = @"topic";
    } else if (model.type == 3) {
        reviewType = @"video";
    }
    NSDictionary *appsflyerParams = @{@"af_postid" : ZFToString(model.reviewId),
                                      @"af_post_channel" : @"",
                                      @"af_post_type" : ZFToString(reviewType),
                                      @"af_post_userid" : ZFToString(model.userId),
                                      @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                      @"af_page_name" : @"community_account",    // 当前页面名称
                                      };
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_post_click" withValues:appsflyerParams];
    
}

- (void)after_accountFavesView:(ZFCommunityAccountFavesView *)favesView requestAccountFavesListData:(BOOL)isFirstPage {
    if (isFirstPage) {
        [self favesStartHeadReferesh];
    }
}

-(void)favesStartHeadReferesh {
    //下拉刷新时，需要重新计算曝光
    [self.analyticsFavesArray removeAllObjects];
}


@end
