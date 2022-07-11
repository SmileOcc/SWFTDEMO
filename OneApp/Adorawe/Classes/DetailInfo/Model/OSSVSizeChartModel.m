//
//  OSSVSizeChartModel.m
// XStarlinkProject
//
//  Created by odd on 2020/10/29.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVSizeChartModel.h"

@implementation OSSVSizeChartModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"position_data" : [OSSVSizeChartItemModel class]
             };
}

//stander_size_data
//+ (NSArray *)modelPropertyWhitelist {
//    return @[
//             @"size_name",
//             @"position_data"
//             ];
//}

@end



@implementation OSSVSizeChartItemModel

@end
