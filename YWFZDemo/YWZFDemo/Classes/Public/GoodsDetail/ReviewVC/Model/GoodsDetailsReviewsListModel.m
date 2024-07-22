//
//  GoodsDetailsReviewsListModel.m
//  Yoshop
//
//  Created by YW on 16/6/10.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import "GoodsDetailsReviewsListModel.h"
#import "GoodsDetailsReviewsImageListModel.h"

@implementation GoodsDetailsReviewsListModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"userName" : @"nickname",
             @"time" : @"date",
             @"star" : @"rate_overall",
             @"imgList" : @"imgs"
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"imgList" : [GoodsDetailsReviewsImageListModel class],
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
             @"review_id",
             @"parent_review_content",
             @"review_size",
             @"attr_strs",
             ];
}

@end

