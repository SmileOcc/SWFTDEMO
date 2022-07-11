//
//  OSSVOrdereRevieweModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/4.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVOrdereRevieweModel.h"

@implementation OSSVOrdereRevieweModel

+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"isReview"        : @"is_review",
             @"reviewScore"    : @"order_review",
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"goods"          : [OSSVAccounteOrdersDetaileGoodsModel class],
             @"reviewScore"    : [STLOrderReviewScore class]
             };
}


+ (NSArray *)modelPropertyWhitelist {
    
    return @[
             @"isReview",
             @"reviewScore",
             @"goods",
             ];
}


@end





@implementation STLOrderReviewScore

+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"transportRate"    : @"transport_rate",
             @"goodsRate"        : @"goods_rate",
             @"payRate"          : @"pay_rate",
             @"serviceRate"      : @"service_rate",
             };
}


+ (NSArray *)modelPropertyWhitelist {
    
    return @[
             @"transportRate",
             @"goodsRate",
             @"payRate",
             @"serviceRate",
             ];
}


@end
