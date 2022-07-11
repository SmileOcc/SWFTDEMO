//
//  OSSVTransportTimeModel.m
// XStarlinkProject
//
//  Created by Kevin on 2021/3/26.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVTransportTimeModel.h"

@implementation OSSVTransportTimeModel


+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"titleSting"   : @"title",
             @"contentSting" : @"content",
             @"childrenContenArray" : @"childrenConten"
           };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"childrenContenArray" : [OSSVTransportTimeListModel class]
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    return @[
             @"titleSting",
             @"contentSting",
             @"childrenContenArray"
              ];
}
@end
