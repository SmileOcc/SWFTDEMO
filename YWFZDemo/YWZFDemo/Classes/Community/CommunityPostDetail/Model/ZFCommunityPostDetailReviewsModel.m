//
//  ZFCommunityPostDetailReviewsModel.m
//  Yoshop
//
//  Created by YW on 16/7/15.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import "ZFCommunityPostDetailReviewsModel.h"
#import "ZFCommunityPostDetailReviewsListMode.h"

@implementation ZFCommunityPostDetailReviewsModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"list" : [ZFCommunityPostDetailReviewsListMode class]
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    
    return @[
             @"list",
             @"curPage",
             @"pageCount",
             @"replyCount",
             @"type"
             ];
}

@end
