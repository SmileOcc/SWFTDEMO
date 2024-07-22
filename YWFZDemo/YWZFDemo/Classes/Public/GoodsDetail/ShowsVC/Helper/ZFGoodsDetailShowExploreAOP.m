//
//  ZFGoodsDetailShowExploreAOP.m
//  ZZZZZ
//
//  Created by YW on 2019/6/18.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGoodsDetailShowExploreAOP.h"
#import "ZFAnalytics.h"
#import "ZFGrowingIOAnalytics.h"
#import "YWCFunctionTool.h"
#import "Constants.h"

#import "ZFGoodsDetailShowListCell.h"


@interface ZFGoodsDetailShowExploreAOP()

@property (nonatomic, strong) NSString *af_page_name;


@end

@implementation ZFGoodsDetailShowExploreAOP

- (void)baseConfigureSource:(ZFAnalyticsAOPSource)source analyticsId:(NSString *)idx {
    self.source = source;
    self.idx = idx ? idx : NSStringFromClass(ZFGoodsDetailShowExploreAOP.class);
    self.af_page_name = @"goods_page";
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.idx = NSStringFromClass(ZFGoodsDetailShowExploreAOP.class);
    }
    return self;
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


- (void)after_collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([cell isKindOfClass:[ZFGoodsDetailShowListCell class]]) {
        ZFGoodsDetailShowListCell *recentCell = (ZFGoodsDetailShowListCell *)cell;
        GoodsShowExploreModel *model = recentCell.model;
        
        ZFGoodsDetailShowExploreSet *showsSet = [ZFGoodsDetailShowExploreSet sharedInstance];
        
        NSString *reviewId = model.reviewsId;
        if ([showsSet containsObject:ZFToString(reviewId) analyticsId:self.idx] || ZFIsEmptyString(reviewId)) {
            return;
        }
        [showsSet addObject:ZFToString(reviewId) analyticsId:self.idx];
        
        // appflyer统计 社区帖子曝光
        NSDictionary *appsflyerParams = @{@"af_content_id"   : ZFToString(reviewId),
                                          @"af_country_code" : ZFToString([AccountManager sharedManager].accountCountryModel.region_code),
                                          @"af_page_name"    : @"goods_page",
                                          @"af_post_channel" : @""
                                          };
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_posts_impression" withValues:appsflyerParams];
    }
    
}

-(void)after_collectionView:(UICollectionView *)collectionView
   didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[ZFGoodsDetailShowListCell class]]) {

        ZFGoodsDetailShowListCell *recentCell = (ZFGoodsDetailShowListCell *)cell;
        GoodsShowExploreModel *model = recentCell.model;
        
        //1:视频
        NSString *postType = model.type == 1 ? @"video" : @"normal";
        //增加AppsFlyer统计
        NSDictionary *appsflyerParams = @{@"af_postid" : ZFToString(model.reviewsId),
                                          @"af_post_channel" : @"",
                                          @"af_post_type" : ZFToString(postType),
                                          @"af_post_userid" : @"",
                                          @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                          @"af_page_name" : ZFToString(self.af_page_name),    // 当前页面名称
                                          };
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_post_click" withValues:appsflyerParams];
    }
}
@end

















@interface ZFGoodsDetailShowExploreSet ()

@property (nonatomic, strong) NSMutableDictionary *listDic;

@end

@implementation ZFGoodsDetailShowExploreSet

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static ZFGoodsDetailShowExploreSet *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[ZFGoodsDetailShowExploreSet alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.listDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)addObject:(NSString *)object analyticsId:(NSString *)idx
{
    if (ZFIsEmptyString(idx) || ZFIsEmptyString(object)) {
        YWLog(@"CMS组件统计有问题-Page:%@_object:%@",idx,object);
        return;
    }
    if (idx) {
        NSMutableArray *datasArray = [self.listDic objectForKey:idx];
        if (ZFJudgeNSArray(datasArray)) {
            [datasArray addObject:object];
        } else {
            datasArray = [[NSMutableArray alloc] init];
            [datasArray addObject:object];
            [self.listDic setObject:datasArray forKey:idx];
        }
    }
}

- (BOOL)containsObject:(NSString *)object analyticsId:(NSString *)idx
{
    if (ZFIsEmptyString(idx) || ZFIsEmptyString(object)) {
        YWLog(@"CMS组件统计有问题%@",NSStringFromClass(ZFGoodsDetailShowExploreAOP.class));
        return YES;
    }
    BOOL isConatins = NO;
    if (idx) {
        NSMutableArray *datasArray = [self.listDic objectForKey:idx];
        if (ZFJudgeNSArray(datasArray)) {
            isConatins = [datasArray containsObject:object];
        }
    }
    
    return isConatins;
}

- (void)removeObject:(NSString *)object analyticsId:(NSString *)idx
{
    if (ZFIsEmptyString(idx) || ZFIsEmptyString(object)) {
        YWLog(@"CMS组件统计有问题%@",NSStringFromClass(ZFGoodsDetailShowExploreAOP.class));
        return;
    }
    if (idx) {
        NSMutableArray *datasArray = [self.listDic objectForKey:idx];
        if (ZFJudgeNSArray(datasArray)) {
            [datasArray removeObject:object];
        }
    }
}

- (void)removeAllObjectsAnalyticsId:(NSString *)idx
{
    if (ZFIsEmptyString(idx)) {
        YWLog(@"CMS组件统计有问题%@",NSStringFromClass(ZFGoodsDetailShowExploreAOP.class));
        return;
    }
    if (idx) {
        NSMutableArray *datasArray = [self.listDic objectForKey:idx];
        if (ZFJudgeNSArray(datasArray)) {
            [datasArray removeAllObjects];
        }
    }
}

@end
