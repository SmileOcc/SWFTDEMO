//
//  GoodsDetailsReviewsModel.m
//  Yoshop
//
//  Created by YW on 16/6/10.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import "GoodsDetailsReviewsModel.h"
#import "GoodsDetailsReviewsListModel.h"

@implementation ReviewsSizeOverModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"middle" : @"ok"
             };
}

@end


@implementation GoodsDetailsReviewsModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"agvRate" : @"avg_rate_all",
             @"reviewList" : @"data",
             @"reviewCount" : @"total",
             @"pageCount" : @"total_page",
             @"page"      : @"current_page",
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"reviewList" : [GoodsDetailsReviewsListModel class],
             @"size_over_all" : [ReviewsSizeOverModel class],
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    return @[
             @"reviewList",
             @"agvRate",
             @"pageCount",
             @"reviewCount",
             @"page",
             @"size_over_all"
             ];
}

@end
