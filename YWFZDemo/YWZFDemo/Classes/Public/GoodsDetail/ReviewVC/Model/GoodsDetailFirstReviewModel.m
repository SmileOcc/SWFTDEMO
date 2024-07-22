//
//  GoodsDetailFirstReviewModel.m
//  ZZZZZ
//
//  Created by YW on 17/1/3.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "GoodsDetailFirstReviewModel.h"
#import "GoodsDetailFirstReviewImgListModel.h"

@implementation GoodsDetailFirstReviewModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"userName" : @"nickname",
             @"time" : @"adddate",
             @"star" : @"rate_overall",
             @"imgList" : @"reviewsPic"
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"imgList" : [GoodsDetailFirstReviewImgListModel class],
             @"review_size" : [GoodsDetailsReviewsSizeModel class]
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    return @[
             @"userName",
             @"content",
             @"time",
             @"star",
             @"avatar",
             @"imgList",
             @"parent_review_content",
             @"review_size"
             ];
}



@end
