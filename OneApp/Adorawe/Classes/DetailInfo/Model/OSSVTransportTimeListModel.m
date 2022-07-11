//
//  OSSVTransportTimeListModel.m
// XStarlinkProject
//
//  Created by Kevin on 2021/3/26.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVTransportTimeListModel.h"

@implementation OSSVTransportTimeListModel


+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"titleString"   : @"title",
             @"numberString"  : @"position",
             @"contentString" : @"content"
           };
}


// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    return @[
             @"titleString",
             @"numberString",
             @"contentString"
              ];
}

@end
