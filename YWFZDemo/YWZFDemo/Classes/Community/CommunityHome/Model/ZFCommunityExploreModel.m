//
//  ZFCommunityExploreModel.m
//  ZZZZZ
//
//  Created by YW on 2017/8/3.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityExploreModel.h"
#import "ZFCommunityFavesItemModel.h"
#import "ZFBannerModel.h"

/**
 * 分馆itemModel
 */
@implementation ZFCommunityBranchBannerModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"banners" : [ZFBannerModel class],
             };
}
@end

/**
 * 社区主页model
 */
@implementation ZFCommunityExploreModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"list" : [ZFCommunityFavesItemModel class],
             @"bannerlist" : [ZFBannerModel class],
             @"branchBannerList" : [ZFCommunityBranchBannerModel class]
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    return @[
             @"list",
             @"bannerlist",
             @"video",
             @"topicList",
             @"pageCount",
             @"curPage",
             @"type",
             @"branchBannerList"
             ];
}
@end
