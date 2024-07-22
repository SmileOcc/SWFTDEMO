//
//  ZFCommunityPostShowOrderModel.m
//  ZZZZZ
//
//  Created by YW on 16/11/29.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityPostShowOrderModel.h"


@implementation ZFCommunityPostShowOrderModel

+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"total_page"    : @"total_page",
             @"page_size"     : @"page_size",
             @"data"          : @"data",
             @"page"          : @"page",
             @"total"         : @"total",
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"data" : [ZFCommunityPostShowOrderListModel class]
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    
    return @[
             @"total_page",
             @"page_size" ,
             @"data" ,
             @"page" ,
             @"total"
             ];
}

@end
