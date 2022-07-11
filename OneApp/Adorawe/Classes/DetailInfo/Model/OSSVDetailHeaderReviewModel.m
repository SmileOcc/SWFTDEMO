//
//  OSSVDetailHeaderReviewModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/10.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVDetailHeaderReviewModel.h"

@implementation OSSVDetailHeaderReviewModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"count" : @"count",
             @"score" : @"score",
             @"data"  : @"data"
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"data" : [OSSVDetailReviewSubModel class]
             };
}
// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    return @[
             @"count",
             @"score",
             @"data"
             ];
}

@end





@implementation OSSVDetailReviewSubModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"content"         : @"content",
             @"rateOverall"     : @"rate_overall",
             @"addTime"         : @"add_time",
             @"nickname"        : @"nickname",
             @"avatar"          : @"avatar",
             @"goodsAttr"       : @"goods_attr",
             @"reviewPic"       : @"reviewPic"
             };
}


// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    return @[
             @"content",
             @"rateOverall",
             @"addTime",
             @"nickname",
             @"avatar",
             @"goodsAttr",
             @"reviewPic"
             ];
}

@end
