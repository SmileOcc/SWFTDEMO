

//
//  ZFCommunityFavesModel.m
//  ZZZZZ
//
//  Created by YW on 2017/8/3.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityFavesModel.h"
#import "ZFCommunityFavesItemModel.h"

@implementation ZFCommunityFavesModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"list" : [ZFCommunityFavesItemModel class]
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    return @[
             @"list",
             @"bannerlist",
             @"pageCount",
             @"curPage"
             ];
}

@end
