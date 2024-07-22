//
//  ZFCommunityTopicDetailModel.m
//  ZZZZZ
//
//  Created by DBP on 16/11/28.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityTopicDetailModel.h"
#import "ZFCommunityTopicDetailListModel.h"
#import "YWCFunctionTool.h"

@implementation ZFCommunityTopicDetailModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"list"    :   [ZFCommunityTopicDetailListModel class]
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

+ (NSString *)sortToStringType:(NSInteger)sortType {
    return [NSString stringWithFormat:@"%li",(long)sortType];
}

+ (NSInteger)sortToIntType:(NSString *)sortType {
    return [ZFToString(sortType) integerValue];
}

@end
