//
//  OSSVHomeItemsModel.m
// OSSVHomeItemsModel
//
//  Created by 10010 on 20/7/31.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVHomeItemsModel.h"


@implementation OSSVHomeItemsModel

+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"pageCount"   : @"pageCount",
             @"goodList"    : @"goodList",
             @"bannerList"  : @"bannerList",
             @"pageSize"    : @"page_size",
             @"page"        : @"page"
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"goodList"    : [OSSVHomeGoodsListModel class],
             @"bannerList"  : [OSSVAdvsEventsModel class]
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    
    return @[
             @"goodList",
             @"bannerList",
             @"pageCount",
             @"pageSize",
             @"page"
             ];
}

@end
