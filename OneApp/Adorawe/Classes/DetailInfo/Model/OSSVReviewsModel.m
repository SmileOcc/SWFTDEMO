//
//  OSSVReviewsModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/27.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVReviewsModel.h"

@implementation OSSVReviewsModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
//             @"agvRate" : @"avg_rate_all",
        @"agvRate" : @"rateAllAvg",
             @"reviewList" : @"reviewList",
        @"reviewCount" : @"totals"

             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"reviewList" : [OSSVReviewsListModel class]
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    return @[
             @"reviewList",
             @"agvRate",
             @"pageCount",
             @"reviewCount",
             @"page"
             ];
}

@end
