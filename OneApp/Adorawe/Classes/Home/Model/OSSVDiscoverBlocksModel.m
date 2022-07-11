//
//  STLDiscoveryBlockModel.m
// XStarlinkProject
//
//  Created by odd on 2020/10/23.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVDiscoverBlocksModel.h"

@implementation OSSVDiscoverBlocksModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"banner"      : [OSSVAdvsEventsModel class],
             @"images"       : [OSSVAdvsEventsModel class],
             @"slide_data"   : [STLDiscoveryBlockSlideGoodsModel class],

             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    
    return @[
             @"banner",
             @"images",
             @"type",
             @"slide_data",
             ];
}

@end

@implementation STLDiscoveryBlockSlideGoodsModel

@end
