
//
//  ZFCommunityMoreHotTopicListModel.m
//  ZZZZZ
//
//  Created by YW on 2017/8/5.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityMoreHotTopicListModel.h"
#import "ZFCommunityMoreHotTopicModel.h"

@implementation ZFCommunityMoreHotTopicListModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"topic"    :   [ZFCommunityMoreHotTopicModel class]
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    return @[
             @"topic",
             @"pageCount",
             @"curPage",
             @"type"
             ];
}
@end
