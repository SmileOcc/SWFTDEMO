//
//  OSSVDetailsAttributeListModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/27.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVDetailsAttributeListModel.h"

@implementation OSSVDetailsAttributeListModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"attributeId"   : @"attr_id",
             @"attributeName" : @"attr_name"
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    return @[
             @"attributeId",
             @"attributeName",
             @"code"
             ];
}

@end
