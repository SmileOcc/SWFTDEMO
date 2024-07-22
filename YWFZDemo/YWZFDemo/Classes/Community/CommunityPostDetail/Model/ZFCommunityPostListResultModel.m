
//
//  ZFCommunityTopicListModel.m
//  ZZZZZ
//
//  Created by YW on 2017/8/8.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityPostListResultModel.h"
#import "ZFCommunityPostListModel.h"

@implementation ZFCommunityPostListResultModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"list"    :   [ZFCommunityPostListModel class]
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    return @[
             @"list",
             @"pageCount",
             @"curPage",
             @"type"
             ];
}

@end
