//
//  OSSVGoodssReviewssModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/4.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVGoodssReviewssModel.h"

@implementation OSSVGoodssReviewssModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"goodsList" : @"goodsList",
             @"totalPage" : @"totalPage",
             @"pageSize"  : @"pageSize",
             @"currentPage" : @"currentPage",
             };
}


+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"goodsList" : [OSSVAccounteOrdersDetaileGoodsModel class]};
}

+ (NSArray *)modelPropertyWhitelist {
    
    return @[
             @"goodsList",
             @"totalPage",
             @"pageSize",
             @"currentPage",
             ];
}


@end
