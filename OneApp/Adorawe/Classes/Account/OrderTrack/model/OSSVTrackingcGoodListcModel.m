//
//  OSSVTrackingcGoodListcModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/6.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVTrackingcGoodListcModel.h"

@implementation OSSVTrackingcGoodListcModel

+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"goodTitle"               : @"goods_title",
             @"goodThumpImageURL"       : @"goods_thumb",
             @"attr"                    : @"attr",
             @"goodNumber"              : @"goods_number"
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    
    return  @[
              @"goodTitle",
              @"goodThumpImageURL",
              @"attr",
              @"goodNumber"
              ];
}

@end
