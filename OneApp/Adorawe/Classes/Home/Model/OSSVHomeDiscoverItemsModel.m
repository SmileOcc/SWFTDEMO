//
//  OSSVHomeDiscoverItemsModel.m
// OSSVHomeDiscoverItemsModel
//
//  Created by 10010 on 20/7/21.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVHomeDiscoverItemsModel.h"
#import "OSSVAdvsEventsModel.h"



@implementation OSSVHomeDiscoverItemsModel

+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"bannerArray"     : @"banner",
             @"listArray"       : @"list",
             @"threeArray"      : @"three",
             @"topicArray"      : @"topic",
             @"pageCount"       : @"pageCount",
             @"pageSize"        : @"page_size",
             @"page"            : @"page"
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"bannerArray"      : [OSSVAdvsEventsModel class],
             @"listArray"        : [OSSVAdvsEventsModel class],
             @"threeArray"       : [OSSVAdvsEventsModel class],
             @"topicArray"       : [OSSVAdvsEventsModel class]
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    
    return @[
             @"bannerArray",
             @"listArray",
             @"threeArray",
             @"topicArray",
             @"pageCount",
             @"pageSize",
             @"page"
             ];
}

@end
